# -*- coding: utf-8  -*-

import regex
import requests, json, re
from datetime import date
from pywikibot import pagegenerators
import pywikibot.data.sparql
import urllib.request
from urllib.parse import unquote
import pywikibot
#Legge til 'lifespan_comment' ??? https://snl.no/Christoffer_av_Bayern.json
BASE_URL = "https://snl.no/api/v1/search" #STABLE
PROTOTYPING_URL = "https://snl.no/.api/prototyping/search" #UNSTABLE

def _get(path, params=None, headers=None):

    response = requests.get(
        path,
        params={'query': params},
    )
    response.raise_for_status()
    
    return response.json()

def getRef(repo):
    #ref
    today = date.today()
    statedin = pywikibot.Claim(repo, u'P248')
    itis = pywikibot.ItemPage(repo, "Q30172599")
    statedin.setTarget(itis)

    retrieved = pywikibot.Claim(repo, u'P813')
    dateCre = pywikibot.WbTime(year=int(today.strftime("%Y")), month=int(today.strftime("%m")), day=int(today.strftime("%d")))
    retrieved.setTarget(dateCre)
    return statedin, retrieved

def createSummery(item,data):
    summary = ""
    try: 
        for key in data['labels']:
            summary+="{} = '{}', ".format(key, data['labels'][key])
        if summary.strip():
            summary = summary[:0] + 'Labels: ' + summary[0:-2]
    except KeyError:
        pass
    summary2 = ""
    try:
        for key in data['descriptions']:
            summary2+="{} = '{}', ".format(key, data['descriptions'][key])
        if summary2.strip():
            summary2 = summary2[:0] + 'Descriptions: ' + summary2[0:-2]
    except KeyError:
        pass
    
    summary3 = ""
    try:
        for key in data['aliases']:
            summary3+="{} = '{}', ".format(key, data['aliases'][key])
        if summary3.strip():
            summary3 = summary3[:0] + 'Aliases: ' + summary3[0:-2]
    except KeyError:
        pass
    
    strings = [summary,summary2,summary3] 
    return ', '.join(x.strip() for x in strings if x.strip())

def wikidataEntity(arts, item, repo, item_dict, data):
    data = {}
    data['labels'] = {}
    if not "nb" in item_dict["labels"]: #update this to a function with list of lang code.
        data['labels'].update({"nb": arts['title']})
    if not "nn" in item_dict["labels"]:
        data['labels'].update({"nn": arts['title']})
    if not "en" in item_dict["labels"]:
        data['labels'].update({"en": arts['title']})
    
    if not "nb" in item_dict["descriptions"]:
        if data['license_name'] == 'fri':
            desc = ""
            descTemp = ""
            descTemp = re.sub(r"\..*","", arts['first_two_sentences'])
            if descTemp.startswith(arts['title'] + " er en") or descTemp.startswith(arts['title'] + " er ei"):
                desc = re.sub(r"^.*?er e[n|i].","",descTemp)
            elif descTemp.startswith(arts['title'] + " var en") or descTemp.startswith(arts['title'] + " var ei"):
                desc = re.sub(r'^.*?[e|va]r e[n|i].', '', descTemp)
            elif descTemp.startswith(arts['title'] + " var"):
                desc = re.sub(r'^.*?[v]ar.', '', descTemp)
            elif descTemp.startswith(arts['title'] + ","):
                desc = descTemp.replace(arts['title'] + ', ', '')
            elif descTemp.startswith(arts['title']):
                desc = descTemp.replace(arts['title'], '')
        
        if desc.strip():
            data.update({"descriptions": {"nb": desc}})
            
    if not "nb" in item_dict["aliases"] or not "nn" in item_dict["aliases"]: #Nicolas Sarkozy (Q329), https://snl.no/Jean_Racine, add for 'nn' if non too
        if arts['article_url_json']:
            alt = ""
            jsonurl = urllib.request.urlopen(arts['article_url_json'])
            data2 = json.load(jsonurl)
            if data2['metadata_license_name'] == "fri":
                if 'alternative_form' in data2['metadata']:
                    alt = re.sub("<[^>]*>","",data2['metadata']['alternative_form'])  # example: "Las Vegas, Nevada" #fjerne det etter komma!
                    alt = re.sub(r"[F|f]ødt.","",alt)
                    alt = re.sub(r"[P|p]seudonym[er].","",alt)
                    alt = re.sub(r"[E|e]gentlig.","",alt)
                    alt = alt[:0] + 'z ' + alt[0:]
                    alt = regex.sub(r'[^\p{Lu}]*((?:[\p{Lu}]+[\p{Ll}]* )*[\p{Lu}-]+[\p{Ll}\p{Lu}-]*)',r'\1, ',alt) #   [^A-Z]+?((?:[A-Z]+[a-z]* )*[A-Z]+[a-z]*)
                    list_string = alt.split(', ')
                    if list_string[-1] == "" or list_string[-1] == ")":
                        del list_string[-1]
                    num = 0
                    for navn in list_string: #connect names like gengish-khan
                        num += 1
                        if navn[-1:] == "-":
                            list_string[num-2] =  navn + list_string[num-2]
                            del list_string[num-1]
                        if navn == item_dict["labels"]["nb"]: #if same name as label, delete.
                            del list_string[num-1]
                    
                    
                    data['aliases'] = {}
                    if not "nb" in item_dict["aliases"]:        
                        data['aliases'].update({"nb": list_string})
                    if not "nn" in item_dict["aliases"]:        
                        data['aliases'].update({"nn": list_string})
    
    summery = createSummery(item,data)
    authorlist = ""
    #for author in data['authors']['full_name']:
    #    authorlist += author['full_name']
    try:
        item.editEntity(data, summary=summery) #TO-DO creds til forfatter etter CC BY-SA 3 and based on what is addded https://www.wikidata.org/wiki/Wikidata:Pywikibot_-_Python_3_Tutorial/Labels
        print("-> " + arts['title'] + " have added " + summery + " by " + data['authors']['full_name'] + ' from https://snl.no/' + unquote(arts['permalink']) )
    except:
        print('Error while saving')
        pass
    
