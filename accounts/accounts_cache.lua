--[[
	Project: SourceMode
	Version: 1.0
	Last Edited: 25/10/2014 (Jack)
	Authors: Jack
	NOTE: ONLY use this for account data! make sure you encrypt any passwords and so on. Do NOT use for normal storage
	as it can be easily lost if the player formats his hard drive or changes computer.
]]--

local cacheData

addEvent("updatePlayerCache",true)

function loadCacheFile()
	cacheData = xmlLoadFile("@account.xml")
	
	if not cacheData then
		cacheData = xmlCreateFile("@account.xml","account")
		xmlSaveFile(cacheData)
	end
	
	triggerEvent("onCacheFileLoaded",resourceRoot)
	return true
end

function getCacheData(key)
	if not cacheData then
		loadCacheFile()
	end
	
	local nodes = xmlNodeGetChildren(cacheData)
	for k,v in ipairs(nodes) do
		local nodeName = xmlNodeGetName(v)
		if (nodeName == key) then
			return xmlNodeGetValue(v)
		end
	end
	return false
end

function setCacheData(key,value)
	if not cacheData then
		loadCacheFile()
	end
	
	--Check if the key already exists, otherwise create it
	local node = xmlNodeGetChildren(cacheData)
	local found = false
	
	for k,v in ipairs(node) do
		if (xmlNodeGetName(v) == tostring(key)) then
			xmlNodeSetValue(v,tostring(value))
			xmlSaveFile(cacheData) --save here, as we're returning true (and won't reach xmlSaveFile at the bottom of the function)
			return true
		end
	end
	
	--Key doesn't exist, meaning we'll have to create one
	local node = xmlCreateChild(cacheData,tostring(key))
	xmlNodeSetValue(node,tostring(value))
	
	--Save it
	xmlSaveFile(cacheData)
	return true --return true anyways.
end

function updatePlayerDetails(username,password,remember)
	if remember then
		setCacheData("username",username)
		setCacheData("password",password)
		setCacheData("encrypted","true")
		setCacheData("remember","true")
	else
		setCacheData("username","")
		setCacheData("password","")
		setCacheData("encrypted","false")
		setCacheData("remember","false")
	end
end
addEventHandler("updatePlayerCache",root,updatePlayerDetails)