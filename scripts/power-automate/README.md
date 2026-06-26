# Power Automate flows

Documented flow designs for D365-triggered automations, since the real
Power Automate export format is a proprietary zip, not portable as text.

## Flows included

| Flow | Trigger | What it does |
|------|---------|---------------|
| `invoice-approved-notify-teams.json` | Vendor invoice approved | Posts a Teams message with invoice details |
| `new-vendor-created-sync-approval.json` | VendorV2 record created | Routes new vendor to Finance lead for approval |
