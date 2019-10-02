# -*- coding: utf-8  -*-

import requests, json, re
from time import sleep
import pywikibot
from pywikibot import pagegenerators
import pywikibot.data.sparql
import requests
from datetime import date
import time

# constant values.
BASE_URL = "https://api.genius.com"
CLIENT_ACCESS_TOKEN = "XXXXXXXXXXX"
        
def _get(path, params=None, headers=None):

        # generate request URL
    requrl = '/'.join([BASE_URL, path])
    token = "Bearer {}".format(CLIENT_ACCESS_TOKEN)
    if headers:
        headers['Authorization'] = token
    else:
        headers = {"Authorization": token}

    response = requests.get(url=requrl, params=params, headers=headers)
    response.raise_for_status()

    return response.json()

def genius(artist_name):
    # find artist id from given data.
    artist_id = None
    artist_url = None
    find_id = _get("search", {'q': artist_name})
    for hit in find_id["response"]["hits"]:
        if hit["result"]["primary_artist"]["name"] == artist_name:
            artist_id = hit["result"]["primary_artist"]["id"]
            artist_url = re.sub("https:\/\/.*[\.com\/$]\/artists\/","",hit["result"]["primary_artist"]["url"])
            break
    if artist_id and artist_url:
        print("-> " + artist_name + "'s id is " + str(artist_id) + " and url is " + str(artist_url) + "\n")
        return artist_id, artist_url
    else:
        print("-> No match found for " + artist_name)
        return None,None

def setStatement(item, repo, genID, genUrl):
    claims = item.get('claims')
    #ref
    today = date.today()
    statedin = pywikibot.Claim(repo, u'P248')
    itis = pywikibot.ItemPage(repo, "Q65660713")
    statedin.setTarget(itis)

    retrieved = pywikibot.Claim(repo, u'P813')
    dateCre = pywikibot.WbTime(year=int(today.strftime("%Y")), month=int(today.strftime("%m")), day=int(today.strftime("%d")))
    retrieved.setTarget(dateCre)

    if u'P2373' in claims[u'claims']:
        pywikibot.output(u'Error: Already have Genius artist ID!')
    else:
        stringclaim = pywikibot.Claim(repo, u'P2373')
        stringclaim.setTarget(str(genUrl))
        item.addClaim(stringclaim, summary=u'Adding Genius artist ID')

        stringclaim.addSources([statedin, retrieved], summary=u'Adding sources to Genius artist ID.')
        print("Added Genius artist ID")
        
    if u'P6351' in claims[u'claims']:
            pywikibot.output(u'Error: Already have Genius artist numeric ID!')
    else:
        stringclaim2 = pywikibot.Claim(repo, u'P6351')
        stringclaim2.setTarget(str(genID))
        item.addClaim(stringclaim2, summary=u'Adding Genius artist numeric ID (P6351)')
        
        stringclaim2.addSources([statedin, retrieved], summary=u'Adding sources to Genius artist numeric ID.')
        print("Added Genius artist numeric ID")
    
def main(*args):
    """
    Main function. Grab a generator and pass it to the bot to work on
    """
    genres = None
    report = None
    for arg in pywikibot.handle_args(args):
        if arg.startswith('-genre:'):
            if len(arg) == 8:
                genres = pywikibot.input(
                        u'Please enter the Q id of the genre to work on:')
            else:
                genres = arg[8:]
        elif arg.startswith('-report:'):
            if len(arg) == 8:
                report = pywikibot.input(
                        u'Please enter the name of the page to report on:')
            else:
                report = arg[8:]
    
    repo = pywikibot.Site("wikidata", "wikidata").data_repository()
    nonGeniusQuery = u"""SELECT DISTINCT ?item
    WHERE {
    ?item wdt:P31 wd:Q5 ;
          wdt:P106/wdt:P279* wd:Q177220 .
    MINUS { { ?item wdt:P2373 [] } UNION { ?item wdt:P6351 [] } }.
    }"""
    
    blacklist = ['Dessa', 'Lunay', 'Ahlam', 'Kyla', 'John-payne', 'Martha Davis', 'Tommy Sands', 'Johnny Lee', 'John Alford', 'Terry Allen']
    
    blacklistQuery = u"""SELECT * WHERE {
      {
    SELECT ?item (COUNT(?obj) AS ?count) WHERE { ?obj wdt:P2373 ?item. }
      }
  FILTER(?count > 1)
    }"""
    
    singerGen = pagegenerators.PreloadingEntityGenerator(pagegenerators.WikidataSPARQLPageGenerator(nonGeniusQuery,site=repo))
    counter = 0
    for singerPage in singerGen:
        item_dict = singerPage.get()
        if singerPage.isRedirectPage():
            pywikibot.output('{0} is a redirect page. Skipping.'.format(singerPage))
            continue
        try:
            name = item_dict["labels"]['en']
            genID, genUrl = genius(name)
            if genID in blacklist:
                pywikibot.output('{0} is in the blacklist. Skipping.'.format(singerPage))
                continue
            elif genID and genUrl:
                setStatement(singerPage, repo, genID, genUrl)
            counter += 1
           # if counter > 200:
            #    blacklistGen = pagegenerators.PreloadingEntityGenerator(pagegenerators.WikidataSPARQLPageGenerator(blacklistQuery,site=repo))
             #   for blacklistName in blacklistGen:
              #      if blacklistName.get()["labels"]['en'] not in blacklist:
               #         blacklist.append(blacklistName.get()["labels"]['en'])
                #counter = 0
        except KeyError:
            # Key is not present
            pass

if __name__ == "__main__":
    main()
