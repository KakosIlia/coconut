-- Copyright (c) 2026 IliaKakos2000. Licensed under the MIT License.
local M = {}

local function getAttribute(tag, key)
    local pattern = key .. '%s*=%s*["\'](.-)["\']'
    return tag:match(pattern)
end

function M.parseString(xml_string)
    local result = {
        imagePath = nil,
        sprites = {}
    }

    local root_tag = xml_string:match("<TextureAtlas%s+[^>]->")
    if root_tag then
        result.imagePath = getAttribute(root_tag, "imagePath")
    else
        error("Invalid XML: <TextureAtlas> tag not found.")
    end

    for sub_tag in xml_string:gmatch("<SubTexture%s+[^>]->") do
        local name = getAttribute(sub_tag, "name")
        
        if name then
            result.sprites[name] = {
                x = tonumber(getAttribute(sub_tag, "x")),
                y = tonumber(getAttribute(sub_tag, "y")),
                width = tonumber(getAttribute(sub_tag, "width")),
                height = tonumber(getAttribute(sub_tag, "height"))
            }
        end
    end

    return result
end

function M.parseFile(file_path)
    local file, err = io.open(file_path, "r")
    if not file then 
        error("Could not open file: " .. tostring(err)) 
    end
    
    local content = file:read("*all")
    file:close()
    
    return M.parseString(content)
end

return M
