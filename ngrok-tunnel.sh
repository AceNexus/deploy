#!/usr/bin/env bash
# AceNexus ngrok 啟動腳本（Linux / Ubuntu）
# 依賴：docker compose、curl、jq
# 用法：bash ngrok-tunnel.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="$SCRIPT_DIR/deploy_ngrok"

# ── 前置檢查 ──────────────────────────────────────────────────
for cmd in docker curl jq kubectl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[錯誤] 找不到指令：$cmd"
        exit 1
    fi
done

if [ ! -f "$DEPLOY_DIR/.env" ]; then
    echo "[錯誤] 找不到 .env 檔案（$DEPLOY_DIR/.env）"
    exit 1
fi

# ── 讀取 .env ─────────────────────────────────────────────────
get_env() {
    grep "^${1}=" "$DEPLOY_DIR/.env" | cut -d= -f2- | tr -d '\r'
}
LINE_TOKEN=$(get_env LINE_CHANNEL_ACCESS_TOKEN)
LINE_WEBHOOK_PATH=$(get_env LINE_WEBHOOK_PATH)
LINE_TOKEN_TEST=$(get_env LINE_CHANNEL_ACCESS_TOKEN_TEST)
LINE_WEBHOOK_PATH_TEST=$(get_env LINE_WEBHOOK_PATH_TEST)

[ -z "$LINE_WEBHOOK_PATH" ]      && LINE_WEBHOOK_PATH="/api/linebot/webhook"
[ -z "$LINE_WEBHOOK_PATH_TEST" ] && LINE_WEBHOOK_PATH_TEST="/api/linebot-test/webhook"

# ── 啟動 ngrok ────────────────────────────────────────────────
echo "[資訊] 正在啟動 ngrok 容器..."
cd "$DEPLOY_DIR"
docker compose down 2>/dev/null || true
docker compose up -d --force-recreate

echo "[資訊] 正在等待 ngrok 啟動..."
sleep 5

# ── 檢查 ERR_NGROK_108 ────────────────────────────────────────
if docker compose logs ngrok --tail 20 | grep -q "ERR_NGROK_108"; then
    echo
    echo "----------------------------------------"
    echo "[警告] 偵測到 ERR_NGROK_108 (連線數已滿)"
    echo "----------------------------------------"
    echo "原因：ngrok 伺服器端認為您還有另一個連線。"
    echo "解決方法："
    echo "1. 請等待 5 分鐘讓伺服器自動斷開舊連線。"
    echo "2. 或至 https://dashboard.ngrok.com/agents 手動檢查。"
    echo "----------------------------------------"
    docker compose down 2>/dev/null || true
    exit 1
fi

# ── 取得 ngrok 網址 ───────────────────────────────────────────
# agent 同時開兩個 tunnel（gateway :8080、SubGo :9000），API 回傳順序不保證，
# 因此依 upstream port 指定 —— 取錯會把 LINE webhook 指到 SubGo 的網頁上。
get_ngrok_url() {
    local port="$1"
    curl -s http://localhost:4040/api/tunnels \
      | jq -r --arg port ":$port" \
          'first(.tunnels[] | select(.config.addr | endswith($port)) | .public_url) // empty' \
          2>/dev/null || true
}

FINAL_URL=$(get_ngrok_url 8080)
if [ -z "$FINAL_URL" ]; then
    echo "[資訊] 正在重試..."
    sleep 5
    FINAL_URL=$(get_ngrok_url 8080)
fi

# SubGo 網頁的 tunnel 與 gateway 各自獨立，取不到不算失敗（可能沒啟動 SubGo）
SUBGO_URL=$(get_ngrok_url 9000)

if [ -z "$FINAL_URL" ]; then
    echo "[錯誤] 無法取得 ngrok 網址，請確認容器是否正常啟動。"
    docker compose logs ngrok --tail 30
    exit 1
fi

echo
echo "========================================"
echo "  ngrok 啟動成功！"
echo "========================================"
echo "  gateway (LINE webhook)： $FINAL_URL"
if [ -n "$SUBGO_URL" ]; then
    echo "  SubGo 網頁 (:9000)：     $SUBGO_URL"
else
    echo "  SubGo 網頁 (:9000)：     (未取得，確認 SubGo 的 web 容器是否啟動)"
fi
echo "========================================"
echo

# 複製到剪貼簿（有 xclip 或 xsel 才執行）
if command -v xclip &>/dev/null; then
    echo "$FINAL_URL" | xclip -selection clipboard
    echo "[成功] gateway 網址已複製到剪貼簿。"
elif command -v xsel &>/dev/null; then
    echo "$FINAL_URL" | xsel --clipboard --input
    echo "[成功] gateway 網址已複製到剪貼簿。"
fi

# ── 更新 nexusbot NEXUSBOT_BASE_URL（K8s）────────────────────
echo "[資訊] 正在更新 nexusbot NEXUSBOT_BASE_URL（K8s）..."
if kubectl set env deployment/nexusbot NEXUSBOT_BASE_URL="$FINAL_URL" -n acenexus; then
    echo "[成功] nexusbot NEXUSBOT_BASE_URL 已更新，K8s 將自動滾動重啟 Pod。"
else
    echo "[警告] kubectl set env 失敗，請確認 K8s 叢集是否正常運行。"
fi

# ── 更新 LINE Webhook ─────────────────────────────────────────
update_webhook() {
    local token="$1"
    local webhook_url="$2"
    echo "  Webhook URL : $webhook_url"
    echo "  Token 前 12 : ${token:0:12}..."
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X PUT \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"endpoint\":\"$webhook_url\"}" \
        "https://api.line.me/v2/bot/channel/webhook/endpoint")
    if [ "$http_code" = "200" ]; then
        echo "[成功] LINE Bot Webhook 已更新為: $webhook_url"
    else
        echo "[警告] LINE Bot Webhook 更新失敗（HTTP $http_code）"
    fi
}

if [ -n "$LINE_TOKEN" ] && [ "$LINE_TOKEN" != "your_line_channel_access_token_here" ]; then
    echo "[資訊] 正在更新 LINE Bot 1 Webhook..."
    update_webhook "$LINE_TOKEN" "${FINAL_URL}${LINE_WEBHOOK_PATH}"
else
    echo "[提示] 未設定 LINE_CHANNEL_ACCESS_TOKEN，跳過 Bot 1 Webhook 更新。"
fi

if [ -n "$LINE_TOKEN_TEST" ] && [ "$LINE_TOKEN_TEST" != "your_test_bot_line_channel_access_token_here" ]; then
    echo "[資訊] 正在更新 LINE Bot 2 (test) Webhook..."
    update_webhook "$LINE_TOKEN_TEST" "${FINAL_URL}${LINE_WEBHOOK_PATH_TEST}"
else
    echo "[提示] 未設定 LINE_CHANNEL_ACCESS_TOKEN_TEST，跳過 Bot 2 Webhook 更新。"
fi

# ── 監控資訊 ──────────────────────────────────────────────────
echo "----------------------------------------"
docker compose logs ngrok --tail 30
echo "----------------------------------------"
echo
echo "  完整資訊與流量監控請至："
echo "  http://localhost:4040/"
echo
