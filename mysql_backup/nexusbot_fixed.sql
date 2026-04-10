-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- 主機： localhost
-- 產生時間： 2026 年 04 月 09 日 07:17
-- 伺服器版本： 8.0.17
-- PHP 版本： 7.3.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `nexusbot`
--

-- --------------------------------------------------------

--
-- 資料表結構 `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` bigint(20) NOT NULL COMMENT '主鍵，自動遞增',
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `room_type` varchar(10) NOT NULL COMMENT '聊天室類型（冗余設計）',
  `user_id` varchar(100) DEFAULT NULL COMMENT '發送者 LINE userId，AI 訊息為 NULL',
  `message_type` varchar(20) NOT NULL COMMENT '訊息類型',
  `content` text NOT NULL COMMENT '訊息內容',
  `tokens_used` int(11) DEFAULT '0' COMMENT 'AI 使用 token 數（成本統計）',
  `processing_time_ms` int(11) DEFAULT '0' COMMENT 'AI 處理時間（毫秒）',
  `ai_model` varchar(50) DEFAULT NULL COMMENT '使用的 AI 模型名稱',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT '軟刪除時間，NULL 表示未刪除'
) ;

--
-- 傾印資料表的資料 `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `room_id`, `room_type`, `user_id`, `message_type`, `content`, `tokens_used`, `processing_time_ms`, `ai_model`, `created_at`, `deleted_at`) VALUES
(1, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-02-24 06:04:02', NULL),
(2, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們怎麼認識的呢？你今天有什麼事想聊聊嗎？', 355, 1216, 'llama-3.1-8b-instant', '2026-02-24 06:04:04', NULL),
(3, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-02-24 17:41:53', NULL),
(4, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '沒事，隨便說點什麼，我就跟你聊聊。', 383, 1198, 'llama-3.1-8b-instant', '2026-02-24 17:41:55', NULL),
(5, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-02-24 17:47:32', NULL),
(6, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '聊什麼呢？想問我題目嗎？', 407, 292, 'llama-3.1-8b-instant', '2026-02-24 17:47:32', NULL),
(7, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '哈囉', 0, 0, NULL, '2026-02-27 10:55:58', NULL),
(8, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們好像在玩聊天遊戲似的。有什麼正事嗎？你想問我什麼題目嗎？', 448, 1498, 'llama-3.1-8b-instant', '2026-02-27 10:56:00', NULL),
(9, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-02 14:08:49', NULL),
(10, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 520, 'gemini-2.5-flash', '2026-03-02 14:08:50', NULL),
(11, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-02 14:25:41', NULL),
(12, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 669, 'gemini-3-flash-preview', '2026-03-02 14:25:42', NULL),
(13, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試 gemini', 0, 0, NULL, '2026-03-02 14:37:54', NULL),
(14, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試 gemini」\n輸入 menu 查看支援的指令。', 0, 654, 'gemini-2.5-flash', '2026-03-02 14:37:55', NULL),
(15, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試 gemini', 0, 0, NULL, '2026-03-02 14:42:40', NULL),
(16, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試 gemini」\n輸入 menu 查看支援的指令。', 0, 6, 'gemini-2.5-flash', '2026-03-02 14:42:40', NULL),
(17, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-02 14:44:36', NULL),
(18, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 462, 'gemini-3-flash-preview', '2026-03-02 14:44:36', NULL),
(19, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-02 14:55:16', NULL),
(20, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 664, 'gemini-3-flash-preview', '2026-03-02 14:55:16', NULL),
(21, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-02 15:10:01', NULL),
(22, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉！測試成功，訊號很清楚。我是你的知識型好朋友，不管你有什麼生活疑問、想聊聊最近的新聞，或是需要一些實際的小建議，都可以直接問我。準備好要聊什麼了嗎？', 783, 5524, 'gemini-3-flash-preview', '2026-03-02 15:10:07', NULL),
(23, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hhhhhhhhhhhhhhhhhhhhhhhhhh', 0, 0, NULL, '2026-03-03 02:38:42', NULL),
(24, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '看來你還在測試連線狀況。訊號沒問題，我這裡都有收到。如果你有任何想聊的話題，或是想問的知識，隨時可以告訴我，不用一直發測試訊息。準備好要聊聊了嗎？', 921, 6488, 'gemini-3-flash-preview', '2026-03-03 02:38:49', NULL),
(25, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試測試測試測試測試測試測試', 0, 0, NULL, '2026-03-03 02:43:14', NULL),
(26, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '測試這麼多次，看來連線真的很穩定。我已經準備好了，你可以不用再發測試訊息。不管你有什麼想聊的知識，或是生活中遇到的問題，隨時都可以跟我說，我會盡量用簡單的方式幫你解答。有什麼想聊的話題嗎？', 944, 5274, 'gemini-3-flash-preview', '2026-03-03 02:43:20', NULL),
(27, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '給我一個冷知識', 0, 0, NULL, '2026-03-03 05:11:51', NULL),
(28, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '既然你想要冷知識，來分享一個跟食物有關的：草莓在植物學定義上其實不是「莓果」，但香蕉、西瓜和番茄反而是。\n\n草莓表面那些一點一點的構造，在生物學上被稱為「瘦果」，它們才是草莓真正的果實，而我們吃的部分其實是支撐果實的花托。另外，草莓是薔薇科的植物，所以它跟玫瑰花其實算是親戚。下次吃草莓的時候可以觀察看看。', 967, 4408, 'gemini-3-flash-preview', '2026-03-03 05:11:55', NULL),
(29, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '給我一個冷知識', 0, 0, NULL, '2026-03-03 10:36:44', NULL),
(30, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '既然你想再聽一個，這裡有個跟太空有關的：在金星上，一天比一年還要長。\n\n金星自轉的速度非常慢，自轉一圈需要 243 個地球日，但它繞太陽公轉一圈只需要 225 個地球日。這代表在金星上，你過完一個生日時，一天還沒結束。另外，金星的自轉方向跟多數行星相反，所以在那裡太陽是從西邊升起、東邊落下。雖然這聽起來很酷，但金星表面溫度高達攝氏 400 多度，完全不適合人類居住。', 1168, 6033, 'gemini-3-flash-preview', '2026-03-03 10:36:50', NULL),
(31, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hk4g', 0, 0, NULL, '2026-03-03 10:38:31', NULL),
(32, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hk4g」\n輸入 menu 查看支援的指令。', 0, 24, 'gemini-3-flash-preview', '2026-03-03 10:38:31', NULL),
(33, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'ggg', 0, 0, NULL, '2026-03-03 10:38:32', NULL),
(34, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「ggg」\n輸入 menu 查看支援的指令。', 0, 12, 'gemini-3-flash-preview', '2026-03-03 10:38:32', NULL),
(35, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'g', 0, 0, NULL, '2026-03-03 10:38:32', NULL),
(36, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「g」\n輸入 menu 查看支援的指令。', 0, 9, 'gemini-3-flash-preview', '2026-03-03 10:38:32', NULL),
(37, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'g', 0, 0, NULL, '2026-03-03 10:38:32', NULL),
(38, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「g」\n輸入 menu 查看支援的指令。', 0, 10, 'gemini-3-flash-preview', '2026-03-03 10:38:32', NULL),
(39, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'g', 0, 0, NULL, '2026-03-03 10:38:32', NULL),
(40, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「g」\n輸入 menu 查看支援的指令。', 0, 8, 'gemini-3-flash-preview', '2026-03-03 10:38:32', NULL),
(41, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'gg', 0, 0, NULL, '2026-03-03 10:38:32', NULL),
(42, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「gg」\n輸入 menu 查看支援的指令。', 0, 7, 'gemini-3-flash-preview', '2026-03-03 10:38:32', NULL),
(43, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'g', 0, 0, NULL, '2026-03-03 10:38:33', NULL),
(44, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「g」\n輸入 menu 查看支援的指令。', 0, 9, 'gemini-3-flash-preview', '2026-03-03 10:38:33', NULL),
(45, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'f', 0, 0, NULL, '2026-03-03 10:40:03', NULL),
(46, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「f」\n輸入 menu 查看支援的指令。', 0, 19, 'gemini-3-flash-preview', '2026-03-03 10:40:03', NULL),
(47, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '5', 0, 0, NULL, '2026-03-03 14:54:08', NULL),
(48, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「5」\n輸入 menu 查看支援的指令。', 0, 173, 'gemini-3-flash-preview', '2026-03-03 14:54:08', NULL),
(49, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-03 16:19:14', NULL),
(50, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「你好」\n輸入 menu 查看支援的指令。', 0, 190, 'gemini-3-flash-preview', '2026-03-03 16:19:14', NULL),
(51, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-03 16:20:30', NULL),
(52, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好，今天想聊什麼呢？', 560, 399, 'llama-3.3-70b-versatile', '2026-03-03 16:20:30', NULL),
(53, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-03 16:22:31', NULL),
(54, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好，看你傳了幾次招呼和一些代碼，是想測試什麼功能嗎？\n\n如果有具體想聊的話題或想問的事，直接告訴我就好。不管是生活常識還是知識問題，我都會盡量用簡單的方式幫你解答。', 875, 5766, 'gemini-3-flash-preview', '2026-03-03 16:22:37', NULL),
(55, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-03 17:52:46', NULL),
(56, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好，看你剛才試了好幾次，是在測試什麼嗎？\n\n我是你的知識型好朋友，你可以直接問我問題，不用像之前那樣輸入代碼。不管是想了解知識還是生活上的建議，我都會盡力回答。今天有什麼想聊的話題嗎？', 871, 5456, 'gemini-3-flash-preview', '2026-03-03 17:52:51', NULL),
(57, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-03 18:23:40', NULL),
(58, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好，看你傳了一些數字跟字母，是在測試我的反應嗎？\n\n我是你的知識型好朋友，你可以直接問我問題。不管是想找資料、尋求建議，或是單純想聊聊某個知識點都可以。如果你一直傳單個字，我會不知道該怎麼幫你。今天有什麼想討論的嗎？', 957, 5431, 'gemini-3-flash-preview', '2026-03-03 18:23:46', NULL),
(59, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-04 01:38:29', NULL),
(60, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '測試成功。看你傳了好幾次簡短的訊息，應該是在看我的反應吧。\n\n我是你的聊天夥伴，不是只會回罐頭訊息的系統。如果你有具體想問的事，不管是生活常識、科技知識，或是需要一些實際的建議，直接說就可以了。\n\n現在有什麼想聊的話題嗎？或是你有什麼一直想不通的問題，也可以丟出來討論。', 1045, 6206, 'gemini-3-flash-preview', '2026-03-04 01:38:36', NULL),
(61, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'H', 0, 0, NULL, '2026-03-04 02:11:45', NULL),
(62, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好，你又傳了 H，看來還在測試我的反應。\n\n如果你有任何問題想問，直接說就可以了。不管是想了解某個知識、需要生活建議，或是單純想聊聊，我都會用比較直接且好懂的方式回答。一直測試單個字母或數字，我沒辦法提供更多實質的幫助。\n\n今天有什麼具體想聊的話題嗎？或是你有什麼想不通的問題？', 1225, 5348, 'gemini-3-flash-preview', '2026-03-04 02:11:51', NULL),
(63, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:21', NULL),
(64, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '嗨，看你傳了好幾次招呼，是在測試我嗎？\n\n不用一直試啦，我是你的聊天夥伴。如果你有什麼想問的，像是生活常識、工作建議，或是單純想找人聊聊某個話題，直接說就可以了。\n\n今天有什麼具體想討論的事嗎？或是需要我提供什麼建議？', 1260, 5330, 'gemini-3-flash-preview', '2026-03-04 02:39:26', NULL),
(65, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:36', NULL),
(66, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:37', NULL),
(67, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:37', NULL),
(68, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:37', NULL),
(69, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:38', NULL),
(70, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:38', NULL),
(71, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:38', NULL),
(72, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hihi', 0, 0, NULL, '2026-03-04 02:39:39', NULL),
(73, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:40', NULL),
(74, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:40', NULL),
(75, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:41', NULL),
(76, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:41', NULL),
(77, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:41', NULL),
(78, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:41', NULL),
(79, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:42', NULL),
(80, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:42', NULL),
(81, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:42', NULL),
(82, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:43', NULL),
(83, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:43', NULL),
(84, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:43', NULL),
(85, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:43', NULL),
(86, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:44', NULL),
(87, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-04 02:39:44', NULL),
(88, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 7526, 'gemini-3-flash-preview', '2026-03-04 02:39:48', NULL),
(89, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 7393, 'gemini-3-flash-preview', '2026-03-04 02:39:48', NULL),
(90, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 11600, 'gemini-3-flash-preview', '2026-03-04 02:39:48', NULL),
(91, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 9187, 'gemini-3-flash-preview', '2026-03-04 02:39:49', NULL),
(92, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 12762, 'gemini-3-flash-preview', '2026-03-04 02:39:50', NULL),
(93, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 12908, 'gemini-3-flash-preview', '2026-03-04 02:39:51', NULL),
(94, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 7770, 'gemini-3-flash-preview', '2026-03-04 02:39:51', NULL),
(95, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 13187, 'gemini-3-flash-preview', '2026-03-04 02:39:51', NULL),
(96, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 8671, 'gemini-3-flash-preview', '2026-03-04 02:39:51', NULL),
(97, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 10090, 'gemini-3-flash-preview', '2026-03-04 02:39:51', NULL),
(98, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 11253, 'gemini-3-flash-preview', '2026-03-04 02:39:53', NULL),
(99, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 10522, 'gemini-3-flash-preview', '2026-03-04 02:39:53', NULL),
(100, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 11443, 'gemini-3-flash-preview', '2026-03-04 02:39:53', NULL),
(101, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 12558, 'gemini-3-flash-preview', '2026-03-04 02:39:54', NULL),
(102, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hihi」\n輸入 menu 查看支援的指令。', 0, 14584, 'gemini-3-flash-preview', '2026-03-04 02:39:54', NULL),
(103, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 17169, 'gemini-3-flash-preview', '2026-03-04 02:39:54', NULL),
(104, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 18509, 'gemini-3-flash-preview', '2026-03-04 02:39:55', NULL),
(105, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 13882, 'gemini-3-flash-preview', '2026-03-04 02:39:57', NULL),
(106, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 13578, 'gemini-3-flash-preview', '2026-03-04 02:39:57', NULL),
(107, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 15236, 'gemini-3-flash-preview', '2026-03-04 02:39:57', NULL),
(108, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 21840, 'gemini-3-flash-preview', '2026-03-04 02:39:59', NULL),
(109, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 16384, 'gemini-3-flash-preview', '2026-03-04 02:40:00', NULL),
(110, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「hi」\n輸入 menu 查看支援的指令。', 0, 16737, 'gemini-3-flash-preview', '2026-03-04 02:40:00', NULL),
(111, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Grafana 要怎麼分析排查問題', 0, 0, NULL, '2026-03-04 02:40:46', NULL),
(112, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「Grafana 要怎麼分析排查問題」\n輸入 menu 查看支援的指令。', 0, 16, 'gemini-3-flash-preview', '2026-03-04 02:40:46', NULL),
(113, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Grafana 要怎麼分析排查問題', 0, 0, NULL, '2026-03-04 02:41:32', NULL),
(114, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「Grafana 要怎麼分析排查問題」\n輸入 menu 查看支援的指令。', 0, 11, 'gemini-3-flash-preview', '2026-03-04 02:41:32', NULL),
(115, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Grafana 要怎麼分析排查問題', 0, 0, NULL, '2026-03-04 02:42:15', NULL),
(116, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '用 Grafana 排查問題，最直接的方式是先看儀表板。如果發現數據有異常波動，可以用 Explore 功能直接對資料來源下查詢，細看那段時間的原始數據。\n\n我也建議你把指標和日誌串起來看，例如用 Loki 來看 Log，這樣能快速對應到錯誤訊息。另外，檢查 Alerting 告警紀錄也很重要，這能幫你縮小故障範圍。\n\n小提醒：排查時記得手動調整時間範圍，對比一下出事前跟出事後的數據差異，通常能很快抓到問題點。', 1176, 8149, 'gemini-3-flash-preview', '2026-03-04 02:42:23', NULL),
(117, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '/status', 0, 0, NULL, '2026-03-04 02:51:45', NULL),
(118, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我目前的狀態一切正常，隨時準備好為你解答。剛才看到你之前的訊息出現了一些重複的系統回覆，可能是剛才連線有點狀況，現在應該沒問題了。\n\n如果你想繼續討論 Grafana 的分析方法，或是需要我幫你整理其他資訊，直接跟我說就行。我會盡力用最簡單的方式解釋給你聽。\n\n小提醒：如果想看特定的數據分析，記得確認你的資料來源（Data Source）是否有正確串接並有數據流入。', 1340, 7434, 'gemini-3-flash-preview', '2026-03-04 02:51:52', NULL),
(119, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '/admin', 0, 0, NULL, '2026-03-04 02:51:56', NULL),
(120, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我這裡沒有真正的管理後台，但我可以幫你梳理 Grafana 的排查邏輯。\n\n排查問題通常分三步：\n1. 看儀表板：先找出異常點，看是哪段時間、哪個指標（如 CPU 或延遲）出問題。\n2. 用 Explore 鑽研：在 Explore 頁面直接寫查詢語句，過濾掉雜訊，專注看異常時間段的數據細節。\n3. 關聯日誌：如果有接 Loki，直接對照指標異常時間點的日誌內容，找出具體的報錯訊息。\n\n小建議：排查時多利用「Compare with previous period」功能，看看現在的數據跟昨天或上週有什麼不同，通常能更快鎖定變更導致的問題。至於你剛才看到的重複訊息，可能是系統串接不穩，現在應該恢復正常了。', 1454, 57184, 'gemini-3-flash-preview', '2026-03-04 02:52:53', NULL),
(121, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-04 16:28:02', NULL),
(122, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '測試成功。剛才看你發的訊息好像有點重複，可能是系統連線不太穩，現在應該恢復正常了。\n\n我是一個可以陪你聊知識、幫你解決問題的朋友。不管是想聊 Grafana 的設定、技術問題，或是其他生活瑣事，隨時都可以跟我說。\n\n小建議：如果你遇到系統一直跳重複訊息，可以先停個幾秒再傳，通常就能恢復正常對話了。有什麼想問的嗎？', 1446, 6425, 'gemini-3-flash-preview', '2026-03-04 16:28:08', NULL),
(123, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '555', 0, 0, NULL, '2026-03-04 17:36:10', NULL),
(124, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '剛才的回覆好像卡在系統自動訊息裡了，現在恢復正常了。\n\n關於 Grafana 排查問題，建議把握三個步驟：\n1. 儀表板找異常：先看整體儀表板，鎖定數值波動或掉零的時間區段。\n2. Explore 鑽研：切換到 Explore 模式，針對該時間點直接寫 Query，過濾掉雜訊來看細節。\n3. 關聯日誌：如果有接 Loki，直接比對指標異常點的日誌（Logs），通常能直接看到具體的錯誤訊息。\n\n小建議：善用「Add Annotation」功能，在系統改版或重啟時做標記，這樣出問題時，一眼就能看出是不是變更造成的。如果有具體的報錯，也可以傳給我看看。', 1809, 7984, 'gemini-3-flash-preview', '2026-03-04 17:36:18', NULL),
(125, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '請你說明 Kubernetes 功能', 0, 0, NULL, '2026-03-04 17:36:29', NULL),
(126, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', 'Kubernetes（簡稱 K8s）簡單來說就是一個「自動化管家」，專門管理容器化的應用程式。它的核心功能有這幾個：\n\n1. 自我修復：如果某個程式掛掉，K8s 會自動重啟它；要是整台機器壞了，它會把程式移到別台機器跑，確保服務不中斷。\n2. 自動擴縮：人潮變多時自動加開機器，沒人時自動縮減，幫你省錢。\n3. 負載平衡：它會自動分配網路流量，不會讓某個容器忙死，另一個卻在偷懶。\n4. 版本更新：它可以幫你無縫更換新版本，如果新版有問題，也能一鍵退回舊版。\n\n小建議：如果你只是跑一兩個小網站，用 K8s 可能有點大材小用，架構會變太複雜；但如果服務很多，它絕對是省心神器。', 1651, 50350, 'gemini-3-flash-preview', '2026-03-04 17:37:19', NULL),
(127, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '請你說明 Kubernetes 功能', 0, 0, NULL, '2026-03-04 17:48:33', NULL),
(128, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '剛才對話好像有點卡住，我重新說明一下 Kubernetes（簡稱 K8s）的核心功能。\n\n它就像是一個「自動化管家」，專門幫你管理容器化的應用程式。重點功能有這幾個：\n\n1. 自我修復：如果某個程式掛掉，K8s 會自動重啟它；要是整台伺服器壞了，它會把上面的程式移到其他健康的機器跑。\n2. 自動擴縮：人潮變多時自動加開容器，沒人時自動縮減，幫你節省資源。\n3. 負載平衡：它會自動分配網路流量，確保每個容器的負擔平均，不會有人太累。\n4. 滾動更新：更新程式時可以一個一個換，確保服務不中斷，萬一新版有問題也能快速退回舊版。\n\n小建議：K8s 雖然強大，但維運成本很高。如果你的服務規模不大，用簡單的 Docker 可能更省事；當服務多到手動管不來時，才是 K8s 出場的好時機。', 2410, 9894, 'gemini-3-flash-preview', '2026-03-04 17:48:43', NULL),
(129, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-05 07:10:07', NULL),
(130, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你來了！現在一切正常，我可以陪你聊天了。想跟我聊什麼呢？是想學習知識，或者有問題需要解答？隨你說，我在！', 1849, 1094, 'llama-3.1-8b-instant', '2026-03-05 07:10:08', NULL),
(131, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '在嘛', 0, 0, NULL, '2026-03-06 01:37:04', NULL),
(132, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '一切正常！我在這裡，隨時跟你聊天。\n\n你想聊什麼？是想學習新知識，或者需要幫忙解答問題？只要跟我說，我就會盡力幫你！', 1738, 664, 'llama-3.1-8b-instant', '2026-03-06 01:37:04', NULL),
(133, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '失敗?', 0, 0, NULL, '2026-03-08 08:38:52', NULL),
(134, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「失敗?」\n輸入 menu 查看支援的指令。', 0, 145, 'gemini-3-flash-preview', '2026-03-08 08:38:52', NULL),
(135, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '失敗?', 0, 0, NULL, '2026-03-08 08:39:58', NULL),
(136, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '怎麼了？是哪裡卡住了嗎？如果是指我們的對話，我現在收得到你的訊息，運作應該是正常的。\n\n如果你是在測試某個程式或系統遇到失敗，可以把錯誤訊息或是具體的狀況跟我說，我們一起研究看看是哪裡出問題。有時候可能是設定跑掉，或是少了一個小步驟。\n\n小建議：測試失敗很正常，通常看 Log 就能找到線索。需要幫忙分析的話，儘管把細節貼上來。', 1651, 3314, 'gemini-3-flash-preview', '2026-03-08 08:40:01', NULL),
(137, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '好~', 0, 0, NULL, '2026-03-10 07:51:50', NULL),
(138, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '別哭別哭，這些工具剛開始看確實會覺得頭大。不管是 Kubernetes 還是 Grafana，都是需要時間磨合的。\n\n如果你現在是處理具體問題到心累，或是練習時卡住，可以先休息一下。之後如果有具體的報錯或是想不通的地方，隨時貼給我，我們一起研究。\n\n小建議：學習這類技術最快的方式是邊做邊查，遇到問題再去解決，會比死背文件有用很多。還有其他想聊的嗎？', 1867, 7170, 'gemini-3-flash-preview', '2026-03-10 07:51:57', NULL),
(139, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '555', 0, 0, NULL, '2026-03-13 17:31:48', NULL),
(140, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「555」\n輸入 menu 查看支援的指令。', 0, 164, 'gemini-3-flash-preview', '2026-03-13 17:31:48', NULL),
(141, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '555', 0, 0, NULL, '2026-03-13 17:31:58', NULL),
(142, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '看來你有點累了！我們可以換個題目聊天一下。想要學習什麼新知識或是聊什麼輕鬆話題？我在！', 1138, 483, 'llama-3.1-8b-instant', '2026-03-13 17:31:58', NULL),
(143, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'hi', 0, 0, NULL, '2026-03-13 17:46:16', NULL),
(144, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你又說了 \"hi\"！看起來你很放鬆！我也一樣，你想聊什麼呢？是跟我聊天，或者學習新知識？', 897, 579, 'llama-3.1-8b-instant', '2026-03-13 17:46:17', NULL),
(145, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'sssssssssssssss', 0, 0, NULL, '2026-03-13 17:53:34', NULL),
(146, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '看起來你很放鬆！我們可以聊天了！你想聊什麼呢？是跟我說心裡話，或者分享一些有趣的故事？', 902, 380, 'llama-3.1-8b-instant', '2026-03-13 17:53:34', NULL),
(147, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '5555', 0, 0, NULL, '2026-03-13 17:56:20', NULL),
(148, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '看起來你還是在說著 \"555\"？那不是一種字元，好像是在跟我說 \"很累\" 吧？如果是真的累了，想做點什麼輕鬆的事情？我可以跟你聊天，或者幫你找點有趣的資源。', 911, 418, 'llama-3.1-8b-instant', '2026-03-13 17:56:20', NULL),
(149, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '在嘛', 0, 0, NULL, '2026-03-13 18:01:50', NULL),
(150, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「在嘛」\n輸入 menu 查看支援的指令。', 0, 26, 'gemini-3.1-pro-preview', '2026-03-13 18:01:50', NULL),
(151, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '在', 0, 0, NULL, '2026-03-13 18:02:21', NULL),
(152, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你還繼續說著 \"在\" 吧？好像你還沒有說完什麼東西？可以再tell 我一下你想說什麼嗎？', 809, 347, 'llama-3.1-8b-instant', '2026-03-13 18:02:22', NULL),
(153, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '想睡覺了', 0, 0, NULL, '2026-03-14 20:31:23', NULL),
(154, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你真的想睡覺了嗎？可以先洗個澡或進行一些放鬆的活動，來幫助你入睡。或者我可以跟你講一些輕鬆的故事，幫助你放鬆一下。', 738, 618, 'llama-3.1-8b-instant', '2026-03-14 20:31:23', NULL),
(155, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '哈羅', 0, 0, NULL, '2026-03-15 12:51:54', NULL),
(156, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你恢復正常了！哈羅！現在我們可以聊天了。想跟我說什麼呢？', 742, 470, 'llama-3.1-8b-instant', '2026-03-15 12:51:55', NULL),
(157, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'HI', 0, 0, NULL, '2026-03-15 12:52:22', NULL),
(158, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「HI」\n輸入 menu 查看支援的指令。', 0, 23, 'gemini-2.5-flash', '2026-03-15 12:52:22', NULL),
(159, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-16 01:54:01', NULL),
(160, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '測試成功，我收到了。剛才看你發了一串字母，是累到手滑了嗎？如果有什麼想聊的或是想問的事情，隨時可以告訴我。', 798, 3831, 'gemini-3-flash-preview', '2026-03-16 01:54:04', NULL),
(161, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '123', 0, 0, NULL, '2026-03-16 07:36:44', NULL),
(162, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '又是 123。看來你還在測試連線，或是現在真的很無聊。\n\n既然還沒去睡，要不要聊點具體的話題？一直打數字可能沒辦法幫你解悶。如果你有什麼想知道的事，或是單純想找人說說話，直接告訴我就好。', 968, 5860, 'gemini-3-flash-preview', '2026-03-16 07:36:50', NULL),
(163, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-18 17:54:41', NULL),
(164, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「你好」\n輸入 menu 查看支援的指令。', 0, 206, 'gemini-3-flash-preview', '2026-03-18 17:54:41', NULL),
(165, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-18 18:04:31', NULL),
(166, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「你好」\n輸入 menu 查看支援的指令。', 0, 26, 'gemini-3-flash-preview', '2026-03-18 18:04:31', NULL),
(167, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-18 18:04:52', NULL),
(168, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「你好」\n輸入 menu 查看支援的指令。', 0, 14, 'gemini-3-flash-preview', '2026-03-18 18:04:52', NULL),
(169, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '美好和', 0, 0, NULL, '2026-03-18 18:33:03', NULL),
(170, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好！看你試了好幾次，現在連線應該很順暢了。\n\n你剛才一直提到「美好和」，是幫我取的新名字嗎？聽起來蠻有溫度的。既然連上線了，有什麼想聊的話題，或是想知道的事嗎？隨時可以告訴我。', 959, 22985, 'gemini-3-flash-preview', '2026-03-18 18:33:26', NULL),
(171, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Hi', 0, 0, NULL, '2026-03-18 18:37:19', NULL),
(172, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你好，看你剛才測試了幾次，現在通訊應該沒問題了。既然連上線了，有什麼想聊的話題或想知道的事情嗎？直接說就好。', 1056, 4113, 'gemini-3-flash-preview', '2026-03-18 18:37:23', NULL),
(173, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '哈', 0, 0, NULL, '2026-03-21 11:44:56', NULL),
(174, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「哈」\n輸入 menu 查看支援的指令。', 0, 402, 'gemini-3-flash-preview', '2026-03-21 11:44:56', NULL),
(175, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '哈', 0, 0, NULL, '2026-03-21 12:07:00', NULL),
(176, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「哈」\n輸入 menu 查看支援的指令。', 0, 12, 'gemini-3-flash-preview', '2026-03-21 12:07:00', NULL),
(177, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-21 14:25:19', NULL),
(178, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 196, 'gemini-3-flash-preview', '2026-03-21 14:25:19', NULL),
(179, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-21 14:25:45', NULL),
(180, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 11, 'gemini-3-flash-preview', '2026-03-21 14:25:45', NULL),
(181, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-21 14:25:54', NULL),
(182, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 13, 'gemini-2.5-flash', '2026-03-21 14:25:54', NULL),
(183, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-21 14:26:17', NULL),
(184, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「測試」\n輸入 menu 查看支援的指令。', 0, 7, 'gemini-2.5-flash', '2026-03-21 14:26:17', NULL),
(185, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-21 14:40:09', NULL),
(186, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，又測試一次啊？看起來我們連線得很穩定喔。\n\n都測試這麼多次了，應該沒問題了吧？有什麼想問的，或者想聊聊的，都可以直接跟我說喔。', 625, 2678, 'gemini-2.5-flash', '2026-03-21 14:40:12', NULL),
(187, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '123', 0, 0, NULL, '2026-03-21 14:50:14', NULL),
(188, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '我們已收到您的訊息：「123」\n輸入 menu 查看支援的指令。', 0, 205, 'gemini-2.5-flash', '2026-03-21 14:50:14', NULL),
(189, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '123', 0, 0, NULL, '2026-03-21 14:50:45', NULL),
(190, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '嘿，又測試一次啊？都通喔，不用擔心。有什麼想問的嗎？', 850, 5036, 'gemini-2.5-flash', '2026-03-21 14:50:50', NULL),
(191, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-23 07:47:56', NULL),
(192, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，你好啊！一直測試，看來連線很穩定喔。\n\n有什麼想問的嗎？還是想聊聊什麼？別客氣，直接說就好。', 509, 1771, 'gemini-2.5-flash', '2026-03-23 07:47:58', NULL),
(193, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-23 07:48:11', NULL),
(194, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，你又回來了！有什麼想問的，或者想聊聊的，都可以跟我說喔。', 653, 429, 'llama-3.1-8b-instant', '2026-03-23 07:48:12', NULL),
(195, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-23 08:04:53', NULL),
(196, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉！好久不見了！你有什麼要聊的嗎？還是想問個問題？', 659, 545, 'llama-3.1-8b-instant', '2026-03-23 08:04:54', NULL),
(197, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '123', 0, 0, NULL, '2026-03-23 15:13:20', NULL),
(198, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '你又測試一次啊？這樣子的聊天，我們都已經測試完了，現在可以聊點什麼吧？', 667, 847, 'llama-3.1-8b-instant', '2026-03-23 15:13:21', NULL),
(199, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-23 15:19:09', NULL),
(200, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '好嘞，又測試一次！看來我們都正常了，無事一樁！你有什麼真正想聊的嗎？', 679, 546, 'llama-3.1-8b-instant', '2026-03-23 15:19:10', NULL),
(201, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-23 15:21:24', NULL),
(202, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，你又測試一次啊？都正常了，看來我們的聊天夥伴角色定位都很穩定。\n\n你有什麼想問的，或是想聊聊什麼？', 667, 653, 'llama-3.1-8b-instant', '2026-03-23 15:21:25', NULL),
(203, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-23 15:22:30', NULL),
(204, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，你再測試一次！看來系統都正常了，現在可以聊點什麼了喔。有什麼想問的，或者想聊聊的都可以跟我說。', 692, 312, 'llama-3.1-8b-instant', '2026-03-23 15:22:31', NULL),
(205, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '測試', 0, 0, NULL, '2026-03-23 15:43:29', NULL),
(206, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，你又測試一次啊？好，好，我知道了！我們連線都很穩定，現在可以聊點什麼了。有什麼想問的嗎？', 710, 939, 'llama-3.1-8b-instant', '2026-03-23 15:43:30', NULL),
(207, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', '你好', 0, 0, NULL, '2026-03-23 16:06:32', NULL),
(208, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', NULL, 'AI', '哈囉，好好！我想我們就這樣聊起來了。有什麼想聊的，或者想要問我什麼，都可以跟我說！', 702, 560, 'llama-3.1-8b-instant', '2026-03-23 16:06:32', NULL);

-- --------------------------------------------------------

--
-- 資料表結構 `chat_rooms`
--

CREATE TABLE `chat_rooms` (
  `id` bigint(20) NOT NULL COMMENT '主鍵，自動遞增',
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID（LINE userId 或 groupId）',
  `room_type` varchar(10) NOT NULL COMMENT '聊天室類型：USER=個人，GROUP=群組',
  `ai_enabled` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'AI 回應功能開關',
  `ai_model` varchar(50) DEFAULT 'llama-3.1-8b-instant' COMMENT '使用的 AI 模型名稱',
  `is_admin` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否為管理員聊天室',
  `auth_pending` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否正在等待輸入認證密碼',
  `waiting_for_location` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否正在等待用戶位置以進行廁所搜尋',
  `timezone` varchar(50) DEFAULT 'Asia/Taipei' COMMENT '聊天室時區設定',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間'
) ;

--
-- 傾印資料表的資料 `chat_rooms`
--

INSERT INTO `chat_rooms` (`id`, `room_id`, `room_type`, `ai_enabled`, `ai_model`, `is_admin`, `auth_pending`, `waiting_for_location`, `timezone`, `created_at`) VALUES
(1, 'Ue60ce762c5e984c186abbc46b1c58ec4', 'USER', 1, 'llama-3.1-8b-instant', 1, 0, 1, 'Asia/Taipei', '2026-02-24 05:44:04'),
(2, 'C31e9a46c5cf24636e230e5aa054e24f7', 'GROUP', 0, 'llama-3.1-8b-instant', 0, 0, 0, 'Asia/Taipei', '2026-02-24 05:48:33'),
(3, 'C5bfed72f7a469825212964006d25a896', 'GROUP', 0, 'llama-3.1-8b-instant', 0, 0, 0, 'Asia/Taipei', '2026-02-24 05:49:34'),
(4, 'Ccc8c2e473d626dc8bad78e0b26b00f32', 'GROUP', 0, 'llama-3.1-8b-instant', 0, 0, 0, 'Asia/Taipei', '2026-03-04 04:14:19'),
(5, 'Ca931f7caf14c5baf3e4834aec61742dd', 'GROUP', 0, 'llama-3.1-8b-instant', 0, 0, 0, 'Asia/Taipei', '2026-03-06 05:27:41'),
(6, 'C90d44571eb7b44d9912510443cdcb55f', 'GROUP', 0, 'llama-3.1-8b-instant', 0, 0, 0, 'Asia/Taipei', '2026-03-18 19:04:14'),
(7, 'C1dbe59d0730419cf89a8047e557531ff', 'GROUP', 0, 'llama-3.1-8b-instant', 0, 0, 0, 'Asia/Taipei', '2026-03-20 10:00:23');

-- --------------------------------------------------------

--
-- 資料表結構 `emails`
--

CREATE TABLE `emails` (
  `id` bigint(20) NOT NULL COMMENT '主鍵，自動遞增',
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `email` varchar(255) NOT NULL COMMENT '電子郵件地址',
  `is_enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否啟用此信箱的 Email 通知',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否啟用，FALSE 表示已軟刪除',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `email_input_states`
