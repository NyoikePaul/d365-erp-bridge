# D365 ERP–Accounting Bridge

A structured learning repo for Microsoft Dynamics 365 Finance & Operations, focused on the **ERP ↔ Accounting bridge** role — understanding how business transactions in ERP modules post to the General Ledger, and how to integrate, extend, and report on D365 data.

## Role context

> **PlanTech / ERP IT** — bridge between the accounting team and D365 F&O.

Your core responsibilities:
- Translate accounting requirements into D365 configuration
- Debug why transactions are posting incorrectly (or not at all)
- Build and maintain integrations (DMF imports, OData API, Power Automate)
- Create custom Electronic Reports for accounting exports
- Write X++ extensions when config alone isn't enough

---

## Repo structure
d365-erp-bridge/

├── docs/

│   ├── 01-finance-fundamentals/   # GL, AP, AR, dimensions, bank recon

│   ├── 02-erp-operations/         # Procurement, Sales, Inventory, Projects

│   ├── 03-integration-tools/      # DMF, OData API, Electronic Reporting

│   └── 04-x-plus-plus/            # X++ language, extensions, CoC

├── scripts/

│   ├── odata/                     # Python scripts hitting D365 OData endpoints

│   ├── dmf/                       # DMF data package templates & import scripts

│   └── power-automate/            # Flow JSON exports

├── notebooks/                     # Jupyter notebooks for data exploration

└── assets/                        # ERDs, screenshots, reference docs

---

## Learning roadmap

| Week | Focus | Key concept |
|------|-------|-------------|
| 1–2  | Finance fundamentals | Chart of accounts, posting profiles, financial dimensions |
| 3–4  | Procure-to-pay | PO → receipt → vendor invoice → GL posting |
| 5–6  | Order-to-cash | SO → packing slip → customer invoice → AR |
| 7–8  | Integration tools | DMF imports, OData API queries |
| 9–10 | Electronic Reporting | Custom export formats |
| 11–12 | X++ basics | Chain of Command, event handlers |

---

## Quick reference

- [Microsoft Learn — D365 Finance](https://learn.microsoft.com/en-us/dynamics365/finance/)
- [D365 OData endpoint reference](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/data-entities/odata)
- [DMF data entities catalog](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/data-entities/data-entities)
- [Electronic Reporting overview](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/analytics/general-electronic-reporting)
- [X++ language reference](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-ref/xpp-language-reference)
