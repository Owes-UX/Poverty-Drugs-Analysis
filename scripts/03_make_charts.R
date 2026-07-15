# 03_make_charts.R
#
# Generates every chart used in the presentation, in ggplot2, using the
# "Clinical Ledger" palette (deep ink, bone paper, oxblood, muted gold)
# so they match the slides.
#
# Input:  ../output/analysis_ready.csv, ../data/world.geojson
# Output: 7 PNG files in ../output/

library(dplyr)
library(readr)
library(ggplot2)
library(scales)
library(sf)

df <- read_csv("../output/analysis_ready.csv", show_col_types = FALSE)

# ---- "Clinical Ledger" palette ----
INK   <- "#161513"
BONE  <- "#EDE6D8"
BLOOD <- "#7A2E3A"
RUST  <- "#B8563F"
GOLD  <- "#E9B44C"
MOSS  <- "#3E4C5A"

ledger_theme <- theme_minimal(base_family = "serif") +
  theme(
    plot.background  = element_rect(fill = BONE, color = NA),
    panel.background = element_rect(fill = BONE, color = NA),
    panel.grid.major = element_line(color = INK, linewidth = 0.08),
    panel.grid.minor = element_blank(),
    axis.text  = element_text(color = INK),
    axis.title = element_text(color = INK, size = 11),
    plot.title = element_text(color = INK, face = "bold", size = 13),
    legend.background = element_rect(fill = BONE, color = NA),
    legend.text  = element_text(color = INK),
    legend.title = element_blank()
  )

# ============================================================
# 1. Scatter: GDP vs. drug death rate, colored by region
# ============================================================
region_colors <- c(
  "Africa" = "#C99A5B", "Asia" = "#8A9BA8", "Europe" = BLOOD,
  "North America" = RUST, "Oceania" = "#6B7280", "South America" = GOLD
)

label_countries <- df %>% filter(entity %in% c("United States", "Canada", "Iceland", "Kiribati"))

p_scatter <- ggplot(df, aes(x = gdp_per_capita, y = drug_death_rate)) +
  geom_point(aes(color = owid_region), size = 2.6, alpha = 0.9) +
  geom_smooth(method = "lm", formula = y ~ log(x), se = FALSE,
              color = INK, linetype = "dashed", linewidth = 0.9) +
  ggrepel::geom_text_repel(data = label_countries, aes(label = entity),
                            color = INK, fontface = "bold", size = 3.2,
                            max.overlaps = 20) +
  scale_x_log10(labels = label_number(big.mark = ",")) +
  scale_color_manual(values = region_colors) +
  labs(x = "GDP per capita (2019, PPP-adjusted USD, log scale)",
       y = "Drug-use disorder deaths per 100,000") +
  ledger_theme

ggsave("../output/plot_scatter.png", p_scatter, width = 11, height = 6.6, dpi = 150, bg = BONE)
cat("Saved plot_scatter.png\n")

# ============================================================
# 2. Boxplot: richer half vs. poorer half
# ============================================================
df$income_group <- factor(df$income_group, levels = c("Poorer half", "Richer half"))

p_box <- ggplot(df, aes(x = income_group, y = drug_death_rate, fill = income_group)) +
  geom_boxplot(linewidth = 0.8, outlier.size = 1.5) +
  scale_y_continuous(trans = "log1p", breaks = c(0, 1, 5, 10, 20)) +
  scale_fill_manual(values = c("Poorer half" = MOSS, "Richer half" = BLOOD)) +
  labs(x = NULL, y = "Drug deaths per 100,000 (log scale)") +
  ledger_theme +
  theme(legend.position = "none")

ggsave("../output/plot_boxplot.png", p_box, width = 7.4, height = 5.1, dpi = 150, bg = BONE)
cat("Saved plot_boxplot.png\n")

# ============================================================
# 3. Region bar chart
# ============================================================
region_stats <- df %>%
  group_by(owid_region) %>%
  summarise(n = n(), mean = mean(drug_death_rate)) %>%
  arrange(mean) %>%
  mutate(owid_region = factor(owid_region, levels = owid_region))

p_region <- ggplot(region_stats, aes(x = mean, y = owid_region, fill = mean)) +
  geom_col(width = 0.72) +
  geom_text(aes(label = sprintf("%.2f", mean)), hjust = -0.15, color = INK,
            fontface = "bold", size = 4.2) +
  scale_fill_gradient(low = "#C8B79A", high = BLOOD, guide = "none") +
  scale_x_continuous(limits = c(0, 2.6), expand = c(0, 0)) +
  labs(x = "Mean drug-use disorder deaths per 100,000", y = NULL) +
  ledger_theme +
  theme(panel.grid.major.y = element_blank())

ggsave("../output/plot_region.png", p_region, width = 8.2, height = 5.0, dpi = 150, bg = BONE)
cat("Saved plot_region.png\n")

# ============================================================
# 4. EDA histogram: raw GDP vs. log(GDP)
# ============================================================
library(e1071)  # for skewness()
# type=1 matches scipy.stats.skew()'s default convention, used on the slides
skew_raw <- skewness(df$gdp_per_capita, type = 1)
skew_log <- skewness(df$log_gdp, type = 1)

p_hist_raw <- ggplot(df, aes(x = gdp_per_capita)) +
  geom_histogram(bins = 28, fill = RUST, color = BONE, linewidth = 0.3) +
  labs(title = sprintf("Raw GDP per capita\nskewness = %.2f", skew_raw),
       x = "GDP per capita (USD)", y = "Number of countries") +
  ledger_theme

