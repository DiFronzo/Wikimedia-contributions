local wd = require('Module:Wd-norsk')
local data = mw.loadData("Modul:Kinfo/data")
local getArgs = require('Module:Arguments').getArgs

local p = {}

function p.kBefolkning(frame) -- TODO! Get population based on date insted of preferred value.
	local args = getArgs(frame)
	
	local knr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best','P2504'}) or 0
	
	for nr, val in pairs(args) do
		if string.lower(val) == 'aar' then
			if knr == 0 then
				local qid = mw.wikibase.getEntityIdForTitle( mw.title.getCurrentTitle().text .. ' kommune',"nnwiki" )
				return tonumber(frame:callParserFunction{ name = '#time:Y', args =  wd._kvalifikator{'rå','enkel',qid,'P1082','P585'} })
			else
				return tonumber(frame:callParserFunction{ name = '#time:Y', args =  wd._kvalifikator{'rå','enkel','P1082','P585'} })
			end
		end
	end
	
	if knr == 0 then
		local qid = mw.wikibase.getEntityIdForTitle( mw.title.getCurrentTitle().text .. ' kommune',"nnwiki" )
		if qid then
			return wd._egenskap{'referanser','nåværende',qid,'P1082'} or ""

		else
			return ""
		end
	else
		return wd._egenskap{'referanser','nåværende','P1082'} or ""
	end
end

function p.knr(frame)
	local knr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best','P2504'}) or 0
	
	if knr == 0 then
		local qid = mw.wikibase.getEntityIdForTitle( mw.title.getCurrentTitle().text .. ' kommune',"nnwiki" )
		knr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best',qid,'P2504'}) or 0
	end
	
	if knr == 0 then
		return ""
	end
	
	return knr
end

local function getRef(frame, definition)
	if definition == "landareal" or definition == "ferskvatn" then
		return frame:callParserFunction{ name = '#tag:ref', args = {
			'{{kilde www |url=https://www.ssb.no/statbank/table/09280/ |tittel=09280: Areal (km²), etter region, arealtype, statistikkvariabel og år |nettside=[[Statistisk sentralbyrå]] |dato=1. januar 2020 |språk=norsk bokmål}}'
	, name = 'SSB2020'} }
	else
		return frame:callParserFunction{ name = '#tag:ref', args = {
    '{{kilde www |url=https://www.kartverket.no/kunnskap/Fakta-om-Norge/Arealstatistikk/Arealstatistikk-Norge/ |tittel=Arealstatistikk for Norge |nettside=[[Kartverket]] |dato=1. januar 2020 |språk=norsk bokmål}}'
	, name = 'Kartverket2020'} }
	end

end

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local table_sort = {'kommune','totareal','areal','havflate','apentomrade','snoisbre','innsjo','elvtorrfall','myr','skog','dmark','btbygg','industri','annet','landareal','ferskvatn'}
local header_sort = {'Nr.','Kommune','Totalt areal','Fastland og øyer','Havflate','Åpent område','Snø, is og bre','Elv med tørrfall','Innsjø','Myr','Skog','Dyrket mark','By- og tettbebyggelse','Industriområde','Annet','Landareal','Ferskvatn'}

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

function containsValueFylke(value)
    return data['fylke'][value] ~= nil
end

function p.tabell(frame)
	local args = getArgs(frame)
	local fylkenr = tonumber(args[1]) or 0
	local row = ''
	
	if containsValueFylke == nil then
		error("Not a valid fylkenummer")
	end
	
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
	tbl:tag('tr')
		:addClass('sortbottom')
		:tag('td')
			:attr('colspan', tablelength(header_sort))
			:wikitext('Alle rader med unntak av "nr." og "kommune" er i enheten km². Basert på tall hentet fra [[Kartverket]] og [[Statistisk sentralbyrå|SSB]].' .. getRef(frame) .. getRef(frame,'landareal')):done()
--	local html = tostring(tbl)
--	local dumphtml = require('Module:Dump')._dumphtml
--	return dumphtml(html)
	return tostring(tbl)
end

