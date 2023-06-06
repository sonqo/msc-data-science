library(ggpubr)
library(ggplot2)
library(gridExtra)
library(tidyverse)

greece_deaths_age <- df
greece_deaths_age$age <-
  ifelse(
    greece_deaths_age$age == '60-75 years' | greece_deaths_age$age == '75-90 years' | greece_deaths_age$age == 'Older than 90 years',
    "Older than 60 years",
    "Younger than 60 years"
  )

greece_deaths_age <-
  greece_deaths_age %>%
  filter(geo_code == 'EL') %>%
  group_by(geo_code, year, age) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths))

greece_deaths_age$dementia_death_ratio <- greece_deaths_age$dementia_deaths * 100 / greece_deaths_age$deaths

p7 <-
  ggplot(greece_deaths_age) +
  geom_smooth(
    aes(x=year, y=dementia_deaths, colour=age), size=0.75, method = "loess", se = FALSE
  ) +
  scale_x_continuous(breaks = 2011:2020, labels = unique(greece_deaths_age$year)) +
  scale_color_manual(values=c("#ED9B83","#3FBDBE")) +
  labs(title = "", x = "", y = "", color='Age Group') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

p8 <-
  ggplot(greece_deaths_age) +
  geom_smooth(
    aes(x=year, y=dementia_death_ratio, colour=age), size=0.75, method = "loess", se = FALSE
  ) +
  scale_x_continuous(breaks = 2011:2020, labels = unique(greece_deaths_age$year)) +
  scale_color_manual(values=c("#ED9B83","#3FBDBE")) +
  labs(title = "", x = "", y = "", color='Age Group') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

grid.arrange(p5, p7, p6, p8, nrow=2, ncol=2, top=text_grob("Dementia Deaths and Dementia Death Ratios in Greece", size=14))
