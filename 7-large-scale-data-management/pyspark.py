# initializations
import findspark
findspark.init()

# imports
from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, StringType
from pyspark.sql.functions import col, split, udf, avg

# app initialization and reading
spark = SparkSession.builder.appName('zillow').getOrCreate()

df = spark.read.option('header', True).csv('./zillow.csv')

# definition of UDFs
def clean_bedrooms(string):
    return int(
        string.replace(' bds', '').replace('None', '-1')
    )

def clean_bathrooms(string):
    curr = string.replace('None', '-1.0').split('.')[0]
    return int(
        curr.strip()
    )
    
def clean_squarefeet(string):
    curr = string.split(' sqft')[0]
    curr = curr.replace('None', '-1')
    return int(
        curr.strip()
    )

def clean_price(string):
    curr = string.split('$')[1]
    curr = curr.replace(',', '')
    return int(
        curr.replace('+', '')
    )

def filter_type_of_offer(string):
    if 'for sale' in string.lower():
        return 'sale'
    elif 'foreclosure' in string.lower():
        return 'foreclose'
    elif 'for rent' in string.lower():
        return 'rent'
    elif 'sold' in string.lower():
        return 'sold'
    else:
        return None

def filter_type_of_listing(string):
    if 'house' in string.lower():
        return 'house'
    elif 'condo' in string.lower():
        return 'condo'
    elif 'multi-family' in string.lower():
        return 'apartment'
    elif 'land' in string.lower():
        return 'land'
    elif 'townhouse' in string.lower():
        return 'townhouse'
    elif 'forclosure' in string.lower():
        return 'forclosure'
    elif 'new construction' in string.lower():
        return 'new-construction'
    else:
        return None

# initialize UDFs
offer_udf = udf(lambda x: filter_type_of_offer(x))
listing_udf = udf(lambda x: filter_type_of_listing(x))
price_udf = udf(lambda x: clean_price(x), IntegerType())
bedrooms_udf = udf(lambda x: clean_bedrooms(x), IntegerType())
bathrooms_udf = udf(lambda x: clean_bathrooms(x), IntegerType())
squarefeet_udf = udf(lambda x: clean_squarefeet(x), IntegerType())

# split facts and features to a transformed dataframe
split_col = split(df['facts and features'], ',')

# transform bedrooms to int
df = df.withColumn('bedrooms', split_col.getItem(0))
df = df.withColumn('bedrooms', bedrooms_udf(col('bedrooms')))

# transform bathrooms to int
df = df.withColumn('bathrooms', split_col.getItem(1))
df = df.withColumn('bathrooms', bathrooms_udf(col('bathrooms')))

# transform square feet to int
df = df.withColumn('sqft', split_col.getItem(2))
df = df.withColumn('sqft', squarefeet_udf(col('sqft')))

# transform price to int
df = df.withColumn('price', price_udf(col('price')))

# rename provider column
df = df.withColumnRenamed('real estate provider', 'provider')

# tasks 1, 2, 3, 7
print('\nTASKS 01, 02, 03, 07')
df = df[['title', 'address', 'city', 'state', 'postal_code', 'bedrooms', 'bathrooms', 'sqft', 'price', 'provider', 'url']]
df.show()

# task 4
print('TASK 04')
df = df.withColumn('type_listing', listing_udf(col('title')))
df.show()

# task 5
print('TASK 05')
df = df.withColumn('type_offer', offer_udf(col('title')))
df.show()

# task 6
print('TASK 06')
df.filter("type_offer == 'sale'").show() # SQL expression

# task 8
print('TASK 08')
df.filter(df.bedrooms < 10).show() # dataframe expression

# task 9
print('TASK 09')
df.filter( (df.price >= 100000) & (df.price <= 20000000) ).show() # dataframe expression

# task 10
print('TASK 10')
df.filter("type_listing == 'house'").show() # SQL expression

# task 11
filtered_df = df.filter(
    (df.bedrooms < 10) & # less than 10 bedrooms
    (df.type_offer == 'sale') & # and for sale
    (df.type_listing == 'house') & # and house∏
    (df.price >= 100000) & (df.price <= 20000000) # and price between 10.000 and 20.000.000
)
fin = filtered_df.groupBy('bedrooms').agg(
    avg('price').alias('avg_price'),
    avg('sqft').alias('avg_sqft'),
)
print('TASK 11')
fin = fin.withColumn(
    'avg_price_per_sqft', col('avg_price') / col('avg_sqft')
    ).drop(
        'avg_price', 'avg_sqft'
    ).sort(
        col('bedrooms')
    ).show()
