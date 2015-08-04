
application:setKeepAwake(true)
application:setOrientation(Application.PORTRAIT)

local ios= application:getDeviceInfo() == "iOS"
local android = application:getDeviceInfo() == "Android"

local width = application:getContentWidth()

local function draw_loading()
	loading = Sprite.new()
	
	local logo = Bitmap.new(Texture.new("images/jdbc_games.png", true))
	logo:setPosition((width - logo:getWidth()) * 0.5, 250)
	loading:addChild(logo)
	
	stage:addChild(loading)
end

-- Loading textures and sounds when game is starting
local function preloader()
	stage:removeEventListener(Event.ENTER_FRAME, preloader)
		
	scenes = {"room", "game"}
	sceneManager = SceneManager.new({
		["room"] = RoomScene,
		["game"] = GameScene,
		})
	stage:addChild(sceneManager)
	
	local timer = Timer.new(1000, 1)
	timer:addEventListener(Event.TIMER, 
				function()
					-- Remove loading scene
					stage:removeChild(loading)
					loading = nil
					sceneManager:changeScene(scenes[1])
				end)
	timer:start()
end

draw_loading()
stage:addEventListener(Event.ENTER_FRAME, preloader)