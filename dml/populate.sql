-- =============================================================================
-- TradeInsight — Trading Journal & Performance Analysis System
-- Milestone 5: Data Manipulation Language (DML) Script
-- =============================================================================
-- Project  : TradeInsight
-- Team     : Shayan Ijaz · Huzaima Zakir
-- Instructor: Ali Hassan
-- =============================================================================
-- Run AFTER schema.sql has been executed.
-- This script:
--   1. Inserts all synthetic dataset rows
--   2. Demonstrates UPDATE with WHERE
--   3. Demonstrates DELETE with WHERE
-- =============================================================================

USE tradeinsight_db;

SET foreign_key_checks = 0;  -- temporarily disable for bulk load order flexibility
SET autocommit = 0;
START TRANSACTION;

-- ---------------------------------------------------------------------------
-- TRUNCATE existing data (for re-runs)
-- ---------------------------------------------------------------------------
TRUNCATE TABLE journal_notes;
TRUNCATE TABLE trades;
TRUNCATE TABLE trade_types;
TRUNCATE TABLE assets;
TRUNCATE TABLE strategies;
TRUNCATE TABLE users;

SET foreign_key_checks = 1;


-- ---------------------------------------------------------------------------
-- INSERT: users (20 rows)
-- ---------------------------------------------------------------------------
INSERT INTO users (UserID, Name, Email, Password, CreatedAt) VALUES
  (1, 'Shayan Ijaz', 'shayan.ijaz@tradeinsight.com', 'hashed_shayan_2824', '2022-06-13 00:00:00'),
  (2, 'Huzaima Zakir', 'huzaima.zakir@tradeinsight.com', 'hashed_huzaima_5506', '2022-10-04 00:00:00'),
  (3, 'Omar Sheikh', 'omar.sheikh@tradeinsight.com', 'hashed_omar_4657', '2022-08-11 00:00:00'),
  (4, 'Bilal Khan', 'bilal.khan@tradeinsight.com', 'hashed_bilal_2679', '2023-05-13 00:00:00'),
  (5, 'Farrukh Malik', 'farrukh.malik@tradeinsight.com', 'hashed_farrukh_9935', '2022-07-15 00:00:00'),
  (6, 'Nadia Akhtar', 'nadia.akhtar@tradeinsight.com', 'hashed_nadia_7912', '2022-06-17 00:00:00'),
  (7, 'Sara Qureshi', 'sara.qureshi@tradeinsight.com', 'hashed_sara_1488', '2022-07-18 00:00:00'),
  (8, 'Zara Hussain', 'zara.hussain@tradeinsight.com', 'hashed_zara_4582', '2022-09-28 00:00:00'),
  (9, 'Ahmed Siddiqui', 'ahmed.siddiqui@tradeinsight.com', 'hashed_ahmed_9279', '2023-04-05 00:00:00'),
  (10, 'Hamza Baig', 'hamza.baig@tradeinsight.com', 'hashed_hamza_1434', '2023-03-15 00:00:00'),
  (11, 'Usman Chaudhry', 'usman.chaudhry@tradeinsight.com', 'hashed_usman_4257', '2023-06-02 00:00:00'),
  (12, 'Ayesha Mirza', 'ayesha.mirza@tradeinsight.com', 'hashed_ayesha_9928', '2023-01-01 00:00:00'),
  (13, 'Rida Rafiq', 'rida.rafiq@tradeinsight.com', 'hashed_rida_4611', '2023-01-16 00:00:00'),
  (14, 'Ali Naqvi', 'ali.naqvi@tradeinsight.com', 'hashed_ali_5557', '2022-06-04 00:00:00'),
  (15, 'Tariq Abbasi', 'tariq.abbasi@tradeinsight.com', 'hashed_tariq_3615', '2023-05-24 00:00:00'),
  (16, 'Hassan Farooqi', 'hassan.farooqi@tradeinsight.com', 'hashed_hassan_7924', '2022-11-22 00:00:00'),
  (17, 'Imran Butt', 'imran.butt@tradeinsight.com', 'hashed_imran_5552', '2022-08-19 00:00:00'),
  (18, 'Sana Rizvi', 'sana.rizvi@tradeinsight.com', 'hashed_sana_4527', '2023-06-26 00:00:00'),
  (19, 'Kamran Javed', 'kamran.javed@tradeinsight.com', 'hashed_kamran_6514', '2022-07-23 00:00:00'),
  (20, 'Mariam Tahir', 'mariam.tahir@tradeinsight.com', 'hashed_mariam_2519', '2022-12-12 00:00:00');

