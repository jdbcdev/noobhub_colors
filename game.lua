
require "box2d"
require "accelerometer"

GameScene = Core.class(Sprite)

local width = application:getContentWidth()
local height = application:getContentHeight()

-- Create a rectangle shape
local function create_rect(color, width, height)

	width = width or 100
	height = height or 25
	
	local shape = Shape.new()
	shape:setFillStyle(Shape.SOLID, color)
	shape:setLineStyle(1, 0x000000, 1)
	shape:drawRoundRectangle(width, height, 0)
	
	return shape
end

--[[
-- Create a circle shape
local function create_circle(color, size)
	local shape = Shape.new()
	shape:setFillStyle(Shape.SOLID, color)
	shape:drawCircle(size, size, size)
	
	return shape
end
]]--

-- Constructor
function GameScene:init(data)
	
	print(json.encode(data))
	
	if (data) then
		self.userid = data.userid
		self.color = data.color
		self.remote_userid = data.remote_userid
	end
	
	
	self:draw_background()
	
	self.world = b2.World.new(0, 0, true)
	
	-- Set up paddles
	self.players = {} -- Two players
	local config = {type = "static"}
	
	local paddle_one = Paddle.new(self, Paddle.PLAYER_ONE)
	paddle_one:setPosition(150, 30)
	self:addChild(paddle_one)
	self.players[1] = paddle_one
	
	local paddle_two = Paddle.new(self, Paddle.PLAYER_TWO)
	paddle_two:setPosition(200, height - paddle_two:getHeight() - 30)
	self:addChild(paddle_two)
	self.players[2] = paddle_two
	
	if (self.color == Paddle.PLAYER_ONE) then
		self.paddle = self.players[1]
		self.paddle2 = self.players[2]
	else
		self.paddle = self.players[2]
		self.paddle2 = self.players[1]
	end
		
	self:addEventListener("enterEnd", self.enterEnd, self)
end

function GameScene:enterEnd()
	
	--self:debug_enabled()
	self.paused = false
	
	self:draw_border()
	self:subscribe_private(self.remote_userid)
	
	accelerometer:start()
	
	local ball = Ball.new(self)
	self.ball = ball	
	ball:start()
	
	--self:drawHUD()
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	--self.world:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	
end

function GameScene:draw_background()
	
	local bg_width = width + 60
	local bg_height = height + 90
	
	local texture = Texture.new("images/pyrite.jpg", true, {wrap = Texture.REPEAT})
	local bg = Shape.new()
	bg:setFillStyle(Shape.TEXTURE, texture)    
	bg:beginPath(Shape.NON_ZERO)
	bg:moveTo(-30,-45)
	bg:lineTo(bg_width, -45)
	bg:lineTo(bg_width, bg_height)
	bg:lineTo(-30, bg_height)
	bg:lineTo(-30, -45)
	bg:endPath()
	
	self:addChild(bg)
end

function GameScene:draw_border()

	local world = self.world
		
	local border_left = create_rect(0x000000, 10, height + 90)
	border_left:setAnchorPoint(0.5, 0.5)
	border_left:setPosition(0, 400)
	self:addChild(border_left)
	
	local body = world:createBody{type = b2.STATIC_BODY}
	body:setPosition(0, -45)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(10, height + 90)
		
	local fixture = body:createFixture{shape = poly, density = 0, friction = 0, restitution = 1 }
										
	
	local body2 = world:createBody{type = b2.STATIC_BODY}
	body2:setPosition(width, 0)
	local poly2 = b2.PolygonShape.new()
	poly2:setAsBox(10, height + 90)
		
	local fixture2 = body2:createFixture{shape = poly, density = 0, friction = 0, restitution = 1 }
										
end

-- Draw speed and score
function GameScene:drawHUD()

	local score = TextField.new(font, 0)
	score:setTextColor(0xffffff)
	score:setShadow(2, 1, 0xff0000)
	score:setPosition(20, 50)
	self:addChild(score)
	self.score = score
		
end

function GameScene:onEnterFrame()
	if self.paused then
		return
	end
	
	self.world:step(1/60, 8, 3)
	
	local x,y,z = application:getAccelerometer()
	if (not (x == 0)) then
		self.paddle:move(x)
		self:publish_private(x)
	end
	
	--print("update ball")
	local ball = self.ball
	ball:update()
	--self.world:update()
	
end

function GameScene:onMouseDown(event)
	
	local paddle = self.paddle
	if (paddle:getX() < event.x) then
		paddle:move(5)
		self:publish_private(5)
	elseif (paddle:getX() > event.x) then
		paddle:move(-5)
		self:publish_private(5)
	end
	
end

-- Subscribe to private channel
function GameScene:subscribe_private(userid)

	print("private channel", userid)
	
	hub:subscribe({
        --channel = userid;
		channel = "prueba",
        callback = function(message)  
                --print("private message received  = "..json.encode(message)); 
				
				self:consume_message(message)
				
        end;
	})
end

-- Publish message to private channel
function GameScene:publish_private(x)
	hub:publish({
					message = {
							action  =  "moving",
							userid = self.userid,
							x = x * 15
						}
					});
end

-- Consume 'moving' message
function GameScene:consume_message(message)

	--print(json.encode(message))
	if (message and message.action == "moving") then
		--if (not (self.userid == message.userid)) then
			print("here")
			self.paddle2:move(message.x)
		--end
	end
end

function GameScene:onBeginContact(event)
	local bodyA = event.fixtureA:getBody()
	local bodyB = event.fixtureB:getBody()
	
	print("contact")
	
end

-- Debug box2d
function GameScene:debug_enabled()
	local debugDraw = b2.DebugDraw.new()
	self.world:setDebugDraw(debugDraw)
	self:addChild(debugDraw)
end
