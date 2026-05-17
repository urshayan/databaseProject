# Dataflow Documentation — TradeInsight

## Milestone 3: Data Flow, Preprocessing & Dataset Documentation

**Project:** TradeInsight — Trading Journal & Performance Analysis System  
**Team:** Shayan Ijaz · Huzaima Zakir  
**Instructor:** Ali Hassan  

---

## 1. System-Level Data Flow

The TradeInsight system follows a classic three-tier architecture. Data originates from the user's browser, travels through the Flask application server, and is persisted in a MySQL relational database.

```
┌──────────────────────────────────────────────────────────────────────┐
│                        CLIENT (Browser)                              │
│   HTML Form / Dashboard → JavaScript fetch() → REST API calls       │
└────────────────────────────┬─────────────────────────────────────────┘
                             │ HTTP/HTTPS (JSON payload)
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   APPLICATION LAYER (Flask / Python)                 │
│                                                                      │
│  ┌────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │  Auth Routes   │    │  Trade Routes    │    │  Report Routes   │  │
│  │  /login        │    │  /trades         │    │  /performance    │  │
│  │  /register     │    │  /trades/<id>    │    │  /analytics      │  │
│  └───────┬────────┘    └────────┬─────────┘    └────────┬─────────┘  │
│          │                     │                        │            │
│          └─────────────────────┼────────────────────────┘            │
│                                ▼                                     │
│                     Input Validation Layer                           │
│             (Type checking, NULL guards, range checks)               │
└────────────────────────────┬─────────────────────────────────────────┘
                             │ MySQL Connector / SQLAlchemy ORM
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER (MySQL)                            │
│                                                                      │
│   USERS ──────────────── TRADES ─────────── JOURNAL_NOTES           │
│                         /  │  \                                      │
│               STRATEGIES  ASSETS  TRADE_TYPES                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Entry Flows (CRUD Operations)

### 2.1 User Registration Flow

```
User fills registration form
    → Client-side: email format check, password length check
    → POST /register → Flask receives {name, email, password}
    → Server-side: check if email already exists (SELECT)
    → Hash password using bcrypt
    → INSERT INTO USERS (Name, Email, Password, CreatedAt)
    → Return success → Redirect to dashboard
```

### 2.2 Trade Entry Flow

```
User opens "Log Trade" form
    → Dropdowns populated from: STRATEGIES, ASSETS, TRADE_TYPES
    → User fills: EntryPrice, ExitPrice, Quantity, TradeDate
    → Client calculates preview ProfitLoss = (ExitPrice - EntryPrice) * Quantity
    → POST /trades → Flask validates all FK references exist
    → Server computes final ProfitLoss (authoritative)
    → INSERT INTO TRADES with UserID from session
    → Optional: POST /journal_notes → INSERT INTO JOURNAL_NOTES
