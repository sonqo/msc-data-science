library(ggplot2)
library(tidyverse)

greece_population_death_trend <-
  greece_deaths_sex %>%
  group_by(geo_code, year) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  inner_join(population, by = c('geo_code' = 'geo_code', 'year' = 'year')) %>%
  mutate(population = population * 0.000001, deaths = deaths * 0.0001) %>%
  pivot_longer(
    cols = c(population, deaths),
    names_to = "metric_flag",
    values_to = "metric_values"
  )

p8 <-
  ggplot(greece_population_death_trend) +
  geom_line(
    aes(x=year, y=metric_values, color=metric_flag), size=0.75
  ) +
  theme_bw() +
  scale_color_manual(values=c("red1","palegreen3")) +
  scale_x_continuous(breaks = 2011:2020, labels = unique(greece_population_death_trend$year)) +
  labs(title = "Greece's Population and Death Trends", x = '', y = 'Population[millions]  |  Deaths [10 thousands]', color='Trend') +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "none")

europe_population_death_trend <- 
  df %>%
  filter(geo_code != 'EL' & geo_code != 'EU28' & geo_code != 'EU27_2020') %>%
  group_by(geo_code, year) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  inner_join(population, by = c('geo_code' = 'geo_code', 'year' = 'year')) %>%
  mutate(population = population * 0.000001, deaths = deaths * 0.0001) %>%
  group_by(year) %>%
  summarise(deaths = mean(deaths), dementia_deaths = mean(dementia_deaths), population=mean(population)) %>%
  pivot_longer(
    cols = c(population, deaths),
    names_to = "metric_flag",
    values_to = "metric_values"
  )

p9 <-
  ggplot(europe_population_death_trend) +
  geom_line(
    aes(x=year, y=metric_values, color=metric_flag), size=0.75
  ) +
  theme_bw() +
  scale_color_manual(values=c("red1","palegreen3")) +
  scale_x_continuous(breaks = 2011:2021, labels = unique(europe_population_death_trend$year)) +
  labs(title = "Europe's Population and Death Trends", x = '', y = '', color='Trend') +
  theme(plot.title = element_text(hjust = 0.5))

grid.arrange(p8, p9, ncol=2)
