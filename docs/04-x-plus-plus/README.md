# X++ — D365 extension language

Use X++ when configuration alone cannot solve the problem.

## Core principle: extensions not overlayering

Never modify base Microsoft code. Instead extend it:
- ExtensionOf(classStr(ClassName)) — extend a class
- ExtensionOf(tableStr(TableName)) — extend a table
- ExtensionOf(formStr(FormName)) — extend a form

## Chain of Command (CoC)

```xpp
[ExtensionOf(classStr(SalesInvoiceJournalPost))]
final class SalesInvoiceJournalPost_PlanTech_Extension
{
    protected void postLine(SalesLine _salesLine)
    {
        // Logic BEFORE base
        next postLine(_salesLine); // REQUIRED
        // Logic AFTER base
    }
}
```

## Event handlers

```xpp
[PostHandlerFor(classStr(LedgerJournalCheckPost), methodStr(LedgerJournalCheckPost, post))]
public static void LedgerJournalCheckPost_post(XppPrePostArgs args)
{
    // Runs after journal posts to GL
}
```

## When to use X++ vs config

| Requirement | Approach |
|-------------|----------|
| New posting rule | Posting profile config |
| Mandatory field on invoice | Form extension + event handler |
| Auto-populate dimension from SO | CoC on invoice post method |
| Custom validation before payment | Pre-event handler |
| New report format | Electronic Reporting (no code) |
| Complex batch calculation | X++ batch job class |

## Dev environment setup

1. Provision D365 developer VM from LCS
2. Install Visual Studio 2022 with Finance and Operations Tools extension
3. Create new model in AOT > Models > New Model
4. Deploy to sandbox via LCS deployable package
