
-- Generate userid for local player
local userid = md5(  math.floor(os.timer() * 1000) ..  math.random()) -- Userid used to create private channel
local remote_userid = nil

local color;
local font = TTFont.new("fonts/ptarm.ttf", 20)
--[[local texture = Texture.new("images/button_blue.png", true)
local bitmap = Bitmap.new(texture)
local button = Button.new(bitmap, bitmap, font, "Publish" )
button:setPosition(100, 200)

button:addEventListener("click", function()
																		
									hub:publish({
										message = {
												action  =  "ping",
												userid = userid,
												--data = "available"
										}
									});
								 end)
stage:addChild(button)
]]--

local text = TextField.new(font, userid)
text:setPosition(10, 50)
text:setText(userid)
stage:addChild(text)

-- Subscribe to private channel
function subscribe_private(userid)
	hub:subscribe({
        channel = userid;
        callback = function(message)  
                print("private message received  = "..json.encode(message)); 
				
				-- Start playing here
				--button:setVisible(false)
								
				--print("color", color)
				--application:setBackgroundColor(color)
				-- Update game state
				
        end;
	})
end



-- Publish to private channel
function publish()
	hub:publish({
					message = {
							action  =  "ping",
							--description = "Ready",
							--color = 0xff0000,
							userid = userid
						}
					});
end

-- Subscribe to public channel looking for available player
function subscribe_public()
	hub:subscribe({
        channel = "public";
        callback = function(message)  
                print("public message received  = "..json.encode(message)); 
				
				local message_userid = message.userid -- Message userid
				--print("userid", userid)
				--print("message_userid", message_userid)
				
				if (userid and (not (userid == message_userid))) then
					-- userid is remote
					
					--remote_userid = message_userid
					
					-- Change background color
					local message_color = message.color
					if (message_color) then
						application:setBackgroundColor(message_color)
						
						hub:publish({
						message = {
								action  =  "ping",
								userid = userid,
								color = 0x0000ff
						}
						});
					else
						--application:setBackgroundColor(0x0000ff)
					end
					
					text:setTextColor(0xffffff)
														
					hub:unsubscribe() -- Unsubscribe from public channel
					subscribe_private(message_userid)
					
					-- Ready to play
					publish()
				else
					print("Ignoring own message")
				end
        end;
	})
end


latencies = {}

hub = noobhub.new({ server = "192.168.1.12"; port = 1337; });

subscribe_public()

-- Send "I am here" message
local timer = Timer.new(1000, 1)
timer:addEventListener(Event.TIMER,  function()
	
	if (not color) then
		
		color = 0xff0000 -- RED
		print("First message", color)
		
		hub:publish({
				message = {
							action  =  "ping",
							userid = userid,
							color = color
					}
		});
	end
		
end);
timer:start()



