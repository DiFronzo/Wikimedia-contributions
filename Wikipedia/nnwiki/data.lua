
return {

--[[ Country settings ]]

-- Countries where state / highest administrative division is displayed if "stad = ja" argument is used
show_state = {
	Q16 = true, -- Canada
	Q30 = true, -- USA
	Q96 = true, -- Mexico
	Q155 = true, -- Brazil
	Q159 = true, -- Russia
	Q183 = true, -- Germany
	Q408 = true, -- Australia
	Q414 = true, -- Argentina
	Q668 = true, -- India
	Q843 = true, -- Pakistan
},

-- Lande
countries = {
	-- 1 = ISO 3166-1 alpha-2 code for geoHack
	-- 2 = sitelink
	-- 3 = label
	Q16 = {'CA', 'Canada'},
	Q17 = {'JP', 'Japan'},
	Q20 = {'NO', 'Noreg'},
	Q27 = {'IE', 'Irland'},
	Q28 = {'HUG', 'Ungarn'},
	Q29 = {'ESS', 'Spania'},
	Q30 = {'US', 'USA'},
	Q31 = {'BE', 'Belgia'},
	Q32 = {'LU', 'Luxembourg'},
	Q33 = {'FI', 'Finland'},
	Q34 = {'SV', 'Sverige'},
	Q35 = {'DA', 'Danmark'},
	Q36 = {'PL', 'Polen'},
	Q37 = {'LT', 'Litauen'},
	Q38 = {'IT', 'Italia'},
	Q39 = {'CH', 'Schweiz'},
	Q40 = {'AT', 'Austerrike'},
	Q41 = {'GR', 'Hellas'},
	Q43 = {'TR', 'Tyrkia'},
	Q45 = {'PT', 'Portugal'},
	Q55 = {'NL', 'Holland'},
	Q77 = {'UY', 'Uruguay'},
	Q79 = {'EIK', 'Egypten'},
	Q96 = {'MX', 'Mexico'},
	Q114 = {'KE', 'Kenya'},
	Q115 = {'EIT', 'Etiopia'},
	Q117 = {'GH', 'Ghana'},
	Q142 = {'FR', 'Frankrike'},
	Q145 = {'GB', 'Storbritannia'},
	Q148 = {'CN', 'Kina'},
	Q155 = {'BR', 'Brasilia'},
	Q159 = {'RU', 'Russland'},
	Q183 = {'DE', 'Tyskland'},
	Q184 = {'BY', 'Kviterussland'},
	Q189 = {'IS', 'Island'},
	Q191 = {'EE', 'Estland'},
	Q211 = {'LV', 'Latvia'},
	Q212 = {'UA', 'Ukraina'},
	Q213 = {'CZ', 'Tjekkiet'},
	Q214 = {'SK', 'Slovakia'},
	Q215 = {'SI', 'Slovenia'},
	Q217 = {'MD', 'Moldova'},
	Q218 = {'RO', 'Rumænien'},
	Q219 = {'BG', 'Bulgaria'},
	Q221 = {'MK', 'Makedonien'},
	Q222 = {'AL', 'Albania'},
	Q223 = {'GL', 'Grønland'},
	Q224 = {'HR', 'Kroatia'},
	Q225 = {'BA', 'Bosnia-Hercegovina'},
	Q227 = {'AZ', 'Aserbajdsjan'},
	Q228 = {'AD', 'Andorra'},
	Q229 = {'CY', 'Cypern'},
	Q230 = {'GE', 'Georgia'},
	Q232 = {'KZ', 'Kasakhstan'},
	Q233 = {'MT', 'Malta'},
	Q235 = {'MC', 'Monaco'},
	Q236 = {'ME', 'Montenegro'},
	Q237 = {'VA', 'Vatikanstaten'},
	Q238 = {'SM', 'San Marino'},
	Q241 = {'CU', 'Cuba'},
	Q242 = {'BZ', 'Belize'},
	Q244 = {'BB', 'Barbados'},
	Q252 = {'ID', 'Indonesia'},
	Q258 = {'ZA', 'Sydafrika'},
	Q262 = {'DZ', 'Algeriet'},
	Q265 = {'UZ', 'Usbekistan'},
	Q298 = {'CL', 'Chile'},
	Q334 = {'SG', 'Singapore'},
	Q347 = {'LI', 'Liechtenstein'},
	Q398 = {'BH', 'Bahrain'},
	Q399 = {'AM', 'Armenia'},
	Q403 = {'RS', 'Serbia'},
	Q408 = {'AU', 'Australia'},
	Q414 = {'AR', 'Argentina'},
	Q419 = {'PE', 'Peru'},
	Q423 = {'KP', 'Nordkorea'},
	Q574 = {'TP', 'Østtimor'},
	Q657 = {'TD', 'Tchad'},
	Q664 = {'NZ', 'New Zealand'},
	Q668 = {'IN', 'India'},
	Q672 = {'TV', 'Tuvalu'},
	Q678 = {'TO', 'Tonga'},
	Q683 = {'WS', 'Samoa'},
	Q685 = {'SB', 'Salomonøyane'},
	Q686 = {'VU', 'Vanuatu'},
	Q691 = {'PG', 'Papua Ny Guinea'},
	Q695 = {'PW', 'Palau'},
	Q697 = {'NR', 'Nauru'},
	Q702 = {'FM', 'Mikronesia'},
	Q710 = {'KI', 'Kiribati'},
	Q711 = {'MN', 'Mongolia'},
	Q712 = {'FJ', 'Fiji'},
	Q717 = {'VE', 'Venezuela'},
	Q733 = {'PY', 'Paraguay'},
	Q734 = {'GY', 'Guyana'},
	Q736 = {'EC', 'Ecuador'},
	Q739 = {'CO', 'Colombia'},
	Q750 = {'BO', 'Bolivia'},
	Q754 = {'TT', 'Trinidad og Tobago'},
	Q757 = {'VC', 'Saint Vincent og Grenadinerne'},
	Q760 = {'LC', 'Saint Lucia'},
	Q766 = {'JM', 'Jamaica'},
	Q769 = {'GD', 'Grenada'},
	Q774 = {'GT', 'Guatemala'},
	Q778 = {'BS', 'Bahamas'},
	Q781 = {'AG', 'Antigua og Barbuda'},
	Q786 = {'DO', 'Dominikanske Republikk'},
	Q790 = {'HT', 'Haiti'},
	Q796 = {'IQ', 'Irak'},
	Q702 = {'SV', 'El Salvador'},
	Q783 = {'HN', 'Honduras'},
	Q794 = {'IR', 'Iran'},
	Q800 = {'CR', 'Costa Rica'},
	Q801 = {'IL', 'Israel'},
	Q804 = {'PA', 'Panama'},
	Q805 = {'YE', 'Yemen'},
	Q810 = {'JO', 'Jordan'},
	Q811 = {'NI', 'Nicaragua'},
	Q813 = {'KG', 'Kirgisistan'},
	Q817 = {'KW', 'Kuwait'},
	Q819 = {'LA', 'Laos'},
	Q822 = {'LB', 'Libanon'},
	Q826 = {'MV', 'Maldivane'},
	Q833 = {'MY', 'Malaysia'},
	Q836 = {'BU', 'Myanmar'}, -- NB. Burma i coord wd/finn
	Q837 = {'NP', 'Nepal'},
	Q842 = {'OM', 'Oman'},
	Q843 = {'PK', 'Pakistan'},
	Q846 = {'QA', 'Qatar'},
	Q851 = {'SA', 'Saudi-Arabia'},
	Q854 = {'LK', 'Sri Lanka'},
	Q858 = {'SY', 'Syria'},
	Q863 = {'TJ', 'Tadsjikistan'},
	Q865 = {'TW', 'Taiwan'}, -- òg kalla Republikken Kina
	Q869 = {'TH', 'Thailand'},
	Q874 = {'TM', 'Turkmenistan'},
	Q878 = {'AE', 'Sameina Arabiske Emirat'},
	Q881 = {'VN', 'Vietnam'},
	Q884 = {'KR', 'Sydkorea'},
	Q889 = {'AV', 'Afghanistan'},
	Q902 = {'BD', 'Bangladesh'},
	Q912 = {'ML', 'Mali'},
	Q916 = {'AO', 'Angola'},
	Q917 = {'BT', 'Bhutan'},
	Q921 = {'BN', 'Brunei'},
	Q924 = {'TZ', 'Tanzania'},
	Q928 = {'PH', 'Filippinene'},
	Q929 = {'CF', 'Sentralafrikanske Republikk'},
	Q945 = {'TG', 'Togo'},
	Q948 = {'TN', 'Tunesien'},
	Q953 = {'ZM', 'Zambia'},
	Q954 = {'ZW', 'Zimbabwe'},
	Q962 = {'BJ', 'Benin'},
	Q963 = {'BW', 'Botswana'},
	Q967 = {'BI', 'Burundi'},
	Q965 = {'BF', 'Burkina Faso'},
	Q970 = {'KM', 'Comorerne'},
	Q971 = {'CD', 'Republikken Congo'},
	Q977 = {'DJ', 'Djibouti'},
	Q983 = {'GQ', 'Ækvatorialguinea'},
	Q984 = {'DM', 'Dominica'},
	Q986 = {'ER', 'Eritrea'},
	Q1000 = {'GA', 'Gabon'},
	Q1005 = {'GM', 'Gambia'},
	Q1006 = {'GN', 'Guinea'},
	Q1007 = {'GW', 'Guinea-Bissau'},
	Q1008 = {'CI', 'Elfenbeinkysten'},
	Q1009 = {'CM', 'Cameroun'},
	Q1011 = {'CV', 'Kap Verde'},
	Q1013 = {'LS', 'Lesotho'},
	Q1014 = {'LR', 'Liberia'},
	Q1016 = {'LY', 'Libyen'},
	Q1019 = {'MG', 'Madagaskar'},
	Q1020 = {'MW', 'Malawi'},
	Q1025 = {'MR', 'Mauretania'},
	Q1027 = {'MU', 'Mauritius'},
	Q1028 = {'MA', 'Marokko'},
	Q1029 = {'MZ', 'Mozambique'},
	Q1030 = {'NA', 'Namibia'},
	Q1032 = {'NE', 'Niger'},
	Q1033 = {'NG', 'Nigeria'},
	Q1036 = {'UG', 'Uganda'},
	Q1037 = {'RW', 'Rwanda'},
	Q1039 = {'ST', 'São Tomé og Príncipe'},
	Q1041 = {'SN', 'Senegal'},
	Q1042 = {'SC', 'Seychellerne'},
	Q1044 = {'SL', 'Sierra Leone'},
	Q1045 = {'SO', 'Somalia'},
	Q1049 = {'SD', 'Sudan'},
	Q1183 = {'PR', 'Puerto Rico'},
	Q4628 = {'FO', 'Færøyane'},
	Q6250 = {'EH', 'Vestsahara'},
	Q8646 = {'HK', 'Hongkong'},
	Q9676 = {'IM', 'Isle of Man'},
	Q15180 = {nil, 'Sovjetunionen'}, -- tidlegare SU
	Q16957 = {'DE', 'DDR', 'Austtyskland'}, --sitelink, label (tidlegare DD)
	Q23635 = {'BM', 'Bermuda'},
	Q25227 = {'AN', 'Nederlandske Antiller'}, -- Opphøyrt 2010
	Q29999 = {'NL', 'Kongeriket Nederlandene'},
	Q33946 = {nil, 'Tjekkoslovakiet'}, -- tidlegare CS
	Q34020 = {'NU', 'Niue'},
	Q34266 = {'RU', 'Det Russiske Keisarriket'}, -- Russiske Keisarrike på coord wd/finn
	Q36704 = {nil, 'Jugoslavia'}, -- tidlegare YU
	Q83286 = {nil, 'Sosialistiske Føderale Republikk Jugoslavia', 'SFR Jugoslavia'}, -- sitelink, label
	Q172579 = {'IT', 'Kongeriket Italia'},
	Q219060 = {'PS', nil, 'Palæstina'}, -- (Gaze og Vestbredden) ingen oppsett
	Q713750 = {'DE', 'Vesttyskland'},
	Q13474305 = {'ESS', 'Spania under Franco'},
},

-- Don't show country for these places even if land = or sted = ja
no_country = {
	Q35 = true, -- Danmark (is located in the country Kingdom of Denmark according to Wikidata)
	Q223 = true, -- Grønland (is located in the country Kingdom of Denmark according to Wikidata)
	Q4628 = true, -- Færøerne (is located in the country Kingdom of Denmark according to Wikidata)
	Q25231 = true, -- Svalbard (is located in the country Kingdom of Norway according to Wikidata)
},

--[[ språkinnstillingar ]]

preferred_language = 'nn',

-- Labels are led in these languages first:
fallback_languages = { 'nb', 'da', 'sv', 'en', 'de', 'nl', 'fr', 'sp', 'it', 'pt' },

-- Names of people are always used without a warning note from these languages
fallback_languages_humans = { 'nb', 'da', 'sv' },

-- Tekst i advarselsnote
fallback_note = '<span style="color:gray; cursor:help;"><small>Namnet er anført på %s og stammer frå [[d:%s|Wikidata]] kor namnet endå ikkje blir funne på nynorsk.</small></span>',

-- If a subject is located in one of these countries, a label in the language listed will be used without language warning
-- The country is listed as its Wikidata topic. The language is indicated by the 2-letter language code.
fallback_languages_after_country = {
	Q20 = 'da', -- Danmark
	Q30 = 'en', -- USA
	Q34 = 'sv', -- Sweden
	Q142 = 'fr', -- France
	Q145 = 'en', -- UK
	Q183 = 'de' -- Germany
},

-- If a subject is a person who is a national of one of these countries, a label in the language listed will be used without language warning
-- The country is listed as its Wikidata topic. The language is indicated by the 2-letter language code.
fallback_languages_for_persons = {
	Q29 = 'sp', -- Spain
	Q30 = 'en', -- USA
	Q33 = 'fi', -- Finland
	Q38 = 'it', -- Italy
	Q40 = 'de', -- Austria
	Q45 = 'pt', -- Portugal
	Q55 = 'nl', -- Netherlands
	Q96 = 'sp', -- Mexico
	Q142 = 'fr', -- France
	Q145 = 'en', -- UK
	Q155 = 'pt', -- Brazil
	Q183 = 'de', -- Germany
	Q189 = 'is', -- Iceland
	Q298 = 'sp', -- Chile
	Q408 = 'en', -- Australia
	Q414 = 'sp', -- Argentina
	Q664 = 'en' -- New Zealand
},

--[[ Tidsindstillinger ]]
bc = ' fvt.',
months = {
	['1'] = 'januar ',		['2'] = 'februar ',		['3'] = 'mars ',
	['4'] = 'april ',		['5'] = 'mai ',			['6'] = 'juni ',
	['7'] = 'juli ',		['8'] = 'august ',		['9'] = 'september ',
	['10'] = 'oktober ',	['11'] = 'november ',	['12'] = 'desember ' },

--[[ Enheter ]]

wd_units = {
	-- area units
	Q712226 = { name = 'km2', show_as = 'km<sup>2</sup>', conv = 1e6, type = 'area' },
	Q25343 = { name = 'm2', show_as = 'm<sup>2</sup>', conv = 1, type = 'area' },
	Q232291 = { name = 'mil2', show_as = 'mil<sup>2</sup>', conv_to = 'km2', conv = 2589988.110336, type = 'area'},
	Q35852 = { name = 'ha', show_as = 'ha', conv_to = 'km2', conv = 10000, type = 'area'},

	-- currency units
	Q25417 = { name = 'DKK', show_as = "dkk", conv = 1, type = 'currency' },
	Q4916 = { name = 'EUR', show_as = "€", conv = 1, type = 'currency' },
	Q25224 = { name = 'GBP', show_as = "£", conv = 1, type = 'currency' },
	Q132643 = { name = 'NOK', show_as = "nok", conv = 1, type = 'currency' },
	Q122922 = { name = 'SEK', show_as = "sek", conv = 1, type = 'currency' },
	Q4917 = { name = 'USD', show_as = "$", conv = 1, type = 'currency' },
	Q41044 = { name = 'RUB', show_as = "rub", conv = 1, type = 'currency' }, -- Russian rubles
	Q1104069 = { name = 'CAD', show_as = "cad", conv = 1, type = 'currency' }, -- Canadian dollars
	Q8146 = { name = 'JPY', show_as = "¥", conv = 1, type = 'currency' }, -- Japanese yen
	Q25344 = { name = 'CHF', show_as = "CHF", conv = 1, type = 'currency' }, -- Swiss franc
	Q202040 = { name = 'KRW', show_as = "₩", conv = 1, type = 'currency' }, -- South Korean won

	-- length units
	Q11573 = { name = 'm', show_as = 'm', conv = 1, type = 'length' },
	Q828224 = { name = 'km', show_as = 'km', conv = 1e3, type = 'length' },
	Q253276 = { name = 'mile', show_as = 'mil', conv_to = 'km', conv = 1609.344, type = 'length' },
	Q3710 = { name = 'foot', show_as = 'fot', conv_to = 'm', conv = 0.3048006, type = 'length' },
	Q174728 = { name = 'cm', show_as = 'cm', conv = 0.01, type = 'length' },
	Q174789 = { name = 'mm', show_as = 'mm', conv = 0.001, type = 'length' },
	Q218593 = { name = 'in', show_as = '″', conv = 0.0254, type = 'length' },

	-- mass units
	Q11570 = { name = 'kg', show_as = 'kg', conv = 1, type = 'mass' },
	Q100995 = { name = 'lb', show_as = "lb", conv = 0.45359237, type = 'mass' },

	-- time units
	Q11574 = { name = 's', show_as = 's', conv = 1, type = 'time' },
	Q7727 = { name = 'minutt', show_as = 'min.', conv = 60, type ='time' },
	Q25235 = { name = 'time', show_as = 't', conv = 3600, type = 'time' },

	-- speed units
	Q182429 = { name = 'm/s', show_as = 'm/s', conv = 1, type = 'speed' },
	Q180154 = { name = 'km/t', show_as = 'km/t', conv = 0.2777777777777777778, type = 'speed' },
	Q128822 = { name = 'Knop', show_as = 'kn', conv = 0.51444444444444444444, type = 'speed' },
	Q748716 = { name = 'ft/s', show_as = 'ft/s', conv = 0,3048, type = 'speed' }},

wanted_units = {
	m2 = { show_as = 'm<sup>2</sup>', conv = 1, type = 'area' },
	km2 = { show_as = 'km<sup>2</sup>', conv = 1e-6, type = 'area' },
	m = { show_as = 'm', conv = 1, type = 'length' },
	km = { show_as = 'km', conv = 1e-3, type = 'length' },
	cm = { show_as = 'cm', conv = 100, type = 'length' },
	kg = { show_as = 'kg', conv = 1, type = 'mass' },
	['km/t'] = { show_as = 'km/t', conv = 3.6, type = 'speed' },
	['m/s'] = { show_as = 'm/s', conv = 1, type = 'speed' },
	min = { show_as = 'min.', conv = 1/60, type = 'time' }},

--[[ Time zones used in Russia for use in the msk parameter in {{Wikidata-emne}}]]
msk_timezones = {
	Q6723 = ' ([[Moskva tid|MSK]]-1)', -- UTC+2
	Q6760 = ' ([[Moskva tid|MSK]])', -- UTC+3
	Q6779 = ' ([[Moskva tid|MSK]]+1)', -- UTC+4
	Q6806 = ' ([[Moskva tid|MSK]]+2)', -- UTC+5
	Q6906 = ' ([[Moskva tid|MSK]]+3)', -- UTC+6
	Q6940 = ' ([[Moskva tid|MSK]]+4)', -- UTC+7
	Q6985 = ' ([[Moskva tid|MSK]]+5)', -- UTC+8
	Q7041 = ' ([[Moskva tid|MSK]]+6)', -- UTC+9
	Q7056 = ' ([[Moskva tid|MSK]]+7)', -- UTC+10
	Q7069 = ' ([[Moskva tid|MSK]]+8)', -- UTC+11
	Q7105 = ' ([[Moskva tid|MSK]]+9)'}, -- UTC+12


--[[ Sporingskategorier ]]
tracking_cats = {
	-- spraak
	fallback_category ='[[Kategori:Informasjon frå Wikidata på eit anna språk enn nynorsk]]',
	category_human_missing_name ='[[Kategori:Personnamn frå Wikidata på eit anna språk enn nynorsk]]',
	category_missing_russian_name = '[[Kategori:Namn manglar på Wikidata for russar eller stad i Russland]]',

	-- mange verdier
	many_p106_category='[[Kategori:Mange opplysingar frå Wikidata for P106 (sysselsetjing)]]',
	tiplus_p106_category='[[Kategori:Meir enn 10 opplysingar frå Wikidata for P106 (sysselsetjing)]]',
	many_p166_category ='[[Kategori:Mange opplysingar frå Wikidata for P166 (utmerkingar)]]',
	many_p463_category ='[[Kategori:Mange opplysingar frå Wikidata for P463 (medlem av)]]',
	many_p737_category ='[[Kategori:Mange opplysingar frå Wikidata for P737 (påverka av)]]',
	many_p800_category ='[[Kategori:Mange opplysingar frå Wikidata for P800 (hovudverk)]]',
	many_p802_category ='[[Kategori:Mange opplysingar frå Wikidata for P802 (elev)]]',
	many_p1082_category ='[[Kategori:Mange opplysingar frå Wikidata for P1082 (innbyggjartal)]]',
	many_p1344_category ='[[Kategori:Mange opplysingar frå Wikidata for P1344 (delstog i)]]',
	
	--einingar
	category_unrecognized_unit = '[[Kategori:Eining for storleik på Wikidata som ikkje er genkendt]]',
	
	-- referansar
	category_repeated_ref = '[[Kategori:Wikidata-referanse bruker same eigenskap meir enn ein gang]]',
	category_unknown_ref = '[[Kategori:Wikidata-referanse bruker ukjend eigenskap]]'},

}
