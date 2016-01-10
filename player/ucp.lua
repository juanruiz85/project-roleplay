--[[
	Project: SourceMode
	Version: 1.0
	Last Edited: 07/01/2016 (juanruiz85)
	Authors: Jack
]]--

addEvent("onUCPStart",true)
addEvent("updateAccounts",true)
addEvent("onClientPlayerSpawned",true)
addEvent("onClientPlayerDespawned",true)

local windows ={}
local labels = {}
local mainLabels = {}
local tabs = {}
local buttons = {}
local grids = {}
local edits = {}

local blocked = false --We'll set this to true if we're doing something important.

function onStart()
	local rX,rY = guiGetScreenSize()
	local width,height = 445, 344
	local offset = 5
	local X,Y = exports.utils:getGUICenter(rX,rY,width,height)
	
	windows["UCP"] = guiCreateWindow(rX-width-offset,rY-height-offset,width,height, "SourceMode - User Control Panel (Press M to hide)", false)
	guiWindowSetSizable(windows["UCP"], false)
	guiWindowSetMovable(windows["UCP"], false)
	guiSetAlpha(windows["UCP"], 0.95)
	
	--Create our Tab Panel and tabs
	tabpanel = guiCreateTabPanel(9, 20, 426, 314, false, windows["UCP"])
	tabs["main"] = guiCreateTab("Main", tabpanel)
	tabs["players"] = guiCreateTab("Players", tabpanel)
	tabs["taxi"] = guiCreateTab("Taxi", tabpanel)
	tabs["vehicles"] = guiCreateTab("Vehicles", tabpanel)
	tabs["account"] = guiCreateTab("Account", tabpanel)
	--guiSetEnabled(tabs["taxi"],false)
	--guiSetEnabled(tabs["vehicles"],false)
	
	--MAIN MENU
	labels["main-title"] = guiCreateLabel(17, 4, 225, 42, "Source Mode", false, tabs["main"])
	labels["main-version"] = guiCreateLabel(260, 4, 135, 42, "V1.0 A", false, tabs["main"])
	guiSetFont(labels["main-title"], "sa-header")
	guiSetFont(labels["main-version"], "sa-header")
	buttons["main-updates"] = guiCreateButton(93, 56, 238, 25, "Latest Gamemode Updates", false, tabs["main"])
	grids["news"] = guiCreateGridList(10, 85, 406, 195, false, tabs["main"])
	news = guiGridListAddColumn(grids["news"], "News", 0.9)
	getNews()
	guiSetEnabled(buttons["main-updates"],false)

	--PLAYERS MENU
	grids["players"] = guiCreateGridList(7, 4, 213, 276, false, tabs["players"])
	players = guiGridListAddColumn(grids["players"], "Players", 0.9)
	buttons["players-message"] = guiCreateButton(228, 14, 188, 28, "Message \"..player..\"", false, tabs["players"])
	buttons["players-mute"] = guiCreateButton(228, 75, 188, 28, "Mute \"..player..\"", false, tabs["players"])
	buttons["players-slap"] = guiCreateButton(228, 113, 188, 28, "Slap \"..player..\"", false, tabs["players"])
	buttons["players-give"] = guiCreateButton(228, 151, 188, 28, "Give \"..player..\" Money", false, tabs["players"])
	buttons["players-goto"] = guiCreateButton(228, 210, 188, 28, "Go to \"..player..\"", false, tabs["players"])
	edits["players-message"] = guiCreateEdit(228, 44, 188, 21, "Enter Message", false, tabs["players"])
	edits["players-money"] = guiCreateEdit(228, 179, 188, 21, "Enter Amount", false, tabs["players"])
	guiSetEnabled(buttons["players-message"],false)
	guiSetEnabled(buttons["players-mute"],false)
	guiSetEnabled(buttons["players-slap"],false)
	guiSetEnabled(buttons["players-give"],false)
	guiSetEnabled(buttons["players-goto"],false)
	updatePlayersList()
	
	--TAXI MENU
	labels["taxi-title"] = guiCreateLabel(100, 4, 225, 42, "Taxy System", false, tabs["taxi"])
	guiSetFont(labels["taxi-title"], "sa-header")
	buttons["taxi-updates"] = guiCreateButton(93, 56, 238, 25, "Go to Destination", false, tabs["taxi"])
	grids["taxilist"] = guiCreateGridList(10, 85, 406, 195, false, tabs["taxi"])
	destination = guiGridListAddColumn(grids["taxilist"], "Destination", 0.9)
	getTaxis()
	addEventHandler("onClientGUIClick",buttons["taxi-updates"],onUCPClick,false)
	--guiSetEnabled(buttons["taxi-updates"],true)
	
	--VEHICLE MENU
	grids["vehicles"] = guiCreateGridList(7, 4, 213, 276, false, tabs["vehicles"])
	vehicles = guiGridListAddColumn(grids["vehicles"], "Vehicles", 0.9)
	buttons["vehicles-spawn"] = guiCreateButton(228, 75, 188, 28, "Spawn", false, tabs["vehicles"])
	getVehiclesList()
	addEventHandler("onClientGUIClick",buttons["vehicles-spawn"],onUCPClick,false)
	
	--ACCOUNTS MENU
	buttons["accounts-logout"] = guiCreateButton(27, 257, 116, 23, "Logout", false, tabs["account"])
	buttons["accounts-changeChar"] = guiCreateButton(153, 257, 116, 23, "Change Character", false, tabs["account"])
	buttons["accounts-changePass"] = guiCreateButton(279, 257, 116, 23, "Change Password", false, tabs["account"])
	labels["accounts-username"] = guiCreateLabel(10, 10, 195, 22, "Username:", false, tabs["account"])
	guiSetFont(labels["accounts-username"], "default-bold-small")
	guiLabelSetHorizontalAlign(labels["accounts-username"], "left", false)
	guiLabelSetVerticalAlign(labels["accounts-username"], "center")
	--[[labels["accounts-character"] = guiCreateLabel(10, 42, 218, 22, "Character:", false, tabs["account"])
	guiSetFont(labels["accounts-character"], "default-bold-small")
	guiLabelSetHorizontalAlign(labels["accounts-character"], "left", false)
	guiLabelSetVerticalAlign(labels["accounts-character"], "center")]]
	labels["accounts-lastlogin"] = guiCreateLabel(10, 74-32, 195, 22, "Last Logged In: Next year", false, tabs["account"])
	guiSetFont(labels["accounts-lastlogin"], "default-bold-small")
	guiLabelSetHorizontalAlign(labels["accounts-lastlogin"], "left", false)
	guiLabelSetVerticalAlign(labels["accounts-lastlogin"], "center")
	labels["accounts-playtime"] = guiCreateLabel(10, 106-32, 195, 22, "Playtime: 99 years", false, tabs["account"])
	guiSetFont(labels["accounts-playtime"], "default-bold-small")
	guiLabelSetHorizontalAlign(labels["accounts-playtime"], "left", false)
	guiLabelSetVerticalAlign(labels["accounts-playtime"], "center")
	labels["accounts-stats"] = guiCreateLabel(215, 10, 201, 22, "Stats", false, tabs["account"])
	grids["accounts-stats"] = guiCreateGridList(215, 32, 201, 215, false, tabs["account"])
	stats = guiGridListAddColumn(grids["accounts-stats"], "Stats", 0.9)
	guiLabelSetHorizontalAlign(labels["accounts-stats"], "center", false)
	guiLabelSetVerticalAlign(labels["accounts-stats"], "center")
	addEventHandler("onClientGUIClick",buttons["accounts-logout"],onUCPClick,false)
	addEventHandler("onClientGUIClick",buttons["accounts-changeChar"],onUCPClick,false)
	guiSetEnabled(buttons["accounts-changePass"],false)
	loadStats()

	--CHANGE PASSWORD WINDOW
	--[[GUIEditor.window[2] = guiCreateWindow(694, 262, 299, 373, "SourceMode - Change Password", false)
	guiWindowSetSizable(GUIEditor.window[2], false)
	guiSetAlpha(GUIEditor.window[2], 0.95)
	GUIEditor.edit[3] = guiCreateEdit(23, 135, 242, 20, "", false, GUIEditor.window[2])
	GUIEditor.label[9] = guiCreateLabel(61, 115, 166, 20, "Old Password", false, GUIEditor.window[2])
	guiSetFont(GUIEditor.label[9], "default-bold-small")
	guiLabelSetHorizontalAlign(GUIEditor.label[9], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[9], "center")
	GUIEditor.label[10] = guiCreateLabel(23, 155, 242, 25, "PASSWORD INCORRECT", false, GUIEditor.window[2])
	guiSetFont(GUIEditor.label[10], "default-bold-small")
	guiLabelSetHorizontalAlign(GUIEditor.label[10], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[10], "center")
	GUIEditor.label[11] = guiCreateLabel(61, 190, 166, 20, "New password", false, GUIEditor.window[2])
	guiSetFont(GUIEditor.label[11], "default-bold-small")
	guiLabelSetHorizontalAlign(GUIEditor.label[11], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[11], "center")
	GUIEditor.edit[4] = guiCreateEdit(23, 210, 242, 20, "", false, GUIEditor.window[2])
	GUIEditor.label[12] = guiCreateLabel(23, 230, 242, 25, "Please Enter your new password", false, GUIEditor.window[2])
	guiSetFont(GUIEditor.label[12], "default-bold-small")
	guiLabelSetHorizontalAlign(GUIEditor.label[12], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[12], "center")
	GUIEditor.label[13] = guiCreateLabel(61, 265, 166, 20, "Confirm new password", false, GUIEditor.window[2])
	guiSetFont(GUIEditor.label[13], "default-bold-small")
	guiLabelSetHorizontalAlign(GUIEditor.label[13], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[13], "center")
	GUIEditor.edit[5] = guiCreateEdit(23, 285, 242, 20, "", false, GUIEditor.window[2])
	GUIEditor.label[14] = guiCreateLabel(23, 305, 242, 25, "Passwords are different!", false, GUIEditor.window[2])
	guiSetFont(GUIEditor.label[14], "default-bold-small")
	guiLabelSetHorizontalAlign(GUIEditor.label[14], "center", false)
	guiLabelSetVerticalAlign(GUIEditor.label[14], "center")
	GUIEditor.button[10] = guiCreateButton(28, 336, 113, 27, "Change Password", false, GUIEditor.window[2])
	guiSetProperty(GUIEditor.button[10], "NormalTextColour", "FFAAAAAA")
	GUIEditor.button[11] = guiCreateButton(147, 336, 113, 27, "Cancel", false, GUIEditor.window[2])
	guiSetProperty(GUIEditor.button[11], "NormalTextColour", "FFAAAAAA")
	GUIEditor.staticimage[1] = guiCreateStaticImage(53, 22, 184, 93, ":guieditor/images/examples/mtalogo.png", false, GUIEditor.window[2])]]
	
	guiSetVisible(windows["UCP"],false)
