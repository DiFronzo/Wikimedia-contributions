local yesno = require('Module:Yesno')
local sdc = require 'Module:Structured Data'
local getArgs = require('Module:Arguments').getArgs

--------------------------------------------------------------------------------
-- Builder
--------------------------------------------------------------------------------
local file = {}

local function get(val)
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
	return text2
end

function file.new(data, pid, name)
	local val = mw.wikibase.getBestStatements(data, pid)
	local file = ''

	if name then
		file = '[[File:' .. name .. '|thumb|'
		if mw.wikibase.getLabel(data) then
			file = file .. mw.wikibase.getLabel(data) .. '. '
		end
		if val[1] then
			local icon = ' [[File:Blue pencil.svg|frameless|text-top|5px|alt=Edit on Wikimedia Commons|link=c:File:' .. name .. '#ooui-php-8' .. '|Edit on Wikimedia Commons]]'
			file = file .. mw.wikibase.getLabel(pid):gsub("^%l", string.upper) .. ': ' .. get(val) .. icon .. ']]'
		else
			file = file .. ']]'
		end
		return file
	end
	return nil

end
	
--------------------------------------------------------------------------------
-- Exports
--------------------------------------------------------------------------------
local p = {}

local function getTitle(...)
	local success, titleObj = pcall(mw.title.new, ...)
	if success then
		return titleObj
	else
		return nil
	end
end

function p.main(frame)
	local title = ''
	local name = getArgs(frame, {
	wrappers = 'Template:FileSD'
	})
	local pid = name['pid'] or 'P275'
	
	if mw.title.getCurrentTitle().namespace == 6 then
		name[1] = mw.title.getCurrentTitle().text
		title = sdc.getMID()
	elseif name then
		title = 'M' .. getTitle('File:' .. name[1]).id
	else
		return ''
	end
	
	return file.new(title, pid, name[1])
end

return p
