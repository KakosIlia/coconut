physics.setWorldGravity(0, 0)
sound.load('laserSound','scenes/spaceGame/laser.mp3')
sound.load('bgMusic','scenes/spaceGame/music.mp3')
sound.play('bgMusic')

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

local bg = display.image('scenes/spaceGame/background.png',0,0,window.width,window.width)
local info = display.text('Score: 0',window.zeroX,window.maxY)
info.anchorX = 1
info.anchorY = 1
info:setFont('scenes/spaceGame/future.ttf',20)

local player = display.imageSheet("scenes/spaceGame/sheet.png", { x = 425, y = 468, width = 93, height = 84 }, 0, 0, 50, 50, "nearest")
player:setAngle(180)
player:setPosition(0, -200)

local direction = { false, false, false, false }
local speed = 300
local health = 3
local score = 0
local bullets = {}
local enemies = {}
local boost = ''

local function spawnEnemy(x, y, hp)
	local self = {}
	if hp < 2 then
		self =
			display.imageSheet("scenes/spaceGame/sheet.png", { x = 425, y = 384, width = 93, height = 84 }, x, y, 50, 50, "nearest")
	else
		self =
			display.imageSheet("scenes/spaceGame/sheet.png", { x = 120, y = 520, width = 104, height = 84 }, x, y, 50, 50, "nearest")
	end
	self.hp = hp
	self:setPhysBody("dynamic")
	self:setFixedRotation(true)
	self:setSensor(true)

	self.moveTimer = timer.performWithDelay(300, function()
		if self.hp > 0 then
			local randomX = math.random(-200, 200)
			local speedY = 200
			self:setLinearVelocity(randomX, speedY)
		end
		if self.hp > 0 and self then
			self:setX(clamp(self:getX(), window.zeroX + 50, window.maxX - 50))
		end
	end, 0)

	table.insert(enemies, self)
end

local spawnEnemies = timer.performWithDelay(math.random(1, 2) * 1000, function()
	spawnEnemy(math.random(window.zeroX+200, window.maxX-200), window.maxY + 50, math.random(0, 3))
end, -1)

local function fire(x)
	local self = display.imageSheet("scenes/spaceGame/sheet.png", { x = 848, y = 738, width = 13, height = 37 }, 0, 0, 10, 30, "nearest")
	self:setPosition(x,player:getY())
	self:setPhysBody("static")
	self.beginContact = function(a, b)
		self.removable = true
		local enemy
		if a ~= self then
			enemy = a
		else
			enemy = b
		end
		if enemy.hp >= 0 then
			enemy.hp = enemy.hp - 1
			enemy.color = {1,0,0,1}
			transition.to(enemy,{time = 200,color = {1,1,1,1},transition = transition.easing.inCubic})
		end
end
	sound.play('laserSound')
	table.insert(bullets, self)
end

onKeyPressed(function(key)
	if key == "a" then
		direction[1] = true
	elseif key == "d" then
		direction[2] = true
	elseif key == "w" then
		direction[3] = true
	elseif key == "s" then
		direction[4] = true
	end

	if key == "h" then
		if boost == 'fire' then
			fire(player:getX())
			fire(player:getX()+25)
			fire(player:getX()-25)
		else
			fire(player:getX())
		end
	end
end)

onKeyReleased(function(key)
	if key == "a" then
		direction[1] = false
	elseif key == "d" then
		direction[2] = false
	elseif key == "w" then
		direction[3] = false
	elseif key == "s" then
		direction[4] = false
	end
end)

loop(function(dt)
	if direction[1] then
		player:setX(player:getX() - speed * dt)
	end
	if direction[2] then
		player:setX(player:getX() + speed * dt)
	end
	if direction[3] then
		player:setY(player:getY() + speed * dt)
	end
	if direction[4] then
		player:setY(player:getY() - speed * dt)
	end

	player:setX(clamp(player:getX(), window.zeroX + 50, window.maxX - 50))
	player:setY(clamp(player:getY(), window.zeroY + 50, 200 - 50))
	info.text = 'Score: ' .. score .. '\n' .. 'Health: ' .. health
end)

loop(function(dt)
	for i = 1, #bullets do
		if bullets[i] and bullets[i]:getY() >= window.maxY then
			bullets[i]:remove()
			table.remove(bullets, i)
		elseif bullets[i] and bullets[i]:getY() < window.maxY then
			bullets[i]:setY(bullets[i]:getY() + 800 * dt)
		end

		if bullets[i] and bullets[i].removable then
			bullets[i]:remove()
			table.remove(bullets, i)
		end
	end
end)

loop(function(dt)
	for i = 1, #enemies do
		if enemies[i] and enemies[i].hp <= 0 then
			enemies[i].moveTimer:cancel()
			local effect = display.imageSheet("scenes/spaceGame/sheet.png", { x =193, y = 240, width = 48, height = 46 }, 0, 0, 0, 0, "nearest")
			effect:setPosition(enemies[i]:getPosition())
			transition.to(effect,{time = 300, width = 50,height = 50, transition = transition.easing.inCubic,onComplete = function()
				transition.to(effect,{time = 300,width = 0,height = 0, onComplete = function()  
					effect:remove()
				end})
			end})
			enemies[i]:remove()
			table.remove(enemies, i)
			score = score + 1
		end
		if enemies[i] and enemies[i]:getY() <= window.zeroX then
			enemies[i].moveTimer:cancel()
			enemies[i]:remove()
			table.remove(enemies, i)
			health = health - 1

			if health <= 0 then
				sceneManager.loadScene('spaceGame_gameOver')
			end
		end
	end
end)
