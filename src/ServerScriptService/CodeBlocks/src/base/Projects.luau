local export = {}
local this = {}

local current, progresses = 0, 0

function this.loopThruRender (StartingInstance:Frame, CurrentIndex:string, BlockData:{})
  for colidx, coldata in pairs(BlockData) do
      --call render
      if coldata["stack"] then
        for tabidx, tabdata in pairs(coldata["stack"]) do
          this.loopThruRender()
        end
      end
  end
end

function export:loadProject (ProjectModule:ModuleScript)
  if typeof(ProjectModule) ~= "ModuleScript" then
    return 100
  end

  local pm = require(ProjectModule)
  for groupidx, groupdata in pairs(pm.codes) do
    if not groupdata["position"] then return -2 end
    local StartingBlock --call render for first Block
    this.loopThruRender(StartingBlock, tostring(groupidx), groupdata)
  end
end

return export