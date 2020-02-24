Linear regression
-----------------

This tutorial will be dedicated to understanding how to use the linear regression algorithm with Wikidata to make predictions. For a very detailed explanation of how this algorithm works please read the [Wikipedia](W:Wikipedia "wikilink") article: [linear regression](W:Linear_regression "wikilink").

### Importing Modules/Packages

Before we start coding, import/install all of the following.

``` python
# -*- coding: utf-8  -*-
import json
import numpy as np
import pandas as pd
import sklearn

from collections import defaultdict
from sklearn import linear_model
```

### Loading in Our Data

Now it's time for some data collection from Wikidata. For this example have I used the yearly (average) population stacked by country in a query. This gives us a lot of interesting values and some with faults, unfortunately. I have chosen to filter this query to only include values from 2005 and newer. How you choose to import the query into the script is your decision. A passibility is to [iterate over a SPARQL query](Wikidata:Pywikibot_-_Python_3_Tutorial/Iterate_over_a_SPARQL_query "wikilink") by downloading the `.rq` file or just download a [JSON](W:JSON "wikilink") file of the result from the query.wikidata.org site. Once you've downloaded the data set and placed it into your main directory you will first need to clean the data, and later load it in using the pandas module.

Yearly Population stacked by country  

Query found on [Wikidata:SPARQL query service/queries/examples/advanced](Wikidata:SPARQL_query_service/queries/examples/advanced "wikilink") (shout-out to the person who made it, saved me a lot of time).

Now that we have cleaned the data and selected the interesting part of the query (country, year and population). We need to import the data into `pandas`. We also need (in this example) to flip the table (switch the place of column and row).

``` python
YEARS = ["2007", "2008", "2009" ,"2010", "2011", "2012", "2013"] # Years we are interested in


def getList(dict): # To get keys for the dict.
    list = [] 
    for key in dict.keys(): 
        list.append(key) 
          
    return list

with open('query.json', 'r') as f: # Downloaded query in a JSON file.
    distros_dict = json.load(f)

allEntries = defaultdict(dict) # saves all the countries in the query with its data

for entry in distros_dict:
    allEntries[entry['countryLabel']].update({entry['year']: entry['population']})

selectedEnt = defaultdict(dict) # saves the countries in the query with its data that has all the values in the YEARS list

for country in allEntries:
    if all(elem in getList(allEntries[country]) for elem in YEARS):
        selectedEnt.update({country: allEntries[country]})
        
df = pd.DataFrame.from_dict(selectedEnt) # pastes it into pandas
data = pd.DataFrame.transpose(df) # flips the table
```

![Scikit-learn is used in this tutorial.](Scikit learn logo small.svg "Scikit-learn is used in this tutorial.")

The data should now look something like this: `print(data)`

                                           2007       2008       2009  \
    Afghanistan                        26349243   27032197   27708187  
    Algeria                            35097043   35591377   36383302 
    ...                                  ...         ...       ...   

Next it's time to only select the data we want to use as test data, and remove the solution. In other words split the data. In this example I have choose to use population values from 2007-2012 (for the countries that have all of them), with a prediction for 2013 (they also need this value).

``` python
data = data[YEARS]

predict = "2013"
```

Now that we've trimmed our data set down we need to separate it into 4 arrays. However, before we can do that we need to define what attribute we are trying to predict. This attribute is known as a **label**. The other attributes that will determine our label are known as **features**. Once we've done this we will use `numpy` to create two arrays. One that contains all of our features and one that contains our labels.

``` python
X = np.array(data.drop([predict], 1)) # Features
y = np.array(data[predict]) # Labels
```

After this we need to split our data into testing and training data. We will use 90% of our data to train and the other 10% to test. The reason we do this is so that we do not test our model on data that it has already seen.

``` python
x_train, x_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y, test_size = 0.1)
```

Next is to implement the linear regression algorithm

### Implementing the Algorithm

We will start by defining the model which we will be using.

``` python
linear = linear_model.LinearRegression()
```

Next we will train and score our model using the arrays.

``` python
linear.fit(x_train, y_train)
acc = linear.score(x_test, y_test) # acc = accuracy 
```

