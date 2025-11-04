local export = {}
local this = {}

local Mods = {}
local Blocks = {}
local Types = {}
local ClassNames = {}

local registry = {}
export.regidstry = registry

local tempRecord = {
  blocks = 0
}

function registry:buildBlock(blockID:string, blockData:{}) -- The Most Common One
  --AUTOMATIC VALIDATION ADDING SOON--
  Blocks[blockID] = blockData
  tempRecord.blocks += 1
end

function registry:addTypes(blockID:string, blockData:{}) -- The Most Common One
  --AUTOMATIC VALIDATION ADDING SOON--
  Blocks[blockID] = blockData
  tempRecord.blocks += 1
end

function registry.doModExist(modid:string)
  if Mods[modid] then
    return true
  else
    return false
  end
end

function export.getAllBlocks()
  return Blocks
end

function export.getAllTypes()
  return Types
end

function export.getAllClassNames()
  return ClassNames
end

function this.loadAllMods()
    for _, mod in pairs(script:GetChildren()) do
      if mod.ClassName == "ModuleScript" then

        local ModData = require(mod)
        
        for _, modClass in pairs(mod:GetDescendants()) do
          if modClass:IsA("ModuleScript") then

            require(modClass)()

          else

            continue

          end
        end

        ModData["Records"] = tempRecord
        Mods[ModData.NAME] = ModData

        tempRecord = {
          blocks = 0
        }

      else

        warn("CodeBlocks.ModCentral: Non-ModuleScript found in Mods folder <"..mod.Name..">, skipping..")

      end
    end

    return 0
end

function export:reload() --Will only be called by CoreProcessor when CB is lunched or user called a Force Reload.
  Mods = {}
  Blocks = {}
  return this.loadAllMods()
end

function export:unload()
  Mods = nil
  Blocks = nil
end

export.libraries = script.Parent:WaitForChild("Libraries")
return export