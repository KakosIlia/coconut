local tags = {}

function tags.removeAllWithTag(tag)
	for key, value in pairs(sceneManager.currentScene.data) do
		if v and v.tag and v.tag == tag then
			v:remove()
		end
	end
end

return tags