function p.innbprkm(frame)
	local args = getArgs(frame)
	local knr = tonumber(args['knr']) or tonumber(args[1])
	local innb = tonumber(args['innb']) or tonumber(args[2])
	local unit = ''
	local ref = ''
	
	for nr, val in pairs(args) do
		if string.lower(val) == 'enhet' then
			unit = ' <small>innb./km²</small>'
		elseif string.lower(val) == 'ref' then
			ref = getRef(frame,'landareal')
		elseif string.lower(val) == 'wd' then
			knr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best','P2504'}) or 0
			innb = tonumber(wd._egenskap{'rå','nåværende','P1082'}) or 0
			if not knr or knr == '' then
				knr = tonumber(string.match(wd._egenskaper{'rå','fremtid','nåværende','normal+','best','P300'}, "%d+")) or 0
			end
		end
	end
	
	if pcall(function() return data['kommune'][knr]['landareal'] end) and innb then
		return  mw.language.getContentLanguage():formatNum(round(innb/tonumber(data['kommune'][knr]['landareal']),2)) .. unit .. ref
	elseif pcall(function() return data['fylke'][knr]['landareal'] end) and innb then
		return mw.language.getContentLanguage():formatNum(round(innb/tonumber(data['fylke'][knr]['landareal']),2)) .. unit .. ref
	else
		local qid = ""
		if knr ~= 0 and pcall(function() return data['kommune'][knr]['kommune'] end) then
			qid = mw.wikibase.getEntityIdForTitle( data['kommune'][knr]['kommune']  .. ' kommune',"nnwiki" )
		else
			qid = mw.wikibase.getEntityIdForTitle( mw.title.getCurrentTitle().text .. ' kommune',"nnwiki" )
		end
		knr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best',qid,'P2504'})
		innb = tonumber(wd._egenskap{'rå','nåværende','best',qid,'P1082'})

		if pcall(function() return data['kommune'][knr]['landareal'] end) and innb then
			return  mw.language.getContentLanguage():formatNum(round(innb/tonumber(data['kommune'][knr]['landareal']),2)) .. unit .. ref
		else
			return ""
		end
	end
end

function p.main(frame)
	local args = getArgs(frame)
	local nr = tonumber(args[1]) or nil
	local verdi = 'kommune'
	local unit = ''
	local ref = ''
	
	for nr2, val in pairs(args) do
		if string.lower(val) == 'enhet' then
			unit = ' <small>km²</small>'
		elseif string.lower(val) == 'ref' then
			if args['hent'] then 
				ref = getRef(frame, string.lower(args['hent']))
			else
				ref = getRef(frame)
			end
		elseif string.lower(val) == 'wd' then
			nr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best','P2504'}) or 0
			if nr == 0 then --Fylke
				nr = tonumber(string.match(wd._egenskaper{'rå','fremtid','nåværende','normal+','best','P300'}, "%d+")) or 0
			end
			if nr == 0 then
				qid = mw.wikibase.getEntityIdForTitle( mw.title.getCurrentTitle().text  .. ' kommune',"nnwiki" )
				nr = tonumber(wd._egenskaper{'rå','fremtid','nåværende','normal+','best',qid,'P2504'})
			end
		end
	end
	
	if nr == nil then
		return ''
	end
	
	if args['hent'] then 
		verdi = string.lower(args['hent'])
	elseif nr <= 54 and nr >= 3 then
		verdi = 'fylke'
	end
	
	if nr <= 54 and nr >= 3 then
		if pcall(function() return data['fylke'][nr][verdi] end) then
			if type(tonumber(data['fylke'][nr][verdi])) == "number" then
				return mw.language.getContentLanguage():formatNum(tonumber(data['fylke'][nr][verdi])) .. unit .. ref
			else
				if data['fylke'][nr][verdi] then
					return data['fylke'][nr][verdi] .. unit .. ref
				else
					return ""
				end
			end
		else  
			error("Not a valid fylkenummer in the list")
		end 
	end
	
	if pcall(function() return data['kommune'][nr][verdi] end) then
		if type(tonumber(data['kommune'][nr][verdi])) == "number" then
			return mw.language.getContentLanguage():formatNum(tonumber(data['kommune'][nr][verdi])) .. unit .. ref
		else
			if data['kommune'][nr][verdi] then
				return data['kommune'][nr][verdi] .. unit .. ref
			else
				return ""
			end
		end
	else  
		return "utdatert"
		--error("Not a valid kommunenummer in the list")
	end 
	

end

return p
