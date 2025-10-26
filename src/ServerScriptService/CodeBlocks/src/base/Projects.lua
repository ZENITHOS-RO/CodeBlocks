--!nocheck
local debugging = true

local export = {}
local this = {}

local Framework = require(script.Parent.Framework)
local current, progresses = 0, 0

function this.loopThruRender (StartingInstance:Frame, CurrentIndex:string, BlockData:{}, Floor:number?, skipOne:boolean?)
	local cBlock = StartingInstance

  	progresses += #BlockData
	for colidx = 1, #BlockData do
		if skipOne and colidx == 1 then continue end

		if debugging then 
			print("Rendering", CurrentIndex.."."..tostring(colidx))
		end

		local cd = BlockData[colidx]
		local block = Framework:render(cBlock, colidx, cd.block, cd.data, Floor)

		if cd.data.stack then
      		progresses += #cd.data.stack
			for tabidx = 1, #cd.data.stack do
				local tablnidx = CurrentIndex.."."..tostring(colidx).."."..tostring(tabidx)
				this.loopThruRender(block, tablnidx, cd.data.stack[tabidx], tabidx, false)
        	current += 1
			end
		end

		cBlock = block
    	current += 1
    	task.wait(0.05)
	end
end

function export:loadProject (ProjectModule:ModuleScript)
	if ProjectModule.ClassName ~= "ModuleScript" then --IsA or typeof() was broken?
		return -2
	end

	local pm = require(ProjectModule)
  	progresses = #pm.codes
	for groupidx = 1, #pm.codes do
		if debugging then 
			print("Rendering Group:", groupidx, "Indexed", groupidx..".1")
		end

		if not pm.codes[groupidx].position then return -10 end
		if not pm.codes[groupidx][1] then return -11 end
		local gc = pm.codes[groupidx]
		local StartingBlock = Framework:render(gc.position, groupidx, gc[1].block, gc[1].data, nil)
		task.defer(function() 
      		this.loopThruRender(StartingBlock, tostring(groupidx), gc, nil, true); 
      		current += 1 
    	end)
	end

  return 0
end

return export
