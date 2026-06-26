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
