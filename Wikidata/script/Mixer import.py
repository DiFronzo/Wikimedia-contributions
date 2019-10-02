# -*- coding: utf-8  -*-
#import sys
#!{sys.executable} -m pip install xlsxwriter

import requests, json, re
import pywikibot
from pywikibot import pagegenerators
import pywikibot.data.sparql
import codecs
import requests
from datetime import date
import time
 
s = requests.Session()
s.headers.update({'Client-ID': 'XXXXXXXXXXXXXX'})

def getRef(repo, vidID):
    #ref
    today = date.today()
    
    ref = pywikibot.Claim(repo, u'P854')
    ref.setTarget('https://mixer.com/browse/games/{}'.format(vidID))

    retrieved = pywikibot.Claim(repo, u'P813')
    dateCre = pywikibot.WbTime(year=int(today.strftime("%Y")), month=int(today.strftime("%m")), day=int(today.strftime("%d")))
    retrieved.setTarget(dateCre)
    return ref, retrieved

def mixerAPI(nameQ):
    page = 0
    
    try:
        while True:
            channel_response = s.get('https://mixer.com/api/v1/types', params={
                'where': 'name:eq:{}'.format(nameQ),
                'fields': 'id,name',
                'page': page
            })
        
            for channel in channel_response.json():
                if channel['name'].lower() == nameQ.lower():
                    return channel['id'], channel['name']
            return None
    except:
        return None

def main(*args):
    repo = pywikibot.Site("wikidata", "wikidata").data_repository()
    videoQuery = u"""SELECT DISTINCT ?item
    WHERE {
    ?item wdt:P31 wd:Q7889 .
    ?item wikibase:sitelinks ?sitelinks.
    MINUS { ?item wdt:P7335 []}.
    }"""
    games = pagegenerators.PreloadingEntityGenerator(pagegenerators.WikidataSPARQLPageGenerator(videoQuery,site=repo))
    vidID = ""
    vidName = ""
    for item in games:
        claims = item.get(u'claims') #Get alle the exsisting claims
        item_dict = item.get()

        if u'P7335' in claims[u'claims']:
            pywikibot.output(u'Error: Already have a Mixer ID (P7335)!')
            continue
        elif item.isRedirectPage():
            pywikibot.output('{0} is a redirect page. Skipping.'.format(item))
            continue
        else:
            try:
                vidID, vidName = mixerAPI(item_dict["labels"]['en'])
                if vidID:
                    print(u'--> {}; Adding Mixer ID (P7335) https://mixer.com/browse/games/{}'.format(item.getID(),vidID))
                    ref, retrieved = getRef(repo, vidID)
                    stringclaim = pywikibot.Claim(repo, u'P7335')
                    stringclaim.setTarget(str(vidID))
                    item.addClaim(stringclaim, summary=u'Adding Mixer ID (P7335) based on Mixer RUST API.')

                    stringclaim.addSources([ref, retrieved], summary=u'Adding sources to Mixer ID (P7335).')
            except:
            # Key is not present
                pass

if __name__ == "__main__":
    main()
