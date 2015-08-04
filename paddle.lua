
Paddle = Core.class(Sprite)

Paddle.PLAYER_ONE = 0xff0000
Paddle.PLAYER_TWO = 0x0000ff

local width = application:getContentWidth()

-- Constructor
function Paddle:init(scene, color)
	self:setAnchorPoint(0.5, 0.5)
	
	print("color", color)
	
	local child
	if (color == Paddle.PLAYER_ONE) then
		child = Bitmap.new("images/paddle_red.png")
	else
		child = Bitmap.new("images/paddle_brillant.png")
	end
	
	self:addChild(child)
	
	scene.world:createRectangle(self, {type="static", friction = 0, restitution = 1} )
	self.body:setPosition(self:getX(), self:getY())
	
end	

-- Move paddle to right or left
function Paddle:move(x)
	local posX = self:getX() + x
	if (posX - self:getWidth() * 0.5 > 10 and posX < width - 10 - self:getWidth() * 0.5) then
		self:setX(posX)
	end
end
