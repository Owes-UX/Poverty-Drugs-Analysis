# Does Poverty Drive Drug Deaths?

> **A cross-country statistical analysis testing one of the most common assumptions in public health.**

**Data Management & Analysis (Unit 2)**  
Sapienza University of Rome

**Authors**
- Owes Mehboob (2173047)
- Sanya Khan (2172944)

---

## Overview

The belief that **poverty leads to drug abuse and drug-related deaths** is widespread, but surprisingly rarely tested at the country level.

This project examines whether national income is statistically associated with drug-use disorder mortality across **185 countries** using publicly available international datasets.

Rather than relying on intuition, we evaluate the relationship using five different statistical techniques.

### Research Question

> **Across countries, is GDP per capita associated with drug-use disorder death rates?**

The analysis focuses on **2019**, the last complete pre-COVID year, and investigates **association rather than causation**.

---

## Key Findings

The results consistently contradict the common assumption.

Across countries:

- Countries with **higher GDP per capita tend to report higher drug-use disorder mortality**
- The relationship is statistically significant across multiple methods
- Removing the United States (an extreme outlier) does **not** change the overall conclusion

This project **does not claim that wealth causes drug deaths**.

Instead, the observed pattern is consistent with factors such as:

- stronger health surveillance systems in wealthier countries,
- better mortality reporting,
- and major regional epidemics (such as the US opioid crisis).

---

## Statistical Methods

Five independent hypotheses were tested.

| Hypothesis | Method | Main Result |
|------------|--------|-------------|
| H1 | Pearson & Spearman Correlation | Positive correlation (p < 0.001) |
| H2 | Welch Two-Sample t-test | Richer countries show significantly higher mortality |
| H3 | One-Way ANOVA | Significant regional differences |
| H4 | Linear Regression | Positive GDP coefficient (R² ≈ 0.13) |
| H5 | Robustness Analysis | Results remain after excluding the United States |

---

## Dataset

The final analysis combines two international datasets.

| Variable | Source |
|----------|--------|
| Drug-use disorder deaths (per 100,000) | WHO Global Health Estimates (via Our World in Data) |
| GDP per capita (PPP-adjusted) | World Bank World Development Indicators (via Our World in Data) |

### Final Sample

- **185 countries**
- **2019 only**
- Complete observations
- Joined using ISO-3 country codes

---

## Repository Structure

```text
.
├── README.md
├── poverty_drugs_deck.pptx
│
├── data/
│   ├── gdp-per-capita-worldbank.csv
│   ├── death-rates-from-drug-use-disorders-who.csv
│   └── world.geojson
│
├── scripts/
│   ├── 01_clean_and_merge.R
│   ├── 02_analysis.R
│   └── 03_make_charts.R
│
└── output/
    ├── analysis_ready.csv
    ├── results.txt
    └── *.png
```

---

## Workflow

The project is fully reproducible.

### Step 1 — Data Cleaning

- Import raw WHO and World Bank datasets
- Filter to sovereign countries
- Keep observations from 2019
- Merge by ISO-3 country code
- Remove missing observations

Output:

```
output/analysis_ready.csv
```

---

### Step 2 — Statistical Analysis

Runs every hypothesis test:

- Pearson correlation
- Spearman correlation
- Welch t-test
- One-way ANOVA
- Linear regression
- Assumption diagnostics
- Robustness analysis (US removed)

Output:

```
output/results.txt
```

---

### Step 3 — Visualization

Generates every figure used in the presentation.

Output:

```
output/*.png
```

---

## Reproducing the Analysis

Requires **R 4.3+**

Install required packages:

```r
install.packages(c(
  "dplyr",
  "tidyr",
  "readr",
  "stringr",
  "ggplot2",
  "scales",
  "lmtest",
  "sf",
  "ggrepel",
  "e1071",
  "patchwork"
))
```

Run the scripts in order:

```r
setwd("scripts")

source("01_clean_and_merge.R")
source("02_analysis.R")
source("03_make_charts.R")
```

---

## Methodological Notes

### Why only 2019?

2019 is the last year before COVID-19 substantially affected international mortality reporting, providing the most complete and comparable cross-country snapshot.

### Why log-transform GDP?

GDP per capita is highly right-skewed.

Applying the logarithm substantially reduces skewness and produces a more suitable predictor for linear regression.

### Why report both Pearson and Spearman?

Pearson measures linear association.

Spearman measures rank-order association and is more robust to outliers.

Reporting both demonstrates that the findings do not depend on a single statistical assumption.

### Regression Diagnostics

Regression assumptions were formally evaluated using:

- Shapiro–Wilk test
- Breusch–Pagan test

Both indicate that the United States behaves as an influential outlier, motivating the robustness analysis performed in H5.

---

## Limitations

This is an **ecological** (country-level) study.

Consequently:

- Association should **not** be interpreted as causation.
- Results cannot be generalized to individuals.
- Differences in national reporting quality may influence observed mortality.
- Other socioeconomic and healthcare variables were not modeled.

---

## Presentation

The repository also contains the complete presentation used for the course submission.

```
poverty_drugs_deck.pptx
```

All numerical results appearing in the presentation were generated directly from the accompanying R scripts.

---

## License

This repository was created for academic purposes.

The datasets remain subject to the licensing terms of their original providers (WHO, World Bank, and Our World in Data).

---

## Acknowledgements

- World Health Organization
- World Bank
- Our World in Data
- Natural Earth

---

## AI Disclosure

AI tools (Claude by Anthropic) were used during development for code scaffolding, figure refinement, slide design, and editorial assistance, in accordance with the course disclosure requirements.

All statistical analyses, interpretation, and final conclusions were verified by the authors.
