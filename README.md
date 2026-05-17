# TradeInsight — Trading Journal & Performance Analysis System

**Course:** Database Systems Lab  
**Instructor:** Ali Hassan  
**Team Members:** Shayan Ijaz · Huzaima Zakir  
**Technology Stack:** Python Flask · MySQL · HTML/CSS/JavaScript  

---

## Project Overview

TradeInsight is a full-featured trading journal and performance analysis system designed to help individual traders record, organize, and evaluate their trades. The system allows users to log every trade they take — including asset, strategy, entry/exit prices, and profit/loss — and pair each trade with personal journal notes that capture the emotional and analytical reasoning behind each decision.

The core motivation is that most traders fail not because of a lack of knowledge, but because of poor record-keeping. TradeInsight solves that by providing a structured database-backed system that turns raw trade data into actionable insight.

---

## Repository Structure

```
TradeInsight/
│
├── README.md                          ← You are here
│
├── ERD/
│   ├── final_erd.png                  ← Entity-Relationship Diagram image
│   └── erd_description.md             ← Detailed ERD explanation
│
├── normalization/
│   └── NORMALIZATION.md               ← Full 1NF → 2NF → 3NF analysis
│
├── dataset/
│   ├── users.csv                      ← 20 synthetic user records
│   ├── strategies.csv                 ← 10 trading strategies
│   ├── assets.csv                     ← 15 tradeable assets
│   ├── trade_types.csv                ← 4 trade type classifications
│   ├── trades.csv                     ← 80 realistic trade records
│   └── journal_notes.csv              ← 60 journal entries with emotions
│
├── dataflow/
│   └── dataflow.md                    ← Data flow & preprocessing documentation
│
├── ddl/
│   └── schema.sql                     ← Full MySQL DDL (CREATE TABLE, indexes)
│
├── dml/
│   └── populate.sql                   ← Data insertion + UPDATE/DELETE examples
│
├── validation/
│   └── validation_queries.sql         ← Data validation & integrity checks
│
└── report/
    └── TradeInsight_DBLab_Report.md   ← Full academic submission report
```

---

## Database Summary

| Table          | Description                              | Rows (Sample) |
|----------------|------------------------------------------|---------------|
| USERS          | Registered trader accounts               | 20            |
| STRATEGIES     | Named trading strategies with description| 10            |
| ASSETS         | Tradeable instruments (Forex/Crypto/Stock)| 15           |
| TRADE_TYPES    | Classification of trade type             | 4             |
| TRADES         | Core trade records with P/L calculation  | 80            |
| JOURNAL_NOTES  | Reflective notes linked to trades        | 60            |

---

## How to Set Up

### 1. Clone the repository
```bash
git clone https://github.com/your-username/TradeInsight.git
cd TradeInsight
```

### 2. Create the database schema
```bash
mysql -u root -p < ddl/schema.sql
```

### 3. Populate with sample data
```bash
mysql -u root -p tradeinsight_db < dml/populate.sql
```

### 4. Run validation queries
```bash
mysql -u root -p tradeinsight_db < validation/validation_queries.sql
```

### 5. Launch the Flask backend
```bash
pip install flask flask-mysqldb
python app.py
```

---

## Key Features

- **User Authentication** — Secure login using hashed passwords
- **Trade Logging** — Record entry/exit prices, quantity, asset, and strategy
- **Profit/Loss Calculation** — Automatically computed per trade
- **Journal Notes** — Attach emotional reflections to each trade
- **Performance Analytics** — Filter by date, asset, strategy, and outcome
- **Trade History** — Full audit trail of all trading activity

---

## Milestones

| Milestone | Deliverable                         | Status  |
|-----------|-------------------------------------|---------|
| M1        | ERD + Relational Schema             | ✅ Done |
| M2        | Normalization (1NF, 2NF, 3NF)       | ✅ Done |
| M3        | Synthetic Dataset + Dataflow        | ✅ Done |
| M4        | DDL Scripts (schema.sql)            | ✅ Done |
| M5        | DML + Validation Scripts            | ✅ Done |

---

*Last updated: 2024 — TradeInsight DB Lab Project*
