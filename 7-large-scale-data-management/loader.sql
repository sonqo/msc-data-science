CREATE LOADER zillow_loader() LANGUAGE PYTHON {

    import pandas as pd

    df = pd.read_csv('/db/zillow.csv')

    df[['bedrooms', 'bathrooms', 'sqft']] = df['facts and features'].str.split(',', expand=True)

    # bedrooms
    df['bedrooms'] = df['bedrooms'].str.replace(' bds', '').replace('None', '-1').astype(int)

    # bathrooms
    df['bathrooms'] = df['bathrooms'].str.replace('None', '-1.0').str.split('.', n=1, expand=True)
    df['bathrooms'] = df['bathrooms'].str.strip().astype(int)

    # square feet
    df['sqft'] = df['sqft'].str.split(' sqft', n=1, expand=True)
    df['sqft'] = df['sqft'].str.replace('None', '-1')
    df['sqft'] = df['sqft'].str.strip().astype(int)

    # price
    df[['dollar', 'price']] = df['price'].str.split('$', n=2, expand=True)
    df['price'] = df['price'].str.replace(',', '')
    df['price'] = df['price'].str.replace('+', '').astype(int)

    df = df.rename(columns={
        'real estate provider': 'provider'
    })

    # remove non-ASCII characters
    df['provider'] = df['provider'].replace({r'[^\x00-\x7F]+':''}, regex=True)

    df = df[[
        'title', 'address', 'city', 'state', 'postal_code', 'bedrooms', 'bathrooms', 'sqft', 'price', 'provider', 'url'
    ]]

    fin = df.to_dict('list')
    _emit.emit(fin)
};

CREATE TABLE zillow FROM  LOADER zillow_loader();
