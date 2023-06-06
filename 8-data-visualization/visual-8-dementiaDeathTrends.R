library(ggplot2)
library(tidyverse)

greece_dementia_trend <-
  df %>%
  filter(geo_code == 'EL') %>%
  group_by(geo_code, year) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  mutate(dementia_death_ratio = dementia_deaths * 100 / deaths)

europe_dementia_trend <- 
  df %>%
  filter(geo_code != 'EL' & geo_code != 'EU28' & geo_code != 'EU27_2020') %>%
  group_by(geo_code, year) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  group_by(year) %>%
  summarise(deaths = mean(deaths), dementia_deaths = mean(dementia_deaths)) %>%
  mutate(dementia_death_ratio = dementia_deaths * 100 / deaths, geo_code = 'EU')

dementia_trend <- rbind(europe_dementia_trend, greece_dementia_trend)

p10 <-
  ggplot(dementia_trend) +
  geom_line(
    aes(x=year, y=dementia_deaths, color=geo_code), size=0.75
  ) +
  theme_bw() +
  scale_color_manual(values=c("blue","gold")) +
  scale_x_continuous(breaks = 2011:2021, labels = unique(dementia_trend$year)) +
  labs(title = "Absolute Dementia Deaths Trend [2011-2021]", x = '', y = 'Dementia Deaths', color='Region') +
  theme(plot.title = element_text(hjust = 0.5))

p11 <- 
  ggplot(dementia_trend) +
  geom_line(
    aes(x=year, y=dementia_death_ratio, color=geo_code), size=0.75
  ) +
  theme_bw() +
  scale_color_manual(values=c("blue","gold")) +
  scale_x_continuous(breaks = 2011:2021, labels = unique(dementia_trend$year)) +
  labs(title = "Dementia Death Ratio Trend [2011-2021]", x = '', y = 'Dementia Death Ratio [%]', color='Region') +
  theme(plot.title = element_text(hjust = 0.5))

grid.arrange(p10, p11, nrow=2)