def wikidataStat(data, item, repo, slug): #Legge til 'lifespan_comment' ??? https://snl.no/Christoffer_av_Bayern.json som quote
    statedin, retrieved = getRef(repo) # MISSING: data['metadata']['birthplace'], data['metadata']['place_of_death'], data['metadata']['pronunciation']
    
    if u'P4342' not in item.claims: #SNL (P95194) Born Busy (P95195)
        stringclaim = pywikibot.Claim(repo, u'P4342')
        stringclaim.setTarget(slug)
        
        item.addClaim(stringclaim, summary=u'Adding Store norske leksikon ID.')
        stringclaim.addSources([statedin, retrieved], summary=u'Adding source to Store norske leksikon ID.')
    
    if u'P21' not in item.claims and 'gender' in data['metadata']: # P21
        gender = ""
        if data['metadata']['gender'] == "m" or data['metadata']['gender'] == "f":
            if data['metadata']['gender'] == "m":
                target = pywikibot.ItemPage(repo, u"Q6581097") # male
            else:
                target = pywikibot.ItemPage(repo, u"Q6581072")
                
            print("Adding gender based of SNL ID.")
            claim = pywikibot.Claim(repo, u'P21')
            claim.setTarget(target)
            item.addClaim(claim, summary=u'Adding gender based of SNL ID.')
            claim.addSources([statedin, retrieved], summary=u'Adding source to gender value.')
        else:
            print("Cant find gender!")

    if u'P569' not in item.claims and 'birth_date' in data['metadata']:
        bDate = pywikibot.Claim(repo, u'P569')
        year, month, day = data['metadata']['birth_date'].split('.')
        if month == 0 and len(year) == 4 and year.isdigit():
            dateCre = pywikibot.WbTime(year=year)
        else:
            dateCre = pywikibot.WbTime(year=year, month=month, day=day)
            
        bDate.setTarget(dateCre)
        
        print("Adding birth date based of SNL ID.")
        item.addClaim(claim, summary=u'Adding birth date based of SNL ID.')
        bDate.addSources([statedin, retrieved], summary=u'Adding source to birth date value.')
    
    if u'P570' not in item.claims and 'death_date' in data['metadata']:
        dDate = pywikibot.Claim(repo, u'P570')
        year, month, day = data['metadata']['death_date'].split('.')
        if month == 0 and len(year) == 4 and year.isdigit():
            dateCre = pywikibot.WbTime(year=year)
        else:
            dateCre = pywikibot.WbTime(year=year, month=month, day=day)
            
        dDate.setTarget(dateCre)
        
        print("Adding death date based of SNL ID.")
        item.addClaim(claim, summary=u'Adding death date based of SNL ID.')
        dDate.addSources([statedin, retrieved], summary=u'Adding source to death date value.')
        
