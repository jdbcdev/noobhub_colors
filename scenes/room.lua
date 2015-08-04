
RoomScene = Core.class(Sprite)

local SERVER_HOST = "192.168.1.10"
local SERVER_PORT = 1337

RoomScene.PLAYER_ONE = 1
RoomScene.PLAYER_TWO = 2

-- Constructor
function RoomScene:init()
		
	hub = noobhub.new({ server = SERVER_HOST; port = SERVER_PORT; });
	self:subscribe_public()
	
	self:addEventListener("enterEnd", self.enterEnd, self)
end

function RoomScene:enterEnd()
	
	local font = TTFont.new("fonts/ptarm.ttf", 20)
	self.text = TextField.new(font, "Waiting")
	self:addChild(self.text)
	
	self:first_message()
end

-- Publish first message (I am here)
function RoomScene:first_message()

	local timer = Timer.new(1000, 1)
	timer:addEventListener(Event.TIMER,  function()
		
	if (not self.playerid) then
		
		local channel = md5(  math.floor(os.timer() * 1000) ..  math.random())
		self.playerid = RoomScene.PLAYER_ONE
		
		hub:publish({
				message = {
							action  =  "ping",
							playerid = self.playerid,
							channel = channel
					}
		});
	end
		
end);
timer:start()
end

-- Subscribe to public channel looking for Player 2
function RoomScene:subscribe_public()
	
	hub:subscribe({
        channel = "public";
        callback = function(message)  
                print("public message received  = "..json.encode(message)); 
												
				local message_playerid = message.playerid
				print(message_playerid, self.playerid)
				
				if (message_playerid == self.playerid) then
					print("This is my message. Ignoring message")
				else
					local channel = message.channel
					
					print("por aqui")
										
					if (not self.playerid) then
						self.playerid = RoomScene.PLAYER_TWO
					end
					
					-- Publish again to provide local userid
					hub:publish({
					message = {
							action  =  "ping",
							playerid = self.playerid,
							channel = channel
						}
					});
					
					hub:unsubscribe() -- Unsubscribe from public channel
					
					--application:setBackgroundColor(self.color)
					sceneManager:changeScene(scenes[2], 
										1, 
										SceneManager.crossfade, 
										easing.linear, 
										{userData = {playerid = self.playerid, channel = channel} 
										})
				end
        end;
	})
end