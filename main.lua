TILESIZE = 10
SPEED = 20
SPEEDINV = 1/SPEED
MAXWIDTH = math.floor(love.graphics.getWidth() / TILESIZE)
MAXHEIGHT = math.floor(love.graphics.getHeight() / TILESIZE)

accumulatedDelta = 0

math.randomseed(os.time())
-- gotta do this to make stuff actually random -_-
math.random()

function getRandomCoord()
	xCoord = math.random(1, MAXWIDTH)
	yCoord = math.random(1, MAXHEIGHT)

	if x == MAXWIDTH/2 and y == MAXHEIGHT/2 then
		coord = getRandomCoord()
	else
		coord = {x = xCoord, y = yCoord}
	end

	return coord
end

apple = getRandomCoord()

snake = {
	velocity = {x = 0, y =  -1},
	body = {},
	length = 10,
	trudCount = 0
}

truds = {}

function love.load()
	love.graphics.setBackgroundColor(0,0,0)
end

function love.keypressed(key)
	if love.keyboard.isDown("left") and not(snake.velocity.x == 1)then
		snake.velocity = {x = -1, y =  0}
    end
    if love.keyboard.isDown("right") and not(snake.velocity.x == -1) then
		snake.velocity = {x = 1, y =  0}
    end
    if love.keyboard.isDown("up") and not(snake.velocity.y == 1) then
		snake.velocity = {x = 0, y =  -1}
    end
    if love.keyboard.isDown("down") and not(snake.velocity.y == -1) then
		snake.velocity = {x = 0, y =  1}
    end
end

function love.update(dt)
	if accumulatedDelta < SPEEDINV then --if we aren't at an update yet, accumulate the time
		accumulatedDelta = accumulatedDelta + dt
	else --otherwise, move the snake forward, remove the last, reset the accumulated time
		if #snake.body == 0 then
			table.insert(snake.body, {x = MAXWIDTH / 2 , y = MAXHEIGHT / 2 })
		else 
			bodySquare = snake.body[#snake.body]
			newCoord = {x = bodySquare.x + snake.velocity.x, y = bodySquare.y + snake.velocity.y}
			
			if isValid(newCoord) then --handle snake building and trud creating
				table.insert(snake.body, newCoord)

				if #snake.body > snake.length then
					if snake.trudCount > 0 then
		    			table.insert(truds, snake.body[1])
		    			snake.trudCount = snake.trudCount - 1
		    		end

					table.remove(snake.body, 1)
				end

				--then handle item events (trud eating, to be clear)
				if (apple and isOverlapping(newCoord, apple)) then
    				apple = nil
    				snake.length = snake.length + 5
    				snake.trudCount = snake.trudCount + 5
    			end

    			for i=1, #truds, 1 do
    				if isOverlapping(newCoord, truds[i]) then
    					table.remove(truds, i)
    					snake.length = snake.length + 5
    					snake.trudCount = snake.trudCount + 5
    					break
    				end
    			end
			else 
				print('ur ded')--todo make dead
				love.event.quit()
			end
		end
		accumulatedDelta = 0
	end
end

function love.draw( )
--draw apple
	if apple then
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle("fill", apple.x * TILESIZE, apple.y * TILESIZE, TILESIZE, TILESIZE)
	end

--draw snake
	for i=1, #snake.body, 1 do
		if i == #snake.body then
			love.graphics.setColor(224, 109, 27)
		else
			love.graphics.setColor(0, 255, 0)
		end
		love.graphics.rectangle( "fill", snake.body[i].x * TILESIZE, snake.body[i].y * TILESIZE, TILESIZE, TILESIZE)
	end

--draw truds
	love.graphics.setColor(156, 93, 26)
	for i=1, #truds, 1 do
		love.graphics.rectangle( "fill", truds[i].x * TILESIZE, truds[i].y * TILESIZE, TILESIZE, TILESIZE)
	end

end

function isValid(coord)
	if coord.x > MAXWIDTH or coord.x < 0 or coord.y > MAXHEIGHT or coord.y < 0 then --bounds check
		return false
	else 
		--self consumption check
		for i = 1, #snake.body, 1 do
			if isOverlapping(coord, snake.body[i]) then
				return false
			end
		end
		return true
	end
end

function isOverlapping(coord1, coord2)
	if coord1.x == coord2.x and coord1.y == coord2.y then
		return true
	else
		return false
	end
end

--for debug
function printCoord(coord)
	print("x= " .. coord.x .. " y= " .. coord.y)
end