p_hist_log <- ggplot(df, aes(x = log_gdp)) +
  geom_histogram(bins = 28, fill = MOSS, color = BONE, linewidth = 0.3) +
  labs(title = sprintf("log(GDP per capita)\nskewness = %.2f", skew_log),
       x = "log(GDP per capita)", y = "Number of countries") +
  ledger_theme

library(patchwork)
p_eda <- p_hist_raw + p_hist_log
ggsave("../output/plot_eda_hist.png", p_eda, width = 11, height = 4.6, dpi = 150, bg = BONE)
cat(sprintf("Saved plot_eda_hist.png (skew: raw=%.3f, log=%.3f)\n", skew_raw, skew_log))

# ============================================================
# 5. Forest plot: with-US vs. without-US, all four robustness stats
# ============================================================
df_no_us <- df %>% filter(entity != "United States")

r_with    <- cor.test(df$gdp_per_capita, df$drug_death_rate)$estimate
r_without <- cor.test(df_no_us$gdp_per_capita, df_no_us$drug_death_rate)$estimate
rs_with    <- cor.test(df$gdp_per_capita, df$drug_death_rate, method = "spearman")$estimate
rs_without <- cor.test(df_no_us$gdp_per_capita, df_no_us$drug_death_rate, method = "spearman")$estimate
r_grp <- df %>% filter(income_group == "Richer half") %>% pull(drug_death_rate)
p_grp <- df %>% filter(income_group == "Poorer half") %>% pull(drug_death_rate)
p_with <- t.test(r_grp, p_grp)$p.value
r_grp2 <- df_no_us %>% filter(income_group == "Richer half") %>% pull(drug_death_rate)
p_grp2 <- df_no_us %>% filter(income_group == "Poorer half") %>% pull(drug_death_rate)
p_without <- t.test(r_grp2, p_grp2)$p.value
r2_with    <- summary(lm(drug_death_rate ~ log_gdp, data = df))$r.squared
r2_without <- summary(lm(drug_death_rate ~ log_gdp, data = df_no_us))$r.squared

forest_data <- tibble(
  metric = factor(c("Pearson r", "Spearman rho", "t-test p-value", "Regression R2"),
                   levels = rev(c("Pearson r", "Spearman rho", "t-test p-value", "Regression R2"))),
  with_us    = c(r_with, rs_with, p_with, r2_with),
  without_us = c(r_without, rs_without, p_without, r2_without)
)

p_forest <- ggplot(forest_data) +
  geom_segment(aes(x = with_us, xend = without_us, y = metric, yend = metric),
               color = "#8F8879", linewidth = 1.1) +
  geom_point(aes(x = with_us, y = metric), color = "#8F8879", size = 5) +
  geom_point(aes(x = without_us, y = metric), color = GOLD, size = 5) +
  facet_wrap(~metric, scales = "free_x", ncol = 1, strip.position = "left") +
  labs(x = NULL, y = NULL) +
  ledger_theme +
  theme(strip.text = element_text(color = INK, face = "bold", size = 11),
        strip.background = element_blank(),
        axis.text.y = element_blank())

ggsave("../output/plot_forest.png", p_forest, width = 8.4, height = 5.6, dpi = 150, bg = BONE)
cat("Saved plot_forest.png\n")

# ============================================================
# 6 & 7. World maps: GDP quartile and drug-death quartile
# ============================================================
world <- st_read("../data/world.geojson", quiet = TRUE)
world <- world %>% left_join(df %>% select(code, income_q, drug_q), by = c("ISO_A3" = "code"))

ramp <- c("#E4C99B", "#CF9A5F", "#B0563D", "#7A2E3A")

plot_quartile_map <- function(data, fill_col, title) {
  ggplot(data) +
    geom_sf(aes(fill = factor(!!sym(fill_col))), color = BONE, linewidth = 0.1) +
    scale_fill_manual(values = ramp, na.value = "#DDD5C4", guide = "none") +
    coord_sf(xlim = c(-170, 190), ylim = c(-58, 85), expand = FALSE) +
    labs(title = title) +
    theme_void(base_family = "serif") +
    theme(plot.background = element_rect(fill = BONE, color = NA),
          plot.title = element_text(color = INK, face = "bold", size = 14, hjust = 0))
}

p_map1 <- plot_quartile_map(world, "income_q", "GDP PER CAPITA \u2014 quartile")
p_map2 <- plot_quartile_map(world, "drug_q", "DRUG DEATH RATE \u2014 quartile")

p_maps <- p_map1 / p_map2  # patchwork vertical stack
ggsave("../output/world_maps.png", p_maps, width = 11, height = 7.4, dpi = 200, bg = BONE)
cat("Saved world_maps.png\n")

# Legend strip
legend_data <- tibble(x = 1:4, label = c("Lowest\nquartile", "Q2", "Q3", "Highest\nquartile"))
p_legend <- ggplot(legend_data, aes(x = x, y = 1, fill = factor(x))) +
  geom_tile(width = 0.9, height = 1) +
  geom_text(aes(label = label), y = 0.3, color = INK, size = 3) +
  scale_fill_manual(values = ramp, guide = "none") +
  theme_void() +
  theme(plot.background = element_rect(fill = BONE, color = NA))
ggsave("../output/map_legend.png", p_legend, width = 5.5, height = 0.55, dpi = 200, bg = BONE)
cat("Saved map_legend.png\n")

cat("\nAll 7 charts generated in ../output/\n")
