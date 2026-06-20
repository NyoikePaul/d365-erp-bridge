# 🔷 D365 ERP–Accounting Bridge

![Microsoft Dynamics 365](https://img.shields.io/badge/Microsoft%20Dynamics%20365-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Azure](https://img.shields.io/badge/Azure%20AD-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

> **Role:** ERP IT — Bridge between the Accounting team and Microsoft Dynamics 365 Finance & Operations at PlanTech.

This repository is a structured knowledge base and integration toolkit for working with D365 F&O — covering finance configuration, ERP transaction flows, API integrations, and X++ extensions.

---

## 📋 Table of Contents

- [Role Overview](#role-overview)
- [Repo Structure](#repo-structure)
- [Learning Roadmap](#learning-roadmap)
- [Quick Start](#quick-start)
- [Key Concepts](#key-concepts)
- [Resources](#resources)

---

## 🎯 Role Overview

As ERP IT at PlanTech, the core responsibilities are:

| Responsibility | Description |
|----------------|-------------|
| 🔧 Configuration | Translate accounting requirements into D365 setup |
| 🐛 Debugging | Trace why transactions post incorrectly to the GL |
| 🔗 Integration | Build DMF imports, OData API pipelines, Power Automate flows |
| 📊 Reporting | Create Electronic Reports for accounting exports |
| 💻 Development | Write X++ extensions when config alone is not enough |

---

## 📁 Repo Structure
d365-erp-bridge/

├── docs/

│   ├── 01-finance-fundamentals/   # GL, AP, AR, dimensions, bank recon

│   ├── 02-erp-operations/         # Procurement, Sales, Inventory, Projects

│   ├── 03-integration-tools/      # DMF, OData API, Electronic Reporting

│   └── 04-x-plus-plus/            # X++ language, extensions, CoC

├── scripts/

│   ├── odata/                     # Python scripts for D365 OData endpoints

│   ├── dmf/                       # DMF data package templates

│   └── power-automate/            # Flow JSON exports

├── notebooks/                     # Jupyter notebooks for data exploration

└── assets/                        # ERDs, screenshots, reference docs

---

## 🗺️ Learning Roadmap

| Phase | Week | Focus | Key Deliverable |
|-------|------|-------|----------------|
| 1 | 1–2 | Navigate D365 | Understand modules, workspaces, legal entities |
| 1 | 3–4 | Finance fundamentals | Chart of accounts, posting profiles, dimensions |
| 2 | 5–6 | Procure-to-pay | PO → receipt → vendor invoice → GL posting |
| 2 | 7–8 | Order-to-cash | SO → packing slip → customer invoice → AR |
| 3 | 9–10 | Integration tools | DMF imports, OData API queries |
| 3 | 11–12 | Reporting & X++ | Electronic Reporting, Chain of Command |

---

## ⚡ Quick Start

### Prerequisites
- Access to a D365 F&O sandbox environment
- Python 3.10+
- Azure app registration with D365 API permissions

### Setup

```bash
# Clone the repo
git clone https://github.com/NyoikePaul/d365-erp-bridge.git
cd d365-erp-bridge

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your D365 credentials
```

---

## 🧠 Key Concepts

### Posting Profiles
Every transaction in D365 hits the GL through a posting profile.
When accounting reports a wrong posting — this is always where you start.

### Financial Dimensions
Tags (Department, Cost Center, Project) attached to every GL transaction.
They flow automatically from source document → invoice → GL entry.

### Data Entities (DMF)
Structured views over D365 tables used for bulk import/export.
Key entities: `GeneralJournalAccountEntry`, `VendorV2`, `CustomerV3`, `MainAccount`.

### OData API
D365 exposes all data via OData v4 REST endpoints.
Base URL: `https://{env}.operations.dynamics.com/data/{EntityName}`

---

## 📚 Resources

| Resource | Link |
|----------|------|
| Microsoft Learn — D365 Finance | [learn.microsoft.com](https://learn.microsoft.com/en-us/dynamics365/finance/) |
| OData endpoint reference | [docs](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/data-entities/odata) |
| DMF data entities catalog | [docs](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/data-entities/data-entities) |
| Electronic Reporting overview | [docs](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/analytics/general-electronic-reporting) |
| X++ language reference | [docs](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-ref/xpp-language-reference) |
| MB-310 Certification | [learn.microsoft.com](https://learn.microsoft.com/en-us/certifications/exams/mb-310/) |

---

## 🏷️ Topics

`dynamics-365` `microsoft-erp` `d365-finance` `accounting` `erp-integration` `odata` `x-plus-plus` `dmf` `power-automate` `kenya` `plantech`

---

*Maintained by [@NyoikePaul](https://github.com/NyoikePaul) — ERP IT, PlanTech*
