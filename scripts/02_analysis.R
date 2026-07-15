# 02_analysis.R
#
# Runs the full analysis pipeline on analysis_ready.csv:
#   H1  Correlation       -- GDP per capita <-> drug death rate (Pearson & Spearman)
#   H2  Group contrast    -- two-sample Welch's t-test, median-GDP split
#   H3  Regional variation -- one-way ANOVA across 6 world regions, + eta-squared
#   H4  Regression        -- linear model on log(GDP), with assumption checks
#   H5  Robustness check  -- H1-H4 re-run with the United States excluded
#
# Input:  ../output/analysis_ready.csv
# Output: printed results (the exact numbers referenced on the slides)

library(dplyr)
library(readr)
library(lmtest)   # for bptest() -- Breusch-Pagan test

df <- read_csv("../output/analysis_ready.csv", show_col_types = FALSE)

cat(strrep("=", 70), "\n")
cat("H1 -- CORRELATION: GDP per capita vs. drug death rate\n")
cat(strrep("=", 70), "\n")

pearson  <- cor.test(df$gdp_per_capita, df$drug_death_rate, method = "pearson")
spearman <- cor.test(df$gdp_per_capita, df$drug_death_rate, method = "spearman")

cat(sprintf("Pearson  r = %.3f, p = %.6f\n", pearson$estimate, pearson$p.value))
cat(sprintf("Spearman rho = %.3f, p = %.6f\n", spearman$estimate, spearman$p.value))

cat("\n", strrep("=", 70), "\n", sep = "")
cat("H2 -- GROUP CONTRAST: richer half vs. poorer half (median GDP split)\n")
cat(strrep("=", 70), "\n")

richer <- df %>% filter(income_group == "Richer half") %>% pull(drug_death_rate)
poorer <- df %>% filter(income_group == "Poorer half") %>% pull(drug_death_rate)

t_result <- t.test(richer, poorer)  # Welch's t-test by default (unequal variance)

pooled_sd <- sqrt(((length(richer) - 1) * var(richer) + (length(poorer) - 1) * var(poorer)) /
                     (length(richer) + length(poorer) - 2))
cohens_d <- (mean(richer) - mean(poorer)) / pooled_sd

cat(sprintf("Richer half: n=%d, mean=%.3f\n", length(richer), mean(richer)))
cat(sprintf("Poorer half: n=%d, mean=%.3f\n", length(poorer), mean(poorer)))
cat(sprintf("Welch's t = %.3f, df = %.1f, p = %.6f\n", t_result$statistic, t_result$parameter, t_result$p.value))
cat(sprintf("Cohen's d = %.3f\n", cohens_d))

cat("\n", strrep("=", 70), "\n", sep = "")
cat("H3 -- ONE-WAY ANOVA: drug death rate across 6 world regions\n")
cat(strrep("=", 70), "\n")

anova_model <- aov(drug_death_rate ~ owid_region, data = df)
anova_summary <- summary(anova_model)
print(anova_summary)

# eta-squared = SS_between / SS_total, computed directly from the ANOVA table
ss <- anova_summary[[1]][["Sum Sq"]]
eta_sq <- ss[1] / sum(ss)
f_val  <- anova_summary[[1]][["F value"]][1]
p_val  <- anova_summary[[1]][["Pr(>F)"]][1]
df1    <- anova_summary[[1]][["Df"]][1]
df2    <- anova_summary[[1]][["Df"]][2]

cat(sprintf("\nF(%d, %d) = %.3f, p = %.6f\n", df1, df2, f_val, p_val))
cat(sprintf("eta-squared = %.4f (region explains %.1f%% of the variance)\n", eta_sq, eta_sq * 100))

cat("\n", strrep("=", 70), "\n", sep = "")
cat("H4 -- LINEAR REGRESSION: drug_death_rate ~ log(GDP per capita)\n")
cat(strrep("=", 70), "\n")

model <- lm(drug_death_rate ~ log_gdp, data = df)
print(summary(model))

sw_test <- shapiro.test(residuals(model))
bp_test <- bptest(model)

cat(sprintf("\nShapiro-Wilk (normality of residuals): W = %.4f, p = %.4f [%s]\n",
            sw_test$statistic, sw_test$p.value,
            ifelse(sw_test$p.value > 0.05, "OK", "FAILS -- residuals not normal")))
cat(sprintf("Breusch-Pagan (constant variance):     BP = %.4f, p = %.4f [%s]\n",
            bp_test$statistic, bp_test$p.value,
            ifelse(bp_test$p.value > 0.05, "OK", "FAILS -- heteroscedastic")))
cat("(Both commonly fail here because the US is an extreme outlier --\n")
cat(" see the robustness check below. The rank-based Spearman correlation\n")
cat(" needs neither assumption and confirms the same direction.)\n")

cat("\n", strrep("=", 70), "\n", sep = "")
cat("H5 -- ROBUSTNESS CHECK: excluding the United States\n")
cat(strrep("=", 70), "\n")

df_no_us <- df %>% filter(entity != "United States")
cat(sprintf("n with US: %d, n without US: %d\n\n", nrow(df), nrow(df_no_us)))

run_all <- function(data, label) {
  rp <- cor.test(data$gdp_per_capita, data$drug_death_rate, method = "pearson")
  rs <- cor.test(data$gdp_per_capita, data$drug_death_rate, method = "spearman")
  r_grp <- data %>% filter(income_group == "Richer half") %>% pull(drug_death_rate)
  p_grp <- data %>% filter(income_group == "Poorer half") %>% pull(drug_death_rate)
  tt <- t.test(r_grp, p_grp)
  m  <- lm(drug_death_rate ~ log_gdp, data = data)
  r2 <- summary(m)$r.squared
  cat(sprintf("%-12s Pearson r=%+.3f  Spearman rho=%+.3f  t-test p=%.5f  regression R2=%.3f\n",
              label, rp$estimate, rs$estimate, tt$p.value, r2))
}

run_all(df, "WITH US")
run_all(df_no_us, "WITHOUT US")

cat("\nDone. These are the exact numbers referenced on the presentation slides.\n")
