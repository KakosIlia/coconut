local m = {}

m.textField = function(x,y,width,height,text,oldText)
    local self = display.rect(x,y,width,height)
    self:setColor('#242424')

    local txt = display.formattedText(text,0,0,self:getWidth())
    txt:setFont('default.ttf',20)
    self:insert(txt)
end

return m