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
