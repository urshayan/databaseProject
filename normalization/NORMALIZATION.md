# Normalization Analysis — TradeInsight

## Milestone 2: Database Normalization (1NF → 2NF → 3NF)

**Project:** TradeInsight — Trading Journal & Performance Analysis System  
**Team:** Shayan Ijaz · Huzaima Zakir  
**Instructor:** Ali Hassan  

---

## Introduction

Normalization is the process of organizing a relational database to reduce data redundancy and improve data integrity. The TradeInsight schema was designed from the ground up with normalization principles in mind. This document walks through every table, explaining how it satisfies — or was restructured to satisfy — First, Second, and Third Normal Forms.

A pre-normalized "flat file" version of this system might look like a single massive spreadsheet with columns like:
`UserName, UserEmail, StrategyName, AssetName, MarketType, TypeName, EntryPrice, ExitPrice, Quantity, ProfitLoss, TradeDate, NoteText, Emotion`

This is clearly problematic: the user's name and email would repeat for every trade, the strategy description would appear redundantly, and any update to an asset name would require touching dozens of rows. The normalization process below shows how we eliminated all of that.

---

## Table 1: USERS

### Pre-normalization concern
In a flat schema, every trade row would embed the full user name, email, and password. This creates massive redundancy and update anomalies — changing a user's email would require updating every one of their trade rows.

### 1NF — First Normal Form
**Rule:** All columns must contain atomic values; no repeating groups; a primary key must exist.

- `UserID` is a unique integer surrogate key — ✅
- `Name` stores a single full name string — ✅ (name is treated as one atomic unit, not split further since the system does not query on first/last name independently)
- `Email` and `Password` are single-valued — ✅
- `CreatedAt` is a single timestamp — ✅
- No multi-valued or composite attributes — ✅

**Result: USERS satisfies 1NF. No changes required.**

### 2NF — Second Normal Form
**Rule:** Must be in 1NF, and every non-key attribute must be fully functionally dependent on the entire primary key.

USERS has a single-column primary key (`UserID`). When the PK is simple (not composite), 2NF is automatically satisfied, since partial dependency is impossible.

- Name, Email, Password, CreatedAt → all depend on UserID — ✅

**Result: USERS satisfies 2NF. No changes required.**

### 3NF — Third Normal Form
**Rule:** Must be in 2NF, and no non-key attribute should transitively depend on the primary key through another non-key attribute.

Checking for transitive dependencies:
- Does `Email` determine `Name`? No — two users could share a name.
- Does `Password` depend on `Email` rather than `UserID`? No — in our model, UserID is the canonical identifier.
- All attributes depend directly and only on `UserID`.

**Result: USERS satisfies 3NF. No changes required.**

---

## Table 2: STRATEGIES

### Pre-normalization concern
If strategy information were embedded in the TRADES table, the full description of "Trend Following" would be repeated in every trade row that used it. Updating the description would require a multi-row update.

### 1NF
- `StrategyID` is unique and atomic — ✅
- `StrategyName` is a single-valued string — ✅
- `Description` is treated as a single text blob; while verbose, it is not a repeating group — ✅

**Result: STRATEGIES satisfies 1NF.**

### 2NF
- Single PK (`StrategyID`) → partial dependency impossible — ✅
- Both `StrategyName` and `Description` fully depend on `StrategyID` — ✅

**Result: STRATEGIES satisfies 2NF.**

### 3NF
- Does `Description` transitively depend on `StrategyName` rather than `StrategyID`? Potentially, since the description describes the strategy, not the ID. However, `StrategyID` is the canonical key and `StrategyName` is not a candidate key (we could have a strategy renamed without changing its fundamental meaning). No true transitive dependency violates 3NF here, because we are not deriving one non-key attribute from another non-key attribute.

**Result: STRATEGIES satisfies 3NF.**

---

## Table 3: ASSETS

### Pre-normalization concern
Embedding asset data (e.g., "EUR/USD" and "Forex") into every trade row would cause the market type label to repeat hundreds of times, wasting storage and creating risk of inconsistency.

### 1NF
- `AssetID` is unique — ✅
- `AssetName` (e.g., "EUR/USD") is atomic — ✅
- `MarketType` (Forex / Crypto / Stock) is a single category value — ✅

**Result: ASSETS satisfies 1NF.**

### 2NF
- Single-column PK → no partial dependency possible — ✅

**Result: ASSETS satisfies 2NF.**

### 3NF
- Does `MarketType` depend on `AssetName` rather than `AssetID`? This is the most interesting case. One could argue that given `AssetName = "EUR/USD"`, you can determine `MarketType = "Forex"` — a transitive dependency.

**Resolution:** This is technically a valid 3NF concern. To fully resolve it, we could create a `MARKET_TYPES` table and add a FK. However, in practice, the `MarketType` values form a small closed set (Forex, Crypto, Stock), and the ASSETS table is explicitly a lookup table used for reporting by market category. The `AssetID` is still the sole key. We accept this as a **pragmatic design trade-off** and note that the `MarketType` CHECK constraint enforces domain integrity, compensating for the lack of full decomposition.

