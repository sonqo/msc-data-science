library(ggplot2)
library(tidyverse)

df_2011 <-
  df %>%
  filter((geo_code != 'EU28' & geo_code != 'EU27_2020')) %>%
  filter(year == 2011) %>%
  group_by(geo_code, geo_name) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  mutate(dementia_death_ratio = dementia_deaths/deaths)

df_2020 <-
  df %>%
  filter((geo_code != 'EU28' & geo_code != 'EU27_2020')) %>%
  filter(year == 2020)  %>%
  group_by(geo_code, geo_name) %>%
  summarise(deaths = sum(deaths), dementia_deaths = sum(dementia_deaths)) %>%
  mutate(dementia_death_ratio = dementia_deaths/deaths) %>%
  inner_join(df_2011, by=c('geo_code' = 'geo_code')) %>%
  mutate(
    delta = (
      ifelse(
        dementia_death_ratio.y != 0,
        (dementia_death_ratio.x - dementia_death_ratio.y) * 100 / dementia_death_ratio.x,
        -Inf
      )
    )
  ) %>%
  filter_all(all_vars(!is.infinite(.))) %>%
  select(geo_code, 'geo_name' = 'geo_name.x', delta)

ggplot(df_2020) +
  geom_bar(
    aes(
      x = delta,
      y = fct_reorder(geo_name, delta), 
      fill = factor(ifelse(geo_code == "EL", "Highlighted", "Normal"))
    ),
    stat = 'identity',
    show.legend = FALSE
  ) +
  geom_text(
    data = df_2020[df_2020$geo_code == "EL", ],
    size = 3,
    hjust = -0.25,
    position = position_dodge(width = 1),
    aes(
      x = delta,
      y = fct_reorder(geo_name, delta),
      label = paste0(round(delta, digits=1), " %")
    )
  ) +
  theme_bw() + 
  scale_x_continuous(labels = scales::label_comma(scale = 1)) +
  scale_fill_manual(name = "geo_name", values=c("blue","grey60")) +
  labs(title = "Dementia Death Ratio Delta [2011 - 2020]\n", x = "Delta [%]", y = "") +
  theme(plot.title = element_text(hjust = 0.5))
