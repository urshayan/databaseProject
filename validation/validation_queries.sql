-- =============================================================================
-- TradeInsight — Trading Journal & Performance Analysis System
-- Milestone 5: Validation Queries
-- =============================================================================
-- Project  : TradeInsight
-- Team     : Shayan Ijaz · Huzaima Zakir
-- Instructor: Ali Hassan
-- =============================================================================
-- Run AFTER populate.sql to verify data integrity and completeness.
-- Expected outputs are documented in comments next to each query.
-- =============================================================================

USE tradeinsight_db;

-- =============================================================================
-- SECTION 1: Row Count Verification
-- Confirms all rows from the dataset were successfully loaded.
-- =============================================================================

-- Expected: 20
SELECT 'USERS ROW COUNT' AS check_name, COUNT(*) AS result FROM users;

-- Expected: 10
SELECT 'STRATEGIES ROW COUNT' AS check_name, COUNT(*) AS result FROM strategies;

-- Expected: 15
SELECT 'ASSETS ROW COUNT' AS check_name, COUNT(*) AS result FROM assets;

-- Expected: 4
SELECT 'TRADE_TYPES ROW COUNT' AS check_name, COUNT(*) AS result FROM trade_types;

-- Expected: 80
SELECT 'TRADES ROW COUNT' AS check_name, COUNT(*) AS result FROM trades;

-- Expected: 59 (60 inserted, 1 deleted in populate.sql)
SELECT 'JOURNAL_NOTES ROW COUNT' AS check_name, COUNT(*) AS result FROM journal_notes;


-- =============================================================================
-- SECTION 2: NULL Checks on Mandatory Columns
-- All NOT NULL constrained columns should return 0.
-- =============================================================================

SELECT 'NULL check: users.Name'       AS check_name, COUNT(*) AS nulls FROM users         WHERE Name       IS NULL;
SELECT 'NULL check: users.Email'      AS check_name, COUNT(*) AS nulls FROM users         WHERE Email      IS NULL;
SELECT 'NULL check: users.Password'   AS check_name, COUNT(*) AS nulls FROM users         WHERE Password   IS NULL;
SELECT 'NULL check: trades.EntryPrice'AS check_name, COUNT(*) AS nulls FROM trades        WHERE EntryPrice IS NULL;
SELECT 'NULL check: trades.ExitPrice' AS check_name, COUNT(*) AS nulls FROM trades        WHERE ExitPrice  IS NULL;
SELECT 'NULL check: trades.Quantity'  AS check_name, COUNT(*) AS nulls FROM trades        WHERE Quantity   IS NULL;
SELECT 'NULL check: trades.ProfitLoss'AS check_name, COUNT(*) AS nulls FROM trades        WHERE ProfitLoss IS NULL;
SELECT 'NULL check: journal.NoteText' AS check_name, COUNT(*) AS nulls FROM journal_notes WHERE NoteText   IS NULL;

-- Expected output: all rows return nulls = 0


-- =============================================================================
-- SECTION 3: Foreign Key Integrity Checks via JOINs
-- Orphaned records (FKs with no matching parent) would show up as non-zero.
-- =============================================================================

-- 3.1 Every UserID in TRADES must exist in USERS
SELECT 'FK integrity: trades.UserID → users' AS check_name,
       COUNT(*) AS orphaned_records
FROM   trades t
LEFT JOIN users u ON t.UserID = u.UserID
WHERE  u.UserID IS NULL;
-- Expected: 0

-- 3.2 Every StrategyID in TRADES must exist in STRATEGIES
SELECT 'FK integrity: trades.StrategyID → strategies' AS check_name,
       COUNT(*) AS orphaned_records
FROM   trades t
LEFT JOIN strategies s ON t.StrategyID = s.StrategyID
WHERE  s.StrategyID IS NULL;
-- Expected: 0

-- 3.3 Every AssetID in TRADES must exist in ASSETS
SELECT 'FK integrity: trades.AssetID → assets' AS check_name,
       COUNT(*) AS orphaned_records
FROM   trades t
LEFT JOIN assets a ON t.AssetID = a.AssetID
WHERE  a.AssetID IS NULL;
-- Expected: 0

-- 3.4 Every TypeID in TRADES must exist in TRADE_TYPES
SELECT 'FK integrity: trades.TypeID → trade_types' AS check_name,
       COUNT(*) AS orphaned_records
FROM   trades t
LEFT JOIN trade_types tt ON t.TypeID = tt.TypeID
WHERE  tt.TypeID IS NULL;
-- Expected: 0

-- 3.5 Every TradeID in JOURNAL_NOTES must exist in TRADES
SELECT 'FK integrity: journal_notes.TradeID → trades' AS check_name,
       COUNT(*) AS orphaned_records
FROM   journal_notes jn
LEFT JOIN trades t ON jn.TradeID = t.TradeID
WHERE  t.TradeID IS NULL;
-- Expected: 0


-- =============================================================================
-- SECTION 4: Business Rule Validation
-- Domain-specific checks that go beyond database constraints.
-- =============================================================================

-- 4.1 No trade should have Quantity = 0 or negative
SELECT 'Business rule: Quantity > 0' AS check_name,
       COUNT(*) AS violations
