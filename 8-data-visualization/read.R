library(readxl)
library(stringr)

# read dementia data
deaths = read_excel('deaths.xlsx') # ( demo_magec )
dementia_deaths = read_excel('dementia_deaths.xlsx') # ( hlth_cd_aro )
geos = read_excel('geos.xlsx', col_names=c('country_codes'))
expenditure = read_excel('healthcare_expenditure.xlsx') # ( hlth_sha11 )
population = read_excel('population.xlsx') # ( t_demo_pop )

# slit country codes and standardize
geos[c('geo_code', 'geo_name')] <- str_split_fixed(geos$country_codes, ']', 2)
# remove brackets from geo codes
geos$geo_code <- gsub("\\[", "", geos$geo_code)
# remove whitespaces
geos$geo_code <- str_trim(geos$geo_code, "both")

# merge dementia deaths data with geos 
df <- merge(x=dementia_deaths, y=geos, by="geo_code")

# merge deaths 
df <- merge(x=df, y=deaths, by.x=c('year', 'geo_code', 'age', 'sex'), by.y=c('year', 'geo_code', 'age', 'sex'))

# select columns
df <- df[c('geo_code', 'geo_name', 'year', 'age', 'sex', 'deaths', 'dementia_deaths')]
