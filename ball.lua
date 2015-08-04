
Ball = Core.class(Sprite)

local width = application:getContentWidth()
local height = application:getContentHeight()

-- Constructor
function Ball:init(scene)

	local ball = Bitmap.new("images/ball_blue.png")
	ball:setScale(0.3)
	ball:setPosition(width * 0.5, height * 0.5)
	scene:addChild(self)
	scene.world:createCircle(ball, {type = "dynamic"})
	ball.body:setPosition(ball:getX(), ball:getY())
	self:addChild(ball)
	self.ball = ball
end

-- Go back to starting position
function Ball:start()
	self.ball.body:applyLinearImpulse(20, 15, 0, 0)
end

-- Ball is moving
function Ball:update()
	local ball = self.ball
	ball:setPosition(ball.body:getPosition())
end