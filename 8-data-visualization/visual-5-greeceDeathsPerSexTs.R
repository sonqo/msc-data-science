library(ggplot2)
library(gridExtra)
library(tidyverse)

greece_deaths_sex <- 
  df %>%
  filter(geo_code == 'EL') %>%
  group_by(geo_code, year, sex) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths))

greece_deaths_sex$dementia_death_ratio <- greece_deaths_sex$dementia_deaths * 100 / greece_deaths_sex$deaths

greece_deaths_sex$sex[greece_deaths_sex$sex == 'M'] <- 'male'
greece_deaths_sex$sex[greece_deaths_sex$sex == 'F'] <- 'female'

p5 <-
  ggplot(greece_deaths_sex) +
  geom_smooth(
    aes(x=year, y=dementia_deaths, colour=sex), size=0.75, method = "loess", se = FALSE
  ) +
  scale_x_continuous(breaks = 2011:2020, labels = unique(greece_deaths_sex$year)) +
  scale_color_manual(values=c("#E6A6C7","#347DC1")) +
  labs(title = "", x = "", y = "Dementia Deaths", color='Genre') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

p6 <-
  ggplot(greece_deaths_sex) +
  geom_smooth(
    aes(x=year, y=dementia_death_ratio, colour=sex), size=0.75, method = "loess", se = FALSE
  ) +
  scale_x_continuous(breaks = 2011:2020, labels = unique(greece_deaths_sex$year)) +
  scale_color_manual(values=c("#E6A6C7","#347DC1")) +
  labs(title = "", x = "", y = "Dementia Death Ratio [%]", color='Genre') +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))
