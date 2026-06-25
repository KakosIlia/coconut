local m = {}

m.parse = function(data)
    local vertices = {}
    local face_vertices = {}
    local edges = {}
     
    local vIndex = 1
    local edge_keys = {}

    for line in string.gmatch(data,"[^\r\n]+") do 
        if line:sub(1, 2) == "v " then
            vertices[vIndex] = {}
            local valueCount = 1
            local keys = {'x','y','z'}
            for value in string.gmatch(line,"%S+") do
                if value ~= 'v' then
                    vertices[vIndex][keys[valueCount]] = tonumber(value)
                    valueCount = valueCount + 1
                end
            end
            vIndex = vIndex + 1

        elseif line:sub(1, 2) == "f " then
            local face_vertices = {}
            
            for vertex_info in string.gmatch(line, "%S+") do
                if vertex_info ~= 'f' then
                    local v_idx = vertex_info:match("^(%d+)")
                    table.insert(face_vertices, tonumber(v_idx))
                end
            end
            
            local count = #face_vertices
            for i = 1, count do
                local v1 = face_vertices[i]
                local v2 = face_vertices[(i % count) + 1]
                
                local p1, p2 = math.min(v1, v2), math.max(v1, v2)
                local edge_id = p1 .. "-" .. p2
                
                if not edge_keys[edge_id] then
                    edge_keys[edge_id] = true
                    table.insert(edges, {p1, p2})
                end
            end
        end
    end

    local resTable = {vertices,face_vertices,edges}
    return resTable
end


return m