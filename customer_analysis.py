import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv("customer_shopping_behavior.csv")
print(df.head())
print(df.shape)

print(df.info())

print(df.describe())

print(df.isnull().sum())

print(df.duplicated().sum())

print(df.columns)
# Fill missing Review Rating values using the median of each Category
df['Review Rating'] = df.groupby('Category')['Review Rating'].transform(
    lambda x: x.fillna(x.median())
)

# Check missing values again
print(df.isnull().sum())

# Convert column names to lowercase
df.columns = df.columns.str.lower()

# Replace spaces with underscores
df.columns = df.columns.str.replace(' ', '_')

# Rename purchase_amount_(usd) to purchase_amount
df = df.rename(columns={
    'purchase_amount_(usd)': 'purchase_amount'
})

# Display column names
print(df.columns)

# Define age group labels
labels = ['Young Adult', 'Adult', 'Middle-aged', 'Senior']

# Divide age into 4 groups
df['age_group'] = pd.qcut(
    df['age'],
    q=4,
    labels=labels
)

# Display age and age_group
print(df[['age', 'age_group']].head(10))


# Map purchase frequency to number of days
frequency_mapping = {
    'Fortnightly': 14,
    'Weekly': 7,
    'Monthly': 30,
    'Quarterly': 90,
    'Bi-Weekly': 14,
    'Annually': 365,
    'Every 3 Months': 90
}

# Create new column
df['purchase_frequency_days'] = df['frequency_of_purchases'].map(
    frequency_mapping
)

# Display the results
print(df[['purchase_frequency_days', 'frequency_of_purchases']].head(10))


# Display both columns
print(df[['discount_applied', 'promo_code_used']].head(10))

# Check whether both columns have identical values
print((df['discount_applied'] == df['promo_code_used']).all())

# Drop promo_code_used column
df = df.drop('promo_code_used', axis=1)

# Display remaining columns
print(df.columns)


# Display final dataset
print(df.head())

# Check dataset information
print(df.info())

# Check missing values
print(df.isnull().sum())




from sqlalchemy import create_engine
from urllib.parse import quote_plus

username = "root"
password = quote_plus("CustAnalysis2026")

engine = create_engine(
    f"mysql+pymysql://{username}:{password}@localhost:3306/customer_behavior"
)

with engine.connect() as connection:
    print("MySQL Connected Successfully!")


    df.to_sql(
    name="customer_data",
    con=engine,
    if_exists="replace",
    index=False
)

print("Data uploaded successfully!")