def main():
    query = u"""select ?item ?sitelinks where {
      ?item wdt:P31 wd:Q5 .
      ?item wikibase:sitelinks ?sitelinks.
      FILTER (?sitelinks >= 10)
    } limit 200"""        

    repo = pywikibot.Site("wikidata", "wikidata").data_repository()
    bioGen = pagegenerators.PreloadingEntityGenerator(pagegenerators.WikidataSPARQLPageGenerator(query,site=repo))        

    for item in bioGen:
        item_dict = item.get()

        already = False #exsist a SNL ID, use it to make find ID fast
        wikinavn = ""
        if item.claims and 'P4342' in item.claims:#Store norske leksikon ID
            try:
                claim_list = item_dict["claims"]['P4342']
                for claaim in claim_list:
                    wikinavn = claaim.getTarget()            
                already = True
            except:
                print('Error while retrieving SNL ID')
                pass
        else:
            if 'nb' not in item_dict["labels"]:
                print('Error while retrieving english label')
                if 'en' not in item_dict["labels"]:
                    print('Error while retrieving english label')
                    continue
                else:
                    wikinavn = item_dict["labels"]['en']
            else:
                wikinavn = item_dict["labels"]['nb']
                
        wikinavnRe = re.sub("\s*\(.*?\)\s*","",wikinavn)
        art = _get(BASE_URL,params=wikinavnRe)
        #print(art)

        for arts in art: #Search through 3 keys.
            if arts['title'].casefold() == wikinavnRe.casefold() or already == True: #Names match
                if arts['license'] == 'fri' or arts['license'] == 'begrenset': #Stated under "free licence" (Creative Commons-licence (CC-BY-SA-3.0))
                    if arts['article_type_id'] == 2: #article_type_id	1: Vanlig artikkel, 2: Biografi, 3: Landartikkel, etc....
                        slug = unquote(arts['permalink'])
                        print(slug)
                        moreInfo = arts['article_url_json']
                        
                        if moreInfo:
                            jsonurl = urllib.request.urlopen(moreInfo)
                            data = json.load(jsonurl)
                            if data['metadata_license_name'] == "fri": #metadata stated under "free licence" (Creative Commons-licence (CC-BY-SA-3.0))
                                wikidataStat(data, item, repo, slug)
                                #wikidataEntity(arts, item, repo, item_dict, data)
                        
                        
                        break
            elif arts['article_type_id'] == 2 and arts['article_url_json']:
                moreinfo2 = arts['article_url_json']
                jsonurl2 = urllib.request.urlopen(moreinfo2)
                data2 = json.load(jsonurl2)
                if 'alternative_form' in data2['metadata']:
                    alt = re.sub("<[^>]*>","",data2['metadata']['alternative_form'])  # example: "Las Vegas, Nevada" #fjerne det etter komma!
                    alt = alt[:0] + 'z ' + alt[0:]
                    alt = regex.sub(r'[^\p{Lu}]*((?:[\p{Lu}]+[\p{Ll}]* )*[\p{Lu}]+[\p{Ll}]*)',r'\1, ',alt) #   [^A-Z]+?((?:[A-Z]+[a-z]* )*[A-Z]+[a-z]*)
                    list_string = alt.split(',')
                    for name in list_string:
                        if name.casefold() == wikinavnRe.casefold():
                            slug = arts['permalink']
                            wikidataEntity(arts, item, repo, item_dict)
                            moreInfo = arts['article_url_json']
                            if moreInfo:
                                jsonurl = urllib.request.urlopen(moreInfo)
                                data = json.load(jsonurl)
                                if data['metadata_license_name'] == "fri": #metadata stated under "free licence" (Creative Commons-licence (CC-BY-SA-3.0))
                                    wikidataStat(data, item, repo, slug)
                            break

if __name__ == "__main__":
    main()        