end
addEventHandler("onClientResourceStart",resourceRoot,onStart)

function onUCPClick(button,state)
	if button == "left" and state == "up" then
		if (source == buttons["accounts-logout"]) then
			guiSetVisible(windows["UCP"],false)
			showCursor(false)
			triggerServerEvent("logoutPlayer",localPlayer,localPlayer)
		elseif (source == buttons["accounts-changeChar"]) then
			guiSetVisible(windows["UCP"],false)
			showCursor(false)
			triggerServerEvent("changeCharacter",localPlayer,localPlayer)
		elseif (source == buttons["taxi-updates"]) then

			-- We verify that the player is not in a car or in an interior
			if ( isPedInVehicle( localPlayer ) ) then
			return
			outputChatBox("You can't make this Action if you are in a Car Genius...", 255, 5, 15) 	  
			end

			if ( getElementInterior(localPlayer) ~= 0 ) or ( getElementDimension ( localPlayer ) ~= 0) then	
			return
				outputChatBox("You must be outside to call a taxi!", 255, 5, 15) 	  
			end

			-- we need load again the xml because i have problem making a table  but of this way is more easy but not the best way
			local file = xmlLoadFile ("taxi.xml")
			for _, v in ipairs ( xmlNodeGetChildren ( file ) ) do
				local taxiname = xmlNodeGetAttribute ( v, "name" )
				local seleccion = tostring(guiGridListGetItemText ( grids["taxilist"], guiGridListGetSelectedItem (grids["taxilist"] ), 1 ))
				if seleccion == taxiname then
					local taxiX = xmlNodeGetAttribute ( v, "x" )
					local taxiY = xmlNodeGetAttribute ( v, "y" )
					local taxiZ = xmlNodeGetAttribute ( v, "z" )
					
					-- Here we calculate the distance between the player and the destination
					local x, y, z = getElementPosition ( localPlayer )
					local distance = getDistanceBetweenPoints2D ( x, y, tonumber(taxiX), tonumber(taxiY) ) / 2
					
					-- Here we do an integer, since the money is managed in integers
					local distresult = math.ceil ( distance )
					local distresult1 = math.ceil ( distance / 2 )
					outputChatBox ( "The Distance between " ..getPlayerName(localPlayer).. " to the" .. taxiname:lower() .. " is "  ..distresult.. " meters.")
					outputChatBox ( "The taxy cost for " ..getPlayerName(localPlayer).. " is the "  ..tostring(distresult1).. "." )
					
					--- the next will be the code for move the player and effects
					vehicle = createVehicle(420, x+3, y, z+.3) 
					taxista = createPed(255, x, y, z)
					setTimer ( setElementPosition, 1000,1,vehicle,taxiX,taxiY,taxiZ + .3)
					setTimer ( setElementPosition, 1000,1,localPlayer,taxiX+3,taxiY,taxiZ + 1)
					warpPedIntoVehicle(taxista, vehicle)
					setTimer ( destroyElement, 7000,1, taxista)
					setTimer ( destroyElement, 7000,1, vehicle)
					setTimer(setElementFrozen,2200,1,vehicle,true)
					setTimer(function(localPlayer)
					if isElement (localPlayer) then
					setCameraTarget(localPlayer)
					end
					end,1900,1,source)
					fadeCamera (false, 1.0, 0, 0, 0 )         -- fade the player's camera to red over a period of 1 second
					setTimer ( fadeCameraDelayed, 1900, 1, localPlayer ) 
					outputChatBox("You will going to your destination in a some seconds, Thanks for use The Taxi System!", 155, 155, 155)

					-- here we take the money of the player :)
					triggerServerEvent("onPlayerpayfortaxi", localPlayer, localplayer, distresult1)

					-- Hidden the menu 
					local state = guiGetVisible(windows["UCP"])
					guiSetVisible(windows["UCP"],not state)
					showCursor(not state)
				end
			end
			xmlUnloadFile (file);  -- close file	
		elseif (source == buttons["vehicles-spawn"]) then
			-- Hidden the menu 
			local state = guiGetVisible(windows["UCP"])
			guiSetVisible(windows["UCP"],not state)
			showCursor(not state)
			-- We verify that the player is not in a car or in an interior
			if ( isPedInVehicle( localPlayer ) ) then 
			return 
				outputChatBox("You can't make this Action if you are in a Car Genius...", 255, 5, 15) 	  
			end

			if ( getElementInterior(localPlayer) ~= 0 ) or ( getElementDimension ( localPlayer ) ~= 0) then	
			return
				outputChatBox("You must be outside to use a vehicle", 255, 5, 15) 	  
			end
			
			if (guiGridListGetSelectedItem (grids["vehicles"])) then
			local car = guiGridListGetItemText (grids["vehicles"], guiGridListGetSelectedItem (grids["vehicles"]), 1)
			if car == "" or car == nil then outputChatBox( "please selected car from list.",255,90,90,true ) return end
			triggerServerEvent ("getCar", localPlayer, car)
			end
		end
	end
