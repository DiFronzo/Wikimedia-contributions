require("Modul:No globals")
local Date = require('Modul:Date')._Date
local data = mw.loadData("Modul:WikidataNN/data")
local preferred_language = data.preferred_language
local fallback_languages = data.fallback_languages
local fallback_languages_humans = data.fallback_languages_humans
local fallback_note = data.fallback_note
local bc = data.bc
local months = data.months
local wd_units = data.wd_units
local wanted_units = data.wanted_units
local msk_timezones = data.msk_timezones
local fallback_languages_after_country = data.fallback_languages_after_country
local fallback_languages_for_persons = data.fallback_languages_for_persons  -- Not used, jet!
local tracking_cats = data.tracking_cats
local os_date = os.date("%d %B %Y")

local p = {}

local tracking_categories = ''
local navnerom = mw.title.getCurrentTitle().namespace
local add_tracking_category = function(cat)
	if navnerom == 0 then
		tracking_categories = tracking_categories .. cat
	end
end

-- The following values are set by get_statements
local the_frame			-- Used to for frame:extensionTag
local the_qid			-- Used to make links to Wikidata and to get more statements if needed later
local the_pid			-- Used to make links to Wikidata

-- The following value is set by get_references
local ref_texts = {}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- Get and format a reference to a statement
local get_reference = function(ref, berreurl)
	local refargs = {}
	-- go throug all reference properties
	local snaks = ref.snaks
	for refpid, ref in pairs(snaks) do
		--mw.logObject(refpid, 'refpid')
		--mw.logObject(ref, 'ref')
		-- There may be more than more than value with the same property, but ignore all but the first
		local ref1 = ref[1]
		if ref[2] then
			add_tracking_category(tracking_cats.category_repeated_ref)
		end
		if ref1.snaktype == 'value' then
			-- We have a reel value, as in not 'somevalue' or 'novalue'  
			if refpid == 'P248' then
				-- P248 is stated in
				-- Get the item the rerefence is stated in
				local refentity = mw.wikibase.getEntity(ref1.datavalue.value.id)
				-- Check these: for book editions
				-- P1476 is title (monolingual text, the language can be default for language)
				-- P1680 is subtitle (monolingual text, include this?)
				-- P50 is author (item)
				-- P2093 is author name strin (string), check also for qualifier P1545 (series ordinal, warning: it is type string!)
				-- P393 is edition number (string)
				-- P98 is editor (item, check no)
				-- P123 is publisher (item)
				-- P291 is place of publication (item)
				-- P577 is publication date (time)
				-- P407 is language of work or name (item)
				-- P1683 is quote (monolinual text)
				-- for journals
				-- P433 is issue (string)
				-- P1433 is published in (item, go to it for journal=title, other info from this?)
				-- P478 is volume
				-- P698 is PubMed ID (pmid, external identifier)
				-- P932 is PMCID (pmc, external identifier)
				-- P356 is DOI (doi, external identifier)
				-- P1065 is archive URL (URL)
				-- P2960 is archive date (time)
				-- P179 is series (item) (Should this be used??)
				-- P31 is instance of (could be checked to know which properties to look for?)
				local reftypestatements = refentity:getBestStatements('P31')
				local instancesof = {}
				if reftypestatements then
					-- mw.logObject(reftypestatements, 'reftypestatements')
					for _, io in pairs(reftypestatements) do
						-- mw.logObject(io, 'io')
						if io.mainsnak.snaktype == 'value' then
							instancesof[io.mainsnak.datavalue.value.id] = true
						end
					end
				end
			elseif refpid == 'P854' then
				-- P854 is reference URL
				refargs.url = ref1.datavalue.value
			elseif refpid == 'P813' then
				-- P813 is retrieved
				refargs.accessdate = p.format_time({}, ref1.datavalue.value)
			elseif refpid == 'P304' then
				-- P304 is page(s)
				refargs.page = ref1.datavalue.value
			elseif refpid == 'P792' then
				-- P792 is chapter
				refargs.chapter = ref1.datavalue.value
			elseif refpid == 'P143' then
				-- P143 is "imported from"
				refargs.importedfrom = ref1.datavalue.value
				local refentity = mw.wikibase.getEntity(ref1.datavalue.value.id)
				local label, lang = refentity:getLabelWithLang(preferred_language)
				if label then refargs.importedfrom["label"] = label end
				--mw.logObject(ref1,'ref1')
			else
				add_tracking_category(tracking_cats.category_unknown_ref)
			end
		end
	end
	local text = ''
	-- mw.logObject(refargs, 'refargs')
	if refargs.url then 
		local reftext = refargs.url
		-- create a link with text from the url
		-- find start position
		local j1 = string.find(reftext,'//',1,true)
		-- remove the first part of the string even the two slashes, if any
		if j1 then reftext = string.sub(reftext,j1+2,string.len(reftext)) else reftext = '' end
		-- mw.logObject(reftext,'reftext')
		-- if the string is not empty
		if reftext ~= '' then
			-- find the position of the next slash in the string
			local i1 = string.find(reftext,'/',1,true)
			-- use only that part of the string that lies before the slash if it exists
		    if i1 then reftext = string.sub(reftext,1,i1-1) end
		    text = 'Informasjonen er frå [[d:' .. the_qid .. '#' .. the_pid .. '|Wikidata]], som viser til denne kjelda: ['..refargs.url..' '..reftext..']. ' 
		end
	end
	if refargs.accessdate and text ~= '' then text = text..'Henta '..refargs.accessdate..'. ' end
	if refargs.importedfrom and berreurl ~= 'ja' then text = text..'Importeret frå '..refargs.importedfrom.label..'. ' end
	-- mw.logObject(text,'text')
	return text
end

-- Get and format all references to a statement
-- Append the references to text and return the new text
-- If text is nil, return nil again
local get_references = function(args, text, references)
	-- This function is work in progess. 
	-- parameter ref is set to 'ja' if references are desired
	local kilderef = mw.text.trim(args['ref'] or '')
	if kilderef ~= 'ja' then return text end
	if not text then return nil end
	-- berreurl is set to 'ja', if only reference urls are desired (P854)
	local berreurl = mw.text.trim(args['berreurl'] or '')
	-- viskm is set to 'ja' if there is to be a note that sources are missing
	local viskm = mw.text.trim(args['viskm'] or '')
	local reference = ''
	-- refs is a table with the references found
	local refs = {}
	if not references or not next(references) then
		--refs[1] = '\nOplysningen er frå [[d:' .. the_qid .. '#' .. the_pid .. '|Wikidata]], som ikkje har kjelder til han.'
	else 
		for _ ,ref in pairs(references) do
			reference = get_reference(ref, berreurl)
			if reference ~= '' then table.insert(refs, reference) end
		end
	end
	-- the content of the note
	local innhald = ''
	-- number of references found
	if #refs == 1 then
		innhald = '\n'..refs[1]
	elseif #refs > 1 then
		innhald = '\nOplysningen er frå [[d:' .. the_qid .. '#' .. the_pid .. '|Wikidata]], som har desse kjeldene: \n*'..table.concat(refs, '\n*')
	elseif viskm == 'ja' then 
		innhald = '\nOplysningen er frå [[d:' .. the_qid .. '#' .. the_pid .. '|Wikidata]], som ikkje har kjelder til den.'
	end
	--mw.logObject(table.concat(refs, '\n*'),'sluttprodukt')
	if innhald ~= '' then 
		local nr -- index for content in ref_texts
		local itabel = has_value(ref_texts, innhald)
		if not itabel then 
			table.insert(ref_texts, innhald) 
			nr = #ref_texts 
		else nr = itabel end
        local ref_args = { name = 'kjelde ' .. the_pid .. the_qid .. nr }
		text = text .. the_frame:extensionTag{ name = 'ref', content = innhald, args = ref_args }
	    --mw.logObject(innhald.nr,'innhald')
	end
	--elseif viskm == 'ja' then text = text .. '<sup><small>[kjelde manglar]</small></sup>' end
	return text 
