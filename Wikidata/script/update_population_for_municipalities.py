# -*- coding: utf-8  -*-
import pywikibot
import json

from pywikibot.data.sparql import SparqlQuery

"""
This is a script to add population data for municipalities of Norway.

1. Download population for a given year from: https://www.ssb.no/statbank/table/07459/ select all the municipalities.
2. Press "Lagre data som..." -> "JSON-stat (json)" -> "Lagre".
3. Add the file in the same directory as this script.
4. Change the variable 'file_name_ssb' to the same name as your file from SSB.
5. This script is made for 2022 data so, make the follwing chagnes for a new year:
    1) Change query in variable 'query_municipality' to FILTER on a new year like (.."2023-01-01...).
    2) Change the variable 'year_adding' to correct year you are adding.
    3) Change the following line date 'dateCre_ref = pywikibot.WbTime(year=year_adding, month=2, day=23)' with the value from 'updated' in the JSON file.

EXTRA:
IF TEST EDITS:
1. Set variable "test_edit" with your bot request, if not a test edit set it to a empty string
2. Change "for val in xml['results']['bindings']:" to "for val in xml['results']['bindings'][:50]:" for 50 test edit.

# https://w.wiki/4Z4Z
"""
file_name_ssb = '07459_20220224-190529.json'
year_adding = 2022
test_edit = '[[Wikidata:Requests for permissions/Bot/IngeniousBot 2|Test edit]]: '

query_municipality = """
SELECT DISTINCT ?item ?value WHERE {
  ?item wdt:P2504 ?value;
    wdt:P31 wd:Q755707, wd:Q755707;
    p:P1082 _:b30.
  _:b30 pq:P585 ?pointintime;
    rdf:type wikibase:BestRank.
  FILTER(?pointintime != "2022-01-01T00:00:00Z"^^xsd:dateTime)
}
"""
wikiquery = SparqlQuery()
xml = wikiquery.query(query_municipality)

# Opening JSON file from SSB
f = open(file_name_ssb)

# returns JSON object as a dictionary
data = json.load(f)

# the dict for data
data_mun = {}

# Iterating through the json
blacklist = ['21-22', '23', 'Rest']
k_num = data['dataset']['dimension']['Region']['category']['index']
for i in k_num:
    if i[2:] not in blacklist:
        data_mun[int(i[2:])] = int(data['dataset']['value'][k_num[i]])

# Closing file
f.close()

site = pywikibot.Site("wikidata", "wikidata")
repo = site.data_repository()

for val in xml['results']['bindings']:

    has_pop_for_year = False
    wd_item = val['item']['value'].rsplit('/', 1)[1]
    municipality_num = int(val['value']['value'])

    item = pywikibot.ItemPage(repo, wd_item)

    if municipality_num in data_mun:

        claims = item.get(u'claims')  # Get all the existing claims
        # Check is any statements in P1082 is set to "preferred", if so set to "normal"
        if 'P1082' in claims[u'claims']:
            for claim in claims[u'claims']['P1082']:

                for qual in claim.qualifiers:  # Checks if the population already has data for a given year
                    if u'P585' in qual:
                        for value in claim.qualifiers[qual]:
                            if value.target_equals(pywikibot.WbTime(site=repo, year=year_adding, month=1, day=1)):
                                has_pop_for_year = True

                if claim.rank == "preferred" and has_pop_for_year == False:
                    claim.setRank('normal')
                    item.editEntity({'claims': [claim.toJSON()]},
                                   summary=f'{test_edit}Changing ranked to normal for population (P1082) statement.')

        if has_pop_for_year:
            continue

        # Add a new claim as "preferred"

        # CLAIM
        quantity_claim = pywikibot.Claim(repo, u'P1082')
        wb_quant = pywikibot.WbQuantity(data_mun[municipality_num], site=repo)  # adding population without unit
        quantity_claim.setTarget(wb_quant)
        quantity_claim.setRank("preferred")

        item.addClaim(quantity_claim, summary=f'{test_edit}Adding population (P1082) for January 1, {year_adding}.')

        # QUALIFIER
        point_it = pywikibot.Claim(repo, u'P585', is_qualifier=True)  # point in time (P585). Data type: Point in time
        dateCre = pywikibot.WbTime(site=repo, year=year_adding, month=1, day=1)  # January 1, 20XX
        point_it.setTarget(dateCre)  # Inserting value

        quantity_claim.addQualifier(point_it,
                                   summary=f'{test_edit}Adding qualifier, point in time (P585), for population (P1082).')

        determination_method = pywikibot.Claim(repo, u'P459',
                                               is_qualifier=True)  # determination method (P459). Data type: Item
        dm_target = pywikibot.ItemPage(repo, "Q64224988")  # Q64224988 = National Population Register
        determination_method.setTarget(dm_target)

        quantity_claim.addQualifier(determination_method,
                                   summary=f'{test_edit}Adding qualifier, determination method (P459), for population (P1082).')

        # REFERENCES
        title = f"Alders- og kjønnsfordeling i kommuner, fylker og hele landets befolkning (K) 1986 - {year_adding}"
        title_ref = pywikibot.Claim(repo, u'P1476')  # title (P1476). Data type: Monolingual text
        title_target = pywikibot.WbMonolingualText(text=title, language='nb')
        title_ref.setTarget(title_target)  # Inserting value

        url = "https://www.ssb.no/statbank/table/07459/"
        ref_url = pywikibot.Claim(repo, u'P854')  # reference URL (P854). Data type: URL
        ref_url.setTarget(url)

        publisher_ref = pywikibot.Claim(repo, u'P123')  # publisher (P123). Data type: Item
        publisher_target = pywikibot.ItemPage(repo, "Q2367019")  # Q2367019 =  Statistics Norway
        publisher_ref.setTarget(publisher_target)

        publication_ref = pywikibot.Claim(repo, u'P577')  # publication date (P577). Data type: Point in time
        dateCre_ref = pywikibot.WbTime(site=repo, year=year_adding, month=2, day=24)  # 24.02.2022
        publication_ref.setTarget(dateCre_ref)  # Inserting value

        quantity_claim.addSources([title_ref, ref_url, publisher_ref, publication_ref],
                                 summary=f'{test_edit}Adding sources to population (P1082) statement.')

        pywikibot.output(f'Claim added for {wd_item}!')