--

CREATE TABLE `email_input_states` (
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '狀態建立時間',
  `expires_at` timestamp NOT NULL COMMENT '狀態過期時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `flyway_schema_history`
--

CREATE TABLE `flyway_schema_history` (
  `installed_rank` int(11) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int(11) DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 傾印資料表的資料 `flyway_schema_history`
--

INSERT INTO `flyway_schema_history` (`installed_rank`, `version`, `description`, `type`, `script`, `checksum`, `installed_by`, `installed_on`, `execution_time`, `success`) VALUES
(1, '1', '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', NULL, 'root', '2026-02-25 07:39:02', 0, 1);

-- --------------------------------------------------------

--
-- 資料表結構 `reminders`
--

CREATE TABLE `reminders` (
  `id` bigint(20) NOT NULL COMMENT '提醒 ID，自動遞增',
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `content` text NOT NULL COMMENT '提醒內容',
  `timezone` varchar(50) DEFAULT 'Asia/Taipei' COMMENT '建立提醒時的時區',
  `reminder_time_instant` bigint(20) DEFAULT NULL COMMENT '提醒時間點（epoch millis）',
  `repeat_type` varchar(20) DEFAULT 'ONCE' COMMENT '重複類型：ONCE, DAILY, WEEKLY',
  `status` varchar(20) DEFAULT 'ACTIVE' COMMENT '狀態：ACTIVE, PAUSED, COMPLETED',
  `created_by` varchar(100) NOT NULL COMMENT '建立者（LINE userId）',
  `notification_channel` varchar(20) DEFAULT 'LINE' COMMENT '通知管道：LINE, EMAIL, BOTH',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 傾印資料表的資料 `reminders`
--

INSERT INTO `reminders` (`id`, `room_id`, `content`, `timezone`, `reminder_time_instant`, `repeat_type`, `status`, `created_by`, `notification_channel`, `created_at`) VALUES
(1, 'C31e9a46c5cf24636e230e5aa054e24f7', '用藥提醒', 'Asia/Taipei', 1775793600000, 'DAILY', 'ACTIVE', 'C31e9a46c5cf24636e230e5aa054e24f7', 'BOTH', '2026-02-24 05:49:19'),
(2, 'C5bfed72f7a469825212964006d25a896', '維他命C', 'Asia/Taipei', 1775793600000, 'DAILY', 'ACTIVE', 'C5bfed72f7a469825212964006d25a896', 'BOTH', '2026-02-24 05:50:04');

-- --------------------------------------------------------

--
-- 資料表結構 `reminder_locks`
--

CREATE TABLE `reminder_locks` (
  `lock_key` varchar(100) NOT NULL COMMENT '鎖定鍵（唯一，防止重複發送）',
  `locked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鎖定時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `reminder_logs`
--

CREATE TABLE `reminder_logs` (
  `id` bigint(20) NOT NULL COMMENT '記錄 ID，自動遞增',
  `reminder_id` bigint(20) NOT NULL COMMENT '提醒 ID',
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `sent_time` timestamp NOT NULL COMMENT '發送時間',
  `status` varchar(20) NOT NULL COMMENT '發送狀態：SENT, FAILED',
  `error_message` text COMMENT '錯誤訊息（發送失敗時記錄）',
  `user_response_time` timestamp NULL DEFAULT NULL COMMENT '用戶確認回應時間',
  `user_response_status` varchar(20) DEFAULT NULL COMMENT '用戶回應狀態（CONFIRMED, SNOOZED）',
  `delivery_method` varchar(20) DEFAULT NULL COMMENT '發送方式：LINE, EMAIL',
  `confirmation_token` varchar(100) DEFAULT NULL COMMENT 'Email 確認用的 UUID Token',
  `confirmed_at` timestamp NULL DEFAULT NULL COMMENT 'Email 確認時間',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 傾印資料表的資料 `reminder_logs`
--

INSERT INTO `reminder_logs` (`id`, `reminder_id`, `room_id`, `sent_time`, `status`, `error_message`, `user_response_time`, `user_response_status`, `delivery_method`, `confirmation_token`, `confirmed_at`, `created_at`) VALUES
(1, 2, 'C5bfed72f7a469825212964006d25a896', '2026-02-25 04:00:02', 'SENT', NULL, '2026-02-25 04:00:18', 'COMPLETED', 'LINE', NULL, NULL, '2026-02-25 04:00:02'),
(2, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-02-25 04:00:02', 'SENT', NULL, '2026-02-25 04:02:16', 'COMPLETED', 'LINE', NULL, NULL, '2026-02-25 04:00:02'),
(3, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-02-26 04:00:02', 'SENT', NULL, '2026-02-26 04:30:25', 'COMPLETED', 'LINE', NULL, NULL, '2026-02-26 04:00:02'),
(4, 2, 'C5bfed72f7a469825212964006d25a896', '2026-02-26 04:00:02', 'SENT', NULL, '2026-02-27 12:57:47', 'COMPLETED', 'LINE', NULL, NULL, '2026-02-26 04:00:02'),
(5, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-02-28 04:00:02', 'SENT', NULL, '2026-02-28 07:49:02', 'COMPLETED', 'LINE', NULL, NULL, '2026-02-28 04:00:02'),
(6, 2, 'C5bfed72f7a469825212964006d25a896', '2026-02-28 04:00:02', 'SENT', NULL, '2026-02-28 04:01:18', 'COMPLETED', 'LINE', NULL, NULL, '2026-02-28 04:00:02'),
(7, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-01 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-01 04:00:01'),
(8, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-01 04:00:02', 'SENT', NULL, '2026-03-01 04:00:17', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-01 04:00:02'),
(9, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-02 04:00:02', 'SENT', NULL, '2026-03-02 04:02:12', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-02 04:00:02'),
(10, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-02 04:00:03', 'SENT', NULL, '2026-03-02 04:00:06', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-02 04:00:03'),
(11, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-03 04:00:01', 'SENT', NULL, '2026-03-03 05:32:17', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-03 04:00:01'),
(12, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-03 04:00:01', 'SENT', NULL, '2026-03-03 04:41:27', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-03 04:00:01'),
(13, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-04 04:00:01', 'SENT', NULL, '2026-03-04 06:50:06', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-04 04:00:01'),
(14, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-04 04:00:01', 'SENT', NULL, '2026-03-04 04:07:23', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-04 04:00:01'),
(15, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-05 06:19:44', 'SENT', NULL, '2026-03-05 06:31:30', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-05 06:19:44'),
(16, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-05 06:19:44', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-05 06:19:44'),
(17, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-06 04:00:01', 'SENT', NULL, '2026-03-06 04:00:21', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-06 04:00:01'),
(18, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-06 04:00:02', 'SENT', NULL, '2026-03-06 04:00:07', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-06 04:00:02'),
(19, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-07 04:00:02', 'SENT', NULL, '2026-03-07 10:13:06', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-07 04:00:02'),
(20, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-07 04:00:02', 'SENT', NULL, '2026-03-07 04:52:26', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-07 04:00:02'),
(21, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-08 04:00:02', 'SENT', NULL, '2026-03-08 11:52:55', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-08 04:00:02'),
(22, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-08 04:00:03', 'SENT', NULL, '2026-03-08 05:07:35', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-08 04:00:03'),
(23, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-09 04:00:01', 'SENT', NULL, '2026-03-09 11:30:19', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-09 04:00:01'),
(24, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-09 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-09 04:00:02'),
(25, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-10 04:00:01', 'SENT', NULL, '2026-03-10 10:24:45', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-10 04:00:01'),
(26, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-10 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-10 04:00:01'),
(27, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-11 04:00:01', 'SENT', NULL, '2026-03-11 04:32:07', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-11 04:00:01'),
(28, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-11 04:00:02', 'SENT', NULL, '2026-03-11 05:17:23', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-11 04:00:02'),
(29, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-13 06:51:28', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-13 06:51:28'),
(30, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-13 06:51:29', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-13 06:51:29'),
(31, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-14 04:00:01', 'SENT', NULL, '2026-03-14 06:10:19', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-14 04:00:01'),
(32, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-14 04:00:02', 'SENT', NULL, '2026-03-14 04:34:20', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-14 04:00:02'),
(33, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-15 04:00:01', 'SENT', NULL, '2026-03-15 06:33:06', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-15 04:00:01'),
(34, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-15 04:00:01', 'SENT', NULL, '2026-03-15 06:28:45', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-15 04:00:01'),
(35, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-16 04:00:01', 'SENT', NULL, '2026-03-16 07:00:27', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-16 04:00:01'),
(36, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-16 04:00:01', 'SENT', NULL, '2026-03-16 05:04:51', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-16 04:00:01'),
(37, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-17 04:00:01', 'SENT', NULL, '2026-03-17 04:03:22', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-17 04:00:01'),
(38, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-17 04:00:02', 'SENT', NULL, '2026-03-17 04:02:50', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-17 04:00:02'),
(39, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-18 04:00:02', 'SENT', NULL, '2026-03-18 09:47:14', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-18 04:00:02'),
(40, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-18 04:00:02', 'SENT', NULL, '2026-03-18 04:56:50', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-18 04:00:02'),
(41, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-19 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-19 04:00:01'),
(42, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-19 04:00:01', 'SENT', NULL, '2026-03-19 04:00:29', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-19 04:00:01'),
(43, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-20 04:00:03', 'SENT', NULL, '2026-03-20 06:24:59', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-20 04:00:03'),
(44, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-20 04:00:03', 'SENT', NULL, '2026-03-20 06:26:32', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-20 04:00:03'),
(45, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-21 08:46:06', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-21 08:46:06'),
(46, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-21 08:46:06', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-21 08:46:06'),
(47, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-22 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-22 04:00:01'),
(48, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-22 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-22 04:00:01'),
(49, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-23 04:00:01', 'SENT', NULL, '2026-03-23 06:34:07', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-23 04:00:01'),
(50, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-23 04:00:02', 'SENT', NULL, '2026-03-23 04:00:06', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-23 04:00:02'),
(51, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-24 04:00:02', 'SENT', NULL, '2026-03-24 05:12:20', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-24 04:00:02'),
(52, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-24 04:00:02', 'SENT', NULL, '2026-03-24 04:23:38', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-24 04:00:02'),
(53, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-25 04:00:01', 'SENT', NULL, '2026-03-25 12:52:08', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-25 04:00:01'),
(54, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-25 04:00:02', 'SENT', NULL, '2026-03-25 05:30:49', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-25 04:00:02'),
(55, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-26 04:00:01', 'SENT', NULL, '2026-03-26 08:47:55', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-26 04:00:01'),
(56, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-26 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-26 04:00:02'),
(57, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-27 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-27 04:00:01'),
(58, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-27 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-27 04:00:02'),
(59, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-28 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-28 04:00:01'),
(60, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-28 04:00:02', 'SENT', NULL, '2026-03-28 08:55:03', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-28 04:00:02'),
(61, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-29 04:00:01', 'SENT', NULL, '2026-03-29 12:00:41', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-29 04:00:01'),
(62, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-29 04:00:02', 'SENT', NULL, '2026-03-29 04:32:59', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-29 04:00:02'),
(63, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-30 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-30 04:00:01'),
(64, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-30 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-30 04:00:02'),
(65, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-03-31 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-03-31 04:00:02'),
(66, 2, 'C5bfed72f7a469825212964006d25a896', '2026-03-31 04:00:02', 'SENT', NULL, '2026-03-31 04:00:22', 'COMPLETED', 'LINE', NULL, NULL, '2026-03-31 04:00:02'),
(67, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-01 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-01 04:00:01'),
(68, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-01 04:00:01', 'SENT', NULL, '2026-04-01 04:02:03', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-01 04:00:01'),
(69, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-02 04:00:02', 'SENT', NULL, '2026-04-02 09:31:32', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-02 04:00:02'),
(70, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-02 04:00:04', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-02 04:00:04'),
(71, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-03 04:00:02', 'SENT', NULL, '2026-04-03 12:50:59', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-03 04:00:02'),
(72, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-03 04:00:03', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-03 04:00:03'),
(73, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-04 04:00:01', 'SENT', NULL, '2026-04-04 23:30:17', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-04 04:00:01'),
(74, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-04 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-04 04:00:02'),
(75, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-05 04:00:01', 'SENT', NULL, '2026-04-05 05:27:19', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-05 04:00:01'),
(76, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-05 04:00:02', 'SENT', NULL, '2026-04-05 04:00:07', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-05 04:00:02'),
(77, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-06 04:00:01', 'SENT', NULL, '2026-04-06 13:16:29', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-06 04:00:01'),
(78, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-06 04:00:01', 'SENT', NULL, '2026-04-06 04:50:11', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-06 04:00:01'),
(79, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-07 04:00:02', 'SENT', NULL, '2026-04-07 13:39:50', 'COMPLETED', 'LINE', NULL, NULL, '2026-04-07 04:00:02'),
(80, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-07 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-07 04:00:02'),
(81, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-08 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-08 04:00:02'),
(82, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-08 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-08 04:00:02'),
(83, 1, 'C31e9a46c5cf24636e230e5aa054e24f7', '2026-04-09 04:00:01', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-09 04:00:01'),
(84, 2, 'C5bfed72f7a469825212964006d25a896', '2026-04-09 04:00:02', 'SENT', NULL, NULL, NULL, 'LINE', NULL, NULL, '2026-04-09 04:00:02');

-- --------------------------------------------------------

--
-- 資料表結構 `reminder_states`
--

CREATE TABLE `reminder_states` (
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `step` varchar(50) NOT NULL COMMENT '當前步驟：WAITING_FOR_REPEAT_TYPE, WAITING_FOR_TIME, WAITING_FOR_CONTENT',
  `repeat_type` varchar(20) DEFAULT NULL COMMENT '暫存的重複類型',
  `reminder_time` timestamp NULL DEFAULT NULL COMMENT '暫存的提醒時間',
  `timezone` varchar(50) DEFAULT NULL COMMENT '暫存的時區',
  `reminder_instant` timestamp NULL DEFAULT NULL COMMENT '暫存的提醒時間點',
  `notification_channel` varchar(20) DEFAULT 'LINE' COMMENT '暫存的通知管道選擇',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
  `expires_at` timestamp NOT NULL COMMENT '狀態過期時間（30 分鐘後自動清除）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `timezone_input_states`
--

CREATE TABLE `timezone_input_states` (
  `room_id` varchar(100) NOT NULL COMMENT '聊天室 ID',
  `resolved_timezone` varchar(50) DEFAULT NULL COMMENT '解析後的時區名稱（如：Asia/Taipei）',
  `original_input` varchar(100) DEFAULT NULL COMMENT '用戶原始輸入',
  `created_at` timestamp NULL DEFAULT NULL COMMENT '建立時間',
  `expires_at` timestamp NOT NULL COMMENT '過期時間'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chat_messages_room_id` (`room_id`),
  ADD KEY `idx_chat_messages_user_id` (`user_id`),
  ADD KEY `idx_chat_messages_room_type` (`room_type`),
  ADD KEY `idx_chat_messages_message_type` (`message_type`),
  ADD KEY `idx_chat_messages_created_at` (`created_at`),
  ADD KEY `idx_chat_messages_deleted_at` (`deleted_at`),
  ADD KEY `idx_chat_messages_room_created` (`room_id`,`created_at`),
  ADD KEY `idx_chat_messages_room_not_deleted` (`room_id`,`deleted_at`);

--
-- 資料表索引 `chat_rooms`
--
ALTER TABLE `chat_rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `room_id` (`room_id`),
  ADD KEY `idx_chat_rooms_room_id` (`room_id`),
  ADD KEY `idx_chat_rooms_room_type` (`room_type`),
  ADD KEY `idx_chat_rooms_ai_enabled` (`ai_enabled`),
  ADD KEY `idx_chat_rooms_ai_model` (`ai_model`),
  ADD KEY `idx_chat_rooms_is_admin` (`is_admin`),
  ADD KEY `idx_chat_rooms_waiting_for_location` (`waiting_for_location`),
  ADD KEY `idx_chat_rooms_timezone` (`timezone`);

--
-- 資料表索引 `emails`
--
ALTER TABLE `emails`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_emails_room_id` (`room_id`),
  ADD KEY `idx_emails_is_active` (`is_active`),
  ADD KEY `idx_emails_room_id_is_active` (`room_id`,`is_active`);

--
-- 資料表索引 `email_input_states`
--
ALTER TABLE `email_input_states`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `idx_email_input_states_expires_at` (`expires_at`);

--
-- 資料表索引 `flyway_schema_history`
--
ALTER TABLE `flyway_schema_history`
  ADD PRIMARY KEY (`installed_rank`),
  ADD KEY `flyway_schema_history_s_idx` (`success`);

--
-- 資料表索引 `reminders`
--
ALTER TABLE `reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_reminders_room` (`room_id`),
  ADD KEY `idx_reminders_time_instant_status` (`reminder_time_instant`,`status`);

--
-- 資料表索引 `reminder_locks`
--
ALTER TABLE `reminder_locks`
  ADD PRIMARY KEY (`lock_key`),
  ADD KEY `idx_locks_locked_at` (`locked_at`);

--
-- 資料表索引 `reminder_logs`
--
ALTER TABLE `reminder_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `confirmation_token` (`confirmation_token`),
  ADD KEY `idx_logs_reminder` (`reminder_id`),
  ADD KEY `idx_logs_room` (`room_id`),
  ADD KEY `idx_reminder_logs_response` (`user_response_status`,`user_response_time`),
  ADD KEY `idx_reminder_logs_confirmation_token` (`confirmation_token`);

--
-- 資料表索引 `reminder_states`
--
ALTER TABLE `reminder_states`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `idx_reminder_states_expires` (`expires_at`);

--
-- 資料表索引 `timezone_input_states`
--
ALTER TABLE `timezone_input_states`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `idx_timezone_input_states_expires_at` (`expires_at`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主鍵，自動遞增';

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `chat_rooms`
--
ALTER TABLE `chat_rooms`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主鍵，自動遞增';

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `emails`
--
ALTER TABLE `emails`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主鍵，自動遞增';

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reminders`
--
ALTER TABLE `reminders`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '提醒 ID，自動遞增', AUTO_INCREMENT=3;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `reminder_logs`
--
ALTER TABLE `reminder_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '記錄 ID，自動遞增', AUTO_INCREMENT=85;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
