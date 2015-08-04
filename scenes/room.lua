
RoomScene = Core.class(Sprite)

local SERVER_HOST = "192.168.1.10"
local SERVER_PORT = 1337

-- Constructor
function RoomScene:init()
	self.userid = md5(  math.floor(os.timer() * 1000) ..  math.random()) -- Userid used to create the private channel
		
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
	
	if (not self.color) then
		
		self.color = Paddle.PLAYER_ONE -- RED
		
		hub:publish({
				message = {
							action  =  "ping",
							userid = self.userid,
							color = self.color
					}
		});
	end
		
end);
timer:start()
end

-- Subscribe to public channel looking for available player
function RoomScene:subscribe_public()

	local userid = self.userid
	
	hub:subscribe({
        channel = "public";
        callback = function(message)  
                print("public message received  = "..json.encode(message)); 
				
				local message_userid = message.userid -- Message userid
				if (userid and (not (userid == message_userid))) then
				
					local color = message.color
					if (not color) then
						self.color = Paddle.PLAYER_TWO
					end
					
					-- userid is remote
					self.remote_userid = message_userid
					
					-- Publish again to provide local userid
					hub:publish({
					message = {
							action  =  "ping",
							userid = userid
						}
					});
					
					hub:unsubscribe() -- Unsubscribe from public channel
					--self:subscribe_private(message_userid)
					
					--self.text:setText("Remote Player ".. message_userid)
					
					sceneManager:changeScene(scenes[2], 
										1, 
										SceneManager.crossfade, 
										easing.linear, 
										{userData = {color = self.color, remote_userid = self.remote_userid} 
										})
					
					-- Ready to play
					--self:publish_ready()
				else
					print("Ignoring message")
				end
        end;
	})
end

-- Subscribe to private channel
--[[
function RoomScene:subscribe_private(userid)
	hub:subscribe({
        channel = userid;
        callback = function(message)  
                --print("private message received  = "..json.encode(message)); 
				
				if (self.consume_message) then
					self:consume_message(message)
				end
				
        end;
	})
end
]]--

-- Publish to private channel
function RoomScene:publish_ready()
	hub:publish({
					message = {
							action  =  "ready",
							userid = self.userid
						}
					});
end

function RoomScene:consume_message(message)

	if (message and message.action == "ready") then
		sceneManager:changeScene(scenes[2], 
										1, 
										SceneManager.crossfade, 
										easing.linear, 
										{userData = {userid = userid, color = self.color, remote_userid = self.remote_userid} 
										})
	end
end