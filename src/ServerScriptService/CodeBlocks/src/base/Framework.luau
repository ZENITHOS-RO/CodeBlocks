local export = {}
local this = {}
local setup = {}
local essential = {}
local processor = {}

local clonables = {
  Block = nil,
  ProcedureBlock = nil,
  VariableBlock = nil
}

function this.phraseBlockType (connections:{})
  if connections.CanInsert then
    return "VariableBlock"
  elseif connections.CanStack then
    return "ProcedureBlock"
  else
    return "Block"
  end
end

function export:render (To:Frame|{}, Index:number, Block:string, WithBlockData:{}?, Floor:number?)
  return
end

return export