To see how well our algorithm performed on our test data we can print out the accuracy.

``` python
print(acc)
```

For this specific data set a score of above 80% is fairly good. This example has 99%.

### Viewing The Constants

If we want to see the constants used to generate the line we can type the following.

``` python
print('Coefficient: \n', linear.coef_) # These are each slope value
print('Intercept: \n', linear.intercept_) # This is the intercept
```

### Predicting the population in 2013

Seeing a score value is nice but we would first like to see how well the algorithm works on specific country. To do this we are going to print out all of our test data. Beside this data we will print the actual population in 2013 and our models predicted population.

``` python
predictions = linear.predict(x_test) # Gets a list of all predictions

print("Country - sklearn guessed value for 2013, the Wikidata values (2007-2012), The Wikidata value (2013)")
for x in range(len(predictions)):
    for country in selectedEnt:
        if x_test[x][0] == selectedEnt[country][YEARS[0]] and x_test[x][1] == selectedEnt[country][YEARS[1]]: # To find the country used in the test data
            print(country, " - ", predictions[x], x_test[x], y_test[x])
```

### Test result

    0.999650607098148
    Coefficient: 
     [ 0.41969474 -1.01050159 -0.20560013  0.0411049   1.3388236   0.41479332]
    Intercept: 
     36691.20709852874

| Country   | [Sklearn](W:scikit-learn "wikilink") guessed value for 2013 | The Wikidata values (2007-2012) | The Wikidata value (2013) |
|-----------|-------------------------------------------------------------|---------------------------------|---------------------------|
| Bhutan    | 791284.6964912245                                           | 679365                          | 692159                    |
| Palau     | 57549.30744685472                                           | 20118                           | 20228                     |
| Venezuela | 30466443.18175283                                           | 27655937                        | 28120312                  |
| Romania   | 19986225.906004228                                          | 20882982                        | 20537875                  |
| Uruguay   | 3439645.730278643                                           | 3338384                         | 3348898                   |
| ..        | ..                                                          | ..                              | ..                        |

### Full code

``` python
# -*- coding: utf-8  -*-
import json
import numpy as np
import pandas as pd
import sklearn

from collections import defaultdict
from sklearn import linear_model

YEARS = ["2007", "2008", "2009", "2010", "2011", "2012", "2013"]


def getList(dict):
    list = []
    for key in dict.keys():
        list.append(key)

    return list

with open('query.json', 'r') as f: 
    distros_dict = json.load(f)

allEntries = defaultdict(dict)

for entry in distros_dict:
    allEntries[entry['countryLabel']].update({entry['year']: entry['population']})

selectedEnt = defaultdict(dict)

for country in allEntries:
    if all(elem in getList(allEntries[country]) for elem in YEARS):
        selectedEnt.update({country: allEntries[country]})

df = pd.DataFrame.from_dict(selectedEnt)
data = pd.DataFrame.transpose(df)

data = data[YEARS]

predict = "2013"

X = np.array(data.drop([predict], 1)) # Features
y = np.array(data[predict]) # Labels

x_train, x_test, y_train, y_test = sklearn.model_selection.train_test_split(X, y, test_size = 0.1)

linear = linear_model.LinearRegression()

linear.fit(x_train, y_train)
acc = linear.score(x_test, y_test)
print(acc)

print('Coefficient: \n', linear.coef_)
print('Intercept: \n', linear.intercept_)

predictions = linear.predict(x_test)

print("Country - sklearn guessed value for 2013, the Wikidata values (2007-2012), The Wikidata value (2013)")
for x in range(len(predictions)):
    for country in selectedEnt:
        if x_test[x][0] == selectedEnt[country][YEARS[0]] and x_test[x][1] == selectedEnt[country][YEARS[1]]:
            print(country, " - ", predictions[x], x_test[x], y_test[x])
```

Jupyter page (PAWS)  

-   [Wikidata - Linear regression](https://paws-public.wmflabs.org/paws-public/User:Premeditated/Other/macine%20lern/Wikidata%20-%20Linear%20regression.ipynb)
