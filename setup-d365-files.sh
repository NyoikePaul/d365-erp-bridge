#!/usr/bin/env bash
set -e

mkdir -p .github/workflows
mkdir -p assets
mkdir -p notebooks
mkdir -p scripts/dmf/templates
mkdir -p scripts/odata
mkdir -p scripts/power-automate/flows

cat > .gitignore << 'EOF'
.env
*.pyc
__pycache__/
.DS_Store
*.log
scripts/odata/output/
.ipynb_checkpoints/
.venv/
venv/
EOF

cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 Paul Nyoike

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

cat > CONTRIBUTING.md << 'EOF'
# Contributing

This repo is primarily a working knowledge base for the ERP IT / D365
bridge role at PlanTech, but it's structured so it stays useful to anyone
doing similar work.

## Adding a doc

- Place it under the right numbered folder in `docs/` (`01-finance-fundamentals`,
  `02-erp-operations`, `03-integration-tools`, `04-x-plus-plus`)
- Lead with the *business* question it answers, then the technical explanation
- Keep examples concrete: use real entity names, real config paths

## Adding a script

- `scripts/odata/` — Python only, reuse `D365Client` rather than writing a
  new auth flow per script
- `scripts/dmf/templates/` — CSV templates only; keep one example row
- `scripts/power-automate/flows/` — documented JSON describing trigger + steps

## Before committing

```bash
ruff check scripts/
python3 -m py_compile scripts/odata/*.py
```

## Secrets

Never commit a real `.env` file, API keys, or D365 environment URLs tied to
production. `.env` is already gitignored.
EOF

cat > assets/README.md << 'EOF'
# Assets

Reference diagrams and screenshots that support the docs.

## What goes here

- ERDs for data entities referenced in docs/03-integration-tools/
- Screenshots of D365 configuration screens referenced in the docs
- Process diagrams for the P2P/O2C flows in docs/02-erp-operations/

## Naming convention

`<topic>-<description>.png`, e.g. `p2p-flow-overview.png`
EOF

cat > .github/workflows/lint.yml << 'EOF'
name: Lint

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint-python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - name: Install lint tools
        run: pip install ruff
      - name: Run ruff
        run: ruff check scripts/

  lint-markdown:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint markdown
        uses: DavidAnson/markdownlint-cli2-action@v16
        with:
          globs: "**/*.md"

  validate-json:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate JSON and notebook files
        run: |
          for f in $(find . -name "*.json" -o -name "*.ipynb"); do
            python3 -c "import json; json.load(open('$f'))" || exit 1
          done
          echo "All JSON/notebook files are valid."
EOF

cat > scripts/odata/README.md << 'EOF'
# OData scripts

Python tooling for querying D365 Finance & Operations over its OData v4 REST API.

## Setup

```bash
pip install -r ../../requirements.txt
cp ../../.env.example ../../.env
```

Your Azure AD app registration needs API permission for the D365 resource,
admin consent, and the app user added inside D365 with an appropriate
security role.

## Files

| File | Purpose |
|------|---------|
| `d365_client.py` | Reusable client: MSAL auth + OData GET/POST/PATCH, auto-paginates |
| `query_examples.py` | Worked examples: open vendor invoices, customer aging, chart of accounts, recent GL entries |

## Run

```bash
python query_examples.py
```
EOF

cat > scripts/odata/d365_client.py << 'PYEOF'
"""
D365 Finance & Operations OData client.
Handles Azure AD (MSAL) client-credentials authentication and provides
a thin wrapper over the OData v4 REST endpoints exposed by D365 F&O.
"""

from __future__ import annotations

import os
from typing import Any, Iterable

import msal
import requests
from dotenv import load_dotenv

load_dotenv()


class D365AuthError(RuntimeError):
    """Raised when token acquisition fails."""


