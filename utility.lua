--[[pod_format="raw",created="2024-03-18 15:31:44",modified="2024-03-23 22:48:55",revision=899]]
--Paths where commands are stored.
--If picotron ever gets a $PATH, use that instead
local command_paths = {
	"sys_manual/", --Builtin manual
	"/appdata/system/util/", --User commands
	"/system/util/" --System commands (there probably arent manuals here)
}


--Remove file extensions from the end of a string
--Also functions as checking if a file has valid extensions
function filter_extensions(string)
	local return_string = nil
	
	local ext = sub(string, #string-3, #string)
	if ext == ".lua" or ext == ".p64" then
		return_string = sub(string, 0, #string-4)
	end
	
	return return_string
end

--Sort a table with a simple insertion sort. May be slow for large tables
function sort(a)
	for i=1,#a do
		local j = i
		while j > 1 and a[j-1] > a[j] do
			a[j],a[j-1] = a[j-1],a[j]
			j = j - 1
		end
	end
	
	return a
end

--Search for text files containing manuals
function find_man_dottxt(command)
	local search_paths = {
		command..".p64/manual.txt",
		command.."_manual.txt"
	}

	for commandpath in all(command_paths) do
		for path in all(search_paths) do
			if fstat(commandpath..path) then
				return fetch(commandpath..path)
			end
		end
	end
	return nil
end

--Search for comments containing manuals
function find_man_comment(command)
	local file = nil
	local search_paths = {
		command..".lua",
		command..".p64/main.lua",
	}
	
	--First, actually get the file content
	for commandpath in all(command_paths) do
		for path in all(search_paths) do
			if fstat(commandpath..path) then
				file = fetch(commandpath..path)
				break
			end
		end
	end
	
	if not file then
		return nil
	end
	
	--Extract the manual from the multiline comment
	--Look for the start of the first multiline comment
	local i0,i1 = file:find("--[[",1,true)
	if not i0 then
		return nil
	end
	
	--Look for the end of the comment
	local i2 = file:find("]]", i1+1, true)
	if not i2 then
		return nil
	end

	--Extract the comment from the code
	return sub(file, i1+1, i2-1)

end

--Get the manual
--Check .txt manuals, then comment manuals
--Parse the result for p8scii
function get_manual(cmd)
	return_text = find_man_dottxt(cmd) or find_man_comment(cmd) or nil
	
	--Parse p8scii
	if return_text then
		return_text = return_text:gsub("\\f",chr(12)) --Text colour
		return_text = return_text:gsub("\\v",chr(11)) --Character decoration
		return_text = return_text:gsub("\\^",chr(6)) --Special command
		return_text = return_text:gsub("\\#",chr(2)) --Background colour
	end

	return return_text --Returns nil if no manual was found
end

--Split a manual into multiple pages based on the page break delimiter (---)
function split_manual(manual_text)
	pages = {}
	current_page = ""
	lines = split(manual_text, "\n")
	
	for text_line in all(lines) do
		if text_line == "---" then --Page break marker
			if current_page ~= "" then --Ignore empty pages
				add(pages, current_page)
				current_page = ""
			end
		else
			current_page = current_page..text_line.."\n"
		end
	end
	
	if current_page ~= "" then
		add(pages, current_page)
	end
	
	return pages
end


function get_page_display(page, max_pages)
 return string.rep("- ", page-1).."x"..string.rep(" -", max_pages-page)
end

--Print a table with custom spacing
function print_table(table, elements_in_row, spacing, highlight)
	local highlight = highlight or false
	local row_elem = 0
	local row_string = ""
	for element in all(table) do
		local row_sub = filter_extensions(element) --Remove the extension	

		if row_sub then --Only list the command if it has a valid extension
		
			local row_colour = "\f7" --Text colour (for -h flag)
			if highlight then
				if not get_manual(row_sub) then
					row_colour = "\f8"
				end
			end		
	
			--Built a row (the "   " fixes a spacing issue somehow)
			local srepeat = flr(spacing-(#row_sub/3))
			row_string = row_string..row_colour..row_sub.."\f7".."   "..string.rep("\t",srepeat-1)
			row_elem += 1
			
			--Print the row once it has the specified number of elements
			if row_elem == elements_in_row then
				row_elem = 0
				print(row_string)
				row_string = ""
			end
		end
	end
	--Print the last row if it has less than the speficied number of elements
	if row_elem > 0 then
		print(row_string)
	end
end