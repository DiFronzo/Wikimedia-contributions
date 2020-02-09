require("Modul:No globals")
local data = mw.loadData("Modul:Kinfo/data")
local getArgs = require('Module:Arguments').getArgs

local p = {}

local function getRef(frame)
	return frame:callParserFunction{ name = '#tag:ref', args = {
    '{{kilde www |url=https://www.kartverket.no/kunnskap/Fakta-om-Norge/Arealstatistikk/Arealstatistikk-Norge/ |tittel=Arealstatistikk for Norge |nettside=[[Kartverket]] |dato=1. januar 2020 |språk=norsk bokmål}}'
	, name = 'Kartverket2020'} }
end

local function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local table_sort = {'kommune','totareal','areal','havflate','apentomrade','snoisbre','innsjo','elvtorrfall','myr','skog','dmark','btbygg','industri','annet','landareal'}
local header_sort = {'Nr.','Kommune','Totalt areal','Fastland og øyer','Havflate','Åpent område','Snø, is og bre','Elv med tørrfall','Innsjø','Myr','Skog','Dyrket mark','By- og tettbebyggelse','Industriområde','Annet','Landareal'}

local function sorted_iter(t)
  local fin = {}
  for i, val in pairs(t) do
    for i2, val2 in pairs(table_sort) do
      if i == val2 then
      	if tonumber(val) then
        	table.insert(fin,i2, tonumber(val))
        else
        	table.insert(fin,i2, val)
        end
      end
    end
  end
  return fin
end

function p.tabell(frame)
	local args = getArgs(frame)
	local fylkenr = tonumber(args[1])
	local row = ''
	local tbl = mw.html.create('table')
	tbl
		:addClass('wikitable sortable')
		:tag('caption'):wikitext(data['fylke'][fylkenr]['fylke']):done()
	local header = mw.html.create('tr'):done()
	for ih, valh in pairs(header_sort) do
		local hData = mw.html.create('th')
			:wikitext(valh):done()
		header:node(hData)
	end
	tbl:node(header)
	for i, val in pairs(data['nummerserie'][fylkenr]) do
		row = mw.html.create('tr'):done()
			:tag('td'):wikitext(val):done()
				
		for i1,val2 in pairs(sorted_iter(data['kommune'][val])) do
			
		if type(val2) == 'number' then
			local data = mw.html.create('td')
				:wikitext(mw.language.getContentLanguage():formatNum(val2)):done()
			row:node(data)
		else
			local data = mw.html.create('td')
				:wikitext(val2):done()
			row:node(data)
		end
		end
		tbl:node(row)
	end
	tbl
		:tag('tr'):done()
			:tag('td')
				:attr('colspan', 16)
					:wikitext('Alle rader med unntak av "nr." og "kommune" er i enheten km². Basert på data hentet fra [[Kartverket]].' .. getRef(frame)):done()
	return tostring(tbl)
end

function p.innbprkm(frame)
	local args = getArgs(frame)
	local knr = tonumber(args['knr']) or tonumber(args[1])
	local innb = tonumber(args['innb']) or tonumber(args[2])
	return  mw.language.getContentLanguage():formatNum(round(innb/tonumber(data['kommune'][knr]['landareal']),2)) .. ' innb./km²' .. getRef(frame)
end

function p.main(frame)
	local args = getArgs(frame)
	local nr = tonumber(args[1]) or nil
	local verdi = 'kommune'
	local unit = ''
	local ref = ''
	
	if nr == nil then
		return ''
	end
	
	if args['hent'] then 
		verdi = string.lower(args['hent'])
	elseif nr <= 54 and nr >= 3 then
		verdi = 'fylke'
	end
	
	for nr, val in pairs(args) do
		if string.lower(val) == 'enhet' then
			unit = ' <small>km²</small>'
		elseif string.lower(val) == 'ref' then
			ref = getRef(frame)
		end
	end
	
	if nr <= 54 and nr >= 3 then
		if pcall(function() return data['fylke'][nr][verdi] end) then
			if type(tonumber(data['fylke'][nr][verdi])) == "number" then
				return mw.language.getContentLanguage():formatNum(tonumber(data['fylke'][nr][verdi])) .. unit .. ref
			else
				return data['fylke'][nr][verdi] .. unit .. ref
			end
		else  
			error("Not a valid fylkenummer in the list")
		end 
	end
	
	if pcall(function() return data['kommune'][nr][verdi] end) then
		if type(tonumber(data['kommune'][nr][verdi])) == "number" then
			return mw.language.getContentLanguage():formatNum(tonumber(data['kommune'][nr][verdi])) .. unit .. ref
		else
			return data['kommune'][nr][verdi] .. unit .. ref
		end
	else  
		error("Not a valid kommunenummer in the list")
	end 
	

end

return p
