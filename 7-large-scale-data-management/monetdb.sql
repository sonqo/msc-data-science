-- LOADER FUNCTION
CREATE LOADER zillow_loader() LANGUAGE PYTHON {

    import pandas as pd

    df = pd.read_csv('zillow.csv')

    # splits features column to bedrooms, bathrooms, square feet
    df[['bedrooms', 'bathrooms', 'sqft']] = df['facts and features'].str.split(',', expand=True)

    # transform bedrooms to integer
    df['bedrooms'] = df['bedrooms'].str.replace(' bds', '').replace('None', '-1').astype(int)

    # transform bathrooms to integer
    df['bathrooms'] = df['bathrooms'].str.replace('None', '-1.0').str.split('.', n=1, expand=True)
    df['bathrooms'] = df['bathrooms'].str.strip().astype(int)

    # transfrom square feet to integer
    df['sqft'] = df['sqft'].str.split(' sqft', n=1, expand=True)
    df['sqft'] = df['sqft'].str.replace('None', '-1')
    df['sqft'] = df['sqft'].str.strip().astype(int)

    # transform price to integer
    df[['dollar', 'price']] = df['price'].str.split('$', n=2, expand=True)
    df['price'] = df['price'].str.replace(',', '')
    df['price'] = df['price'].str.replace('+', '').astype(int)

    df = df.rename(columns={
        'real estate provider': 'provider'
    })

    # cast provider column to unicode
    df['provider'] = df['provider'].replace({r'[^\x00-\x7F]+':''}, regex=True)

    # select final columns
    df = df[[
        'title', 'address', 'city', 'state', 'postal_code', 'bedrooms', 'bathrooms', 'sqft', 'price', 'provider', 'url'
    ]]

    fin = df.to_dict('list')
    _emit.emit(fin)
};

-- LOADING DATA
CREATE TABLE zillow FROM LOADER zillow_loader();

-- TASK 4
CREATE FUNCTION filter_type_of_listing(strings STRING) RETURNS STRING LANGUAGE PYTHON {
    
    def type_of_listing_mapper(string):
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

    return [type_of_listing_mapper(entry) for entry in strings]

};
SELECT *, filter_type_of_listing(title) AS type_of_listing FROM zillow;

-- TASK 5
CREATE FUNCTION filter_type_of_offer(strings STRING) RETURNS STRING LANGUAGE PYTHON {
    
    def type_of_offer_mapper(string):
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

    return [type_of_offer_mapper(entry) for entry in strings]

};
SELECT *, filter_type_of_offer(title) AS type_of_offer FROM zillow;

-- TASK 6
SELECT * FROM zillow WHERE filter_type_of_offer(title) = 'sale';

-- TASK 8
SELECT * FROM zillow WHERE bedrooms < 10;

-- TASK 9
SELECT * FROM zillow WHERE price BETWEEN 100000 AND 20000000;

-- TASK 10
SELECT * FROM zillow WHERE filter_type_of_listing(title) = 'house';

-- TASK 11
SELECT 
    bedrooms, AVG(sqft) * 1.0 / AVG(price) AS AvPricePerSqFt
FROM
    zillow
WHERE
    bedrooms < 10
    AND price BETWEEN 100000 AND 20000000
    AND filter_type_of_offer(title) = 'sale'
    AND filter_type_of_listing(title) = 'house'
GROUP BY
    bedrooms
ORDER BY
    bedrooms;