end

function ucpGUIManager(window,fade,state)
	if (window == "all") then
		guiSetVisible(windows["UCP"],state)
		--guiSetVisible(windows["changePass"],state)
	else
		if (windows[window]) then
			guiSetVisible(windows[window],state)
		end
	end
end

function toggleCursor(state)
	if state == nil then
		showCursor(not isCursorShowing())
	else
		showCursor(state)
	end
end

function toggleUCP()
	if blocked then return false end
	if not (exports.accounts:isPlayerLoggedIn()) then return false end
	local state = guiGetVisible(windows["UCP"])
	guiSetVisible(windows["UCP"],not state)
	showCursor(not state)
end
bindKey("m","down",toggleUCP)

function updatePlayersList()
	guiGridListClear(grids["players"])
	for k,v in ipairs(getElementsByType("player")) do
		if (v ~= localPlayer) then
			local name = getPlayerName(v)
			local r,g,b = getPlayerNametagColor(v)
			
			local row = guiGridListAddRow(grids["players"])
			guiGridListSetItemText(grids["players"],row,players,name,false,false)
			guiGridListSetItemColor(grids["players"],row,players,r,g,b)
		end
	end
end
addEventHandler("onClientPlayerJoin",root,updatePlayersList)
addEventHandler("onClientPlayerLeave",root,updatePlayersList)

