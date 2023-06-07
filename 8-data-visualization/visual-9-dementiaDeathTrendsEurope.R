library(ggplot2)
library(gridExtra)
library(tidyverse)

key_countries_dementia_trend <- 
  df %>%
  filter(geo_code == c('DE', 'ES', 'IT', 'FR', 'TR')) %>%
  group_by(geo_code, year) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  mutate(dementia_death_ratio = dementia_deaths * 100 / deaths )

p12 <-
  ggplot(key_countries_dementia_trend) +
  geom_smooth(
    aes(x=year, y=dementia_death_ratio, color=geo_code), size=0.75, se = FALSE
  ) +
  theme_bw() +
  scale_color_manual(values=c("#E65271","#FAD26D", "#43D3A0", "#3488B0", "#143A4B")) +
  scale_x_continuous(breaks = 2011:2021, labels = unique(key_countries_dementia_trend$year)) +
  labs(title = "Dementia Death Ratio Trend | Key European Countries\n", x = '', y = 'Dementia Death Ratio [%]', color='Country') +
  theme(plot.title = element_text(hjust = 0.5))

grid.arrange(p10, p11, p12, nrow=3)