-- ---------------------------------------------------------------------------
-- INSERT: strategies (10 rows)
-- ---------------------------------------------------------------------------
INSERT INTO strategies (StrategyID, StrategyName, Description) VALUES
  (1, 'Trend Following', 'Enter trades in the direction of the prevailing market trend using moving averages and momentum indicators.'),
  (2, 'Breakout Trading', 'Buy or sell when price breaks through a key support or resistance level with strong volume confirmation.'),
  (3, 'Scalping', 'Execute many small trades capturing minor price movements within very short timeframes.'),
  (4, 'Swing Trading', 'Hold positions for several days to capture medium-term price swings within a trend.'),
  (5, 'Mean Reversion', 'Bet that price will revert to its historical average after deviating significantly.'),
  (6, 'News Trading', 'Enter trades immediately following high-impact economic news releases or earnings announcements.'),
  (7, 'Range Trading', 'Buy at established support and sell at resistance in a clearly defined sideways market.'),
  (8, 'Position Trading', 'Long-term trades held for weeks or months based on fundamental and macro analysis.'),
  (9, 'VWAP Strategy', 'Use Volume Weighted Average Price as a benchmark to time intraday entries and exits.'),
  (10, 'RSI Divergence', 'Identify divergence between RSI oscillator and price action to anticipate reversals.');

-- ---------------------------------------------------------------------------
-- INSERT: assets (15 rows)
-- ---------------------------------------------------------------------------
INSERT INTO assets (AssetID, AssetName, MarketType) VALUES
  (1, 'EUR/USD', 'Forex'),
  (2, 'GBP/USD', 'Forex'),
  (3, 'USD/JPY', 'Forex'),
  (4, 'AUD/USD', 'Forex'),
  (5, 'USD/CHF', 'Forex'),
  (6, 'BTC/USD', 'Crypto'),
  (7, 'ETH/USD', 'Crypto'),
  (8, 'BNB/USD', 'Crypto'),
  (9, 'SOL/USD', 'Crypto'),
  (10, 'XRP/USD', 'Crypto'),
  (11, 'AAPL', 'Stock'),
  (12, 'TSLA', 'Stock'),
  (13, 'GOOGL', 'Stock'),
  (14, 'AMZN', 'Stock'),
  (15, 'MSFT', 'Stock');

-- ---------------------------------------------------------------------------
-- INSERT: trade_types (4 rows)
-- ---------------------------------------------------------------------------
INSERT INTO trade_types (TypeID, TypeName) VALUES
  (1, 'Long'),
  (2, 'Short'),
  (3, 'Options'),
  (4, 'Futures');

