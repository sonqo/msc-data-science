library(ggplot2)

# calculate dementia deaths to total deaths ratio
total_deaths_per_country$dementia_death_ratio <- 
  round(
    total_deaths_per_country$dementia_deaths * 100 / total_deaths_per_country$deaths, 
    digits=2)

p2 <-
  ggplot(total_deaths_per_country) +
  geom_bar(
    aes(
      x = dementia_death_ratio,
      y = fct_reorder(geo_name, dementia_death_ratio),
      fill = factor(ifelse(geo_code == "EL", "highlighted", "normal"))
    ),
    stat = 'identity',
    show.legend = FALSE) +
  geom_text(
    data = total_deaths_per_country[total_deaths_per_country$geo_code == "EL", ],
    size = 3,
    hjust = -0.25,
    position = position_dodge(width = 1),
    aes(
      x = dementia_death_ratio,
      y = fct_reorder(geo_name, dementia_death_ratio),
      label = paste0(dementia_death_ratio, " %")
    )
  ) +
  scale_x_continuous(labels = scales::label_comma(scale = 1)) +
  scale_fill_manual(name = "geo_name", values=c("blue","grey60")) +
  labs(title = "Dementia Deaths to Total Deaths Ratio in European Countries [2011-2022]\n", x = "Dementia Death Ratio [%]", y = "") +
  theme(plot.title = element_text(hjust = 0.5))
p2
