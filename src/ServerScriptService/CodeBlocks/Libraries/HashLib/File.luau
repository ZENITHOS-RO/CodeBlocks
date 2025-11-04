local export = {}
local HLS = require(script.Parent)
local RS = game:GetService("RunService")
local dbg = false

function export.toSHA256(repo:Folder)
	local desc = repo:GetDescendants()

	local hashes = [[]]
	for _, item in ipairs(desc) do
		
		if item:IsA("ModuleScript") or item:IsA("Script") or item:IsA("LocalScript") then
			if dbg and RS:IsEdit() then
				hashes = hashes.."{name:"..item.Name..",class:"..item.ClassName..",code:"..item.Source.."},"
			else
				hashes = hashes.."{name:"..item.Name..",class:"..item.ClassName..",code:not_plugin},"
			end
		else
			hashes = hashes.."{name:"..item.Name..",class:"..item.ClassName.."},"
		end
		
	end
	
	print(hashes)
	return HLS.sha512(hashes)
end

return export