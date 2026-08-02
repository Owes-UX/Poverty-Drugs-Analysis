# Does Poverty Drive Drug Deaths?

> **A cross-country statistical analysis testing one of the most common assumptions in public health.**

**Data Management & Analysis (Unit 2)**  
**Sapienza University of Rome**

**Authors**

- **Owes Mehboob** — 2173047
- **Sanya Khan** — 2172944

---

## 📖 Overview

The idea that *poverty causes drug problems* is widely accepted, but surprisingly rarely tested with international data.

This project investigates a simple question:

> **Across countries, is national income associated with drug-use disorder mortality?**

Using publicly available data from the **World Health Organization (WHO)** and the **World Bank**, we analyzed **185 countries** using multiple statistical techniques to determine whether wealthier nations experience lower drug-related mortality—or whether the data tell a different story.

The study focuses on **2019**, the last complete pre-COVID year, providing a consistent snapshot before the pandemic affected health reporting worldwide.

---

## 🔍 Key Findings

Five independent statistical analyses were performed.

| Test | Result |
|------|--------|
| Pearson Correlation | **r = +0.414**, *p* < 0.001 |
| Spearman Correlation | **ρ = +0.473**, *p* < 0.001 |
| Welch Two-Sample t-test | **t = 3.77**, *p* < 0.001 |
| One-Way ANOVA | **F(5,179) = 4.34**, *p* < 0.001 |
| Linear Regression | **R² = 0.128**, *p* < 0.001 |
| Robustness Check | Results remain significant after excluding the United States |

### Main Finding

Contrary to the common assumption, **higher-income countries report higher drug-use disorder mortality rates.**

This project demonstrates an **association**, **not causation**. Possible explanations—including reporting capacity, surveillance quality, and the US opioid epidemic—are discussed, but not claimed as causal.

---

## 📂 Repository Structure

```text
.
├── README.md
├── poverty_drugs_deck.pptx          # Final presentation
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

## ⚙️ Reproducing the Analysis

Install the required R packages:

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

Run the analysis:

```r
source("scripts/01_clean_and_merge.R")
source("scripts/02_analysis.R")
source("scripts/03_make_charts.R")
```

Outputs are automatically generated inside:

```
output/
```

---

## 🧪 Methodology

The workflow consists of three stages:

### 1. Data Preparation

- Import WHO and World Bank datasets
- Filter to sovereign countries
- Restrict both datasets to **2019**
- Merge using ISO-3 country codes
- Remove incomplete observations

Final sample:

**185 countries**

### 2. Statistical Analysis

The project evaluates the relationship using:

- Pearson correlation
- Spearman correlation
- Welch's t-test
- One-Way ANOVA
- Linear regression
- Regression diagnostics
- Robustness analysis (excluding the United States)

### 3. Visualization

All charts used in the presentation are generated directly from the analysis scripts using **ggplot2**.

---

## 📊 Data Sources

| Dataset | Source |
|---------|--------|
| Drug-use disorder mortality | WHO Global Health Estimates (via Our World in Data) |
| GDP per capita (PPP) | World Bank World Development Indicators (via Our World in Data) |
| Country boundaries | Natural Earth |

---

## 💻 Tech Stack

- R
- dplyr
- ggplot2
- sf
- lmtest
- patchwork
- ggrepel

---

## ⚠️ Limitations

- Country-level (ecological) analysis
- Association does **not** imply causation
- Differences in national reporting quality may influence results
- Other socioeconomic factors were not included in the model

---

## 🙏 Acknowledgements

This project uses publicly available datasets provided by:

- World Health Organization (WHO)
- World Bank
- Our World in Data
- Natural Earth

---

## 🤖 AI Disclosure

Claude (Anthropic) was used for code scaffolding, and editorial assistance in accordance with the course disclosure requirements.
The statistical methodology, analysis, interpretation, and conclusions presented in this repository were verified by the authors.