```

### 2.3 Trade Update Flow

```
User edits an existing trade
    → GET /trades/<TradeID> → Load existing values into form
    → User modifies fields
    → PUT /trades/<TradeID> → Flask validates ownership (session UserID = trade's UserID)
    → Recompute ProfitLoss
    → UPDATE TRADES SET ... WHERE TradeID = ? AND UserID = ?
```

### 2.4 Trade Delete Flow

```
User clicks "Delete" on a trade
    → DELETE /trades/<TradeID>
    → Flask checks: does this TradeID have any JOURNAL_NOTES?
    → If yes: prompt "Delete notes too?" → DELETE FROM JOURNAL_NOTES first
    → Then DELETE FROM TRADES WHERE TradeID = ? AND UserID = ?
```

### 2.5 Performance Report Flow

```
User accesses dashboard analytics
    → GET /performance?user_id=X&from=YYYY-MM-DD&to=YYYY-MM-DD
    → Flask executes aggregation query:
        SELECT AssetName, MarketType,
               COUNT(*) as TotalTrades,
               SUM(ProfitLoss) as TotalPL,
               AVG(ProfitLoss) as AvgPL
        FROM TRADES JOIN ASSETS ...
        WHERE UserID = X AND TradeDate BETWEEN ? AND ?
        GROUP BY AssetID
    → Serialize result as JSON → Client renders charts
```

---

## 3. Synthetic Dataset — Generation Methodology

### 3.1 Why Synthetic Data?

Since the system is not yet deployed to real users, a realistic synthetic dataset was generated to:
1. Test all SQL queries with plausible data
2. Demonstrate performance analytics features
3. Populate the database for demonstration purposes
4. Validate referential integrity across all tables

### 3.2 Dataset Size

| Table         | Rows | Generation Method                    |
|---------------|------|--------------------------------------|
| users         | 20   | Pakistani/international names, seeded random emails |
| strategies    | 10   | Manually curated real trading strategies |
| assets        | 15   | 5 Forex pairs + 5 Cryptos + 5 Stocks |
| trade_types   | 4    | Fixed domain: Long, Short, Options, Futures |
| trades        | 80   | Seeded random with realistic price ranges |
| journal_notes | 60   | Realistic reflective text pool (20 templates) |

### 3.3 Realism Constraints Applied

**For TRADES:**
- Entry prices are bounded per asset type:
  - Forex (EUR/USD): 1.05–1.12 range
  - Crypto (BTC/USD): $25,000–$65,000 range
  - Stocks (AAPL): $140–$200 range
- Win rate set to ~55% (industry-realistic for an improving trader)
- Winning trades move 0.5%–3.5% in the trader's favor
- Losing trades move 0.5%–2.5% against the trader
- Quantity values reflect real lot sizes (100–1000 for Forex, 0.1–10 for Crypto)

**For JOURNAL_NOTES:**
- 60 out of 80 trades have a journal note (75% coverage — realistic for a disciplined trader)
- Emotions sampled from: Confident, Anxious, Happy, Greedy, Calm, Frustrated, Impulsive, Proud, Stressed, Satisfied, Motivated, Relieved, Unfocused, Cautious, Regretful, Disciplined, Excited, Overconfident, Focused, Analytical

---

## 4. Data Preprocessing Assumptions

### 4.1 Passwords
- All passwords in the dataset are stored as `hashed_<firstname>_<random4digits>` strings to simulate bcrypt hashes.
- In production, Flask uses `werkzeug.security.generate_password_hash()`.

### 4.2 ProfitLoss
- ProfitLoss is computed as `(ExitPrice - EntryPrice) × Quantity` and rounded to 2 decimal places.
- For Short trades, a lower exit price yields a profit. The application layer handles sign convention correctly before insertion.
- The stored value is always from the buyer's perspective for Long trades and inverted for Short trades.

### 4.3 Foreign Key Consistency
- All `UserID` values in TRADES reference a valid row in USERS (IDs 1–20).
- All `StrategyID` values reference STRATEGIES (IDs 1–10).
- All `AssetID` values reference ASSETS (IDs 1–15).
- All `TypeID` values reference TRADE_TYPES (IDs 1–4).
- All `TradeID` values in JOURNAL_NOTES reference TRADES (IDs 1–80, no repeats — one note per trade in our dataset, though the schema supports many).

### 4.4 Date Ranges
- User `CreatedAt` dates fall between June 2022 and June 2023 (account setup period).
- `TradeDate` timestamps fall between January 2023 and December 2024 (active trading period).
- This ensures all users existed before their first trade.

### 4.5 Data Cleaning Notes
- No NULL values exist in required fields.
- Email addresses are lowercased and formatted consistently.
- Asset names follow standard financial notation (e.g., `EUR/USD`, `BTC/USD`, `AAPL`).
- No duplicate trades (all TradeIDs are unique).
- Strategy descriptions are non-empty and manually verified for accuracy.

---

## 5. Data Validation Post-Load

After loading all CSV data into the database, the following checks are run (see `validation/validation_queries.sql`):

1. Row count verification per table
2. NULL checks on mandatory fields
3. FK integrity: every TradeID in JOURNAL_NOTES exists in TRADES
4. FK integrity: every UserID in TRADES exists in USERS
5. Business rule: no trade has ExitPrice = 0
6. Business rule: no trade has Quantity ≤ 0
7. Profit/Loss sign consistency check
