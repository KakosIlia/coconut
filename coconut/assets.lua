local m = {}
local assets = {}
m.add = function(asset, type, name)
	local self = {
		asset = asset,
		type = type,
		name = name,
	}
	table.insert(assets, self)
end

m.get = function(name)
	local inAssets = false
	for k, v in pairs(assets) do
		if v.name == name then
			inAssets = v.asset
		end
	end
	return inAssets
end

return m
