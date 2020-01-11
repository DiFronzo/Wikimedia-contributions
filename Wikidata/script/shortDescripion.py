# -*- coding: utf-8  -*-
import pywikibot
import json
import re
from pywikibot import pagegenerators

"""
Get local description and add it to Wikidata items description.
"""
def findDesc(page):
    #page = pywikibot.Page(site, '2 (Netsky album)')
    content = page.templatesWithParams()

    for val in content:
        if re.search(r"\[\[wikipedia:en:Template:[sS]hort [dD]escription\]\]",str(val[0])):
            return val[1][0]

    PARAMS = {
        "action": "query",
        "format": "json",
        "prop": "description",
        "titles": page.title(),
    }

    data = site._simple_request(**PARAMS).submit()
    for val in data["query"]["pages"]:
        return data["query"]["pages"][val]['description']

def addDesc(page, item):
    desc = findDesc(page)
    try:
        if desc[0].isdigit() or not re.match("(Afghan|Albanian|Algerian|Andorran|Angolan|Barbuda|Antiguan|Barbudan|Argentine|Armenian|Australian|Austrian|Azerbaijani|Azeri|Bahamas|Bahamian|Bahraini|Bengali|Barbadian|Belarusian|Belgian|Belizean|Beninese|Beninois|Bhutanese|Bolivian|Bosnian|Herzegovinian|Motswana|Botswanan|Brazilian|Bruneian|Bulgarian|Faso|Burkinabé|Burmese|Burundian|Verde|Cabo|Verdean|Cambodian|Cameroonian|Canadian|African|Chadian|Chilean|Chinese|Colombian|Comoran|Comorian|Congolese|Rican|Ivorian|Croatian|Cuban|Cypriot|Republic|Czech|Danish|Djiboutian|Dominican|Republic|Dominican|Timor|Timorese|Ecuadorian|Egyptian|Salvador|Salvadoran|Guinea|US|Union|Equatorial|Guinean|Equatoguinean|Eritrean|Estonian|Ethiopian|Fijian|Finnish|French|Gabonese|The|Gambian|Georgian|German|Ghanaian|Gibraltar|Greek|Hellenic|Grenadian|Guatemalan|Guinean|Bissau|Guinean|Guyanese|Haitian|Honduran|Hungarian|Magyar|Icelandic|Indian|Indonesian|Iranian|Persian|Iraqi|Irish|Israeli|Italian|Coast|Ivorian|Jamaican|Japanese|Jordanian|Kazakhstani|Kazakh|Kenyan|Kiribati|Korea|North|Korean|Korea|South|Korean|Kuwaiti|Kyrgyzstani|Kyrgyz|Kirgiz|Kirghiz|Lao|Laotian|Latvian|Lettish|Lebanese|Basotho|Liberian|Libyan|Liechtensteiner|Lithuanian|Luxembourg|Luxembourgish|Republic|of|Macedonian|Malagasy|Malawian|Malaysian|Maldivian|Malian|Malinese|Maltese|Islands|Marshallese|Martiniquais|Martinican|Mauritanian|Mauritian|Mexican|Federated|States|of|Micronesian|Moldovan|Monégasque|Monacan|Mongolian|Montenegrin|Moroccan|Mozambican|Namibian|Nauruan|Nepali|Nepalese|Dutch|Netherlandic|Zealand|New|Zealand|NZ|Zelanian|Nicaraguan|Nigerien|Nigerian|Mariana|Islands|Northern|Marianan|Norwegian|Omani|Pakistani|Palauan|Palestinian|Panamanian|New|Guinea|Papua|New|Guinean|Papuan|Paraguayan|Peruvian|Filipino|Philippine|Polish|Portuguese|Rico|Puerto|Rican|Qatari|Romanian|Russian|Rwandan|Kitts|and|Nevis|Kittitian|or|Nevisian|Lucia|Saint|Lucian|Vincent|and|the|Grenadines|Saint|Vincentian|Vincentian|Samoan|Marino|Major|League|Baseball|Sammarinese|ão|Tomé|and|Príncipe|São|Toméan|Arabia|Saudi|Saudi|Arabian|Senegalese|Serbian|Seychellois|Leone|Sierra|Leonean|Singapore|Singaporean|Slovak|Slovenian|Slovene|Islands|Solomon|Island|Somali|Africa|South|African|Sudan|South|Sudanese|Spanish|Lanka|Sri|Lankan|Sudanese|Surinamese|Swazi|Swedish|Swiss|Syrian|Tajikistani|Tanzanian|Thai|Leste|Timorese|Togolese|Tokelauan|Tongan|and|Tobago|Trinidadian|or|Tobagonian|Tunisian|Turkish|Turkmen|Tuvaluan|Ugandan|Ukrainian|Arab|Emirates|Emirati|Emirian|Emiri|Kingdom|of|Great|Britain|and|Northern|Ireland|UK|British|States|of|America|United|States|U.S.|American|NewYork|New|York|Uruguayan|Uzbekistani|Uzbek|Vanuatu|Vanuatuan|City|State|Vatican|Venezuelan|Vietnamese|Yemeni|Zambian|Zimbabwean)",desc):
            desc = desc[0].lower() + desc[1:]

        if not item.labels['en'].lower() == desc.lower():
            item.editDescriptions(descriptions={'en': desc}, summary=u'Adding [en] description: {}'.format(desc))
    except:
        print('Uses {{Short description|}} or missing label or duplicate')

def main(*args):

    site = pywikibot.Site(u'en', u'wikipedia')
    repo = site.data_repository()  # this is a DataSite object
    site.login()
    cat = pywikibot.Category(site,'Category:Articles with short description')
    gen = pagegenerators.CategorizedPageGenerator(cat)

    f = open('WD.txt', 'w+')

    blacklist = ['16th Brigade (Australia)']

    for page in gen:
        if page.title() in blacklist:
            continue
        try:
            item = pywikibot.ItemPage.fromPage(page)  # this can be used for any page object
            item.get()
        except:
            f.write("%s\n" % page.title())
            continue

        try:
            if not item.descriptions['en']:
                print(page.title())
                addDesc(page, item)
        except KeyError:
            print(page.title())
            addDesc(page, item)

    f.close()

if __name__=='__main__':
    main(sys.argv)
