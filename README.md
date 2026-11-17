# TrendStock — Apparel Demand & Replenishment Planner

A small product case study built around a practical seller problem: **which apparel SKUs should be watched or replenished first?**

TrendStock uses a public Amazon.in apparel seller order dataset to study historical demand by SKU, size, category and location. It then combines that demand signal with stock-on-hand and supplier lead-time inputs to produce a simple reorder suggestion.

> **Scope note:** The public file is an order-line export from an apparel seller operating on Amazon.in. It is not Amazon's internal warehouse or inventory data. Current stock, supplier lead time and safety-stock policy are not present in the source file; they are entered separately by the person using the planner.

## What is included

- A repeatable Python cleaning and analysis pipeline.
- SKU, category/size, daily-demand, state and order-status summary files.
- A rule-based replenishment calculator (no machine-learning model required).
- MySQL 8 schema and business questions as ready-to-run queries.
- An Excel inventory-planning template with formulas.
- Product requirements, metric definitions, experiment plan and rollout roadmap.

**The Power BI dashboard is intentionally not included.** Use the CSV outputs in `data/processed/` as the source for your own report.

## Dataset

The project is designed for the public **Amazon Sale Report** dataset, commonly distributed through Kaggle. Public project references describe the full file as 128,975 rows and 24 columns, covering 31 March 2022 to 29 June 2022. The data is attributed to an Amazon.in apparel seller, not to Amazon's internal systems.

- Kaggle dataset: <https://www.kaggle.com/datasets/thedevastator/unlock-profits-with-e-commerce-sales-data?select=Amazon+Sale+Report.csv>
- Dataset search (alternate source / mirror discovery): <https://www.kaggle.com/search?q=Amazon%20Sale%20Report>
- Dataset details and schema reference: <https://github.com/aashish-kar/amazon-sales-analysis>
- Public sample CSV reference: <https://raw.githubusercontent.com/aashish-kar/amazon-sales-analysis/main/data/raw/Amazon_Sale_Report_sample.csv>
- More detail: [docs/dataset_provenance.md](docs/dataset_provenance.md)

The full CSV is not committed here. It is large and should be obtained from its source. See [data/README.md](data/README.md).

## Quick start

### 1. Set up Python

Python 3.10 or newer is recommended.

```bash
python -m venv .venv
# Windows PowerShell
.venv\Scripts\Activate.ps1
# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
```

### 2. Add the full dataset

Download `Amazon Sale Report.csv` from the dataset source and place it here:

```text
data/raw/Amazon Sale Report.csv
```

The project can also be run against the included sample:

```bash
python scripts/run_pipeline.py --input data/sample/amazon_apparel_sample.csv
```

For the full file:

```bash
python scripts/run_pipeline.py --input "data/raw/Amazon Sale Report.csv"
```

The pipeline writes the cleaned file and analysis outputs to `data/processed/`.

### 3. Prepare replenishment suggestions

Copy `data/processed/inventory_inputs_template.csv` into `data/inputs/inventory_inputs_template.csv`. Fill in `current_stock` and `lead_time_days` for the SKUs you want to review. You can change the default safety-stock and review-period days as well.

Then run:

```bash
python scripts/run_pipeline.py \
  --input "data/raw/Amazon Sale Report.csv" \
  --inventory-file data/inputs/inventory_inputs_template.csv
```

The result is written to `data/processed/replenishment_recommendations.csv`.

### 4. Run the tests

```bash
python -m unittest discover -s tests -v
```

## Project structure

```text
TrendStock/
├── data/
│   ├── raw/                  # Put the downloaded source CSV here (not committed)
│   ├── sample/               # Small source excerpt for a quick run
│   ├── processed/            # Generated CSV outputs (not committed)
│   └── inputs/               # Seller stock / lead-time inputs
├── docs/                     # Product and analysis documents
├── excel/                    # Excel planning template
├── prototype/                # Clickable reorder-planning prototype
├── scripts/                  # Command-line entry point
├── sql/                      # MySQL schema and analysis queries
├── src/trendstock/           # Data preparation and reorder logic
└── tests/                    # Unit tests
```

## How the reorder suggestion works

For each SKU:

- **Average daily demand** = units ordered in the selected recent window ÷ number of calendar days in that window.
- **Reorder point** = average daily demand × (supplier lead time + safety-stock days).
- **Target stock** = average daily demand × (supplier lead time + safety-stock days + review-period days).
- **Suggested order quantity** = max(0, target stock − current stock).

This is a transparent starting rule, not a demand-forecasting model. It assumes the recent demand rate is a reasonable short-term planning proxy. The team should validate it with a pilot before using it for purchasing decisions.

## Important interpretation notes

1. The file contains order lines, not necessarily one row per distinct customer order. `order_id` can repeat across different lines. Count distinct orders when an order count is needed; do not deduplicate the dataset by order ID.
2. The dataset covers roughly three months in 2022. Any demand rate is historical and should not be presented as a current forecast.
3. The `quantity` field is used for unit demand. Cancelled lines are excluded from the demand signal. Return/rejection statuses are retained as a separate status group; the demand metric represents placed demand excluding cancellations, not final retained sales.
4. The dataset does not include stock-on-hand snapshots, supplier lead times, purchase orders, margin, impressions or page views. These cannot be derived from this file.
5. The included sample is only for checking the code path. Do not draw commercial conclusions from the sample.

## Product framing

TrendStock is positioned as a **seller-side decision-support tool**, not an Amazon product and not a claim about Amazon's internal operations. Its first use case is a small apparel seller who needs a clearer view of demand across style, SKU and size before planning replenishment.

See [docs/PRD.md](docs/PRD.md) for the product definition and [docs/portfolio_case_study.md](docs/portfolio_case_study.md) for an interview-ready narrative.

## License and attribution

The code and documents in this repository are provided under the MIT License. The underlying dataset remains subject to the terms set by its original publisher. It is not redistributed here; download it from the original source and follow that source's terms.
