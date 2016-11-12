
GameScene = Core.class(Sprite)

local half_width = application:getContentWidth() * 0.5

local level = {
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					{0,1,1,1,1,1,1,0,0,0,0,0,0,0},
					{0,1,1,1,1,1,1,1,1,1,1,1,1,0},
					{0,1,1,1,1,1,1,1,1,1,1,1,1,0},
					{0,1,1,1,1,1,1,0,1,0,0,0,1,0},
					{0,1,1,1,1,1,1,0,1,0,0,0,1,0},
					{0,1,1,1,1,1,1,0,1,0,0,0,1,0},
					{0,1,1,1,1,1,1,0,1,0,0,0,1,0},
					{0,1,1,1,1,1,1,1,1,1,1,1,1,0},
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0}
					}

-- Constructor
function GameScene:init()
	self:addEventListener("enterEnd", self.enterEnd, self)
end

function GameScene:enterEnd()
	print("Loaded GameScene")
	
	application:setBackgroundColor(0x000000)
	local texture_floor = Texture.new("images/white.png", true)
	local texture_wall = Texture.new("images/crate.png", true)
	local map = Sprite.new()
	self:addChild(map)
	self.map = map
	
	self.squares = {}
	for row=1,#level do
		self.squares[row] = {}
		for col=1,#level[row] do
			local square
			if (level[row][col] == 1) then 
				square = Bitmap.new(texture_floor)
			else
				square = Bitmap.new(texture_wall)
			end
			square:setPosition((col-1)*64,(row-1)*64)
			square:setAnchorPoint(0.5, 0.5)
			map:addChild(square)
			self.squares[row][col] = square
		end
	end
	
	print(#self.squares)
	
	self.worldWidth = map:getWidth()
	self.worldHeight = map:getHeight()
	
	self:createPlayer()
	self:createCamera()
	self:drawController()
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:addEventListener("exitBegin", self.onExitBegin, self)
end

-- Create maze level
function GameScene:createLevel()
	local tilemap = TileMapSingle.new("data/platformer.lua")
	self:addChild(tilemap)
end

-- Create our player
function GameScene:createPlayer()
	local texture = Texture.new("images/enemy01.png", true)
	local player = Bitmap.new(texture)
	player:setScale(0.5)
	player:setAnchorPoint(0.5, 0.5)
	player:setPosition(256,256)
	self.map:addChild(player)
	self.player = player
	
	self.speedX = 0
	self.speedY = 0
end

-- Create camera following player
function GameScene:createCamera()
	local camera = Camera.new(self.map)
	camera:setFollowMode()
	self.camera = camera
	--self.camera:setTarget(self.player:getPosition())
end

-- Update player position
function GameScene:updatePlayer()
	local newX = self.player:getX() + self.speedX
	local newY = self.player:getY() + self.speedY
	
	-- Collision with maze
	self:checkCollision()
	
	self.player:setPosition(newX, newY)
	if (self.player:getX() > half_width-32 and self.player:getX() < self.worldWidth - half_width-32) then
		self.camera:setTarget(self.player:getPosition())
	end
	
	--print("self.map:getX() ", self.map:getX())
	--print("self.player:getX() ", self.player:getX())
end

-- Draw left and right arrows to handle the car player
function GameScene:drawController()
	local texture_left = Texture.new("images/left.png", true)
	local icon_left = Bitmap.new(texture_left)
	icon_left:setPosition(10, 560)
	icon_left:addEventListener(Event.MOUSE_DOWN,
						function(event)
							if (icon_left:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.speedX = -2
								self.speedY = 0
							end
						end)	
	self:addChild(icon_left)
	
	local texture_right= Texture.new("images/right.png", true)
	local icon_right = Bitmap.new(texture_right)
	icon_right:setPosition(110, 560)
	icon_right:addEventListener(Event.MOUSE_DOWN,
						function(event)
							if (icon_right:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.speedX = 2
								self.speedY = 0
							end
						end)
	self:addChild(icon_right)
	
	local texture_up = Texture.new("images/up.png", true)
	local icon_up = Bitmap.new(texture_up)
	icon_up:setPosition(60, 500)
	icon_up:addEventListener(Event.MOUSE_DOWN,
						function(event)
							if (icon_up:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.speedX = 0
								self.speedY = -2
							end
						end)
	self:addChild(icon_up)
	
	local texture_down = Texture.new("images/down.png", true)
	local icon_down = Bitmap.new(texture_down)
	icon_down:setPosition(60, 620)
	icon_down:addEventListener(Event.MOUSE_DOWN,
						function(event)
							if (icon_down:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.speedX = 0
								self.speedY = 2
							end
						end)
	self:addChild(icon_down)
end

-- Collision with maze
function GameScene:checkCollision()
	local tile_width = 64
	local player = self.player
	
	local left_tile = player:getX() / tile_width
	local right_tile = (player:getX() + player:getWidth()) / tile_width
	local top_tile = player:getY() / tile_width
	local bottom_tile = (player:getY() + player:getHeight()) / tile_width
  
	print("left", left_tile)
	print("right", right_tile)
	print("top", top_tile)
	print("bottom", bottom_tile)
	
  --[[return rect1.x < rect2.x + rect2.width and
         rect2.x < rect1.x + rect1.width and
         rect1.y < rect2.y + rect2.height and
         rect2.y < rect1.y + rect1.height]]--
end

-- Update camera and car player
function GameScene:onEnterFrame()
	self:updatePlayer()
	self.camera:update()
end

function GameScene:onExitBegin()
  self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end