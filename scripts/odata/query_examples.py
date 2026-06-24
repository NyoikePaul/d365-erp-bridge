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
