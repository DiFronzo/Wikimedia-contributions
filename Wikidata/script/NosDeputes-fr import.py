# -*- coding: utf-8  -*-

import pywikibot
from datetime import date
import json, re

def addID(item, repo, slug, twitter, fnaId):
    #ref
    today = date.today()
    statedin = pywikibot.Claim(repo, u'P248')
    itis = pywikibot.ItemPage(repo, "Q65517895")
    statedin.setTarget(itis)

    retrieved = pywikibot.Claim(repo, u'P813')
    dateCre = pywikibot.WbTime(year=int(today.strftime("%Y")), month=int(today.strftime("%m")), day=int(today.strftime("%d")))
    retrieved.setTarget(dateCre)
    
    if item.claims:
        if u'P7040' not in item.claims and u'P4123' not in item.claims:#NosDéputés.fr identifiant & French National Assembly ID
            
            stringclaim = pywikibot.Claim(repo, u'P7040')
            stringclaim.setTarget(slug)
    
            stringclaim3 = pywikibot.Claim(repo, u'P4123')
            stringclaim3.setTarget(str(fnaId))
            
            item.addClaim([stringclaim, stringclaim3], summary=u'Adding NosDéputés.fr identifiant & French National Assembly ID.')
            stringclaim.addSources([statedin, retrieved], summary=u'Adding source to NosDéputés.fr identifiant.')
            stringclaim3.addSources([statedin, retrieved], summary=u'Adding source to French National Assembly ID.')
            print("Adding NosDéputés.fr identifiant & French National Assembly ID.")
            
        elif u'P7040' not in item.claims: #NosDéputés.fr identifiant
            stringclaim = pywikibot.Claim(repo, u'P7040')
            stringclaim.setTarget(slug)
            
            item.addClaim(stringclaim, summary=u'Adding NosDéputés.fr identifiant.')
            stringclaim.addSources([statedin, retrieved], summary=u'Adding source to NosDéputés.fr identifiant.')
            print("Adding NosDéputés.fr identifiant")
            
        elif u'P4123' not in item.claims: #French National Assembly ID
            stringclaim3 = pywikibot.Claim(repo, u'P4123')
            stringclaim3.setTarget(str(fnaId))
            
            item.addClaim(stringclaim3, summary=u'Adding French National Assembly ID.')
            stringclaim3.addSources([statedin, retrieved], summary=u'Adding source to French National Assembly ID.')
            print("Adding French National Assembly ID.")
            
        elif u'P2002' not in item.claims and twitter: #twitter user
            stringclaim2 = pywikibot.Claim(repo, u'P2002')
            stringclaim2.setTarget(twitter)
            item.addClaim([stringclaim2], summary=u'Adding Twitter')
            stringclaim2.addSources([statedin, retrieved], summary=u'Adding source to Twitter.')
            print("Adding Twitter")

        else:
            pywikibot.output(u'Error: Already have NosDéputés.fr identifiant and French National Assembly ID!')
    
def main():
    with open('2017.json') as json_file:
        data = json.load(json_file)
        twitter = None
        for p in data['deputes']:
            name = p['depute']['nom']
            slug = p['depute']['slug']
            fnaId = p['depute']['id_an']
            if p['depute']['twitter']:
                twitter = p['depute']['twitter']
            site = pywikibot.Site('fr', 'wikipedia')  # any site will work, this is just an example
            page = pywikibot.Page(site, name)
            try:
                item = pywikibot.ItemPage.fromPage(page)  # this can be used for any page object

                repo = site.data_repository()  # this is a DataSite object
                item.get()  # you need to call it to access any data.
                
                item_dict = item.get()  # you need to call it to access any data.
                
                sourcesid = 'P39'
                sourceid = 'Q3044918'
                found=False
                if item_dict['descriptions']:
                    try:
                        if sourcesid in item.claims:
                            for source in item.claims[sourcesid]:
                                if source.target.id == sourceid:
                                    found=True
            
                        if found == False:
                            page = pywikibot.Page(site, name + " (homme politique)")
                            item = pywikibot.ItemPage.fromPage(page)
                    except:
                        print("-> No membership for {}".format(name))
                        pass
                
                if 'fr' in item.labels:
                    print('Found: ' + item.labels['fr'])
                    if sourcesid in item.claims:
                        for source in item.claims[sourcesid]:
                            if source.target.id == sourceid:
                                addID(item, repo, slug, twitter, fnaId)
                                break
                            else:
                                print("-> Searching for {} at {}".format(sourceid, name))
            except:
                print("-> Can't find site! Skip page {}".format(name))
                pass
    
if __name__ == "__main__":
    main()
