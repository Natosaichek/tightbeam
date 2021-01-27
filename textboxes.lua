local utf8 = require("utf8")

Textbox = {text = "", textcolor = {}, bgcolor = {}, focuscolor = {}, x = 0, y = 0, width = 0, height = 0, focussed = false, visible = true}

Textboxes = {boxes = {}}

function Textboxes.addTextbox(t)
	table.insert(Textboxes.boxes,t)
end

function Textboxes.create(t)
	tb = Textbox:create(t)
	Textboxes.addTextbox(tb)
	return tb
end

function Textboxes.getTextboxes()
	return Textboxes.boxes
end

function Textbox:create(tb)
	tb = tb or {}
	setmetatable(tb, self)
    self.__index = self
	return tb
end

function Textbox:setText(text)
	self.text = text
end
function Textbox:setTextcolor(text)
	self.textcolor = color
end
function Textbox:setBgColor(color)
	self.bgcolor = color
end
function Textbox:setFocusColor(color)
	self.focuscolor = color
end
function Textbox:getGeometry()
	return self.x,self.y,self.width,self.height
end
function Textbox:focus()
	self.focussed = true
end
function Textbox:unfocus()
	self.focussed = false
end
function Textbox:show()
	self.visible = true
end
function Textbox:hide()
	self.visible = false
end
function Textbox:render()
	if self.focussed then 
		love.graphics.setColor(self.focuscolor)
	else
		love.graphics.setColor(self.bgcolor)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(self.textcolor)
	love.graphics.print(self.text, self.x, self.y)
end

function Textboxes.draw()
	for i,tb in ipairs(Textboxes.boxes) do
		if tb.visible then
			if mouseinBox(tb.x,tb.y,tb.width,tb.height) then
				tb:focus()
			else
				tb:unfocus()
			end
			tb:render()
		end
	end
end

function love.textinput(newtext)
	-- only operable if we're typing in a textbox.  Textbox must have focus.
	for i,tb in ipairs(Textboxes.getTextboxes()) do
		if tb.focussed then 
			tb:setText(tb.text..newtext)
		end
	end	
end

function love.keypressed(key)
    if key == "backspace" then
    	for i,tb in ipairs(Textboxes.getTextboxes()) do
			if tb.focussed then 
				local rawtext = tb.text
		        -- get the byte offset to the last UTF-8 character in the string.
		        local byteoffset = utf8.offset(rawtext, -1)
		        if byteoffset then
		            -- remove the last UTF-8 character.
		            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
		            rawtext = string.sub(rawtext, 1, byteoffset - 1)
		        end
		        tb:setText(rawtext)
		    end
		end
    end
end

