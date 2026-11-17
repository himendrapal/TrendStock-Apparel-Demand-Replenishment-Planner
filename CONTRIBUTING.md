# Working on TrendStock

Keep the data rules and formula definitions in sync across the Python code, SQL and Excel workbook.

Before submitting a change:

1. Run the sample pipeline.
2. Run `python -m unittest discover -s tests -v`.
3. Check that no source data or seller stock data has been committed accidentally.
4. Update the relevant product and metric documentation when calculation logic changes.

Do not add the full source dataset to Git. Keep the original publisher's terms attached to any data used outside the local project.