-- ---------------------------------------------------------------------------
-- INSERT: trades (80 rows)
-- ---------------------------------------------------------------------------
INSERT INTO trades (TradeID, UserID, StrategyID, AssetID, TypeID, EntryPrice, ExitPrice, Quantity, ProfitLoss, TradeDate) VALUES
  (1, 4, 6, 14, 3, 154.34, 151.32, 5, -15.1, '2023-05-08 00:00:00'),
  (2, 13, 2, 9, 3, 169.2928, 165.53, 10, -37.63, '2023-07-16 00:00:00'),
  (3, 3, 1, 11, 2, 186.38, 182.26, 200, -824.0, '2024-01-25 00:00:00'),
  (4, 9, 8, 11, 3, 149.76, 153.52, 25, 94.0, '2024-10-25 00:00:00'),
  (5, 3, 10, 11, 2, 172.05, 175.3, 0.1, 0.33, '2024-10-17 00:00:00'),
  (6, 18, 4, 11, 3, 190.57, 188.74, 100, -183.0, '2023-11-20 00:00:00'),
  (7, 13, 5, 2, 2, 1.2931, 1.2681, 1000, -25.0, '2024-11-02 00:00:00'),
  (8, 16, 7, 15, 4, 300.0, 308.2, 5, 41.0, '2023-09-27 00:00:00'),
  (9, 19, 7, 15, 4, 330.68, 328.11, 2, -5.14, '2023-04-04 00:00:00'),
  (10, 2, 2, 3, 2, 145.8416, 146.8488, 1, 1.01, '2024-09-02 00:00:00'),
  (11, 15, 9, 5, 1, 0.9276, 0.9569, 0.1, 0.0, '2024-10-18 00:00:00'),
  (12, 11, 2, 5, 4, 0.8911, 0.9149, 0.1, 0.0, '2024-05-27 00:00:00'),
  (13, 6, 9, 15, 1, 401.87, 411.58, 10, 97.1, '2023-07-23 00:00:00'),
  (14, 5, 6, 13, 2, 141.58, 139.37, 100, -221.0, '2024-09-05 00:00:00'),
  (15, 11, 8, 1, 1, 1.115, 1.0909, 0.1, -0.0, '2023-09-03 00:00:00'),
  (16, 2, 4, 15, 1, 291.99, 294.06, 5, 10.35, '2023-05-09 00:00:00'),
  (17, 5, 8, 9, 2, 67.7102, 66.8, 1000, -910.2, '2024-07-06 00:00:00'),
  (18, 7, 5, 7, 3, 2376.2002, 2396.71, 1000, 20509.8, '2023-03-07 00:00:00'),
  (19, 11, 1, 10, 2, 0.6354, 0.65, 100, 1.46, '2023-08-23 00:00:00'),
  (20, 3, 1, 14, 3, 106.38, 109.05, 1000, 2670.0, '2024-07-06 00:00:00'),
  (21, 5, 10, 10, 4, 0.4972, 0.51, 200, 2.56, '2023-04-10 00:00:00'),
  (22, 14, 6, 7, 4, 2434.0493, 2389.1, 25, -1123.73, '2023-04-11 00:00:00'),
  (23, 2, 7, 12, 3, 254.08, 256.81, 5, 13.65, '2024-04-04 00:00:00'),
  (24, 5, 7, 3, 3, 139.2526, 138.3464, 5, -4.53, '2023-04-11 00:00:00'),
  (25, 2, 9, 14, 1, 187.21, 183.1, 500, -2055.0, '2024-02-21 00:00:00'),
  (26, 16, 8, 4, 4, 0.6932, 0.6967, 1, 0.0, '2023-09-29 00:00:00'),
  (27, 15, 5, 7, 4, 1809.5937, 1871.23, 10, 616.36, '2024-07-09 00:00:00'),
  (28, 2, 6, 1, 1, 1.0909, 1.1243, 500, 16.7, '2023-02-28 00:00:00'),
  (29, 17, 2, 14, 2, 106.17, 109.45, 1, 3.28, '2023-05-03 00:00:00'),
  (30, 19, 4, 10, 1, 0.6478, 0.66, 5, 0.06, '2023-11-20 00:00:00'),
  (31, 9, 4, 11, 3, 154.32, 158.2, 0.1, 0.39, '2024-04-13 00:00:00'),
  (32, 11, 2, 1, 4, 1.0935, 1.0858, 5, -0.04, '2023-08-07 00:00:00'),
  (33, 17, 5, 3, 3, 147.6173, 145.7882, 500, -914.55, '2024-03-24 00:00:00'),
  (34, 18, 5, 10, 1, 0.6671, 0.65, 200, -3.42, '2023-05-18 00:00:00'),
  (35, 9, 2, 15, 1, 383.94, 389.11, 1000, 5170.0, '2023-12-18 00:00:00'),
  (36, 7, 5, 9, 4, 65.2018, 64.81, 25, -9.8, '2024-03-09 00:00:00'),
  (37, 9, 1, 1, 3, 1.104, 1.0927, 2, -0.02, '2024-07-18 00:00:00'),
  (38, 14, 9, 1, 1, 1.0553, 1.0309, 5, -0.12, '2023-02-06 00:00:00'),
  (39, 12, 10, 9, 2, 97.3616, 98.91, 100, 154.84, '2024-01-02 00:00:00'),
  (40, 7, 4, 11, 1, 161.22, 157.59, 10, -36.3, '2023-06-08 00:00:00'),
  (41, 8, 3, 13, 2, 155.26, 159.47, 0.5, 2.11, '2024-02-26 00:00:00'),
  (42, 8, 5, 3, 1, 137.6508, 140.2828, 1000, 2632.0, '2024-04-16 00:00:00'),
  (43, 12, 5, 14, 2, 120.06, 118.5, 0.1, -0.16, '2023-03-13 00:00:00'),
  (44, 9, 6, 11, 4, 180.77, 178.67, 100, -210.0, '2023-04-29 00:00:00'),
  (45, 9, 3, 10, 3, 0.4153, 0.41, 0.5, -0.0, '2024-03-22 00:00:00'),
  (46, 20, 9, 2, 4, 1.292, 1.3002, 1, 0.01, '2023-01-02 00:00:00'),
  (47, 17, 9, 11, 2, 161.85, 165.88, 0.5, 2.02, '2024-09-30 00:00:00'),
  (48, 11, 2, 12, 3, 215.93, 213.44, 0.1, -0.25, '2024-07-21 00:00:00'),
  (49, 5, 4, 7, 4, 2854.6359, 2805.22, 0.1, -4.94, '2024-02-20 00:00:00'),
  (50, 18, 1, 5, 3, 0.8947, 0.8794, 0.5, -0.01, '2024-04-21 00:00:00'),
  (51, 15, 8, 11, 2, 170.67, 166.54, 500, -2065.0, '2024-11-05 00:00:00'),
  (52, 3, 5, 9, 3, 36.8097, 36.45, 0.1, -0.04, '2023-08-19 00:00:00'),
  (53, 7, 3, 1, 1, 1.0671, 1.0996, 200, 6.5, '2024-04-11 00:00:00'),
  (54, 14, 10, 4, 4, 0.6646, 0.681, 100, 1.64, '2023-04-20 00:00:00'),
  (55, 14, 4, 3, 4, 131.0044, 134.9935, 2, 7.98, '2023-05-17 00:00:00'),
  (56, 15, 9, 9, 3, 191.0071, 187.71, 5, -16.49, '2024-03-12 00:00:00'),
  (57, 18, 8, 15, 2, 384.11, 389.02, 1000, 4910.0, '2024-10-14 00:00:00'),
  (58, 9, 9, 8, 2, 268.6494, 272.3, 0.1, 0.37, '2023-12-10 00:00:00'),
  (59, 11, 9, 2, 2, 1.2321, 1.2439, 1000, 11.8, '2023-03-07 00:00:00'),
  (60, 14, 7, 6, 4, 41630.9694, 42363.85, 10, 7328.81, '2024-12-13 00:00:00'),
  (61, 1, 10, 7, 4, 1511.7922, 1553.52, 1, 41.73, '2024-07-05 00:00:00'),
  (62, 18, 10, 15, 2, 348.35, 355.17, 1, 6.82, '2023-12-11 00:00:00'),
  (63, 13, 3, 14, 4, 182.76, 179.89, 1, -2.87, '2024-08-29 00:00:00'),
  (64, 19, 1, 2, 4, 1.2309, 1.2389, 1, 0.01, '2023-12-02 00:00:00'),
  (65, 7, 8, 6, 3, 55449.1883, 56977.38, 1, 1528.19, '2023-09-16 00:00:00'),
  (66, 3, 8, 1, 1, 1.12, 1.1474, 25, 0.68, '2023-02-11 00:00:00'),
  (67, 1, 4, 4, 1, 0.6735, 0.6864, 200, 2.58, '2024-07-31 00:00:00'),
  (68, 7, 8, 12, 3, 249.7, 255.5, 200, 1160.0, '2023-06-17 00:00:00'),
  (69, 10, 2, 10, 1, 0.7716, 0.75, 1, -0.02, '2024-02-11 00:00:00'),
  (70, 7, 2, 10, 2, 0.4408, 0.43, 10, -0.11, '2023-05-04 00:00:00'),
  (71, 19, 1, 6, 4, 51460.8536, 52717.85, 100, 125699.64, '2024-03-06 00:00:00'),
  (72, 16, 2, 7, 3, 2771.1702, 2718.11, 1, -53.06, '2023-06-30 00:00:00'),
  (73, 17, 5, 10, 4, 0.5859, 0.58, 0.5, -0.0, '2023-09-09 00:00:00'),
  (74, 3, 5, 15, 4, 314.14, 321.46, 1, 7.32, '2023-12-11 00:00:00'),
  (75, 1, 8, 14, 3, 116.37, 119.74, 0.5, 1.68, '2023-10-14 00:00:00'),
  (76, 20, 5, 9, 1, 112.9929, 114.38, 1, 1.39, '2024-05-15 00:00:00'),
  (77, 18, 4, 12, 4, 233.97, 240.71, 200, 1348.0, '2023-10-29 00:00:00'),
  (78, 8, 7, 12, 2, 189.81, 187.06, 5, -13.75, '2023-12-19 00:00:00'),
  (79, 14, 9, 6, 3, 53114.1977, 53780.36, 200, 133232.46, '2023-07-17 00:00:00'),
  (80, 11, 2, 12, 2, 174.9, 173.06, 10, -18.4, '2024-06-21 00:00:00');