end

-- Looks at the arguments 'spraak' and 'skrivspraak' in args
-- Returns 3 values: 1) get_all: true if all languages are wanted
-- 2) show_language: true if language name is wanted
-- 3) a table with keys for wanted languages.
local get_lang_args = function(args)
	local languages = mw.text.trim(args.spraak or preferred_language)
	local show_language = mw.text.trim(args.skrivspraak or '') == 'ja'
	local get_all = false
	local wanteds = {}
	if languages == 'alle' then
		get_all = true
	else
		for key in mw.text.gsplit(languages, '%s*,%s*') do
			wanteds[key] = true 
		end
	end
	return get_all, show_language, wanteds
end

-- Get values from a qualifier with data type time
-- Insert the values in the table given as first argument
-- The table elements are tables with the uformatted and the formatted value
-- Return the table
local get_time_qualifier = function(args, times, qualifiers)
	if qualifiers then
		for key, qualifier in pairs(qualifiers) do
			if qualifier.snaktype == "value" then
				local value = qualifier.datavalue.value
				local text = p.format_time(args, value)
				if text then
					table.insert(times, { value.time, text })
				end
			end
		end
	end
	return times
end

-- combine the formated dates in the second element of the element in the dates table
local combine_dates = function(dates)
	local text = ''
	if dates and dates[1] then
		text = dates[1][2]
	end
	for i = 2, #dates do
		text = text .. '/' .. dates[i][2]
	end
	return text
end

-- Get time values from the qualifiers and add them to the table times
-- The elements of times are tables with unformated and formated time values
-- Returns the times table 
local get_qualifier_times = function(args, times, qualifiers)
	if qualifiers then
		get_time_qualifier(args, times, qualifiers.P585) -- P585 is point of time
		local starts = get_time_qualifier(args, {}, qualifiers.P580) -- P580 is start time
		local ends = get_time_qualifier(args, {}, qualifiers.P582) -- P582 is end time
		if #starts > 0 then
			-- There can be more than one start time, e.g. if the sources don't agree
			if #ends > 0 then
				-- Period with start and end time
				table.insert(times, { starts[1][1], combine_dates(starts) .. '-' .. combine_dates(ends) } )
			else
				-- Only start time
				table.insert(times, { starts[1][1], 'frå ' .. combine_dates(starts) } )
			end
		else
			if #ends > 0 then
				-- Only end time
				table.insert(times, { ends[1][1], 'til ' .. combine_dates(ends) } )
			end
		end
	end
	return times
end

-- Sort and combine the qualifier time values in the table times.
-- The elements of times are tables with unformated and formated time values.
-- Returns text ready to append to the value.
local format_qualifier_times = function(times)

	local text = ''
	if #times > 0 then
		table.sort(times, function (a,b)
			-- Use the unformated ISO 8601 time string for sorting
			local signa, signb = a[1]:sub(1, 1), b[1]:sub(1, 1)
			if signa == '+' then
				if signb == '+' then
					return a[1] < b[1] -- 2 AD times: The higher number is greater
				else
					return false -- AD time is greater than BC time
				end
			else
				if signb == '+' then
					return true -- BC time is lesser than AD time
				else
					return a[1] > b[1] -- 2 BC times: The higher number is lesser
				end
			end
		end)
		text = text .. ' (' .. times[1][2]
		for i = 2, #times do
			text = text .. ', ' .. times[i][2]
		end
		text = text .. ')'
	end
	return text
end

-- Convert a signed desimal degree to degrees, arch minutes and direction letter
local function convert_to_dm(degrees, posdir, negdir)
	local dir
	if degrees < 0 then
		degrees = -degrees
		dir = negdir
	else
		dir = posdir
	end
	local d = math.floor(degrees)
	local m = (degrees - d) * 60
	return d, m, dir
end

-- Convert a signed desimal degree to degrees, arch minutes, arch seconds and direction letter
local function convert_to_dms(degrees, posdir, negdir)
	local d, minutes, dir = convert_to_dm(degrees, posdir, negdir)
	local m = math.floor(minutes)
	local s = (minutes - m) * 60
	return d, m, s, dir
end

-- round the number 'n' to use max. 'decimals' decimals
local function round(n, decimals)
	return tonumber(string.format('%.' .. decimals .. 'f', n))
end

