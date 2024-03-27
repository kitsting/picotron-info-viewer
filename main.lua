--[[pod_format="raw",created="2024-03-17 02:51:46",modified="2024-03-27 02:00:27",revision=1292]]
--This command lists all available terminal commands
--Looks in both /system/util and /appdata/system/util

--Includes
include "utility.lua"


util_name = "infman" --Store the name in a variable incase i need to rename it again u_u
--==========================================================
--Installer Mode
--Copy from /ram/cart to /appdata/system/util/info.p64 if its being run from the bbs
--==========================================================
if pwd() == "/ram/cart" then
	print("Looks like you're trying to run \ff"..util_name.."\f7 from a bbs cart (or dev environment)")
	print("Running automatic installer...")
	mkdir("/appdata/system/util") --Make sure the util directory exists
	cp("/ram/cart", "/appdata/system/util/"..util_name..".p64")
	print("Installation successful! Type '\ff"..util_name.."\f7' to get started")
end


--Parse arguments
local argv = env().argv

local command_given = false
local page_given = false
local sys_only = false
local user_only = false
local highlight_mode = false
local use_command = ""
local view_page = 1

for argument in all(argv) do
	if argument == "--system" or argument == "-s" then
		sys_only = true
	elseif argument == "--user" or argument == "-u" then
		user_only = true
	elseif argument == "--highlight" or argument == "-h" then
		highlight_mode = true
	else
		if not command_given then
			use_command = argument
			command_given = true
		elseif not page_given then
			view_page = tonum(argument)
			page_given = true
		end
	end
end

--==========================================================
--Command list mode
--==========================================================
if not command_given then
	
	--Print the list of commands
	if sys_only then
		print("\n\fe\128Command list - System commands (in /system/util/)\n")
		print_table(sort(ls("/system/util/")), 3, 8, highlight_mode)
		
	elseif user_only then
		print("\n\fe\128Command list - User commands (in /appdata/system/util/)\n")
		local appdata_dir = ls("/appdata/system/util/")
		if appdata_dir[1] ~= nil then
			print_table(sort(appdata_dir), 3, 8, highlight_mode)
		else
			print("No user commands found")
			print("To add user commands, place .lua files in /appdata/system/util/")
		end
		
	else
		print("\n\fe\128Command list - All commands\n")
		local all_commands = ls("/system/util/")	
		local appdata_dir = ls("/appdata/system/util/")
		--Add the commands from /appdata/system/util only if theres stuff to add
		if appdata_dir[1] ~= nil then
			for cmd in all(appdata_dir) do
				add(all_commands, cmd)
			end
		end
		print_table(sort(all_commands), 3, 8, highlight_mode)
	end
	print("\n\fdHint: type \""..util_name.." [command]\" to get usage info for that command\n ")

--==========================================================
--Manual mode
--==========================================================
else --A command has been given

	--Get the list of all commands
	local sys_commands = ls("/system/util/")	
	local user_commands = ls("/appdata/system/util/")

	--Check if the entered command actually exists
	local command_found = false
	local command_is_user = false		
	
	--Look in system directory first (thats what the terminal does i think)
	for command in all(sys_commands) do
		if filter_extensions(command) == use_command then
			command_found = true
			break
		end
	end
	
	--If it's not in the system directory, look in appdata
	if not command_found then
		for command in all(user_commands) do
			if filter_extensions(command) == use_command then
				command_found = true
				command_is_user = true
				break
			end
		end
	end
	
	if command_found then
		--Print header
		if command_is_user then
			print("\n\fe\128"..use_command.." - User command (in /appdata/system/util/)")
		else
			print("\n\fe\128"..use_command.." - System command (in /system/util/)")
		end
	
		--Print actual manual
		local mancontent = get_manual(use_command)			
		if mancontent then
			--Special case: update the manual for this command automatically
			if use_command == util_name then
				mancontent = mancontent:gsub("{name}", util_name)
			end
			local pages = split_manual(mancontent)
			view_page = min(view_page, #pages)	--Make sure that view_page isnt too high		
			if view_page > 0 then --View a specific page
				print("\fe\t[Page "..tostr(view_page).." of "..tostr(#pages).."]["..get_page_display(view_page, #pages).."]\n")
				print(pages[view_page])
				if view_page < #pages then
					print("\fdType "..util_name.." "..use_command.." "..tostr(view_page+1).." to see the next page")
				end
			else --View all pages
				print("\fe\t[All pages]\n")
				print(mancontent)
			end
		else
			--Print an error message if no manual page could be found
			print("Could not find a manual for \ff"..argv[1].."\f7.")
			print("Try \ff"..argv[1].." --help\f7")
		end	
		print("")
	else
		print(util_name..": Could not find command \ff"..argv[1].."\f7. Check your spelling!")
	end
end