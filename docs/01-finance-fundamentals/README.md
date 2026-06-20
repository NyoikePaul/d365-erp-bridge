# Finance fundamentals

The accounting team's world in D365. Understand this before bridging anything.

## 1. Chart of accounts (COA)
- Main accounts: Balance sheet vs P&L
- Account types: Asset, Liability, Revenue, Expense, Equity
- Config path: `General ledger > Chart of accounts > Accounts > Main accounts`

## 2. Posting profiles
Every transaction hits the GL through a posting profile — a mapping of business event to debit + credit accounts.

| Business event | Posting type | Example account |
|----------------|-------------|-----------------|
| Vendor invoice received | Vendor balance | AP summary account |
| Product receipt posted | Purchase expenditure | Interim receipt account |
| Customer invoice | Customer balance | AR summary account |
| Inventory issue | Inventory issue | COGS account |

When accounting says "this posted to the wrong account" — trace it back to the posting profile.

## 3. Financial dimensions
Tags attached to every GL transaction:
- Department (Sales, Finance, HR)
- Cost center (by geography or product line)
- Project (billable vs internal)

Dimensions flow automatically from source document through to the GL entry.

## 4. Fiscal periods & year-end close
- Period states: Open > On hold > Closed > Permanently closed
- Period close checklist: subledger recon > bank recon > adjustments > close
- Year-end close job zeroes P&L accounts and rolls balance to retained earnings

## 5. Bank reconciliation
- Bank statement import via DMF or bank connector
- Auto-matching rules for routine transactions
- Manual matching for exceptions

## Common accounting team requests you will handle
1. "Why did this invoice post to the wrong account?" — trace posting profile
2. "Add a new dimension value for our new department" — Financial dimensions setup
3. "I cannot post — period is closed" — Ledger calendar / period status
4. "Run the trial balance for last month" — Financial reports / Row-Column designer