class D365Client:
    """Minimal OData client for D365 Finance & Operations."""

    def __init__(
        self,
        tenant_id: str | None = None,
        client_id: str | None = None,
        client_secret: str | None = None,
        env_url: str | None = None,
    ) -> None:
        self.tenant_id = tenant_id or os.environ["D365_TENANT_ID"]
        self.client_id = client_id or os.environ["D365_CLIENT_ID"]
        self.client_secret = client_secret or os.environ["D365_CLIENT_SECRET"]
        self.env_url = (env_url or os.environ["D365_ENV_URL"]).rstrip("/")
        self._token: str | None = None

    def _get_token(self) -> str:
        if self._token:
            return self._token
        authority = f"https://login.microsoftonline.com/{self.tenant_id}"
        app = msal.ConfidentialClientApplication(
            client_id=self.client_id,
            client_credential=self.client_secret,
            authority=authority,
        )
        scope = [f"{self.env_url}/.default"]
        result = app.acquire_token_for_client(scopes=scope)
        if "access_token" not in result:
            raise D365AuthError(
                f"Token acquisition failed: {result.get('error')} - "
                f"{result.get('error_description')}"
            )
        self._token = result["access_token"]
        return self._token

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self._get_token()}",
            "Accept": "application/json",
            "OData-MaxVersion": "4.0",
            "OData-Version": "4.0",
        }

    def get_entity(
        self,
        entity_name: str,
        select: Iterable[str] | None = None,
        filter: str | None = None,
        expand: str | None = None,
        top: int | None = None,
        cross_company: bool = False,
    ) -> list[dict[str, Any]]:
        url = f"{self.env_url}/data/{entity_name}"
        params: dict[str, Any] = {}
        if select:
            params["$select"] = ",".join(select)
        if filter:
            params["$filter"] = filter
        if expand:
            params["$expand"] = expand
        if top:
            params["$top"] = top
        if cross_company:
            params["cross-company"] = "true"
        records: list[dict[str, Any]] = []
        while url:
            response = requests.get(url, headers=self._headers(), params=params, timeout=60)
            response.raise_for_status()
            payload = response.json()
            records.extend(payload.get("value", []))
            url = payload.get("@odata.nextLink")
            params = {}
        return records

    def get_entity_count(self, entity_name: str, filter: str | None = None) -> int:
        url = f"{self.env_url}/data/{entity_name}/$count"
        params = {"$filter": filter} if filter else {}
        response = requests.get(url, headers=self._headers(), params=params, timeout=60)
        response.raise_for_status()
        return int(response.text)

    def create_entity(self, entity_name: str, payload: dict[str, Any]) -> dict[str, Any]:
        url = f"{self.env_url}/data/{entity_name}"
        headers = {**self._headers(), "Content-Type": "application/json"}
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()
        return response.json()

    def update_entity(self, entity_name: str, key: str, payload: dict[str, Any]) -> None:
        url = f"{self.env_url}/data/{entity_name}{key}"
        headers = {**self._headers(), "Content-Type": "application/json"}
        response = requests.patch(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()
PYEOF

cat > scripts/odata/query_examples.py << 'PYEOF'
"""
Example queries against common accounting-relevant data entities.
Run with: python scripts/odata/query_examples.py
"""

from __future__ import annotations

import os
import pandas as pd
from d365_client import D365Client

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")


def _save(df: pd.DataFrame, filename: str) -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    path = os.path.join(OUTPUT_DIR, filename)
    df.to_csv(path, index=False)
    print(f"Saved {len(df)} rows -> {path}")


def get_open_vendor_invoices(client: D365Client) -> pd.DataFrame:
    records = client.get_entity(
        "VendorInvoiceJournalHeaders",
        select=["InvoiceId", "InvoiceAccount", "InvoiceAmount", "InvoiceDate", "ApprovalStatus"],
        filter="ApprovalStatus ne Microsoft.Dynamics.DataEntities.VendInvoiceApprovalStatus'Approved'",
    )
    return pd.DataFrame(records)


def get_customer_aging(client: D365Client) -> pd.DataFrame:
    records = client.get_entity(
        "CustTransOpenTransactions",
        select=["CustomerAccount", "Invoice", "TransactionDate", "AmountCurDebit", "AmountCurCredit"],
    )
    return pd.DataFrame(records)


def get_chart_of_accounts(client: D365Client) -> pd.DataFrame:
    records = client.get_entity(
        "MainAccounts",
        select=["MainAccountId", "Name", "MainAccountCategory", "Type"],
    )
    return pd.DataFrame(records)


def get_recent_gl_entries(client: D365Client, days: int = 7) -> pd.DataFrame:
    from datetime import datetime, timedelta
    since = (datetime.utcnow() - timedelta(days=days)).strftime("%Y-%m-%dT00:00:00Z")
    records = client.get_entity(
        "GeneralJournalAccountEntries",
        select=["JournalNumber", "AccountDisplayValue", "AmountCurDebit", "AmountCurCredit", "TransDate"],
        filter=f"TransDate ge {since}",
    )
    return pd.DataFrame(records)


if __name__ == "__main__":
    client = D365Client()
    _save(get_open_vendor_invoices(client), "open_vendor_invoices.csv")
    _save(get_customer_aging(client), "customer_aging.csv")
    _save(get_chart_of_accounts(client), "chart_of_accounts.csv")
    _save(get_recent_gl_entries(client), "recent_gl_entries.csv")
PYEOF

cat > scripts/dmf/README.md << 'EOF'
# DMF (Data Management Framework) templates

CSV templates matching D365 data entities, for use with
System administration > Data management > Import.

## Templates included

| Template | Entity | Use case |
|----------|--------|----------|
| `CustomerV3_template.csv` | CustomerV3 | Bulk customer onboarding |
| `VendorV2_template.csv` | VendorV2 | Bulk vendor onboarding |
| `GeneralJournalAccountEntry_template.csv` | GeneralJournalAccountEntry | Manual journal import |

## A note on validation

DMF loads data into a staging table first. A successful staging load does
not guarantee the records post cleanly into the live D365 tables — check
the target error log, not just the staging log, after an import.
EOF

cat > scripts/dmf/templates/CustomerV3_template.csv << 'EOF'
CUSTOMERACCOUNT,ORGANIZATIONNAME,CUSTOMERGROUPID,CURRENCYCODE,PAYMENTTERMS,LANGUAGEID,ADDRESSCOUNTRYREGIONID,ADDRESSSTREET,ADDRESSCITY,PRIMARYCONTACTEMAIL,PRIMARYCONTACTPHONE
CUST-0001,Example Growers Ltd,10,KES,NET30,en-us,KE,Naivasha Industrial Area,Naivasha,accounts@examplegrowers.co.ke,+254700000000
EOF

cat > scripts/dmf/templates/VendorV2_template.csv << 'EOF'
VENDORACCOUNT,ORGANIZATIONNAME,VENDORGROUPID,CURRENCYCODE,PAYMENTTERMS,LANGUAGEID,ADDRESSCOUNTRYREGIONID,ADDRESSSTREET,ADDRESSCITY,PRIMARYCONTACTEMAIL,PRIMARYCONTACTPHONE
VEND-0001,Example Greenhouse Supplies,20,KES,NET30,en-us,KE,Naivasha Industrial Area,Naivasha,sales@examplegreenhouse.co.ke,+254700000001
EOF

cat > scripts/dmf/templates/GeneralJournalAccountEntry_template.csv << 'EOF'
JOURNALNAME,ACCOUNTTYPE,ACCOUNTDISPLAYVALUE,TRANSDATE,DOCUMENTNUMBER,DESCRIPTION,CURRENCYCODE,DEBITAMOUNT,CREDITAMOUNT,DEPARTMENT,COSTCENTER
GenJrn,Ledger,110100,2026-06-24,OPENBAL-0001,Opening balance import - cash,KES,500000.00,0.00,HQ,FINANCE
GenJrn,Ledger,330100,2026-06-24,OPENBAL-0001,Opening balance import - retained earnings,KES,0.00,500000.00,HQ,FINANCE
EOF

cat > scripts/power-automate/README.md << 'EOF'
# Power Automate flows

Documented flow designs for D365-triggered automations, since the real
Power Automate export format is a proprietary zip, not portable as text.

## Flows included

| Flow | Trigger | What it does |
|------|---------|---------------|
| `invoice-approved-notify-teams.json` | Vendor invoice approved | Posts a Teams message with invoice details |
| `new-vendor-created-sync-approval.json` | VendorV2 record created | Routes new vendor to Finance lead for approval |
EOF

cat > scripts/power-automate/flows/invoice-approved-notify-teams.json << 'JSONEOF'
{
  "flow_name": "Vendor invoice approved -> notify Teams",
  "description": "Posts a summary message to the Finance Teams channel whenever a vendor invoice is approved in D365.",
  "trigger": {
    "connector": "Dynamics 365 Finance and Operations",
    "trigger_type": "When a record is created or modified",
    "entity": "VendorInvoiceJournalHeaders",
    "filter": "ApprovalStatus eq 'Approved'"
  },
  "steps": [
    {
      "step": 1,
      "connector": "Dynamics 365 Finance and Operations",
      "action": "Get a record",
      "config": {
        "entity": "VendorInvoiceJournalHeaders",
        "record_id": "@{triggerOutputs()?['body/InvoiceId']}"
      }
    },
    {
      "step": 2,
      "connector": "Microsoft Teams",
      "action": "Post message in a chat or channel",
      "config": {
        "team": "Finance",
        "channel": "Accounts Payable",
        "message_template": "Invoice {InvoiceId} for vendor {InvoiceAccount} approved - amount {InvoiceAmount} {CurrencyCode}."
      }
    }
  ]
}
JSONEOF

cat > scripts/power-automate/flows/new-vendor-created-sync-approval.json << 'JSONEOF'
{
  "flow_name": "New vendor created -> approval before activation",
  "description": "Routes every new vendor record to the Finance lead for approval before it is usable in purchase orders.",
  "trigger": {
    "connector": "Dynamics 365 Finance and Operations",
    "trigger_type": "When a record is created",
    "entity": "VendorV2"
  },
  "steps": [
    {
      "step": 1,
      "connector": "Approvals",
      "action": "Start and wait for an approval",
      "config": {
        "approval_type": "Approve/Reject - First to respond",
        "approver": "finance-lead@plantechkenya.com"
      }
    },
    {
      "step": 2,
      "connector": "Control",
      "action": "Condition",
      "config": {
        "if": "Outcome equals Approve"
      }
    }
  ]
}
JSONEOF

cat > notebooks/explore_d365_data.ipynb << 'JSONEOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": ["# Exploring D365 finance data\n", "\n", "Quick-look notebook for sanity-checking data pulled via the OData client."]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": ["import sys\n", "sys.path.append(\"../scripts/odata\")\n", "\n", "import pandas as pd\n", "import matplotlib.pyplot as plt\n", "\n", "from d365_client import D365Client\n", "\n", "client = D365Client()"]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": ["coa = pd.DataFrame(\n", "    client.get_entity(\n", "        \"MainAccounts\",\n", "        select=[\"MainAccountId\", \"Name\", \"MainAccountCategory\", \"Type\"],\n", "    )\n", ")\n", "coa[\"MainAccountCategory\"].value_counts()"]
  }
 ],
 "metadata": {
  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
  "language_info": {"name": "python", "version": "3.10"}
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
JSONEOF

echo "=== Done ==="
git add -A
git status --short
