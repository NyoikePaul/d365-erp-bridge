# Integration & bridge tools

Your primary domain as ERP IT.

## 1. Data Management Framework (DMF)

Import/export data using data entities — structured views over D365 tables.

### Import workflow
1. System administration > Data management > Import
2. Create project, choose format (Excel, CSV, XML)
3. Map source columns to entity fields
4. Run import, check execution log

### Key data entities for accounting
| Entity | Use case |
|--------|----------|
| GeneralJournalAccountEntry | Import journal entries |
| CustomerV3 | Bulk customer load |
| VendorV2 | Bulk vendor load |
| MainAccount | COA import |
| BankStatementDocument | Bank statement import |

## 2. OData API

D365 exposes data via OData v4 — standard REST queryable with $filter, $select, $expand.

Base URL:
https://{environment}.operations.dynamics.com/data/{EntityName}

Authentication: OAuth 2.0 with Azure AD client credentials flow.

See scripts/odata/ for Python examples.

## 3. Electronic Reporting (ER)

Configurable report/export engine. Used for:
- Tax report formats
- Bank statement formats
- Audit file exports
- Custom accounting extracts for external BI tools

ER separates data model (what data) from format (how it renders).
Configure formats in the ER designer — no code required for most cases.

## 4. Power Automate

Lightweight integrations without code:
- D365 invoice approved > send email notification
- New vendor created > sync to external approval workflow
- Journal posted > trigger export to reporting database
