
Room = Core.class(Sprite)

-- Constructor
function Room:init()
	self.userid = md5(  math.floor(os.timer() * 1000) ..  math.random()) -- Userid used to create the private channel
	self.hub = noobhub.new({ server = "192.168.1.12"; port = 1337; });
	
	self:addEventListener("enterEnd", self.enterEnd, self)
end

function Room:enterEnd()
	
	
	-- Subscribe to public channel
	self:subscribe_public()
	
	local font = TTFont.new("fonts/ptarm.ttf", 20)
	self.text = TextField.new(font, "Waiting")
	self:addChild(self.text)
	
	-- Send message with userid to the public channel
	local timer = Timer.new(1000, 1)
	timer:addEventListener(Event.TIMER,  
		function()
			local hub = self.hub
			hub:publish({
						message = {
									action  =  "ping",
									userid = self.userid
							}
			});
		end);
	timer:start()
	
	
end

-- Subscribe to public channel looking for available player
function Room:subscribe_public()

	local hub = self.hub
	local userid = self.userid
	
	hub:subscribe({
        channel = "public";
        callback = function(message)  
                print("public message received  = "..json.encode(message)); 
				
				local message_userid = message.userid -- Message userid
				if (userid and (not (userid == message_userid))) then
					-- userid is remote
					remote_userid = message_userid
												
					-- Publish again to provide local userid
					hub:publish({
					message = {
							action  =  "ping",
							userid = userid
						}
					});
					
					hub:unsubscribe() -- Unsubscribe from public channel
					subscribe_private(message_userid)
					
					-- Ready to play
					publish_ready()
				else
					print("Ignoring message")
				end
        end;
	})
end

-- Publish to private channel
function Room:publish_ready()
	hub:publish({
					message = {
							action  =  "ping",
							description = "Ready",
							userid = userid
						}
					});
end