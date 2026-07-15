# 01_clean_and_merge.R
#
# Loads the two raw public datasets, cleans them, and merges them into a
# single analysis-ready table for 2019 (the last complete pre-COVID year).
#
# Inputs  (in ../data/):
#   gdp-per-capita-worldbank.csv                    World Bank WDI, via Our World in Data
#   death-rates-from-drug-use-disorders-who.csv     WHO Global Health Estimates, via Our World in Data
#
# Output (in ../output/):
#   analysis_ready.csv

library(dplyr)
library(readr)
library(stringr)

YEAR <- 2019

# ---------------------------------------------------------------------------
# 1. Load raw files
# ---------------------------------------------------------------------------
gdp <- read_csv("../data/gdp-per-capita-worldbank.csv", show_col_types = FALSE) %>%
  rename(gdp_per_capita = ny_gdp_pcap_pp_kd)

drugs_raw <- read_csv("../data/death-rates-from-drug-use-disorders-who.csv", show_col_types = FALSE)
drug_col  <- names(drugs_raw)[str_detect(names(drugs_raw), "death_rate")][1]
drugs <- drugs_raw %>% rename(drug_death_rate = !!drug_col)

cat(sprintf("GDP raw:   %d rows, %d entities, %d-%d\n",
            nrow(gdp), n_distinct(gdp$entity), min(gdp$year), max(gdp$year)))
cat(sprintf("Drugs raw: %d rows, %d entities, %d-%d\n",
            nrow(drugs), n_distinct(drugs$entity), min(drugs$year), max(drugs$year)))

# ---------------------------------------------------------------------------
# 2. Preprocessing
#    - keep real countries only (3-letter ISO code, drop OWID's aggregate
#      "OWID_WRL" world-total row and any row with a missing code)
#    - restrict to YEAR
#    - merge on ISO code
#    - drop rows missing either variable
# ---------------------------------------------------------------------------
keep_real_countries <- function(df) {
  df %>% filter(!is.na(code), nchar(code) == 3, code != "OWID_WRL")
}

gdp   <- keep_real_countries(gdp)
drugs <- keep_real_countries(drugs)

gdp_year   <- gdp   %>% filter(year == YEAR)
drugs_year <- drugs %>% filter(year == YEAR)

before <- nrow(drugs_year)
merged <- drugs_year %>%
  inner_join(gdp_year %>% select(code, gdp_per_capita, owid_region), by = "code") %>%
  filter(!is.na(drug_death_rate), !is.na(gdp_per_capita))

cat(sprintf("\nMerged rows for %d: %d -> %d after dropping missing values\n",
            YEAR, before, nrow(merged)))

# ---------------------------------------------------------------------------
# 3. Feature engineering
#    - log(GDP): raw GDP is heavily right-skewed (skewness ~1.68); logging
#      brings it close to symmetric (~-0.25), which is why the regression
#      slide uses log(GDP) rather than raw GDP.
#    - income_group: median split, used for the two-sample t-test
#    - income_q / drug_q: quartile bins, used for the world-map slide
#      (course technique: binning a quantitative variable, section 5.1.4)
# ---------------------------------------------------------------------------
merged <- merged %>%
  mutate(
    log_gdp      = log(gdp_per_capita),
    median_gdp    = median(gdp_per_capita),
    income_group = if_else(gdp_per_capita > median_gdp, "Richer half", "Poorer half"),
    income_q     = as.integer(ntile(gdp_per_capita, 4)) - 1L,
    drug_q       = as.integer(ntile(drug_death_rate, 4)) - 1L
  ) %>%
  select(-median_gdp)

# ---------------------------------------------------------------------------
# 4. Save
# ---------------------------------------------------------------------------
dir.create("../output", showWarnings = FALSE, recursive = TRUE)
write_csv(merged, "../output/analysis_ready.csv")

cat(sprintf("\nFinal sample: %d countries\n", nrow(merged)))
cat(sprintf("Median GDP per capita (split point): $%s\n",
            format(round(median(merged$gdp_per_capita)), big.mark = ",")))
cat("Saved -> ../output/analysis_ready.csv\n")
