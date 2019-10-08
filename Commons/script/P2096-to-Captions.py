# -*- coding: utf-8  -*-
import pywikibot
import re
import pywikibot.data.sparql
import time
from pywikibot.comms import http
import json
from pywikibot import pagegenerators
import urllib.request
from urllib.parse import unquote

def regex(text):
    newText = ""
    newText = re.sub(r'(<|&lt;)br\s*\/*(>|&gt;)', '', text) #remove <br
    newText = re.sub(r'<ref>(.*?)<\/ref>', '', newText) #remove <ref>..</ref>
    newText = re.sub(r'\<.*', '', newText) #remove <sm...
    newText = re.sub(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]',r'\1 ', newText) #remove [[stockholm|stook]]
    newText = re.sub(r"([''|'])", '', newText)
    return newText

def getCaptions(mediaid, jsonF=False):
    try:     #example https://commons.wikimedia.org/w/api.php?action=wbgetentities&format=json&ids=M4026453
        jsonurl = urllib.request.urlopen(u'https://commons.wikimedia.org/w/api.php?action=wbgetentities&format=json&ids={}'.format(mediaid))
        data = json.load(jsonurl)
        if jsonF == True:
            if data['success'] == 1:
                return [lang for lang in data['entities'][mediaid]['labels']]
            else:
                pywikibot.output("Error: The request for {} didtn went successful!".format(mediaid))
                return -1
        else:
            for lang in data['entities'][mediaid]['labels']:
                print("{}: {}".format(lang, data['entities'][mediaid]['labels'][lang]['value']))
    except:
        return ""


def addCaptions(mediaid, value, pageid, ID):
    labels = {}
    existingCap = getCaptions(mediaid,jsonF=True)

    for (lang), (text)  in zip(value[pageid]['lang'], value[pageid]['text']):
        if not (lang in existingCap) and text.strip() and existingCap != -1:
            labels[lang] = {u'language' : lang, 'value' : text}

    if not labels:
        pywikibot.output('Didnt add anything to {0}. Skipping.'.format(mediaid))
        return ""

    tokenrequest = http.fetch(u'https://commons.wikimedia.org/w/api.php?action=query&meta=tokens&type=csrf&format=json')
    tokendata = json.loads(tokenrequest.text)
    token = tokendata.get(u'query').get(u'tokens').get(u'csrftoken')

    summary = u'Adding captions for {0} language(s) based on [[d:{1}|{1}]] qualifier(s), media legend (P2096)'.format(len(value[pageid]['lang']), ID)
    pywikibot.output(mediaid + u' ' + summary)

    postdata = {u'action' : u'wbeditentity',
                u'format' : u'json',
                u'id' : mediaid,
                u'data' : json.dumps({ u'labels' : labels}),
                u'token' : token,
                u'summary' : summary,
                u'bot' : True,
                }
    apipage = http.fetch(u'https://commons.wikimedia.org/w/api.php', method='POST', data=postdata)

def runOnCommons(captions, ID):

    repo = pywikibot.Site().data_repository()
    site = pywikibot.Site(u'commons', u'commons')
    for pageid in captions:
        mediaid = u'M%s' % (pageid,)
        addCaptions(mediaid, captions, pageid, ID)

def main(*args):
    """
    Main function. Grab a generator and pass it to the bot to work on
    """
    repo = pywikibot.Site("wikidata", "wikidata").data_repository()

    CherQu = u"""SELECT ?item WHERE {
      ?item wdt:P758 _:b1 ;
            wdt:P18 [].
    }"""
    
    logoQu = u"""SELECT DISTINCT ?item
    WHERE
    {
     ?item p:P154 ?statement.
     ?statement ps:P154 ?image.
     ?statement pq:P2096 ?media.
    }"""

    humanQu = u"""SELECT DISTINCT ?item
    WHERE
    {
     ?item wdt:P31 wd:Q5.
     ?item p:P18 ?statement.
     ?statement ps:P18 ?image.
     ?statement pq:P2096 ?media.
    }"""

    nonHumanQu = u"""SELECT DISTINCT ?item
    WHERE
    {
     ?item p:P18 ?statement.
     ?statement ps:P18 ?image.
     ?statement pq:P2096 ?media.
     MINUS { ?item wdt:P31 wd:Q5. }
    }"""

    personGen = pagegenerators.PreloadingEntityGenerator(pagegenerators.WikidataSPARQLPageGenerator(CherQu,site=repo))
    count = 0
    for item in personGen:
        if item.isRedirectPage():
            pywikibot.output('{0} is a redirect page. Skipping.'.format(item))
            continue
        item.get() #Get the item dictionary
        value = {}
        val = None
        pageid = None
        print('--> ' + item.getID() + ': ')
        for claim in item.claims['P18']:
            value[str(claim.getTarget().pageid)] = {'lang':[], 'text':[]}

            if 'P2096' in claim.qualifiers:
                for qual in claim.qualifiers['P2096']:
                    try:
                        value[str(claim.getTarget().pageid)]['lang'].append(qual.getTarget().language)
                        value[str(claim.getTarget().pageid)]['text'].append(regex(qual.getTarget().text))
                    except:
                        continue

        if value:
            runOnCommons(value, item.getID())
            count += 1
            for pageid in value:
                for (lang), (text)  in zip(value[pageid]['lang'], value[pageid]['text']):
                    print('--> {}; {}: {}'.format(pageid,lang, text))

        if count == 50:
            pywikibot.output('Sleep for 60 sec. ...')
            time.sleep(60)

if __name__ == "__main__":
    main()
