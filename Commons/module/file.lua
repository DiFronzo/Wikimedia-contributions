local p = {}
local WikidataIB = require("Module:WikidataIB")

function p.getMID()
	return "M" .. mw.title.getCurrentTitle().id
end

function p.preview(frame)
	local mId = frame.args[1] or p.getMID()
	local endItem = frame.args.item or 'P275'
	local captions = ''

	if frame.args[1] then
		mId = mw.wikibase.getEntity(frame.args[1]).id or ''
	end

	local file = frame.args.file or mw.title.getCurrentTitle().text

	if not mw.wikibase or not mId then
        return ''
    end

	captions = mw.wikibase.getLabel(mId)

	local val = mw.wikibase.getBestStatements( mId, endItem)
	local text = {}
	local text2 = ''
	for i, v in ipairs(val) do
    	text[#text+1] = mw.wikibase.getLabel(v.mainsnak.datavalue.value.id)
	end

	if not text[1] then
		return ''
	elseif not text[2] then
		text2 = text[1]:gsub("^%l", string.upper)
	else
		text[1] = text[1]:gsub("^%l", string.upper)
		text2 = table.concat(text, ', ')
	end

	local icon = ''
	if text then
		icon = ' [[File:Blue pencil.svg|frameless|text-top|5px|alt=Edit on Wikimedia Commons|link=c:File:' ..
				file .. '#' .. endItem .. '|Edit on Wikimedia Commons]]'
	end

	return '[[File:' .. file .. '|thumb|250px|' .. captions .. '. ' .. mw.wikibase.getLabel(endItem):gsub("^%l", string.upper) .. ': ' .. text2 .. '.' .. icon .. ']]'
end

return p
