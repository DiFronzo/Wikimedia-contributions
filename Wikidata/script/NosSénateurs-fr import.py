# -*- coding: utf-8  -*-
import pywikibot
from datetime import date
import json, re

def addID(item, repo, slug, twitter, fnaId):
    #ref
    today = date.today()
    statedin = pywikibot.Claim(repo, u'P248')
    itis = pywikibot.ItemPage(repo, "Q65548286")
    statedin.setTarget(itis)

    retrieved = pywikibot.Claim(repo, u'P813')
    dateCre = pywikibot.WbTime(year=int(today.strftime("%Y")), month=int(today.strftime("%m")), day=int(today.strftime("%d")))
    retrieved.setTarget(dateCre)
    
    if item.claims:
        if u'P7060' not in item.claims and u'P1808' not in item.claims:#NosSénateurs.fr identifier & senat.fr ID.
            
            stringclaim = pywikibot.Claim(repo, u'P7060')
            stringclaim.setTarget(slug)
    
            stringclaim3 = pywikibot.Claim(repo, u'P1808')
            stringclaim3.setTarget("senateur/" + fnaId)
            
            item.addClaim([stringclaim, stringclaim3], summary=u'Adding NosSénateurs.fr identifier & senat.fr ID.')
            stringclaim.addSources([statedin, retrieved], summary=u'Adding source to NosSénateurs.fr identifier.')
            stringclaim3.addSources([statedin, retrieved], summary=u'Adding source to senat.fr ID.')
            print("Adding NosSénateurs.fr identifier & senat.fr ID.")
            
        elif u'P7060' not in item.claims: #NosSénateurs.fr identifier
            stringclaim = pywikibot.Claim(repo, u'P7060')
            stringclaim.setTarget(slug)
            
            item.addClaim(stringclaim, summary=u'Adding NosSénateurs.fr identifier.')
            stringclaim.addSources([statedin, retrieved], summary=u'Adding source to NosSénateurs.fr identifier.')
            print("Adding NosSénateurs.fr identifier")
            
        elif u'P1808' not in item.claims: #senat.fr ID (P1808)
            stringclaim3 = pywikibot.Claim(repo, u'P1808')
            stringclaim3.setTarget("senateur/" + fnaId)
            
            item.addClaim(stringclaim3, summary=u'Adding senat.fr ID.')
            stringclaim3.addSources([statedin, retrieved], summary=u'Adding source to senat.fr ID.')
            print("Adding senat.fr ID.")
            
        elif u'P2002' not in item.claims and twitter: #twitter user
            stringclaim2 = pywikibot.Claim(repo, u'P2002')
            stringclaim2.setTarget(twitter)
            item.addClaim([stringclaim2], summary=u'Adding Twitter')
            stringclaim2.addSources([statedin, retrieved], summary=u'Adding source to Twitter.')
            print("Adding Twitter")

        else:
            pywikibot.output(u'Error: Already have NosDéputés.fr identifiant and French National Assembly ID!')
    
def main(): #from text file donloaded.
    with open('2019.json') as json_file:
        data = json.load(json_file)
        twitter = None
        file = open("testfile.txt","w")
        for p in data['senateurs']:
            name = p['senateur']['nom']
            slug = p['senateur']['slug']
            fnaId = p['senateur']['id_institution']
            if p['senateur']['twitter']:
                twitter = p['senateur']['twitter']
            site = pywikibot.Site('fr', 'wikipedia')  # any site will work, this is just an example
            page = pywikibot.Page(site, name)
            
             
            try:
                item = pywikibot.ItemPage.fromPage(page)  # this can be used for any page object

                repo = site.data_repository()  # this is a DataSite object
                item.get()  # you need to call it to access any data.
                
                item_dict = item.get()  # you need to call it to access any data.
                
                sourcesid = 'P39'
                sourceid = 'Q14828018'
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
                            found = True
                    except:
                        print("-> No membership for {}".format(name))
                        pass
                
                if 'fr' in item.labels:
                    print('Found: ' + item.labels['fr'])
                    if found == True:
                        addID(item, repo, slug, twitter, fnaId)
                    else:
                        print("-> Something went wrong with {}".format(sourceid, name))
                        file.write("{}: {}".format(name, slug))
            except:
                print("-> Can't find site! Skip page {}".format(name))
                file.write("{}: {}".format(name, slug))
                pass
    file.close()

if __name__ == "__main__":
    main()
