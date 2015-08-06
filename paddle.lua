
Paddle = Core.class(Sprite)

local width = application:getContentWidth()

-- Constructor
function Paddle:init(scene, playerid)
	--self:setAnchorPoint(0.5, 0.5)
	
	--print("color", color)
	
	local child
	if (playerid == RoomScene.PLAYER_ONE) then
		child = Bitmap.new("images/paddle_red.png")
	else
		child = Bitmap.new("images/paddle_brillant.png")
	end
	
	self:addChild(child)
	
	child:setPosition(-self:getWidth() * 0.5, -self:getHeight() * 0.5)
	
	scene.world:createRectangle(self, {type="static", friction = 0, restitution = 1} )
	self.body:setPosition(self:getX(), self:getY())
	
end	

-- Move paddle to right or left
function Paddle:move(x)
	local posX = self:getX() + x
	--self:setX(posX)
	
	if (posX - self:getWidth()> 10 and posX < width - 10) then
		self:setX(posX)
	end
end
