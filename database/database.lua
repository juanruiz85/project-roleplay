--[[
	Project: SourceMode
	Version: 1.0
	Last Edited: 25/10/2014 (Jack)
	Authors: Jack
]]--

local connection

function onStart()
	--Make sure we have the database information from settings
	if not (type(mysql.username) == "string") or not (#mysql.username >= 1) then error("[Database] Username required!") end
	--if not (type(mysql.password) == "string") or not (#mysql.password >= 1) then error("[Database] Password required!") end --removed for use without password
	if not (type(mysql.host) == "string") or not (#mysql.host >= 1) then error("[Database] Hostname required!") end
	if not (type(mysql.port) == "number") then mysql.port = 3302 end
	if not (type(mysql.database) == "string") or not (#mysql.database >= 1) then error("[Database] Database name required!") end
	
	--Attempt to create a new connection and connect
	connection = dbConnect("mysql","dbname="..mysql.database..";host="..mysql.host..";autoreconnect=1",tostring(mysql.username),tostring(mysql.password))

	function db_exec ( ... )
		return dbExec ( connection, ... );
	end

	if isElement(connection) then
		outputDebugString("[Database] Connection established.")
		--Creating the DBs
		db_exec ( [[CREATE TABLE IF NOT EXISTS `accountdata` ( `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',  `username` varchar(255) NOT NULL COMMENT 'Player''s account ID',  `name` tinytext NOT NULL COMMENT 'Key name',  `value` text NOT NULL COMMENT 'Key value',  PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;]]);
		db_exec ( [[CREATE TABLE IF NOT EXISTS `accounts` (`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Player''s unique account ID',  `username` varchar(255) NOT NULL COMMENT 'Player''s username',  `password` char(64) NOT NULL COMMENT 'Player''s password (encrypted)',  `email` tinytext COMMENT 'Player''s email',  `serial` char(32) DEFAULT NULL COMMENT 'Player''s serial.',  `banned` tinyint(1) DEFAULT '0' NOT NULL COMMENT 'Is the player''s account banned?', PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1;]]);
		return true
	else
		outputDebugString("[Database] Connection failed.",1)
		return false
	end
end
addEventHandler("onResourceStart",resourceRoot,onStart)

function getConnection()
	return connection or false
end

function forceReconnect()
	if isElement(connection) then
		outputDebugString("[Database] Connection is online, disconnecting...")
		destroyElement(connection)
	end
	
	outputDebugString("[Database] Starting new connection...")
	onStart()
end
