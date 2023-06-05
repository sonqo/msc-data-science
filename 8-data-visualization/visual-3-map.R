library(sf)
library(scales)
library(cowplot)
library(ggplot2)
library(leaflet)
library(ggthemes)
library(eurostat)
library(tidyverse)

# SOURCE : http://stavrakoudis.econ.uoi.gr/r-eurostat/drawing-maps-of-europe.html

# get Europe country polygons
SHP_0 <- get_eurostat_geospatial(resolution = 10, nuts_level = 0, year = 2021)

# discard any countries not present in our dataset
SHP_EU <- 
  SHP_0 %>% 
  select(geo = NUTS_ID, geometry) %>% 
  arrange(geo) %>% 
  st_as_sf()

DATA_SHP_EU <-
  total_deaths_per_country %>%
  select(geo_code, dementia_deaths) %>% 
  inner_join(SHP_EU, by = c('geo_code' = 'geo')) %>% 
  st_as_sf()

DATA_SHP_EU %>% 
  ggplot(aes(fill = dementia_deaths)) + 
  scale_fill_gradient(name = "", labels = scales::label_comma(scale = 1), low = "#B589D6", high = "#552586", na.value = 'white') +
  theme_bw() + 
  labs(title="Total Dementia Deaths in European Countries [2011-2021]\n") +
  theme(
    legend.title = element_text(hjust = 1), 
    axis.text.x=element_blank(), 
    axis.ticks.x=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  geom_sf() + 
  scale_x_continuous(limits = c(-10, 45)) + 
  scale_y_continuous(limits = c(35, 70))
