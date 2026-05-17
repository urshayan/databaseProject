# TradeInsight: Trading Journal & Performance Analysis System
## Database Systems Lab — Full Project Report

---

**Course:** Database Systems Lab  
**Instructor:** Ali Hassan  
**Team Members:** Shayan Ijaz · Huzaima Zakir  
**Technology Stack:** Python Flask · MySQL · HTML · CSS · JavaScript  
**Repository:** github.com/your-username/TradeInsight  

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Milestone 1 — ERD & Relational Schema](#2-milestone-1--erd--relational-schema)
3. [Milestone 2 — Normalization](#3-milestone-2--normalization)
4. [Milestone 3 — Synthetic Dataset & Dataflow](#4-milestone-3--synthetic-dataset--dataflow)
5. [Milestone 4 — DDL Scripts & EER](#5-milestone-4--ddl-scripts--eer)
6. [Milestone 5 — DML & Validation](#6-milestone-5--dml--validation)
7. [Conclusion](#7-conclusion)

---

## 1. Project Overview

### 1.1 Background and Motivation

Trading in financial markets — whether forex, stocks, or cryptocurrency — demands rigorous self-analysis. The majority of retail traders who fail do so not because of a lack of market knowledge, but because of poor record-keeping and the absence of structured self-reflection. Without a systematic way to log trades and review performance, traders repeat the same mistakes, give in to the same emotional biases, and have no empirical basis for improving their strategies.

TradeInsight addresses this problem by providing a database-backed trading journal and performance analysis system. The system allows traders to record every trade they take, pair it with a reflective journal note, and analyze their performance across assets, strategies, and time periods.

### 1.2 Project Objectives

- Design a normalized relational database that accurately models the trading journal domain.
- Implement the schema using MySQL with proper constraints and indexes.
- Populate the database with a realistic synthetic dataset for demonstration.
- Build validation queries that confirm data integrity.
- Provide a foundation for a full-stack Flask web application.

### 1.3 Scope

The TradeInsight database system covers:

- **User management:** Registration and login for multiple traders.
- **Trade logging:** Recording entry price, exit price, quantity, asset, strategy, and trade type for every trade.
- **Profit/Loss tracking:** Calculated and stored per trade.
- **Journal entries:** Reflective notes with emotional tagging attached to individual trades.
- **Performance reporting:** Aggregated views by user, asset, strategy, and time period.

### 1.4 Technology Stack

| Layer       | Technology              | Role                                   |
|-------------|-------------------------|----------------------------------------|
| Frontend    | HTML, CSS, JavaScript   | User interface and dashboards          |
| Backend     | Python 3 / Flask        | REST API, business logic, session auth |
| Database    | MySQL 8.0               | Persistent data storage                |
| ORM/Driver  | Flask-MySQLdb / SQLAlchemy | Database connectivity               |
| Tools       | VS Code, GitHub, Postman | Development and version control        |

---

## 2. Milestone 1 — ERD & Relational Schema

### 2.1 Entity Identification

Analysis of the trading journal domain yielded six distinct entities:

1. **USERS** — The traders who use the system.
2. **STRATEGIES** — Named trading approaches (e.g., Trend Following, Scalping).
3. **ASSETS** — Financial instruments being traded (e.g., EUR/USD, BTC/USD, AAPL).
4. **TRADE_TYPES** — Classification of the position (Long, Short, Options, Futures).
5. **TRADES** — The central fact entity connecting all others.
6. **JOURNAL_NOTES** — Reflective notes associated with individual trades.

### 2.2 Relationship Summary

| Relationship | Cardinality | Mandatory |
|---|---|---|
| USERS ↔ TRADES | One-to-Many | A trade must belong to a user |
| STRATEGIES ↔ TRADES | One-to-Many | A trade must reference a strategy |
| ASSETS ↔ TRADES | One-to-Many | A trade must reference an asset |
| TRADE_TYPES ↔ TRADES | One-to-Many | A trade must have a type |
| TRADES ↔ JOURNAL_NOTES | One-to-Many | A note must belong to a trade |

### 2.3 Relational Schema (Formal)

```
USERS (
    UserID*    INT          PK AUTO_INCREMENT,
    Name       VARCHAR(100) NOT NULL,
    Email      VARCHAR(150) NOT NULL UNIQUE,
    Password   VARCHAR(255) NOT NULL,
    CreatedAt  DATETIME     NOT NULL
)

STRATEGIES (
    StrategyID*  INT          PK AUTO_INCREMENT,
    StrategyName VARCHAR(100) NOT NULL UNIQUE,
    Description  TEXT
)

ASSETS (
    AssetID*   INT         PK AUTO_INCREMENT,
    AssetName  VARCHAR(50) NOT NULL UNIQUE,
    MarketType VARCHAR(30) NOT NULL CHECK (IN 'Forex','Crypto','Stock')
)

TRADE_TYPES (
    TypeID*   INT         PK AUTO_INCREMENT,
    TypeName  VARCHAR(50) NOT NULL UNIQUE
)

TRADES (
    TradeID*    INT            PK AUTO_INCREMENT,
    UserID°     INT            FK → USERS
    StrategyID° INT            FK → STRATEGIES
    AssetID°    INT            FK → ASSETS
    TypeID°     INT            FK → TRADE_TYPES
    EntryPrice  DECIMAL(15,4)  NOT NULL CHECK > 0
    ExitPrice   DECIMAL(15,4)  NOT NULL CHECK > 0
    Quantity    DECIMAL(15,4)  NOT NULL CHECK > 0
    ProfitLoss  DECIMAL(15,2)  NOT NULL
    TradeDate   DATETIME       NOT NULL
)

JOURNAL_NOTES (
    NoteID*  INT         PK AUTO_INCREMENT,
    TradeID° INT         FK → TRADES
    NoteText TEXT        NOT NULL
    Emotion  VARCHAR(50)
)
```

> `*` = Primary Key · `°` = Foreign Key

### 2.4 Referential Integrity Decisions

All FK relationships on the TRADES table use `ON DELETE RESTRICT` — you cannot delete a user, strategy, asset, or trade type if trades reference them. This protects the historical record.

The FK on JOURNAL_NOTES uses `ON DELETE CASCADE` — when a trade is deleted, its associated notes are automatically removed. This is the correct semantic choice since notes have no meaningful existence without their parent trade.

---

## 3. Milestone 2 — Normalization

### 3.1 Pre-Normalization Flat Schema

Before normalization, a naive flat schema for this system might have been:

```
TRADING_LOG (
    TraderName, TraderEmail, TraderPassword,
    StrategyName, StrategyDescription,
    AssetName, MarketType, TradeTypeName,
    EntryPrice, ExitPrice, Quantity, ProfitLoss, TradeDate,
    JournalNote, Emotion
)
```

This single-table design suffers from severe redundancies and anomalies:

- **Update anomaly:** Changing a strategy description requires updating every trade row using that strategy.
- **Insert anomaly:** You cannot record an asset until a trade has been placed on it.
- **Delete anomaly:** Deleting all trades for a user also loses the user's account information.

Normalization resolves all of these.

### 3.2 First Normal Form (1NF)

**Rule:** All columns contain atomic, single-valued data; no repeating groups; a primary key exists.

The flat schema was decomposed by:
- Assigning surrogate integer primary keys to each entity (UserID, StrategyID, etc.)
- Ensuring every column holds exactly one value per row
- Extracting the multi-valued journal notes into a separate table (since one trade can have multiple notes, storing them in a single column would violate 1NF)

**Result:** All six tables satisfy 1NF.

### 3.3 Second Normal Form (2NF)

**Rule:** Must be in 1NF; every non-key attribute must be fully functionally dependent on the entire primary key (eliminates partial dependencies).

All six tables use single-column surrogate primary keys. When the primary key is a single attribute, partial dependency is structurally impossible — every non-key attribute must depend on the whole key by definition.

**Result:** All six tables satisfy 2NF automatically given single-column PKs.

### 3.4 Third Normal Form (3NF)

**Rule:** Must be in 2NF; no non-key attribute transitively depends on the PK through another non-key attribute.

Potential violations were examined in each table:

- **ASSETS:** `MarketType` could arguably be derived from `AssetName` (EUR/USD → Forex). We document this as a pragmatic design exception — the three-value domain is enforced via a CHECK constraint, and decomposing into a MARKET_TYPES table would add complexity without query benefit.

- **TRADES:** `ProfitLoss` is derived from `(ExitPrice - EntryPrice) × Quantity`. Storing a computed column is a common performance-driven denormalization, fully documented and enforced at the application layer.

All other attributes have direct, non-transitive dependencies on their respective PKs.

**Result:** All tables satisfy 3NF, with two documented and justified engineering trade-offs.

### 3.5 Summary

| Table         | 1NF | 2NF | 3NF | Structural Changes Made          |
|---------------|-----|-----|-----|----------------------------------|
| USERS         | ✅  | ✅  | ✅  | Separated from flat schema       |
| STRATEGIES    | ✅  | ✅  | ✅  | Separated from flat schema       |
| ASSETS        | ✅  | ✅  | ✅* | MarketType kept with note        |
| TRADE_TYPES   | ✅  | ✅  | ✅  | New lookup table                 |
| TRADES        | ✅  | ✅  | ✅* | ProfitLoss stored with note      |
| JOURNAL_NOTES | ✅  | ✅  | ✅  | Extracted from TRADES to allow 1:N |

---

## 4. Milestone 3 — Synthetic Dataset & Dataflow

### 4.1 Dataset Overview

A synthetic dataset of 195 total rows across six tables was generated using a seeded Python script to ensure reproducibility and consistency across all foreign key relationships.

| Table         | Rows | Key Design Decisions                        |
|---------------|------|---------------------------------------------|
| users         | 20   | Pakistani and international names; unique emails |
| strategies    | 10   | Real-world strategy names with accurate descriptions |
| assets        | 15   | 5 Forex + 5 Crypto + 5 Stock instruments    |
| trade_types   | 4    | Long, Short, Options, Futures               |
| trades        | 80   | Realistic prices, ~55% win rate, varied lot sizes |
| journal_notes | 60   | 20 reflective templates, 12 emotion categories |

### 4.2 Data Realism

**Price ranges by asset type:**

| Category | Example        | Entry Price Range  |
|----------|----------------|--------------------|
| Forex    | EUR/USD        | 1.05 – 1.12        |
| Forex    | USD/JPY        | 130 – 150          |
| Crypto   | BTC/USD        | $25,000 – $65,000  |
| Crypto   | ETH/USD        | $1,500 – $3,500    |
| Stock    | AAPL           | $140 – $200        |
| Stock    | TSLA           | $150 – $280        |

**Win/loss structure:** 55% winning trades (0.5%–3.5% favorable move), 45% losing trades (0.5%–2.5% adverse move). This reflects a realistically skilled but imperfect trader.

**Emotional distribution:** 12 emotional states sampled across journal notes, including Confident, Anxious, Greedy, Frustrated, Overconfident, and Analytical — representing the full spectrum of trader psychology.

### 4.3 System Data Flow

Data flows through three layers:

1. **Client Layer:** The trader fills HTML forms in their browser. Client-side JavaScript provides real-time P/L calculation previews and input validation.

2. **Application Layer:** Flask routes receive JSON payloads via HTTP. The server validates inputs, checks session authentication, enforces business rules (ownership checks, quantity > 0), computes authoritative P/L, and executes parameterized SQL queries.

3. **Database Layer:** MySQL stores the result. All writes use transactions; multi-step operations (e.g., insert trade + insert note) are atomic.

### 4.4 Data Preprocessing Assumptions

- Passwords are stored as simulated bcrypt hash strings (`hashed_<name>_<4digits>`).
- All timestamps are in `YYYY-MM-DD HH:MM:SS` format (MySQL DATETIME compatible).
- All numeric values use period (`.`) as decimal separator.
- All FK values were verified programmatically before CSV export — no orphaned records.

---

## 5. Milestone 4 — DDL Scripts & EER

### 5.1 Schema Design Highlights

The DDL script (`ddl/schema.sql`) creates the full database with the following features:

**AUTO_INCREMENT PKs:** All six tables use `AUTO_INCREMENT` integer surrogate keys, ensuring stable, index-friendly identifiers that are independent of business data.

**UNIQUE constraints:** Email in USERS, StrategyName in STRATEGIES, AssetName in ASSETS, and TypeName in TRADE_TYPES all carry UNIQUE constraints to prevent duplicates.

**CHECK constraints:**
- `assets.MarketType IN ('Forex', 'Crypto', 'Stock')` — enforces the closed category set
- `trades.Quantity > 0` — no zero-quantity trades allowed
- `trades.EntryPrice > 0` and `trades.ExitPrice > 0` — no zero-price records

**Indexes created:**

| Index                    | Table  | Columns             | Purpose                              |
|--------------------------|--------|---------------------|--------------------------------------|
| idx_users_createdat      | users  | CreatedAt           | User acquisition time-range queries  |
| idx_assets_markettype    | assets | MarketType          | Filter by Forex / Crypto / Stock     |
| idx_trades_userid        | trades | UserID              | Per-user trade retrieval             |
| idx_trades_tradedate     | trades | TradeDate           | Date-range performance reports       |
| idx_trades_assetid       | trades | AssetID             | Filter trades by asset               |
| idx_trades_strategyid    | trades | StrategyID          | Group by strategy for analytics      |
| idx_trades_user_date     | trades | (UserID, TradeDate) | Composite: user dashboard queries    |
| idx_journal_tradeid      | journal_notes | TradeID       | Join notes to trades                 |
| idx_journal_emotion      | journal_notes | Emotion       | Emotion-based analytics              |

**Referential Integrity:**
- All FK relationships on TRADES: `ON DELETE RESTRICT ON UPDATE CASCADE`
- JOURNAL_NOTES → TRADES: `ON DELETE CASCADE` (notes follow their trade)

### 5.2 EER Diagram Notes

The Enhanced ER model for TradeInsight includes:

- **Strong entities:** USERS, STRATEGIES, ASSETS, TRADE_TYPES, TRADES
- **Weak entity:** JOURNAL_NOTES (existence depends on TRADES, CASCADE delete)
- **Specialization:** ASSETS has a partial specialization on MarketType into Forex, Crypto, and Stock. Since the attributes are identical across all subtypes, this is implemented as an attribute + CHECK constraint rather than separate subtables.
- **Participation:** TRADES has total participation in all four relationships (a trade must always have a user, strategy, asset, and type).

---

## 6. Milestone 5 — DML & Validation

### 6.1 Data Population Strategy

The DML script (`dml/populate.sql`) uses explicit `INSERT INTO ... VALUES (...)` statements rather than `LOAD DATA INFILE` for maximum portability across different MySQL configurations. The script:

1. Wraps all insertions in a single transaction for atomicity.
2. Temporarily disables `foreign_key_checks` for load-order flexibility.
3. Re-enables `foreign_key_checks` before committing.
4. Concludes with a row-count summary query.

### 6.2 UPDATE Example

```sql
-- User corrects an entry price error on Trade #5
UPDATE trades
SET    ExitPrice  = 1.0987,
       ProfitLoss = ROUND((1.0987 - EntryPrice) * Quantity, 2)
WHERE  TradeID = 5;
```

This demonstrates a targeted, single-row update with a recomputed derived column.

### 6.3 DELETE Example

```sql
-- User removes an inaccurate journal note
DELETE FROM journal_notes
WHERE  NoteID = 10;
```

Because JOURNAL_NOTES uses `ON DELETE CASCADE` from TRADES (not the reverse), deleting a note directly is a simple operation. The CASCADE behavior is demonstrated implicitly: if Trade #10 were deleted, its associated note would be automatically removed.

### 6.4 Validation Results (Expected)

| Validation Check                          | Expected Result |
|-------------------------------------------|-----------------|
| Row count: users                          | 20              |
| Row count: strategies                     | 10              |
| Row count: assets                         | 15              |
| Row count: trade_types                    | 4               |
| Row count: trades                         | 80              |
| Row count: journal_notes (after delete)   | 59              |
| NULL check: all NOT NULL columns          | 0 nulls in all  |
| FK integrity: trades.UserID               | 0 orphans       |
| FK integrity: trades.StrategyID           | 0 orphans       |
| FK integrity: trades.AssetID              | 0 orphans       |
| FK integrity: trades.TypeID               | 0 orphans       |
| FK integrity: journal_notes.TradeID       | 0 orphans       |
| Business rule: Quantity > 0              | 0 violations    |
| Business rule: EntryPrice > 0            | 0 violations    |
| Business rule: Long trade P/L consistency | 0 violations    |

---

## 7. Conclusion

TradeInsight demonstrates a professionally designed relational database system built to support a real-world application. The six-table schema achieves Third Normal Form throughout, with all design decisions documented and justified. The synthetic dataset provides 195 rows of logically consistent, domain-realistic trading data across Forex, Crypto, and Stock markets.

Key design achievements include:

- **Full normalization:** Eliminates all update, insert, and delete anomalies from the pre-normalized flat schema.
- **Comprehensive constraints:** CHECK, UNIQUE, FK, and NOT NULL constraints enforce data integrity at the database level, independent of application code.
- **Strategic indexing:** Nine indexes cover the most common query patterns identified in the dataflow analysis, ensuring dashboard queries remain performant as data grows.
- **Referential integrity:** The RESTRICT/CASCADE combination on foreign keys ensures both historical data protection and sensible cascading behavior for subordinate records.
- **Documented trade-offs:** The two pragmatic deviations from strict 3NF (MarketType in ASSETS, ProfitLoss in TRADES) are clearly documented with technical justification.

The complete project is available in the repository with all SQL scripts, CSV datasets, and documentation organized for straightforward review and deployment.

---

*TradeInsight DB Lab Project — Shayan Ijaz & Huzaima Zakir*
