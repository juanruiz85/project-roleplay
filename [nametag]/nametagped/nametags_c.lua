local nametags = { }

-- settings
local _max_distance = 120 -- max. distance it's visible
local _min_distance = 7.5 -- minimum distance, if a player is nearer his nametag size wont change
local _alpha_distance = 20 -- nametag is faded out after this distance
local _nametag_alpha = 170 -- alpha of the nametag (max.)
local _bar_alpha = 120 -- alpha of the bar (max.)
local _scale = 0.2 -- change this to keep it looking good (proportions)
local _nametag_textsize = 0.6 -- change to increase nametag text
local _chatbubble_size = 15
local _bar_width = 40
local _bar_height = 6
local _bar_border = 1.2

-- adjust settings
local _, screenY = guiGetScreenSize( )
real_scale = screenY / ( _scale * 800 ) 
local _alpha_distance_diff = _max_distance - _alpha_distance
local localPlayer = getLocalPlayer( )

addEventHandler( 'onClientRender', root, 
	function( )
		-- get the camera position of the local player
		local cx, cy, cz = getCameraMatrix( )
		local dimension = getElementDimension( localPlayer )
		local interior = getElementInterior( localPlayer )
		
		for key, player in pairs( getElementsByType( 'ped' )  ) do
			if isPedDead(player) ~= true then
				if getElementDimension( player ) == dimension and getElementInterior( player ) == interior and isElementOnScreen( player ) then
					local px, py, pz = getElementPosition( player )
					local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
					if distance <= _max_distance and ( getElementData( localPlayer, "collisionless" ) or isLineOfSightClear( cx, cy, cz, px, py, pz, true, true, false, true, false, false, true, getPedOccupiedVehicle( player ) ) ) then
						local dz = 1 + 2 * math.min( 1, distance / _min_distance ) * _scale
						if isPedDucked( player ) then
							dz = dz / 2
						end
						pz = pz + dz
						local sx, sy = getScreenFromWorldPosition( px, py, pz )
						if sx and sy then
							local cx = sx
							
							-- how large should it be drawn
							distance = math.max( distance, _min_distance )
							local scale = _max_distance / ( real_scale * distance )
							
							-- visibility
							local alpha = ( ( distance - _alpha_distance ) / _alpha_distance_diff )
							local bar_alpha = ( ( alpha < 0 ) and _bar_alpha or _bar_alpha - (alpha * _bar_alpha) ) * ( getElementData( localPlayer, "collisionless" ) and 1 or getElementAlpha( player ) / 255 )
							if bar_alpha > 0 then
								local nametag_alpha = bar_alpha / _bar_alpha * _nametag_alpha

								local r, g, b = 0,255,0
								
								namebot = getElementData(player, "namebot")
								if  namebot == false then
									namebot = "bot"
								end
								dxDrawText(namebot, sx, sy, sx, sy, tocolor( r, g, b, nametag_alpha ), scale * _nametag_textsize, 'default', 'center', 'bottom' )
								
								-- draw the health bar
								local width, height = math.ceil( _bar_width * scale ), math.ceil( _bar_height * scale )
								local sx = sx - width / 2
								local border = math.ceil( _bar_border * scale )
								
								-- draw the armor bar
								local armor = math.min( 100, getPedArmor( player ) )
								if armor > 0 then
									
									-- outer background
									dxDrawRectangle( sx, sy, width, height, tocolor( 0, 0, 0, bar_alpha ) )
									
									-- get the colors
									local r, g, b = 255, 255, 255
									
									-- inner background, which fills the whole bar but is somewhat transparent
									dxDrawRectangle( sx + border, sy + border, width - 2 * border, height - 2 * border, tocolor( r, g, b, 0.4 * bar_alpha ) )
									
									-- fill it with the actual armor
									dxDrawRectangle( sx + border, sy + border, math.floor( ( width - 2 * border ) / 100 * getPedArmor( player ) ), height - 2 * border, tocolor( r, g, b, bar_alpha ) ) 
									
									-- set the nametag below
									sy = sy + 1.2 * height
								end
								
								-- outer background
								dxDrawRectangle( sx, sy, width, height, tocolor( 0, 0, 0, bar_alpha ) )
								
								-- get the colors
								local health = math.min( 100, getElementHealth( player ) )
								local r, g, b = 255 - 255 * health / 100, 255 * health / 100, 0
								
								-- inner background, which fills the whole bar but is somewhat transparent
								dxDrawRectangle( sx + border, sy + border, width - 2 * border, height - 2 * border, tocolor( r, g, b, 0.4 * bar_alpha ) )
								
								-- fill it with the actual health
								dxDrawRectangle( sx + border, sy + border, math.floor( ( width - 2 * border ) / 100 * health ), height - 2 * border, tocolor( r, g, b, bar_alpha ) )
								
							end
						end
					end
				end
			end
		end
	end
)