-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local utf8 = require("utf8")

function createTextDialog( placeholder, listener)
    local x,y = 0,0
    local width,height = window.width/4,window.height/12
	local bg = display.rect(x, y, width, height)
	bg:setColor("#1d1d1d")

	local ph = display.text(placeholder, x - width / 2, y)
	ph:setColor("#636363")
	ph.anchorX = 1
	bg:insert(ph)

	local writedData = ""
	local textfield = display.text("", x - width / 2, y)
	textfield.anchorX = 1
	bg:insert(textfield)

	local function textInputListener(text)
		writedData = writedData .. text
		textfield.text = writedData

		if string.len(writedData) > 0 then
			ph.visible = false
		else
			ph.visible = true
		end
	end

	local function keyPressedListener(key)
        textfield:setRenderRect(bg:getX(), bg:getY(), bg:getWidth(), bg:getHeight())
		if key == "backspace" then
			local byteoffset = utf8.offset(writedData, -1)
			if byteoffset then
				writedData = string.sub(writedData, 1, byteoffset - 1)
				textfield.text = writedData
			end

			if string.len(writedData) > 0 then
				ph.visible = false
			else
				ph.visible = true
			end
		end

		if key == "return" then
			listener(textfield.text)
			bg:remove()
			textfield:remove()
			ph:remove()
		end

        if key == "escape" then
            bg:remove()
			textfield:remove()
			ph:remove()
        end
	end

	onTextInput(textInputListener)
	onKeyPressed(keyPressedListener)

	return true
end

--true
function scrollDialog(x, y, width, height, data,listener)
	local bg = display.rect(x, y, width, height)
	bg:setColor("#1d1d1d")

	local content = display.node()
	content.x = x
	content.y = y
	bg:insert(content)

	local t = data

	local currentY = bg:getY() + bg:getHeight() / 2 - 25
	for k,v in pairs(t) do
		local object = display.rect(x, currentY, width-20, 50)
		object:setRenderRect(x, y, width, height)
        object.layer = 1
		content:insert(object)
		object:setColor({ 0.2, 0.2, 0.2 })
        object:onTouched(function(e)
            listener(i)
            bg:remove()
        end)
        
        local text = display.text(tostring(k .. ":" .. v),x,currentY)
        content:insert(text)
        text.layer = 2
        text:setRenderRect(x,y,width,height)

		currentY = currentY - 55
	end

	local wheelMovedEvent = onWheelMoved(function(x, y)
		if y == 1 and content:getY() >= y then
			content:setY(content:getY() - y * 20)
		end
        local contentHeight = #t*50
		if y == -1 and content:getY() <= contentHeight-height+55 then
			content:setY(content:getY() - y * 20)
		end
	end)
end
