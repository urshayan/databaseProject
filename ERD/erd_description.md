# Entity-Relationship Diagram — TradeInsight

## Milestone 1: ERD & Relational Schema

**Project:** TradeInsight — Trading Journal & Performance Analysis System  
**Team:** Shayan Ijaz · Huzaima Zakir  
**Instructor:** Ali Hassan  

---

## 1. ERD Overview

The TradeInsight ERD models a normalized relational database of six entities. The central entity is **TRADES**, which acts as the hub connecting users, strategies, assets, and trade types. Each trade can optionally be paired with one or more journal notes, capturing the trader's mindset at the time of the trade.

---

## 2. Entities and Attributes

### USERS
Stores the registered accounts of traders using the system.

| Attribute   | Type         | Constraint       | Notes                      |
|-------------|--------------|------------------|----------------------------|
| UserID      | INT          | PK, AUTO_INCREMENT | Surrogate primary key     |
| Name        | VARCHAR(100) | NOT NULL         | Full name of the trader    |
| Email       | VARCHAR(150) | NOT NULL, UNIQUE | Used for login             |
| Password    | VARCHAR(255) | NOT NULL         | Stored as hashed string    |
| CreatedAt   | DATETIME     | NOT NULL         | Account registration time  |

---

### STRATEGIES
A lookup table for named trading strategies. Separating strategies into their own table eliminates repeated text and allows consistent strategy-level analytics.

| Attribute    | Type         | Constraint         | Notes                        |
|--------------|--------------|--------------------|------------------------------|
| StrategyID   | INT          | PK, AUTO_INCREMENT | Surrogate primary key        |
| StrategyName | VARCHAR(100) | NOT NULL, UNIQUE   | e.g., "Trend Following"      |
| Description  | TEXT         | NULL allowed       | Detailed strategy description |

---

### ASSETS
Represents the tradeable instruments — currencies, cryptocurrencies, or stocks.

| Attribute  | Type        | Constraint         | Notes                          |
|------------|-------------|--------------------|--------------------------------|
| AssetID    | INT         | PK, AUTO_INCREMENT | Surrogate primary key          |
| AssetName  | VARCHAR(50) | NOT NULL, UNIQUE   | e.g., "EUR/USD", "BTC/USD"     |
| MarketType | VARCHAR(30) | NOT NULL           | Forex / Crypto / Stock         |

---

### TRADE_TYPES
A simple classification table distinguishing between Long, Short, Options, and Futures trades.

| Attribute | Type        | Constraint         | Notes                     |
|-----------|-------------|--------------------|---------------------------|
| TypeID    | INT         | PK, AUTO_INCREMENT | Surrogate primary key     |
| TypeName  | VARCHAR(50) | NOT NULL, UNIQUE   | e.g., "Long", "Short"     |

---

### TRADES
The core fact table of the database. Each row represents one complete trade, from entry to exit, with calculated profit/loss.

| Attribute  | Type          | Constraint            | Notes                          |
|------------|---------------|-----------------------|--------------------------------|
| TradeID    | INT           | PK, AUTO_INCREMENT    | Surrogate primary key          |
| UserID     | INT           | FK → USERS(UserID)    | Who placed this trade          |
| StrategyID | INT           | FK → STRATEGIES       | Which strategy was used        |
| AssetID    | INT           | FK → ASSETS           | What was traded                |
| TypeID     | INT           | FK → TRADE_TYPES      | Long / Short / Options / Futures |
| EntryPrice | DECIMAL(15,4) | NOT NULL              | Price when trade was opened    |
| ExitPrice  | DECIMAL(15,4) | NOT NULL              | Price when trade was closed    |
| Quantity   | DECIMAL(15,4) | NOT NULL, > 0         | Volume / lot size              |
| ProfitLoss | DECIMAL(15,2) | NOT NULL              | Computed: (Exit-Entry)*Qty     |
| TradeDate  | DATETIME      | NOT NULL              | Timestamp of trade entry       |

---

### JOURNAL_NOTES
Stores reflective notes written by the trader after (or during) a trade. This supports emotional tracking and post-trade analysis.

| Attribute | Type         | Constraint          | Notes                            |
|-----------|--------------|---------------------|----------------------------------|
| NoteID    | INT          | PK, AUTO_INCREMENT  | Surrogate primary key            |
| TradeID   | INT          | FK → TRADES(TradeID)| Which trade this note belongs to |
| NoteText  | TEXT         | NOT NULL            | The actual journal entry         |
| Emotion   | VARCHAR(50)  | NULL allowed        | e.g., Confident, Anxious, Calm   |

---

## 3. Relationships and Cardinalities

| Relationship                           | Type         | Description                                                            |
|----------------------------------------|--------------|------------------------------------------------------------------------|
| USERS → TRADES                         | One-to-Many  | One user account can have many trade records                           |
| STRATEGIES → TRADES                    | One-to-Many  | One strategy can be applied across many trades                         |
| ASSETS → TRADES                        | One-to-Many  | One asset (e.g., BTC/USD) can appear in many trade records             |
| TRADE_TYPES → TRADES                   | One-to-Many  | One type classification (e.g., Long) can apply to many trades          |
| TRADES → JOURNAL_NOTES                 | One-to-Many  | One trade can have multiple journal notes written at different times    |

---

## 4. Relational Schema (Formal Notation)

```
USERS(UserID*, Name, Email, Password, CreatedAt)

STRATEGIES(StrategyID*, StrategyName, Description)

ASSETS(AssetID*, AssetName, MarketType)

TRADE_TYPES(TypeID*, TypeName)

TRADES(TradeID*, UserID°, StrategyID°, AssetID°, TypeID°,
        EntryPrice, ExitPrice, Quantity, ProfitLoss, TradeDate)

JOURNAL_NOTES(NoteID*, TradeID°, NoteText, Emotion)
```

> **Legend:** `*` = Primary Key · `°` = Foreign Key

---

## 5. Referential Integrity Summary

All foreign key relationships enforce `ON DELETE RESTRICT` to prevent orphaned records. For example:
- A user cannot be deleted if they have trades on record.
- A trade cannot be deleted if it has associated journal notes.
- An asset or strategy referenced by a trade is protected from deletion.

This design ensures full referential integrity across the entire system.

---

## 6. ERD Notation Guide

The ERD uses **Crow's Foot notation** for expressing cardinality:

```
USERS ─────────<  TRADES   (One-to-Many: one user, many trades)
STRATEGIES ─────────<  TRADES
ASSETS ─────────<  TRADES
TRADE_TYPES ─────────<  TRADES
TRADES ─────────<  JOURNAL_NOTES
```

Mandatory participation (total participation) is denoted with double lines on the many side, confirming that every trade MUST reference a valid user, strategy, asset, and type.
