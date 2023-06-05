library(ggplot2)

expenses_2019 <-
  expenditure %>%
  filter(geo_code != 'EU27_2020' & geo_code != 'EU28' & year == 2019)

population_2019  <-
  population %>%
  filter(geo_code != 'EU27_2020' & geo_code != 'EU28' & year == 2019)

deaths_2019 <-
  df %>%
  filter(year == 2019) %>%
  group_by(geo_code) %>%
  summarise(geo_name = max(geo_name), deaths = sum(deaths), dementia_deaths = sum(dementia_deaths))

deaths_2019$dementia_death_ratio <- deaths_2019$dementia_deaths / deaths_2019$deaths

population_hc_expenditure_2019 <-
  deaths_2019 %>%
  inner_join(expenses_2019, by='geo_code') %>%
  inner_join(population_2019, by='geo_code') 

p4 <- 
  ggplot(
    population_hc_expenditure_2019, 
    aes(x = log(population), y = euro)
  ) + 
  geom_point(
    aes(
      size = dementia_deaths, 
      alpha = factor(ifelse(geo_code == "EL", 1, 0.70)),
      color = factor(ifelse(geo_code == "EL", "highlighted", "normal")),
      shape = dementia_death_ratio > 0.05
    )
  ) +
  geom_label(
    data = population_hc_expenditure_2019[population_hc_expenditure_2019$geo_code == 'EL', ],
    size = 3,
    hjust = 0.5,
    vjust = 0.5,
    nudge_x = 0.20,
    nudge_y = -8500,
    aes(
      label = geo_name
    )
  ) +
  scale_alpha_discrete(range=c(0.75,1)) +
  scale_shape_manual(values = c(16, 13)) + 
  scale_color_manual(name = "geo_name", values=c("blue", "grey50")) +
  scale_size_continuous(name="Size of sales", range=c(4, 14)) + 
  scale_y_continuous(labels = scales::label_comma(scale = 1), n.breaks = 5) +
  labs(title = "Population to Healthcare Expenses for European Counties [2019]\n", x = "Population [log scale]", y = "Euro (€)") +
  guides(
    color = FALSE,
    alpha = FALSE, 
    size = guide_legend("Dementia Deaths", override.aes = list(size = c(1, 2, 3, 4, 5, 6))), 
    shape = guide_legend("Dementia Death Ratio > 5%", override.aes = list(size = 5))
  ) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5), legend.key.size = unit(1, 'line'))
p4