**Result: ASSETS satisfies 3NF with a documented pragmatic exception on MarketType categorization.**

---

## Table 4: TRADE_TYPES

### Pre-normalization concern
Without this table, the string "Long" or "Short" would appear in every trade row, making it impossible to rename a type without a full-table update.

### 1NF
- `TypeID` is unique — ✅
- `TypeName` is atomic — ✅

**Result: TRADE_TYPES satisfies 1NF.**

### 2NF & 3NF
- With only one non-key attribute (`TypeName`) and a single-column PK, there are no dependencies to violate 2NF or 3NF.

**Result: TRADE_TYPES satisfies 2NF and 3NF automatically.**

---

## Table 5: TRADES

This is the most complex table and the one where normalization provides the greatest benefit.

### Pre-normalization "flat" version (rejected)

A naive flat version might have been:

```
TRADES_FLAT(TradeID, UserName, UserEmail, StrategyName, StrategyDescription,
            AssetName, MarketType, TypeName, EntryPrice, ExitPrice,
            Quantity, ProfitLoss, TradeDate, NoteText, Emotion)
```

This version has severe problems:
1. User information repeats for every trade the user takes.
2. Strategy description repeats for every trade using that strategy.
3. Asset market type repeats for every trade on that asset.
4. Journal notes force NULLs when there's no note, and can't hold multiple notes.

### 1NF
After decomposition into separate lookup tables:
- `TradeID` is the unique surrogate PK — ✅
- All columns are atomic and single-valued — ✅
- Foreign keys (UserID, StrategyID, AssetID, TypeID) are simple integer values — ✅

**Result: TRADES satisfies 1NF.**

### 2NF
- The PK is a single column (`TradeID`) → partial dependency is structurally impossible.
- `EntryPrice`, `ExitPrice`, `Quantity` all depend on the specific trade — ✅
- `ProfitLoss` is derived from `(ExitPrice - EntryPrice) * Quantity`, making it a computed attribute. We store it for query performance (denormalized for read speed) and enforce it at the application layer — ✅

**Result: TRADES satisfies 2NF.**

### 3NF
Testing for transitive dependencies:
- Does `ProfitLoss` transitively depend on `EntryPrice`, `ExitPrice`, and `Quantity`? Technically yes — it is derived. However, storing computed values for performance reasons is a widely accepted practice. The derivation is documented and enforced at the application layer.
- Do any of the FK columns (UserID, StrategyID, etc.) determine each other? No — a user can use any strategy on any asset.

**Result: TRADES satisfies 3NF, with a documented performance-driven choice to store `ProfitLoss` as a materialized computed column.**

---

## Table 6: JOURNAL_NOTES

### Pre-normalization concern
If notes were stored as a column in TRADES, the schema could only hold one note per trade and would have NULLs wherever no note was written. Holding multiple notes in one column would violate 1NF.

### 1NF
- `NoteID` is the unique PK — ✅
- `NoteText` is a single text blob — ✅
- `Emotion` is a single categorical value — ✅
- Extracting notes into their own table (with `TradeID` as FK) allows a trade to have multiple notes — ✅

**Result: JOURNAL_NOTES satisfies 1NF.**

### 2NF
- Single-column PK → no partial dependency possible — ✅

**Result: JOURNAL_NOTES satisfies 2NF.**

### 3NF
- Does `Emotion` depend on `NoteText` rather than `NoteID`? In theory, one could infer emotion from text (via sentiment analysis), but that is a semantic/application concern, not a database dependency. In the relational model, `Emotion` is an independently assigned attribute.
- No transitive dependencies exist.

**Result: JOURNAL_NOTES satisfies 3NF.**

---

## Summary of Normalization

| Table         | 1NF | 2NF | 3NF | Changes Required         |
|---------------|-----|-----|-----|--------------------------|
| USERS         | ✅  | ✅  | ✅  | None                     |
| STRATEGIES    | ✅  | ✅  | ✅  | None                     |
| ASSETS        | ✅  | ✅  | ✅* | *Pragmatic exception noted|
| TRADE_TYPES   | ✅  | ✅  | ✅  | None                     |
| TRADES        | ✅  | ✅  | ✅* | *ProfitLoss stored as computed column |
| JOURNAL_NOTES | ✅  | ✅  | ✅  | None                     |

---

## Redundancy and Anomaly Elimination

**Update Anomaly:** Before normalization, changing a strategy description would require updating every trade row. After normalization, only the single row in STRATEGIES needs to change.

**Insert Anomaly:** Before normalization, you couldn't add a new asset until a trade existed for it. After creating the ASSETS lookup table, assets are independent entities.

**Delete Anomaly:** Before normalization, deleting all trades for a user would also delete the user's information. After normalization, USERS and TRADES are separate, and referential integrity prevents unintended cascading deletions.

---

## Conclusion

The TradeInsight schema was designed with normalization principles as a first-class concern. All six tables satisfy Third Normal Form. The two documented exceptions — `MarketType` in ASSETS and `ProfitLoss` in TRADES — are engineering trade-offs that prioritize query performance and developer clarity over strict theoretical purity, and both are fully compensated by application-layer enforcement and database constraints.
