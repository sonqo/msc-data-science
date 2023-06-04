library(ggplot2)
library(forcats)

# calculate total dementia deaths per country
total_deaths_per_country <-
  aggregate(
    list(deaths = df$deaths, dementia_deaths = df$dementia_deaths),
    list(geo_code = df$geo_code, geo_name = df$geo_name),
    FUN = sum
  )

# discard European groups
total_deaths_per_country <-
  total_deaths_per_country[!total_deaths_per_country$geo_code %in% c("EU28", "EU27_2020"), ]

p1 <-
  ggplot(total_deaths_per_country) +
  geom_bar(
    aes(
      x = dementia_deaths,
      y = fct_reorder(geo_name, dementia_deaths),
      fill = factor(ifelse(geo_code == "EL", "Highlighted", "Normal"))
    ),
    stat = 'identity',
    show.legend = FALSE) +
  geom_text(
    data = total_deaths_per_country[total_deaths_per_country$geo_code == "EL", ],
    size = 3,
    hjust = -0.25,
    position = position_dodge(width = 1),
    aes(
      x = dementia_deaths,
      y = fct_reorder(geo_name, dementia_deaths),
      label = paste0(dementia_deaths, " deaths")
    )
  ) +
  scale_x_continuous(labels = scales::label_comma(scale = 1)) +
  scale_fill_manual(name = "geo_name", values=c("blue","grey60")) +
  labs(title = "Total Dementia Deaths in European Countries [2011-2022]\n", x = "Dementia Deaths", y = "") +
  theme(plot.title = element_text(hjust = 0.5))
p1
