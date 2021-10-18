import requests
from bs4 import BeautifulSoup
import csv
import re

alle_programmer = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','ae','oe','aa','0-9']
arr_programs = [] # example [{'name': Kongen av Gulset, 'id': 'serie/kongen-av-gulset'}]

for letter in alle_programmer:
    nrk_url = f'https://tv.nrk.no/alle-programmer/{letter}'
    html_text = requests.get(nrk_url).text
    soup = BeautifulSoup(html_text, 'html.parser')
    for link in soup.find_all('a', href=re.compile('\/(?:serie|program\/[A-Z])')):
        arr_programs.append({'name': link.text, 'id': link.get('href')[1:], 'url': f"https://tv.nrk.no{link.get('href')}"})

print("---------------- Get desc from API ----------------")

for index, val in enumerate(arr_programs):
    type_nrk = val['id'].rsplit('/', 1)
    url = ""
    param = ""
    if type_nrk and type_nrk[0] == "program":
        url = f"https://psapi.nrk.no/tv/catalog/programs/{type_nrk[1]}"
        param = "programInformation"
    elif type_nrk and type_nrk[0] == "serie":
        url = f"https://psapi.nrk.no/tv/catalog/series/{type_nrk[1]}"
    else:
        continue
    
    try: # Some of the programs/series times-out, missing entry in the API.
        r = requests.get(url)
        data = r.json()
        
        if param == "": # is a 'serie'.
            param = data['seriesType']
            
        arr_programs[index].update({'desc': data[param]['titles']['subtitle']}"})
    except: # Some entries is missing an desc.
        arr_programs[index].update({'desc': ''})

print("---------------- Creates file 'nrk_tv.csv' ----------------")
                                  
# csv header
fieldnames = ['id', 'name', 'desc', 'url']

with open('nrk_tv.csv', 'w', encoding='UTF8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(arr_programs)

# GO TO https://mix-n-match.toolforge.org/#/import/4768
# PICK "Comma-separated values"
# UPLOAD THE FILE "nrk_tv.csv"
# CHECK "Looks good"
# UPLOAD THE UPDATED DATA
