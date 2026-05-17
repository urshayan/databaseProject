-- =============================================================================
-- TradeInsight — Trading Journal & Performance Analysis System
-- Milestone 4: Database Definition Language (DDL) Script
-- =============================================================================
-- Project  : TradeInsight
-- Team     : Shayan Ijaz · Huzaima Zakir
-- Instructor: Ali Hassan
-- Database : MySQL 8.0+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Create and select the database
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS tradeinsight_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tradeinsight_db;

-- -----------------------------------------------------------------------------
-- Drop tables in reverse dependency order for clean re-runs
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS journal_notes;
DROP TABLE IF EXISTS trades;
DROP TABLE IF EXISTS trade_types;
DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS strategies;
DROP TABLE IF EXISTS users;


-- =============================================================================
-- TABLE: users
-- Description: Stores registered trader accounts.
-- Each user has a unique email address and a hashed password.
-- =============================================================================
CREATE TABLE users (
    UserID      INT             NOT NULL AUTO_INCREMENT,
    Name        VARCHAR(100)    NOT NULL,
    Email       VARCHAR(150)    NOT NULL,
    Password    VARCHAR(255)    NOT NULL,
    CreatedAt   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_users        PRIMARY KEY (UserID),
    CONSTRAINT uq_users_email  UNIQUE      (Email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Registered trader accounts';

-- Index on CreatedAt for time-range queries on user acquisition
CREATE INDEX idx_users_createdat ON users (CreatedAt);


-- =============================================================================
-- TABLE: strategies
-- Description: Named trading strategies with a human-readable description.
-- Separated from TRADES to eliminate redundancy of strategy text.
-- =============================================================================
CREATE TABLE strategies (
    StrategyID    INT          NOT NULL AUTO_INCREMENT,
    StrategyName  VARCHAR(100) NOT NULL,
    Description   TEXT         NULL,

    CONSTRAINT pk_strategies           PRIMARY KEY (StrategyID),
    CONSTRAINT uq_strategies_name      UNIQUE      (StrategyName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Named trading strategies applied to trades';


-- =============================================================================
-- TABLE: assets
-- Description: Tradeable financial instruments.
-- MarketType is constrained to exactly three categories.
-- =============================================================================
CREATE TABLE assets (
    AssetID     INT          NOT NULL AUTO_INCREMENT,
    AssetName   VARCHAR(50)  NOT NULL,
    MarketType  VARCHAR(30)  NOT NULL,

    CONSTRAINT pk_assets              PRIMARY KEY (AssetID),
    CONSTRAINT uq_assets_name         UNIQUE      (AssetName),
    CONSTRAINT chk_assets_markettype  CHECK       (MarketType IN ('Forex', 'Crypto', 'Stock'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tradeable instruments: Forex pairs, cryptocurrencies, and stocks';

-- Index on MarketType for filtering by market category in reports
CREATE INDEX idx_assets_markettype ON assets (MarketType);


-- =============================================================================
-- TABLE: trade_types
-- Description: Classification of the trade position type.
-- Values: Long, Short, Options, Futures
-- =============================================================================
CREATE TABLE trade_types (
    TypeID    INT         NOT NULL AUTO_INCREMENT,
    TypeName  VARCHAR(50) NOT NULL,

    CONSTRAINT pk_trade_types       PRIMARY KEY (TypeID),
    CONSTRAINT uq_trade_types_name  UNIQUE      (TypeName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Trade position type classifications';


-- =============================================================================
-- TABLE: trades
-- Description: Core fact table — one row per completed trade.
-- References users, strategies, assets, and trade_types via foreign keys.
-- ProfitLoss is stored as a materialized computed column for query performance.
-- =============================================================================
CREATE TABLE trades (
    TradeID     INT             NOT NULL AUTO_INCREMENT,
    UserID      INT             NOT NULL,
    StrategyID  INT             NOT NULL,
    AssetID     INT             NOT NULL,
    TypeID      INT             NOT NULL,
    EntryPrice  DECIMAL(15, 4)  NOT NULL,
    ExitPrice   DECIMAL(15, 4)  NOT NULL,
    Quantity    DECIMAL(15, 4)  NOT NULL,
    ProfitLoss  DECIMAL(15, 2)  NOT NULL,
    TradeDate   DATETIME        NOT NULL,

    CONSTRAINT pk_trades          PRIMARY KEY (TradeID),
    CONSTRAINT fk_trades_user     FOREIGN KEY (UserID)     REFERENCES users(UserID)       ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trades_strategy FOREIGN KEY (StrategyID) REFERENCES strategies(StrategyID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trades_asset    FOREIGN KEY (AssetID)    REFERENCES assets(AssetID)     ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trades_type     FOREIGN KEY (TypeID)     REFERENCES trade_types(TypeID) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT chk_trades_quantity    CHECK (Quantity > 0),
    CONSTRAINT chk_trades_entryprice  CHECK (EntryPrice > 0),
    CONSTRAINT chk_trades_exitprice   CHECK (ExitPrice > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Core trade records with entry/exit prices and profit/loss';

-- Index on UserID — most queries filter by user
CREATE INDEX idx_trades_userid    ON trades (UserID);

-- Index on TradeDate — date-range queries for performance reports
CREATE INDEX idx_trades_tradedate ON trades (TradeDate);

-- Index on AssetID — filtering trades by asset
CREATE INDEX idx_trades_assetid   ON trades (AssetID);

-- Index on StrategyID — analytics grouped by strategy
CREATE INDEX idx_trades_strategyid ON trades (StrategyID);

-- Composite index for the most common dashboard query: user trades in a date range
CREATE INDEX idx_trades_user_date ON trades (UserID, TradeDate);


-- =============================================================================
-- TABLE: journal_notes
-- Description: Personal reflections and emotional observations linked to trades.
-- A trade can have multiple notes; each note belongs to exactly one trade.
-- =============================================================================
CREATE TABLE journal_notes (
    NoteID    INT          NOT NULL AUTO_INCREMENT,
    TradeID   INT          NOT NULL,
    NoteText  TEXT         NOT NULL,
    Emotion   VARCHAR(50)  NULL,

    CONSTRAINT pk_journal_notes       PRIMARY KEY (NoteID),
    CONSTRAINT fk_journal_notes_trade FOREIGN KEY (TradeID) REFERENCES trades(TradeID)
        ON DELETE CASCADE ON UPDATE CASCADE

    -- Note: ON DELETE CASCADE is intentional — deleting a trade should remove its notes.
    -- This differs from trades→users (RESTRICT) because notes are subordinate records.
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Reflective trade journal entries with emotional tagging';

-- Index on TradeID — joining notes to trades is a frequent operation
CREATE INDEX idx_journal_tradeid ON journal_notes (TradeID);

-- Index on Emotion — allows filtering/grouping by emotional state
CREATE INDEX idx_journal_emotion ON journal_notes (Emotion);


-- =============================================================================
-- EER (Enhanced Entity-Relationship) Diagram Notes
-- =============================================================================
-- The EER diagram for this schema would show the following:
--
-- Entities (strong):    USERS, STRATEGIES, ASSETS, TRADE_TYPES
-- Entity (strong):      TRADES (participates in four binary relationships)
-- Entity (weak):        JOURNAL_NOTES (existence depends on TRADES)
--
-- Specialization:       ASSETS can be specialized into Forex, Crypto, Stock
--                       (this is handled via the MarketType attribute rather than
--                        separate subtables, as the attributes do not differ
--                        between subclasses — a pragmatic design choice)
--
-- Relationships:
--   USERS      1 ──<  TRADES           (one user, many trades)
--   STRATEGIES 1 ──<  TRADES           (one strategy, many trades)
--   ASSETS     1 ──<  TRADES           (one asset, many trades)
--   TRADE_TYPES 1 ──< TRADES           (one type, many trades)
--   TRADES     1 ──<  JOURNAL_NOTES    (one trade, many notes)
--
-- All relationships on the TRADES side use RESTRICT to protect data integrity,
-- except TRADES→JOURNAL_NOTES which uses CASCADE (notes follow their trade).
-- =============================================================================

-- Verify schema creation
SELECT TABLE_NAME, TABLE_ROWS, TABLE_COMMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'tradeinsight_db'
ORDER BY TABLE_NAME;
