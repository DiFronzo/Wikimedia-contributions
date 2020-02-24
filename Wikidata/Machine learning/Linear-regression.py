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