local function format_coordinates(args, value)
	local lat = value.latitude
	local lon = value.longitude
	local precision = value.precision or 0
	local format = args.format

	local coordArgs
	local coordArgsFormat

	local roundedPrecision = string.format('%.1e', precision)
		-- The rounded precision will have the format 'd.d1e±dd'
	if precision >= 1 then
		--[[ No fractions of degrees, so both formats will present the same way. ]]
		coordArgs = { round(lat, 0), round(lon, 0) }
	elseif	(format ~= 'dec' and roundedPrecision == '1.7e-02') or
		(format == 'dms' and precision >= 0.01) then
		--[[ Convert to degrees and minutes to get the most accurate value if the precision is 1 arch minute
			and the format is not dec. Also Convert to degrees and minutes if dms is requested
			and precsion is in range. ]]
		local lat_d, lat_m, lat_NS = convert_to_dm(lat, 'N', 'S')
		local lon_d, lon_m, lon_EW = convert_to_dm(lon, 'E', 'W')
		coordArgs = { lat_d,  round(lat_m, 0),  lat_NS, lon_d, round(lon_m, 0), lon_EW }
		coordArgsFormat = 'dm'
	elseif	roundedPrecision == '2.8e-04' or roundedPrecision == '2.8e-05' or
			roundedPrecision == '2.8e-06' or roundedPrecision == '2.8e-07' or
			format == 'dms' then
		--[[ Convert to degrees, minutes and seconds to get the most accurate value if the precision is
			1, 1/10, 1/100 or 1/1000 arch second. Also convert to degrees, minutes and seconds if dms is requested
			and precsion is in range. ]]
		local lat_d, lat_m, lat_s, lat_NS = convert_to_dms(lat, 'N', 'S')
		local lon_d, lon_m, lon_s, lon_EW = convert_to_dms(lon, 'E', 'W')
		if precision > 0 then
			local decimals = tonumber(string.sub(roundedPrecision, -1)) - 4
			if string.sub(roundedPrecision, 1, 1) == '1' then
				decimals = decimals + 1
			end
			if decimals >= 0 then
				lat_s = round(lat_s, decimals)
				lon_s = round(lon_s, decimals)
			end
		end
		coordArgs = { lat_d, lat_m, lat_s, lat_NS, lon_d, lon_m, lon_s, lon_EW }
		coordArgsFormat = 'dms'
	else
		local decimals = tonumber(string.sub(roundedPrecision, -3))
		if decimals <= 0 then
			coordArgs = { round(lat, -decimals), round(lon, -decimals) }
		else
			coordArgs = { lat, lon }
		end
	end

	if args.koordlink == 'nei' then
		-- no geoHack or other links
		if coordArgsFormat == 'dm' then
			return	coordArgs[1] .. '°' .. coordArgs[2] .. '′' .. coordArgs[3] .. ' ' ..
					coordArgs[4] .. '°' .. coordArgs[5] .. '′' .. ((coordArgs[6] == 'E') and 'Ø' or 'V')
		elseif coordArgsFormat == 'dms' then
			return	coordArgs[1] .. '°' .. coordArgs[2] .. '′' .. coordArgs[3] .. '″' .. coordArgs[4] .. ' ' ..
					coordArgs[5] .. '°' .. coordArgs[6] .. '′' .. coordArgs[7] .. '″' ..
					((coordArgs[8] == 'E') and 'Ø' or 'V')
		else
			lat = coordArgs[1]
			lon = coordArgs[2]
			lat = (lat < 0) and (-lat .. '°S') or (lat .. '°N')
			lon = (lon < 0) and (-lon .. '°V') or (lon .. '°A')
			return lat .. ' ' .. lon
		end
	end

	local geoHackParameters = {}
	if args.dim then geoHackParameters[#geoHackParameters + 1] = 'dim:' .. args.dim end
	if args.scale then geoHackParameters[#geoHackParameters + 1] = 'scale:' .. args.scale end
	if args.type then geoHackParameters[#geoHackParameters + 1] = 'type:' .. args.type end

	local globe = value.globe -- The first 31 chars is 'http://www.wikidata.org/entity/', then comes Qid
	if globe ~= 'http://www.wikidata.org/entity/Q2' then -- Q2 is earth
		-- The globe name in lower case is used for the subpage name to Template:GeoTemplate
		geoHackParameters[#geoHackParameters + 1] = 'globe:' ..
			string.lower(mw.wikibase.getLabelByLang(string.sub(globe, 32), 'en'))
	end

	if args.region then
		geoHackParameters[#geoHackParameters + 1] = 'region:' .. args.region
	else
		local countries = mw.wikibase.getBestStatements(the_qid, 'P17') -- P17 is country
		if countries[1] and countries[1].mainsnak.snaktype == 'value' then
			local country = countries[1].mainsnak.datavalue.value.id
			country = data.countries[country]
			if country and country[1] then
				geoHackParameters[#geoHackParameters + 1] = 'region:' .. country[1]
			end
		end
	end

	if #geoHackParameters > 0 then
		coordArgs[#coordArgs + 1] = table.concat(geoHackParameters, '_')
	end
	coordArgs.display = args.display
	coordArgs.format = format
	coordArgs.name = args.name
	return require('Modul:Coordinates')._coord(coordArgs)
end

-- Handle a qualifier
-- Return new text inkl. the qualifier or nil to remove the statement from the results
local get_qualifier = function(args, text, qual, format, formatwithout, use)
	if not qual then
		-- No such qualifier
		if use == 'med' then
			-- Only statements with the qualifier is wanted, so remove this statement
			return nil
		else
			-- Otherwise return the statement with the formatwithout applied
			-- Use the table version of string.gsub to avoid having to escape % chars
			return (string.gsub(formatwithout, '$1', { ['$1'] = text }))
		end
	end
	if use == 'utan' then
		-- Only statements without the qualifier is wanted, so remove this statement
		return nil
	end

	-- These are used for monolingual texts. We will only get values for them if necessary
	local get_all, show_language, wanteds = false, false, false

	-- Get the qualifier. There can be several values, loop over them and separate with comma
	local qualtext, qualpure, testUseValue = {}, {}, ( use ~= 'alle' and use ~= 'med' and use~= '' ) -- 'utan' is eliminated here
	for _, q in pairs(qual) do
		if q.snaktype == 'novalue' then
			qualtext[#qualtext + 1] = 'ingen'
		elseif q.snaktype == 'somevalue' then
			qualtext[#qualtext + 1] = 'ukjent'
		else
			local datatype = q.datatype
			if datatype == 'time' then
				qualtext[#qualtext + 1] = p.format_time(args, q.datavalue.value)
			elseif datatype == 'monolingualtext' then
				if not wanteds then
					-- wanteds will be true if the language args are already fetched
					get_all, show_language, wanteds = get_lang_args(args)
				end
				if get_all or wanteds[q.datavalue.value.language] then
					if show_language then
						qualtext[#qualtext + 1] = mw.text.nowiki(q.datavalue.value.text) .. ' (' ..
							mw.language.fetchLanguageName(q.datavalue.value.language, preferred_language) .. ')'
					else
						qualtext[#qualtext + 1] = mw.text.nowiki(q.datavalue.value.text)
					end
				end
			elseif datatype == 'string' or datatype == 'commonsMedia' or datatype == 'external-id' then
				qualtext[#qualtext + 1] = mw.text.nowiki(q.datavalue.value)
			elseif datatype == 'url' then
				qualtext[#qualtext + 1] = q.datavalue.value
			elseif datatype == 'quantity' then
				qualtext[#qualtext + 1] = p.format_number(args, q.datavalue.value)
			elseif datatype == 'wikibase-item' then
				qualtext[#qualtext + 1] = p.get_label(args, q.datavalue.value.id, nil, nil)
				if testUseValue then
					-- q-value
					qualpure[#qualpure + 1] = q.datavalue.value.id
					-- label without link
					local label = mw.wikibase.getLabel(q.datavalue.value.id)
					if label then
						qualpure[#qualpure + 1] = label
					end
				end
			elseif datatype == 'globe-coordinate' then
				qualtext[#qualtext + 1] = format_coordinates(args, q.datavalue.value)
			elseif datatype == 'math' then
				qualtext[#qualtext + 1] = '<math>' .. q.datavalue.value .. '</math>'
			end
		end
	end
	if testUseValue then
		local function useValueInTable(tbl)
			for _, qualTextHere in pairs(tbl) do
				if qualTextHere == use then return true end
			end
			return false
		end
		if (not useValueInTable(qualtext) and (not useValueInTable(qualpure))) then
			return nil
		end
	end

	if #qualtext == 0 then
		-- No usable qualifiers. This happens if no qualifiers of type monolingualtext is in the right languages.
		return (use == 'med') and nil or (string.gsub(formatwithout, '$1', { ['$1'] = text }))
	end
	return (string.gsub(format, '$[12]', { ['$1'] = text, ['$2'] = table.concat(qualtext, ', ') }))
end

-- Handle requets for qualifiers for a statement
-- text is the already formated statement
-- Return the new text with qualifiers or nil to remove the statement from the results
local get_qualifiers = function(args, text, qualifiers, notime)
	if not notime and mw.text.trim(args.tid or '') == 'ja' then
		-- Check qualifiers for point of time, start time, and end time
		local times = get_qualifier_times(args, {}, qualifiers)
		text = text .. format_qualifier_times(times)
	end
   -- mw.logObject(qualifiers,'qualifiers')
	local qualno = 1
	repeat
		local qual = mw.text.trim(args['kvalifikator' .. tostring(qualno)] or '')
		if qual == '' then break end
		local format = mw.text.trim(args['kvalifikatorformat' .. tostring(qualno)] or '$1 ($2)')
		local formatwithout = mw.text.trim(args['kvalifikatorformatutan' .. tostring(qualno)] or '$1')
		local use = mw.text.trim(args['kvalifikatorbruk' .. tostring(qualno)] or 'alle')
		text = get_qualifier(args, text, qualifiers and qualifiers[qual], format, formatwithout, use)
		qualno = qualno + 1
	until not text
	return text
end

-- Determine if the string 'name' is in the list 'list' med comma separated names
-- Returns true if 'name' is in the list. 
local function inlist (name, list)
	for n in mw.text.gsplit(list, '%s*,%s*') do
		if n == name then return true end
	end
	return false
end

--[[ Handle commnon arguments for all "hent"-functions: the unnamed arguments 1 og 2, q, feltnamn, wikidata, ingen_wikidata.
     Get the best statements, that is statements with preferred rank is any, or else statements with normal rank.
     Return args, statements, return_now (the last contains a value to return immediately if not nil)
     Set shared local variables: frame, the_pid, the_qid ]]
local get_statements = function(frame)

	the_frame = frame
	-- If called via #invoke, use the args passed into the invoking template.
	-- Otherwise, for testing purposes, assume args are being passed directly in.
	local args = (frame == mw.getCurrentFrame()) and frame:getParent().args or frame.args

	-- If a second unnamed argument is present and not empty, return it unconditionally
	local input_parm =  mw.text.trim(args[2] or "")
	if input_parm and (#input_parm > 0) then
		return nil, nil, input_parm
	end

	-- Test if there is an infobox fieldname, and if Wikidata should be used for that field
	local fieldname = mw.text.trim(args.feltnamn or '')
	if #fieldname > 0 then
		local blacklist = args.ingen_wikidata
		if blacklist and inlist(fieldname, blacklist) then
			-- The fieldname is blaklisted
			return nil, nil, ''
		end
		local whitelist = mw.text.trim(args.wikidata or '')
		if whitelist ~= 'alle' and whitelist ~= 'ja' and not inlist(fieldname, whitelist) then
			-- fieldname isn't on the list of allowed fieldnames
			return nil, nil, ''
		end
	end

	-- Get the item to use from either the parameter q or the item connected to the current page
	the_qid = mw.text.trim(args.q or '')
	if the_qid == '' then
		the_qid = mw.wikibase.getEntityIdForCurrentPage()
		if the_qid == nil then
			-- No entity, stop here
			return nil, nil, ''
		end
	end

	-- The property is first unnamed argument
	the_pid = mw.text.trim(args[1] or "")
	local statements = mw.wikibase.getBestStatements(the_qid, the_pid)
	if statements == nil or #statements == 0 then
		-- No data to fetch
		return nil, nil, ''
	end

	return args, statements
end

-- Make a link to a page if wanted from a label
-- Make the link to the entity 'entity' if not nil, else to 'qid' 
p.make_link = function(args, label, entity, qid)
	-- Convert characters with special meaning in wikitext to HTML entities
	label = mw.text.nowiki(label)

	-- Use italics if requested
	local use_italics = mw.text.trim(args.kursiv or "")
	if use_italics == 'ja' then
		label = "''" .. label .. "''"
	end

	local link = mw.text.trim(args.link or "")
	if  link == 'nei' then
		-- link is not wanted
		return label
	end

	local sitelink
	if entity then
		sitelink = entity:getSitelink()
	else
		sitelink = mw.wikibase.getSitelink(qid)
	end
	if sitelink == nil then
		-- link is not possible
		return label
	end

	if sitelink == label then
		return '[[' .. sitelink .. ']]'
	else
		return '[[' .. sitelink .. '|' .. label .. ']]'
	end
end

-- Make text with message, reference, and category about using a fallback language
p.make_language_message = function(args, langcode, qid)
	local language = mw.language.fetchLanguageName(langcode, preferred_language)
	-- No language in parenthesis for now
	-- local text =' (' .. language .. ')'
	local text = ''
	local language_note = mw.text.trim(args.spraaknote or '')
	if language_note ~= 'nei' then
		local ref_args = { name = 'spraak ' .. langcode .. qid }
		local language_notegroup = mw.text.trim(args.spraaknotegroup or '')
		if language_notegroup ~= '' then
			ref_args.group = language_notegroup
		end
		text = text .. the_frame:extensionTag{ name = 'ref', content = string.format(fallback_note, language, qid), args = ref_args }
	end
	local language_cat = mw.text.trim(args.spraakkat or '')
	if language_cat ~= 'nei' and (language_note ~= 'nei' or language_cat == 'ja') then
		add_tracking_category(tracking_cats.fallback_category)
	end
	return text
end

-- Make a link a for a country or state if make_link is true, else just get the label.
local make_country_link = function(country_id, make_link)
	local label = mw.wikibase.getLabel(country_id)
	if make_link then
		local sitelink = mw.wikibase.getSitelink(country_id)
		if sitelink then
			label = '[[' .. sitelink .. '|' .. mw.text.nowiki(label or sitelink) .. ']]'
		end
	end
	return label
end
	
-- Get the country (or countries) for a place. Return formatted link(s) to the country/countries, and country_id if unique
local get_country = function(place_id, make_link)
	local statements = mw.wikibase.getBestStatements(place_id, 'P17')
	local text
	local country_id
	for _, statement in pairs(statements) do
		if statement.mainsnak.snaktype == 'value' then
			country_id = statement.mainsnak.datavalue.value.id
			if country_id == place_id then
				return	-- The place is the country. Return nil for no result.
			end
			local link = make_country_link(country_id, make_link)
			if link then
				text = text and (text .. '/' .. link) or link
			end
		end
	end
	return text, #statements == 1 and country_id or nil
end

-- Get a value of type item from an entity if it is unique.
local get_unique_item_value = function(entity, pid)
	local statements = entity:getBestStatements(pid)
	if statements and #statements == 1 and
			statements[1].mainsnak and
			statements[1].mainsnak.snaktype == 'value' then
		return statements[1].mainsnak.datavalue.value.id
	end
	return nil
end

-- Format the label with upper case, link, extras (party or country), and language note
-- make_note is the item ID to link to if a note is wanted, or else nil
-- If requested there is linked to 'entity', or 'qid' if no entity
local format_label = function(args, format, text, extra_text, entity, qid, lang, use_ucfirst, make_note)
	if use_ucfirst then
		text = mw.getLanguage(lang):ucfirst(text)
	end
	local text = p.make_link(args, text, entity, qid)
	if make_note then
		text = text .. p.make_language_message(args, lang, make_note)
	end
	if extra_text then
		return (string.gsub(format, '$[12]', { ['$1'] = text, ['$2'] = extra_text }))
	else
		return text
	end
end

-- Get the label of an item.
-- Creates a link using the sitelink if it exists unless the link argument is set to no
-- Converts the first character of the label to uppercase if use_ucfirst
-- Finds and adds country, state and country, or political party for the item if requested in the args and get_extras is true
p.get_label = function(args, qid, use_ucfirst, get_extras)

	-- In order to save memory we will only get the entire entity for qid if necessary.
	-- It isn't needed if country or political party isn't requsted,
	-- and the entity have a label in the preferred language
    
    -- Find out if which extra, if any, are requested, and get extra_format
	local extra_format
	local get_party
	local show_country
	local place
	if get_extras then
		extra_format = mw.text.trim(args.parti or '')
		if extra_format ~= '' then
			get_party = true
		else
			extra_format = mw.text.trim(args.land or '')
			if extra_format ~= '' then
				show_country = true
			else
				place = mw.text.trim(args.sted or '') == 'ja'
				if place then
					extra_format = '$1, $2'
				else
					get_extras = nil
				end
			end
		end
	end

	if not get_extras then
		-- Try for a label in the the preferred language
		local label = mw.wikibase.getLabelByLang(qid, preferred_language)
		if label then
			return format_label(args, nil, label, nil, nil, qid, preferred_language, use_ucfirst, nil)
		end
	end

	-- OK, we will need the entity to continue (for now)
	local entity = mw.wikibase.getEntity(qid)
	if not entity then return nil end

	local extra_text
	local country_id, tried_to_get_country_id

	-- Find political party of the item if requested
	if get_party then
		-- P102 is member of political party
		local party_id = get_unique_item_value(entity, 'P102')
		if party_id then
			-- First try a shortname/abbreviation for the party, P1813 is short name
			local shortname_statements = mw.wikibase.getBestStatements(party_id, 'P1813')
			for key, statement in pairs(shortname_statements) do
				if statement.mainsnak.snaktype == 'value' and
					statement.mainsnak.datavalue.value.language == 'da' then
					extra_text = statement.mainsnak.datavalue.value.text
					break -- one is enough. As we don't know which is best, take the first
				end
			end
			if not extra_text then
				-- No shortname, get the label
				local extra_text = mw.wikibase.getLabelByLang(party_id, preferred_language)
			end
			if extra_text then
				extra_text = p.make_link(args, extra_text, nil, party_id)
			end
		end
	else
		-- Party was not requested. Get country if requested	
		if (show_country or place) and not data.no_country[qid]  then
			local make_link = mw.text.trim(args.link or "") ~= 'nei'
			extra_text, country_id = get_country(qid, make_link)
			tried_to_get_country_id = true
			if place and data.show_state[country_id] then
				local unit_id = qid
				local state_id
				repeat
					-- Walk though administrative units until we come to the country, and then show the last unit before country
					local statements = mw.wikibase.getBestStatements(unit_id, 'P131')
						-- P131 is 'located in the administrative territorial entity'
					if statements[1] and statements[1].mainsnak.snaktype == 'value' then
						state_id = unit_id -- previous value
						unit_id = statements[1].mainsnak.datavalue.value.id
					else
						state_id = nil -- the chain is broken
						break;
					end
				until unit_id == country_id
				if state_id and state_id ~= qid then
					local link = make_country_link(state_id, make_link)
					if link then
						extra_text = link .. ', ' .. extra_text
					end
				end
			end
		end
	end

	-- Try the preferred language
	local label, lang = entity:getLabelWithLang(preferred_language)
	if lang == preferred_language then
		return format_label(args, extra_format, label, extra_text, entity, nil, lang, use_ucfirst, nil)
	end

	-- Next try the local language if the item is located in certain countries
	if not country_id and not tried_to_get_country_id then
		-- P17 is country
		country_id, tried_to_get_country_id = get_unique_item_value(entity, 'P17'), true
	end
	if country_id then
		local fallback = fallback_languages_after_country[country_id]
		if fallback then
			local label, lang = entity:getLabelWithLang(fallback)
			if lang == fallback then
				return format_label(args, extra_format, label, extra_text, entity, nil, lang, use_ucfirst, nil)
			end
		end
		if country_id == 'Q159' or		-- Q159 is Russia
			country_id == 'Q34266' or	-- Q34266 is Russian Empire
			country_id == 'Q15180' then	-- Q15180 is Soviet Union
			add_tracking_category(tracking_cats.category_missing_russian_name)
		end
	end

	-- Find out if the item is a human
	local ishuman = nil
	-- P31 is instance of
	local instanceof = entity:getBestStatements('P31')
	for key, statement in pairs(instanceof) do
		-- Q5 is human
		if statement.mainsnak.snaktype == 'value' and statement.mainsnak.datavalue.value.id == 'Q5' then
			ishuman = true
			break
		end
	end

	if ishuman then
		-- Next for humans try first group of fallback languags for humans (Norgewian and Swedish)
		for i, fallback in ipairs(fallback_languages_humans) do
			local label, lang = entity:getLabelWithLang(fallback)
			if lang == fallback then
				return format_label(args, extra_format, label, extra_text, entity, nil, lang, use_ucfirst, nil)
			end
		end

		-- Next for humans try the language of their country if there is one main language
		-- and it is written in a Latin script (the table of these is probably incomplete)
		-- P27 is country of citizenship
		local citizenship = get_unique_item_value(entity, 'P27')
		if citizenship then
			local fallback = fallback_languages_for_persons[citizenship]
			if fallback then
				local label, lang = entity:getLabelWithLang(fallback)
				if lang == fallback then
					return format_label(args, extra_format, label, extra_text, entity, nil, lang, use_ucfirst, nil)
				end
			end
			if citizenship == 'Q159' or			-- Q159 is Russia
				citizenship == 'Q34266' or		-- Q34266 is Russian Empire
				citizenship == 'Q15180' then	-- Q15180 is Soviet Union
				add_tracking_category(tracking_cats.category_missing_russian_name)
			end
		end
		add_tracking_category(tracking_cats.category_human_missing_name)
	end

	-- Try the fallback languages
	for i, fallback in ipairs(fallback_languages) do
		local label, lang = entity:getLabelWithLang(fallback)
		if lang == fallback then
			return format_label(args, extra_format, label, extra_text, entity, nil, lang, use_ucfirst, qid)
		end
	end

	-- Last resort: try any label
	local labels = entity.labels
	if labels then
		for lang,labeltable in pairs(labels) do
			if lang then
				return format_label(args, extra_format, labeltable.value, extra_text, entity, nil, lang, use_ucfirst, qid)
			else
				return '' -- no label in wikidata results in missing text (only possibly only a pencil icon)
			end
			break
		end
	end
	return nil
end

p.format_statement_group = function(args, statements, startrange, endrange, use_ucfirst)
	local statement = statements[startrange]
	local text = nil
	if statement.sortkey == 'novalue' then
		text = mw.text.trim(args.ingen or "")
		if (text == '') then return nil end
	elseif statement.sortkey == "somevalue" then
		text = mw.text.trim(args.ukjent or "")
		if (text == '') then return nil end
	else
		text = p.get_label(args, statement.sortkey, use_ucfirst, true)

		-- if the entity is a timezone in Russia, then add the MSK time if requested
		if mw.text.trim(args.msk or '') == 'ja' and msk_timezones[statement.sortkey] then
			text = text .. msk_timezones[statement.sortkey]
		end

		-- Go through all statements for time qualifiers if requested
		if mw.text.trim(args.tid or '') == 'ja' then
			local times = {}
			for i = startrange, endrange - 1 do
				local qualifiers = statements[i].qualifiers
				 get_qualifier_times(args, times, qualifiers)
			end
			text = text .. format_qualifier_times(times)
		end
	end

	-- handle qualifier arguments except for "tid" which may be used for statement groups
	-- and is handled separately above. When grouping is used, this call will have no effect
	-- because the qualifier arg will have turned grouping off in hent_emne().
	text = get_qualifiers(args, text, statement.qualifiers, true)
	text = get_references(args, text, statement.references)
	return text
end

-- format the list of statements with the wanted separator
p.output_all_statements = function(args, output, meir_enn_maks)

	-- Avoid empty lists
	if #output == 0 then
		-- No tracking categories for empty results, as infoboxes or others may test if the result is empty or not
		return ''
	end

	-- Prepare an icon with link to Wikidata
	local icon = ''
	if mw.text.trim(args.ikon or '') == 'ja' then
		icon = ' [[File:Blue pencil.svg|frameless|text-top|5px|alt=Rediger på Wikidata|link=d:' ..
				the_qid .. '#' .. the_pid .. '|Rediger på Wikidata]]'
	end

	local max = tonumber(args.maks or 1e6)
	local number = math.min(#output, max)
	local suffix
	if number == 1 then
		suffix = mw.text.trim(args.eintal or '')
	else
		suffix = mw.text.trim(args.fleirtal or '')
	end

	local list = args.liste or ''
	if (list == 'ja') then
		if meir_enn_maks and meir_enn_maks ~= '' then
			meir_enn_maks = '</li><li>' .. meir_enn_maks
		else
			meir_enn_maks = ''
		end
		return '<ul><li>' .. table.concat(output, '</li><li>', 1, number) ..
			meir_enn_maks .. '</li></ul>' .. icon .. suffix .. tracking_categories
	else
		local separator = args.atskil or ', '
		if meir_enn_maks and meir_enn_maks ~= '' then
			meir_enn_maks = ' ' .. meir_enn_maks
		else
			meir_enn_maks = ''
		end
		return table.concat(output, separator, 1, number) ..  meir_enn_maks .. icon .. suffix .. tracking_categories
	end
end

p.hent_emne = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end

	-- Sort the statements after snaktype (value, novalue, somevalue) and id
	-- This makes it possible to find and group equal values together
	for key, statement in pairs(statements) do
		if statement.mainsnak.snaktype == 'value' then
			if statement.mainsnak.datatype ~= 'wikibase-item' then
				-- The property has a wrong datatype, ignore it.
				return ''
			end
			statement.sortkey = statement.mainsnak.datavalue.value.id
		else
			statement.sortkey = statement.mainsnak.snaktype
		end
	end
	table.sort(statements, function (a,b)
		return (a.sortkey < b.sortkey)
	end)

	if #statements > 5 then -- finds pages where much is available from Wikidata
		if the_pid =='P463' then add_tracking_category(tracking_cats.many_p463_category)
		elseif the_pid =='P106' and #statements > 10 then add_tracking_category(tracking_cats.tiplus_p106_category)
		elseif the_pid =='P106' then add_tracking_category(tracking_cats.many_p106_category)
		elseif the_pid =='P1344' then add_tracking_category(tracking_cats.many_p1344_category)
		elseif the_pid =='P802' then add_tracking_category(tracking_cats.many_p802_category)
		elseif the_pid =='P800' then add_tracking_category(tracking_cats.many_p800_category)
		elseif the_pid =='P737' then add_tracking_category(tracking_cats.many_p737_category)
		elseif the_pid =='P166' then add_tracking_category(tracking_cats.many_p166_category)
		end
	end

	local output = {}
	local upper_case_labels = mw.text.trim(args.medstort or '')
	local firstvalue = true

	local qual1 = mw.text.trim(args.kvalifikator1 or '')
	local no_statement_grouping = qual1 ~= ''

	-- Go thru the statements and format them for displaying
	local startrange = 1
	local endrange = 1
	local only = mw.text.trim(args.berre or '')
	-- We need to keep track of the maximal allowed number of results here, so references 
	-- made with frame:extensionTag() for removed results will not stay behind. 
	local max = tonumber(args.maks) or 1e6 -- if no limit then set some limit we will never reach 
	while max > 0 and startrange <= #statements do
		local sortkey = statements[startrange].sortkey
		while endrange <= #statements and statements[endrange].sortkey == sortkey do
			endrange = endrange + 1
			if no_statement_grouping then
				-- We have qualifiers to check for each statement, so we cannot group
				-- statements with equal values together.
				break
			end
		end
		-- Check if only results with a certain value is requested 
		if only == '' or only == sortkey then
			local use_ucfirst = upper_case_labels == 'alle' or (upper_case_labels == 'ja' and firstvalue)
			local text = p.format_statement_group(args, statements, startrange, endrange, use_ucfirst)
			if text then
				output[#output + 1] = text
				max = max - 1
				firstvalue = false
			end
		end
		startrange = endrange
	end

	local meir_enn_maks = nil -- an addition that states that not everything is displayed because the list is longer than max
	if tonumber(args.maks) and #statements > tonumber(args.maks) then
		if args.meir_enn_maks then
			-- an empty string can be used to remove the default value
			meir_enn_maks = mw.text.trim(args.meir_enn_maks)
		else
			meir_enn_maks = 'med fleire'
		end
	end
	
	return p.output_all_statements(args, output, meir_enn_maks)
end

local function process_statements(statements, type, format_func, args)
	local output = {}
	-- Go through the statements and format them for displaying
	for _, statement in pairs(statements) do
		local text = nil
		if statement.mainsnak.snaktype == 'value' then
			if statement.mainsnak.datatype == type then
				text = format_func(args, statement.mainsnak.datavalue.value)
			end
		elseif statement.mainsnak.snaktype == 'novalue' then
			text = mw.text.trim(args.ingen or "")
		elseif statement.mainsnak.snaktype == 'somevalue' then
			text = mw.text.trim(args.ukjent or "")
		end
		if text then
			text = get_qualifiers(args, text, statement.qualifiers)
			text = get_references(args, text, statement.references)
			if text and text ~= '' then
				output[#output + 1] = text
			end
		end
	end
	return p.output_all_statements(args, output, nil)
end

-- Format a time value
-- Return formatted text for the date
p.format_time = function(args, value)
	-- Parse the ISO 8601 time value
	-- The format is like '+2000-00-00T00:00:00Z'.
	-- For now the value can only contain date. Their is no timezone or time.

	local sign, year, month, day = string.match(value.time, '^([%+-])0*(%d+)-0?(%d+)-0?(%d+)T')
	if not sign then
		-- No match. We can consider an error message or category for this, but ignore for now
		return nil
	end

	-- handle year and AD/BC
	local bc_text = ''	-- text for AD or BC
	if sign == '-' then
		-- Year 0 doesn't exist, year 1,2,3 BC etc is given as -1,-2,-3 etc.
		-- (or maybe also in some cases as 0,-1,-2 etc.?)
		-- (see also [[nn:Help:Dates#Years BC]])
		bc_text = bc
	end

	if value.precision >= 9 then
		-- precision is year or greater
		local date = year .. bc_text
		local yearonly = mw.text.trim(args['berreår'] or "") == 'ja'
		if not yearonly and value.precision >= 10 then
			-- precision is month or greater: Prepend the month
			date = months[month] .. date
			if value.precision >= 11 then
				-- precision is day or greater: Prepend the day
				date = day .. '. ' .. date

				-- Compare the date with another date and calculate age if requested
				local agepid = mw.text.trim(args['alder'] or "")
				if agepid ~= '' then
					local ageformat = mw.text.trim(args['alderformat'] or "$1 ($3 år)")
					local agestatements = mw.wikibase.getBestStatements(the_qid, agepid)
					local agevalue = agestatements and #agestatements == 1 and
						agestatements[1].mainsnak and agestatements[1].mainsnak.snaktype == 'value' and
						agestatements[1].mainsnak.datavalue.value
					if agevalue and agevalue.precision >= 11 then
						local agedate = p.format_time({['berreår']=args['berreår']}, agevalue)
						local age
						local agesign, ageyear, agemonth, ageday = string.match(agevalue.time, '^([%+-])0*(%d+)-0?(%d+)-0?(%d+)T')
						-- First get the difference in the years. Remember that year 0 doesn't exist.
						if agesign == '-' then
							if sign == '-' then
								age = tonumber(ageyear) - tonumber(year)		-- e.g. 100 BC - 50 BC
							else
								age = tonumber(ageyear) + tonumber(year) - 1	-- e.g. 10 BC - 40 AD
							end
						else
							if sign == '-' then
								age = 1 - tonumber(year) - tonumber(ageyear)		-- e.g 40 AD - 10 BC (negative gives no sense)
							else
								age = tonumber(year) - tonumber(ageyear)			-- e.g. 50 AD - 100 AD
							end
						end
						--Substract a year if the birthday isn't reached in the last year
						if tonumber(month) < tonumber(agemonth) or
							(tonumber(month) == tonumber(agemonth) and tonumber(day) < tonumber(ageday)) then
							age = age - 1
						end
						return (string.gsub(ageformat, '$[123]', { ['$1'] = date, ['$2'] = agedate, ['$3'] = tostring(age) }))
					end -- if agevalue
				end -- if agepid
			end -- if value.precision >= 11 then
		end -- if value.precision >= 10 then
		return date
	end --if value.precision >= 9 then

	-- precision is less than year
	local year_num = tonumber(year)
	if value.precision == 8 then
		-- precision is decade
		-- 10 (or any number in the period) seems to mean years 10-19,
		-- 20 (or any number in the period) seems to mean years 20-29,
		-- 2010 (or any number in the period) seems to mean years 2010-2019
		if year_num <= 10 then
			return '1. tiår' .. bc_text
		else
			-- Make sure the number ends with 0
			return tostring(math.floor(year_num/10)*10) .. "-åra" .. bc_text
		end
	end

	if value.precision == 7 then
		-- precision is century
		-- 100 (or any number in the period) seems to mean years 1-100,
		-- 200 (or any number in the period) seems to mean years 101-200,
		-- 2100 (or any number in the period) seems to mean years 2001-2100
		if year_num <= 100 then
			return '1. hundreåret' .. bc_text
		else
			-- Make sure the number ends with 00 and convert the period one year down
			return tostring(math.floor((year_num - 1)/100)*100) .. '-talet' .. bc_text
		end
	end

	-- precision less than century is not handled
	return nil
	-- if value.precision == 6 then -- precision is 1000 years
	-- if value.precision == 5 then -- precision is 10.000 years
	-- if value.precision == 4 then -- precision is 100.000 years
	-- if value.precision == 3 then -- precision is million years
	-- if value.precision == 2 then -- precision is 10 million years
	-- if value.precision == 1 then -- precision is 100 million years
	-- if value.precision == 0 then -- precision is 1 billion years
end

p.hent_tid = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end
	return process_statements(statements, 'time', p.format_time, args)
end

local insert_delimiters = function(number)
	-- first change the decimal mark to comma
	number = string.gsub(number, '%.', ',')
	repeat
		-- Find the group of 3 digits and insert delimiter
		local matches
		number, matches = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1.%2')
	until matches == 0
	return number
end

local make_the_number = function(args, amount, diff, unit)

	local decimals = mw.text.trim(args.desimaler or '0')
	if decimals == 'smart' then
		if amount > 100 then decimals = '0'
		elseif amount > 10 then decimals = '1'
		elseif amount > 1 then decimals = '2'
		else decimals = '3' end
	else
		decimals = tostring(math.floor(tonumber(decimals) or 0))
	end

	-- First the amount
	local text = insert_delimiters(string.format('%.' .. decimals .. 'f', amount))

	-- Second the variation
	if diff > 0 and mw.text.trim(args.visusikkerheit or "") ~= 'nei' then
		local difftext = string.format('%.' .. decimals .. 'f', diff)
		-- Don't show the diff it if is rounded to 0
		if tonumber(difftext) ~= 0 then
			text = text .. '±' .. insert_delimiters(difftext)
		end
	end

	-- Third the unit
	if unit and mw.text.trim(args.viseining or "") ~= 'nei' then
		text = text .. ' ' .. unit
	end
	return text
end

-- Format a quantity value and return the formated value
-- Also return the amount as a number if it a quantity with a recogniced unit
-- (used to get area)
p.format_number = function(args, value)

	local amount = tonumber(value.amount)
	local diff1, diff2 = 0, 0
	if value.lowerBound then
		diff1 = amount - tonumber(value.lowerBound)
	end
	if value.upperBound then
		diff2 = tonumber(value.upperBound) - amount
	end
	local diff = math.max(diff1, diff2)

	local unit = value.unit
	if unit == '1' then
		-- Number without unit
		local text = make_the_number(args, amount, diff, nil)

		-- We may have to find the area and calculate the density
		local densityformat = mw.text.trim(args['arealogtettleik'] or '')
		if densityformat ~= '' then
			local area_text, area_number, density_text
			-- P2046 is area
			local area_statements = mw.wikibase.getBestStatements(the_qid, 'P2046')
			if area_statements and #area_statements == 1 and area_statements[1].mainsnak.snaktype == 'value' then
				area_text, area_number =
					p.format_number({ eining='km2', viseining='nei', visusikkerheit=args.visusikkerheit, desimaler='smart' },
						area_statements[1].mainsnak.datavalue.value)
				if area_number then
					density_text = p.format_number({ desimaler='smart' }, { amount=amount / area_number, unit='1' })
					return (string.gsub(densityformat, '$[123]', { ['$1'] = text, ['$2'] = area_text, ['$3'] = density_text }))
				end
			end
			-- No area found. Return the value with densityformatwithout applied
			local densityformatwithout = mw.text.trim(args['arealogtettleikutan'] or '$1')
			return (string.gsub(densityformatwithout, '$1', { ['$1'] = text }))
		end
		-- area and density was not asked for.
		return text
	end

	local unit_qid = string.match(unit, 'http://www%.wikidata%.org/entity/(Q%d+)$')
	if not unit_qid then
		-- Unknown unit format
		return nil
	end

	local wd_unit = wd_units[unit_qid]
	if not wd_unit then
		-- The unit is not in our table. Here we could read information
		-- about the unit entity. Maybe to be done later
		add_tracking_category (tracking_cats.category_unrecognized_unit)
		return make_the_number(args, amount, diff, nil)
	end
	local wanted_unit = mw.text.trim(args.eining or "")
	if wanted_unit == '' and wd_unit.conv_to then
		wanted_unit = wd_unit.conv_to
	end

	local wanted = wanted_units[wanted_unit]
	if wanted and wd_unit.name ~= wanted_unit and wd_unit.type == wanted.type then
		amount = amount * wd_unit.conv * wanted.conv
		diff = diff * wd_unit.conv * wanted.conv
		return make_the_number(args, amount, diff, wanted.show_as), amount
	end
	return make_the_number(args, amount, diff, wd_unit.show_as), amount
end

p.hent_tal = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end
	if #statements > 1 then -- more than 1 result is retrieved from Wikidata
		if the_pid =='P1082' then  -- population
			add_tracking_category(tracking_cats.many_p1082_category)
		end
	end
	return process_statements(statements, 'quantity', p.format_number, args)
end

-- Handle datatypes string, url, commonsMedia, external-id which have similar structures
p.hent_streng = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end

	local output = {}

	-- For formating of strings. $1 in the format will be replaced by the string 
	local format = mw.text.trim(args.format or '')
	if format == '' then
		format = nil
	end

	-- Go thru the statements and format them for displaying
	for key, statement in pairs(statements) do
		local text = nil
		if statement.mainsnak.snaktype == 'value' then
			if statement.mainsnak.datatype == 'string' then
				text = mw.text.nowiki(statement.mainsnak.datavalue.value)
			elseif statement.mainsnak.datatype == 'url' or
				statement.mainsnak.datatype == 'commonsMedia' or
				statement.mainsnak.datatype == 'external-id' then
				text = statement.mainsnak.datavalue.value
			end
			if format and text then
				-- We have to escape any % in the found string with another % before using it as repl in string.gsub
				text = string.gsub(text, '%%', '%%%%')
				text = string.gsub(format, '$1', text)
			end
		elseif statement.mainsnak.snaktype == 'novalue' then
			text = mw.text.trim(args.ingen or "")
		elseif statement.mainsnak.snaktype == 'somevalue' then
			text = mw.text.trim(args.ukjent or "")
		end
		if text then
			text = get_qualifiers(args, text, statement.qualifiers)
			text = get_references(args, text, statement.references)
			if text and text ~= '' then
				table.insert(output, text)
			end
		end
	end

	return p.output_all_statements(args, output, nil)
end

p.hent_tekst = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end

	local output = {}

	local get_all, show_language, wanteds = get_lang_args(args)	

	-- Go thru the statements and format them for displaying
	for key, statement in pairs(statements) do
		local text = nil
		if statement.mainsnak.snaktype == 'value' then
			if statement.mainsnak.datatype == 'monolingualtext' then
				if get_all or wanteds[statement.mainsnak.datavalue.value.language] then
					text = mw.text.nowiki(statement.mainsnak.datavalue.value.text)
					if show_language then
						text = text .. ' (' ..
							mw.language.fetchLanguageName(statement.mainsnak.datavalue.value.language, preferred_language) .. ')'
					end
				end
			end
		elseif statement.mainsnak.snaktype == 'novalue' then
			text = mw.text.trim(args.ingen or "")
		elseif statement.mainsnak.snaktype == 'somevalue' then
			text = mw.text.trim(args.ukjent or "")
		end
		if text then
			text = get_qualifiers(args, text, statement.qualifiers)
			text = get_references(args, text, statement.references)
			if text and text ~= 0 then
				table.insert(output, text)
			end
		end
	end

	return p.output_all_statements(args, output, nil)
end

p.hent_koord = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end
	return process_statements(statements, 'globe-coordinate', format_coordinates, args)
end

local function format_math(args, value)
	return '<math>' .. value .. '</math>'
end

p.hent_matematik = function(frame)
	local args, statements, return_now = get_statements(frame)
	if return_now then
		return return_now
	end
	return process_statements(statements, 'math', format_math, args)
end

-- Get Wikidata entity ID for the current page.
-- Arguments: format: format string with $1 for the ID, non: text to return for no entity
p.hent_id = function(frame)
	local args = (mw.getCurrentFrame()) and frame:getParent().args or frame.args

	-- Get the item to use from either the parameter q or the item connected to the current page
	local qid = mw.text.trim(args.q or '')
	if qid == '' then
		qid = mw.wikibase.getEntityIdForCurrentPage()
	end	
	
	if qid then
		local format = mw.text.trim(args.format or '$1')
		return (string.gsub(format, '$1', { ['$1'] = qid }))
	else
		return mw.text.trim(args.ingen or '')
	end
end

p.formatTime = function(bDate)
    local year = tonumber(string.sub(bDate, 2, 5))
    local month = tonumber(string.sub(bDate, 7, 8))
    local day = tonumber(string.sub(bDate, 10, 11))
        if string.sub(bDate, 1, 1) == '-' then
        year = 0 - year
    end
    
    if year ~= nil and month ~= nil and day ~= nil then
    	return Date(tonumber(year), tonumber(month), tonumber(day))
    else 
    	return nil
    end
    
end

p.alderinfo = function(frame)
	if not mw.wikibase then
        return ''
    end
    local artikkel = mw.wikibase.getEntityObject()
    if not artikkel then
        return ''
    end
	local birth = artikkel:getBestStatements('P569' ), nil
	local death = artikkel:getBestStatements('P570'), nil

	if death[1] ~= nil then
		return ''
	end
	
	if birth[1] ~= nil then
		local bDate = birth[1].mainsnak.datavalue.value.time
		local diff = Date(p.formatTime(bDate)) - Date(os_date)
		return mw.text.nowiki('('..diff.years..' år)')
	end
end

return p