-- ---------------------------------------------------------------------------
-- INSERT: journal_notes (60 rows)
-- ---------------------------------------------------------------------------
INSERT INTO journal_notes (NoteID, TradeID, NoteText, Emotion) VALUES
  (1, 77, 'Woke up early for the London open and the setup was exactly as expected.', 'Focused'),
  (2, 37, 'Macro environment is tough. Reduced position size to stay conservative.', 'Cautious'),
  (3, 13, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (4, 25, 'Woke up early for the London open and the setup was exactly as expected.', 'Focused'),
  (5, 38, 'Reviewed my last 10 trades before this one. Much more prepared.', 'Analytical'),
  (6, 30, 'Felt rushed going in. The setup was not 100% there but took the trade anyway.', 'Anxious'),
  (7, 47, 'Reviewed my last 10 trades before this one. Much more prepared.', 'Analytical'),
  (8, 23, 'Held too long hoping for more profit. Should have respected my take-profit level.', 'Greedy'),
  (9, 39, 'Revenge traded after a losing session. Doubled down and made it worse.', 'Impulsive'),
  (10, 2, 'Revenge traded after a losing session. Doubled down and made it worse.', 'Impulsive'),
  (11, 69, 'Emotionally difficult session. Three losses in a row really tested my patience.', 'Stressed'),
  (12, 17, 'Great trade. The trend continuation signal was clean and execution was smooth.', 'Happy'),
  (13, 36, 'News came out unexpected and hit my stop. Nothing I could have done differently.', 'Frustrated'),
  (14, 6, 'Perfect execution. Used VWAP as a guide and the trade played out textbook.', 'Proud'),
  (15, 7, 'News came out unexpected and hit my stop. Nothing I could have done differently.', 'Frustrated'),
  (16, 76, 'Felt overconfident after a winning streak and sized up too large.', 'Overconfident'),
  (17, 70, 'Great trade. The trend continuation signal was clean and execution was smooth.', 'Happy'),
  (18, 41, 'News came out unexpected and hit my stop. Nothing I could have done differently.', 'Frustrated'),
  (19, 56, 'Followed the plan perfectly. Entered at the breakout and exited with discipline.', 'Confident'),
  (20, 49, 'Macro environment is tough. Reduced position size to stay conservative.', 'Cautious'),
  (21, 32, 'Took profits too early. The trend continued for another 200 pips.', 'Regretful'),
  (22, 66, 'Reviewed my last 10 trades before this one. Much more prepared.', 'Analytical'),
  (23, 62, 'Broke my own rule about trading on Mondays. Paid the price.', 'Disciplined'),
  (24, 1, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (25, 79, 'Felt rushed going in. The setup was not 100% there but took the trade anyway.', 'Anxious'),
  (26, 19, 'Perfect execution. Used VWAP as a guide and the trade played out textbook.', 'Proud'),
  (27, 31, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (28, 54, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (29, 29, 'Took profits too early. The trend continued for another 200 pips.', 'Regretful'),
  (30, 22, 'Great trade. The trend continuation signal was clean and execution was smooth.', 'Happy'),
  (31, 12, 'Perfect execution. Used VWAP as a guide and the trade played out textbook.', 'Proud'),
  (32, 4, 'Emotionally difficult session. Three losses in a row really tested my patience.', 'Stressed'),
  (33, 64, 'Woke up early for the London open and the setup was exactly as expected.', 'Focused'),
  (34, 53, 'Revenge traded after a losing session. Doubled down and made it worse.', 'Impulsive'),
  (35, 8, 'Macro environment is tough. Reduced position size to stay conservative.', 'Cautious'),
  (36, 5, 'Held too long hoping for more profit. Should have respected my take-profit level.', 'Greedy'),
  (37, 26, 'Felt overconfident after a winning streak and sized up too large.', 'Overconfident'),
  (38, 60, 'Perfect execution. Used VWAP as a guide and the trade played out textbook.', 'Proud'),
  (39, 45, 'Cut the loss quickly. No regrets — capital preservation is the priority.', 'Calm'),
  (40, 58, 'Emotionally difficult session. Three losses in a row really tested my patience.', 'Stressed'),
  (41, 61, 'Cut the loss quickly. No regrets — capital preservation is the priority.', 'Calm'),
  (42, 10, 'Great trade. The trend continuation signal was clean and execution was smooth.', 'Happy'),
  (43, 72, 'Felt rushed going in. The setup was not 100% there but took the trade anyway.', 'Anxious'),
  (44, 63, 'News came out unexpected and hit my stop. Nothing I could have done differently.', 'Frustrated'),
  (45, 20, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (46, 67, 'Reviewed my last 10 trades before this one. Much more prepared.', 'Analytical'),
  (47, 16, 'Woke up early for the London open and the setup was exactly as expected.', 'Focused'),
  (48, 46, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (49, 27, 'Took profits too early. The trend continued for another 200 pips.', 'Regretful'),
  (50, 68, 'Held too long hoping for more profit. Should have respected my take-profit level.', 'Greedy'),
  (51, 74, 'Took profits too early. The trend continued for another 200 pips.', 'Regretful'),
  (52, 44, 'The RSI divergence setup was textbook. Entry and exit both timed well.', 'Satisfied'),
  (53, 75, 'Distracted during this trade. Should have waited for better confirmation.', 'Unfocused'),
  (54, 33, 'Emotionally difficult session. Three losses in a row really tested my patience.', 'Stressed'),
  (55, 80, 'This setup reminded me why I love breakout trading. Clean and decisive.', 'Excited'),
  (56, 48, 'Felt overconfident after a winning streak and sized up too large.', 'Overconfident'),
  (57, 78, 'Broke my own rule about trading on Mondays. Paid the price.', 'Disciplined'),
  (58, 15, 'Took profits too early. The trend continued for another 200 pips.', 'Regretful'),
  (59, 73, 'Great trade. The trend continuation signal was clean and execution was smooth.', 'Happy'),
  (60, 65, 'Reviewed my last 10 trades before this one. Much more prepared.', 'Analytical');

-- ---------------------------------------------------------------------------
-- EXAMPLE: UPDATE with WHERE condition
-- Scenario: A user realized they entered the wrong exit price on trade #5.
--           They re-calculate and update the record.
-- ---------------------------------------------------------------------------
UPDATE trades
SET    ExitPrice  = 1.0987,
       ProfitLoss = ROUND((1.0987 - EntryPrice) * Quantity, 2)
WHERE  TradeID = 5;

-- Scenario: Bulk update — mark all trades before 2023-06-01 as archived
--           by adding a flag. (Illustrative: requires adding an IsArchived column)
-- UPDATE trades SET IsArchived = 1 WHERE TradeDate < '2023-06-01';


-- ---------------------------------------------------------------------------
-- EXAMPLE: DELETE with WHERE condition
-- Scenario: User #3 decides to remove a journal note they find inaccurate.
-- ---------------------------------------------------------------------------
DELETE FROM journal_notes
WHERE  NoteID = 10;

-- Scenario: Remove all trades for a test user account before launch
-- DELETE FROM trades WHERE UserID = 20;   -- Journal notes cascade automatically


-- ---------------------------------------------------------------------------
-- Commit all changes
-- ---------------------------------------------------------------------------
COMMIT;

SET autocommit = 1;

-- Final row counts to confirm successful load
SELECT 'users'         AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'strategies',   COUNT(*) FROM strategies
UNION ALL
SELECT 'assets',       COUNT(*) FROM assets
UNION ALL
SELECT 'trade_types',  COUNT(*) FROM trade_types
UNION ALL
SELECT 'trades',       COUNT(*) FROM trades
UNION ALL
SELECT 'journal_notes',COUNT(*) FROM journal_notes;
