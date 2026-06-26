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
