local export = {}
local this = {}

local current, progresses = 0, 0

function this.loopThruRender (StartingInstance:Frame, CurrentIndex:string, BlockData:{})
  for colidx, coldata in pairs(BlockData) do
      --render
      if coldata["stack"] then
        for tabidx, tabdata in pairs(coldata["stack"] do
          
        end
      end
  end
end

function export:loadProject (ProjectModule:ModuleScript)
  if typeof(ProjectModule) ~= "ModuleScript" then
  
  end

  local pm = require(ProjectModule)
  for groupidx, groupdata in pairs(pm.codes) do
    if not BlockData["position"] then return -2 end
    --call render for first Block

  end
end

return export