function getNews()
	guiGridListClear( grids["news"] )
	if guiGetVisible(windows["UCP"]) == true then
	    local file = xmlLoadFile ("news.xml")
    	for _, v in ipairs ( xmlNodeGetChildren ( file ) ) do
       		local row = guiGridListAddRow (grids["news"] )
        	local model = xmlNodeGetAttribute ( v, "name" )
        	guiGridListSetItemText ( grids["news"], row, news, tostring ( model ), false, false )
    	end
    	xmlUnloadFile (file);  -- close file
	end
end

function getTaxis()
	guiGridListClear( grids["taxilist"] )
	if guiGetVisible(windows["UCP"]) == true then
	    local file = xmlLoadFile ("taxi.xml")
    	for _, v in ipairs ( xmlNodeGetChildren ( file ) ) do
       		local row = guiGridListAddRow (grids["taxilist"] )
        	local model = xmlNodeGetAttribute ( v, "name" )
        	guiGridListSetItemText ( grids["taxilist"], row, destination, tostring ( model ), false, false )
    	end
    	xmlUnloadFile (file);  -- close file
	end
end

function getVehiclesList()
	guiGridListClear( grids["vehicles"] )
	if guiGetVisible(windows["UCP"]) == true then
	    local file = xmlLoadFile ("vehicles.xml")
    	for _, v in ipairs ( xmlNodeGetChildren ( file ) ) do
       		local row = guiGridListAddRow (grids["vehicles"])
        	local id = xmlNodeGetAttribute ( v, "id" )
        	local name = getVehicleNameFromModel (tonumber(id))
        	guiGridListSetItemText ( grids["vehicles"], row, vehicles, tostring ( name ), false, false )
    	end
    	xmlUnloadFile (file);  -- close file
	end
end

function loadStats()
	row = guiGridListAddRow(grids["accounts-stats"])
	guiGridListSetItemText(grids["accounts-stats"],row,stats,"Stats unavailable. Try again later",false,false)
	guiGridListSetItemColor(grids["accounts-stats"],row,stats,255,0,0)
end

function updateAccounts(username,lastLogin,playtime)
	
	guiSetText(labels["accounts-username"],"Username: " .. tostring(username))
	guiSetText(labels["accounts-lastlogin"],"Last Logged In:  " .. tostring(lastLogin))
	--guiSetText(labels["accounts-playtime"],playtime)
end
addEventHandler("updateAccounts",root,updateAccounts)

-- Taxy System --> This function prevents debug warnings when the player disconnects while the timer is running.
function fadeCameraDelayed(player) 
      if (isElement(player)) then
            fadeCamera(true, 0.5)
      end
end