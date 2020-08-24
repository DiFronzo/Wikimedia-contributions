# -*- coding: utf-8  -*-

import bs4 as bs
import urllib.request
import re
from datetime import date
import pywikibot

regex = {'spotify': 'http:\/\/open\.spotify\.com\/album\/(.*)', 'youtube': 'https:\/\/youtu\.be\/(.*)\?', 
         'soundcloud': 'https:\/\/soundcloud\.com\/(.*)', 'google-play': 'https:\/\/play\.google\.com\/music\/m\/(.*)',
        'deezer': 'https:\/\/www\.deezer\.com\/album\/(.*)\?', 'amazonmusic': 'https:\/\/www\.amazon\.com\/dp\/(.*)\?',
        'applemusic': 'https:\/\/music\.apple\.com\/[a-z-]{0,5}\/album\/(.*)\?', 'youtubemusic': 'https:\/\/music\.youtube\.com\/playlist\?list=(.*)&src',
        'tidal': 'http:\/\/listen\.tidal\.com\/album\/(.*)'}

propery = {'spotify': 'P2205', 
           'youtube': 'P1651', 
           'soundcloud': 'P3040', 
           'google-play': 'P4199',
           'deezer': 'P2723',
           'amazonmusic': 'P5749',
          'applemusic': 'P2281',
          'youtubemusic': 'P4300',
          'tidal': 'P4577'}

def getRef(repo, url):
    #ref
    today = date.today()

#     ref = pywikibot.Claim(repo, u'P854') #Blacklisted url
#     ref.setTarget(url)
    
    statedin = pywikibot.Claim(repo, u'P248')
    itis = pywikibot.ItemPage(repo, "Q95877104")
    statedin.setTarget(itis)

    retrieved = pywikibot.Claim(repo, u'P813')
    dateCre = pywikibot.WbTime(year=int(today.strftime("%Y")), month=int(today.strftime("%m")), day=int(today.strftime("%d")))
    retrieved.setTarget(dateCre)
    
    return retrieved, statedin


def regex_run(service, txt):
    x = re.search(regex[service], txt)
    if x and x.group():
        return x.group(1)
    
    return ''

def add_to_wd(x, service, url, qid, repo):
    item = ''
    try:
        item = pywikibot.ItemPage(repo, qid)
    except:
        pywikibot.output(u'Error: QID not found!')
        return ''
    
    claims = item.get(u'claims')
    
    if propery[service] in claims[u'claims']:
        pywikibot.output(u'Error: Already have {} ID!'.format(service))
        return ''
    
    retrieved, statedin = getRef(repo, url)
    stringclaim = pywikibot.Claim(repo, propery[service]) #add the value
    stringclaim.setTarget(x)
    item.addClaim(stringclaim, summary=u'Adding {} ID'.format(service))
    
    stringclaim.addSources([retrieved, statedin], summary=u'Adding reference(s) to {} ID'.format(service))
    
    pywikibot.output(u'Success: Added {} ID!'.format(service))

def main()
  #ONLY CHANGE THE FOLLOWING VALUES! WORKES ONLY WITH lnk.to URLs.

  qid = 'Q47482898'
  url2 = 'https://drake.lnk.to/ScaryHoursYD'

  # -------------------------------------------
  repo = pywikibot.Site("wikidata", "wikidata").data_repository()

  source = urllib.request.urlopen(url2).read()
  soup = bs.BeautifulSoup(source,'lxml')
  nav = soup.nav


  for url in nav.find_all('a'):
      if url.get('data-label') in regex:
          x = regex_run(url.get('data-label'), url.get('href'))
          if x:
              add_to_wd(x, url.get('data-label'), url2, qid, repo)

  pywikibot.output(u'Done!')
  
if __name__ == "__main__":
    main()
