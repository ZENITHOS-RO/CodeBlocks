return function()
	local mod = require(script.Parent.Parent)
	local block = {
		group = "Variables",
		
		--Block (Normal LUA Block), EndBlock (Return Block, ect..), ProcedureBlock (Define function, ect..), VariableBlock (String, Num, ect..)
		--Block // Allow Connection Above: true, Allow Connection Below: true, Can Stack Inside: false, Can Input: false
		--EndBlock // Allow Connection Above: true, Allow Connection Below: false, Can Stack Inside: false, Can Input: false
		--ProcedureBlock // Allow Connection Above: true, Allow Connection Below: true, Can Stack Inside: true, Can Input: false
		--VariableBlock // Allow Connection Above: false, Allow Connection Below: false, Can Stack Inside: false, Can Input: true
		
		render = {
			color = Color3.fromRGB(255, 180, 0),
			size = "AUTO", --AUTO Recommended. use {0,0} (Udim2 Offset only!) for custom scale.
			
			icon = 0, -- Must be a Image ID
			connections = {
				allow_connection_above = true,
				allow_connection_below = true,
				can_stack_inside = false,
				can_input = false,
			},
			
			contents = { -- ROW:COLUMNS
				[1] = {
					[1] = {type = "label", position = "AUTO", text = "Set local variable"},
					[2] = {type = "menu", position = "AUTO", options = function() local list = mod.api.getAllTypes(); table.insert(list, mod.api.getAllClassNames()); table.insert(list, "any"); return list end, selected = "any"},
					[3] = {type = "label", position = "AUTO", text = "to"},
					[4] = {type = "inbox", position = "AUTO", value = nil},
					[5] = {type = "label", position = "AUTO", text = "as"},
					[6] = {type = "textbox", position = "AUTO", placeholder = "NAME"},
				}
			}
		},
		
		onAttemptUpdate = function(blockAttempting) -- For Pre-Validations (PS: This will only fire when a block is attempting to insert inside).
			return true --Always return true if no pre-validation is required.
		end,

		onUpdate = function(blockData) -- For Validations / Automatic Features, ect.. (PS: This do not fire that is not Columns changes).
			local newBlockData = blockData
			local Analysis = {}
			
			local className = blockData.row[1].columns[2].selected
			local c4Input = newBlockData.row[1].columns[4].input
			if string.lower(className) == "string" and c4Input == nil and c4Input ~= mod.MODID..":types.string" then
				newBlockData.row[1].columns[4].input = {mod.MODID..":types.string", ""}
			elseif string.lower(className) == "number" and c4Input == nil and c4Input ~= mod.MODID..":types.number" then
				newBlockData.row[1].columns[4].input = {mod.MODID..":types.number", 1}
			elseif string.lower(className) == "boolean" and c4Input == nil and c4Input ~= mod.MODID..":types.boolean" then
				newBlockData.row[1].columns[4].input = {mod.MODID..":types.boolean", false}
			elseif string.lower(className) == "table" and c4Input == nil and c4Input ~= mod.MODID..":types.table" then
				newBlockData.row[1].columns[4].input = {mod.MODID..":types.table", {}}
			end

			return {
				updateBlockData = newBlockData,
				Analysis = Analysis -- Similar to Roblox Built-in features
			}
		end,
		
		compile = function(blockData) -- Compile this Block to LUA
			--Can return either one string for one line (then skip line) or {string} as place-each-line.
		end,
		
		convert = function(lineData) -- Convert LUA to (Code)Block
			if lineData[1] ~= "local" then return nil end -- If doesn't match, return nil to let Processor continue asking another Block until it matches.
		end,
		
		compact = function(blockData, to) -- Convert LUA to another Language (Cross-Language)
			if to == "C++" then
				-- Do not write anything here for now, this feature is still under planning.
			end
		end,
	}

	mod.api.registry.blocks:build(mod.MODID..":variables.local", block)
	return
end
