.PHONY: sample test

sample:
	python scripts/run_pipeline.py --input data/sample/amazon_apparel_sample.csv

test:
	python -m unittest discover -s tests -v