FROM   trades
WHERE  Quantity <= 0;
-- Expected: 0

-- 4.2 No trade should have EntryPrice = 0
SELECT 'Business rule: EntryPrice > 0' AS check_name,
       COUNT(*) AS violations
FROM   trades
WHERE  EntryPrice <= 0;
-- Expected: 0

-- 4.3 No trade should have ExitPrice = 0
SELECT 'Business rule: ExitPrice > 0' AS check_name,
       COUNT(*) AS violations
FROM   trades
WHERE  ExitPrice <= 0;
-- Expected: 0

-- 4.4 ProfitLoss sign consistency check
-- For Long trades: ProfitLoss should be positive when ExitPrice > EntryPrice
SELECT 'Business rule: Long trade P/L consistency' AS check_name,
       COUNT(*) AS inconsistencies
FROM   trades
WHERE  TypeID = 1   -- TypeID 1 = 'Long'
  AND  ExitPrice > EntryPrice
  AND  ProfitLoss < 0;
-- Expected: 0

-- 4.5 Every user must have a unique email (spot-check on top of UNIQUE constraint)
SELECT 'Uniqueness: users.Email' AS check_name,
       COUNT(*) AS duplicates
FROM (
    SELECT Email, COUNT(*) AS cnt
    FROM   users
    GROUP  BY Email
    HAVING cnt > 1
) AS dup_emails;
-- Expected: 0


-- =============================================================================
-- SECTION 5: Analytical Validation Queries
-- These double as useful business queries for the dashboard.
-- =============================================================================

-- 5.1 Total profit/loss per user (top 10)
SELECT u.UserID,
       u.Name,
       COUNT(t.TradeID)          AS total_trades,
       SUM(t.ProfitLoss)         AS total_pl,
       ROUND(AVG(t.ProfitLoss),2)AS avg_pl,
       SUM(CASE WHEN t.ProfitLoss > 0 THEN 1 ELSE 0 END) AS wins,
       SUM(CASE WHEN t.ProfitLoss < 0 THEN 1 ELSE 0 END) AS losses
FROM   users u
JOIN   trades t ON u.UserID = t.UserID
GROUP  BY u.UserID, u.Name
ORDER  BY total_pl DESC
LIMIT  10;

-- 5.2 Performance breakdown by market type
SELECT a.MarketType,
       COUNT(t.TradeID)           AS total_trades,
       ROUND(SUM(t.ProfitLoss),2) AS total_pl,
       ROUND(AVG(t.ProfitLoss),2) AS avg_pl
FROM   trades t
JOIN   assets a ON t.AssetID = a.AssetID
GROUP  BY a.MarketType
ORDER  BY total_pl DESC;

-- 5.3 Strategy effectiveness ranking
SELECT s.StrategyName,
       COUNT(t.TradeID)           AS times_used,
       ROUND(SUM(t.ProfitLoss),2) AS total_pl,
       ROUND(AVG(t.ProfitLoss),2) AS avg_pl,
       ROUND(
           100.0 * SUM(CASE WHEN t.ProfitLoss > 0 THEN 1 ELSE 0 END) / COUNT(*), 1
       )                          AS win_rate_pct
FROM   strategies s
JOIN   trades t ON s.StrategyID = t.StrategyID
GROUP  BY s.StrategyID, s.StrategyName
ORDER  BY avg_pl DESC;

-- 5.4 Most common emotions in winning vs losing trades
SELECT jn.Emotion,
       SUM(CASE WHEN t.ProfitLoss > 0 THEN 1 ELSE 0 END) AS win_count,
       SUM(CASE WHEN t.ProfitLoss < 0 THEN 1 ELSE 0 END) AS loss_count,
       COUNT(*) AS total_notes
FROM   journal_notes jn
JOIN   trades t ON jn.TradeID = t.TradeID
WHERE  jn.Emotion IS NOT NULL
GROUP  BY jn.Emotion
ORDER  BY total_notes DESC;

-- 5.5 Full trade detail view with all joined information
SELECT  t.TradeID,
        u.Name              AS Trader,
        a.AssetName         AS Asset,
        a.MarketType,
        s.StrategyName      AS Strategy,
        tt.TypeName         AS TradeType,
        t.EntryPrice,
        t.ExitPrice,
        t.Quantity,
        t.ProfitLoss,
        t.TradeDate,
        jn.NoteText         AS JournalNote,
        jn.Emotion
FROM    trades t
JOIN    users       u  ON t.UserID     = u.UserID
JOIN    assets      a  ON t.AssetID    = a.AssetID
JOIN    strategies  s  ON t.StrategyID = s.StrategyID
JOIN    trade_types tt ON t.TypeID     = tt.TypeID
LEFT JOIN journal_notes jn ON t.TradeID = jn.TradeID
ORDER  BY t.TradeDate DESC
LIMIT  20;

-- 5.6 Monthly P/L summary
SELECT  DATE_FORMAT(TradeDate, '%Y-%m') AS month,
        COUNT(*)                        AS trades,
        ROUND(SUM(ProfitLoss), 2)       AS monthly_pl
FROM    trades
GROUP   BY DATE_FORMAT(TradeDate, '%Y-%m')
ORDER   BY month;
