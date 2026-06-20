# ERP operations layer

These modules create business transactions that automatically post to the GL.

## Procure-to-pay (P2P)

Flow: Purchase requisition > Purchase order > Product receipt > Vendor invoice > Payment

| Step | GL impact |
|------|-----------|
| PO confirmed | No GL impact (commitment only) |
| Product receipt | Dr Interim receipt / Cr Accrued purchases |
| Vendor invoice | Dr Accrued purchases / Cr Accounts payable |
| Payment | Dr Accounts payable / Cr Bank |

## Order-to-cash (O2C)

Flow: Sales order > Packing slip > Customer invoice > Collection

| Step | GL impact |
|------|-----------|
| Packing slip | Dr COGS / Cr Inventory |
| Customer invoice | Dr Accounts receivable / Cr Revenue |
| Collection | Dr Bank / Cr Accounts receivable |

## Inventory costing methods

| Method | Best for |
|--------|----------|
| FIFO | General retail/distribution |
| Weighted average | Commodities |
| Standard cost | Manufacturing |

Inventory close runs at month-end to settle cost differences.

## Project accounting

Cost types:
- Hour — timesheet entry posts as labor cost
- Expense — expense report posts as cost
- Fee — fixed-price milestone billing
- Item — inventory issued to project

All post to GL via project posting profiles.
