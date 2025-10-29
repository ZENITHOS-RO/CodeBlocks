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
				can_input = false, -- This will disable Connections.
			},

			floors = { 1 }, --Can Stack must be enabled for this to work.

			contents = { -- FLOOR:ROW:COLUMNS
				[1] = {
					[1] = {
						[1] = { type = "label", position = "AUTO", text = "Define local variable" },
						[2] = {
							type = "menu",
							position = "AUTO",
							options = function()
								local list = mod.api.getAllTypes()
								table.insert(list, mod.api.getAllClassNames())
								table.insert(list, "any")
								return list
							end,
							selected = "any",
						},
						[3] = { type = "input", position = "AUTO", value = nil, placeholder = "VALUE" },
						[4] = { type = "label", position = "AUTO", text = "as" },
						[5] = { type = "textbox", position = "AUTO", placeholder = "NAME" },
					},
				},
			}, --You can use !.. (Start from Left) and ..! (Start from Right) to make it fill the rest of the row automatically.

			--SELF NOTE--
			--INPUTS {2 = 1, 3 = 2, 5 = 3} (Meaning Column 2 is Input 1, Column 4 is Input 2, ect..)

			-- You can add custom options here that can be interacted by user on the Left "Setting" (Icon) button.
			-- (Using Icon Button is due to Roblox Right Click is reserved, therefore RMB is not taken into account.)
			options = {
				--[[ EXAMPLE
				{
					type = "button",
					text = "Example Button",
					onClick = function()
						return {
							updateBlockRender = newBlockRender,
						}
					end,
				},
				]]
			},
		},

		onAttemptUpdate = function(blockAttempting) -- For Pre-Validations (PS: This will only fire when a block is attempting to insert inside).
			return true --Always return true if no pre-validation is required.
		end,

		onUpdate = function(blockData) -- For Validations / Automatic Features, ect.. (PS: This do not fire that is not Columns changes).
			local newBlockData = blockData
			local Analysis = {}

			local className = newBlockData.inputs[1].selected
			local c4Input = newBlockData.inputs[2].value
			if string.lower(className) == "string" and c4Input == nil and c4Input ~= mod.MODID .. ":types.string" then
				newBlockData.row[1][4].input = { mod.MODID .. ":types.string", "" }
			elseif
				string.lower(className) == "number"
				and c4Input == nil
				and c4Input ~= mod.MODID .. ":types.number"
			then
				newBlockData.row[1][4].input = { mod.MODID .. ":types.number", 1 }
			elseif
				string.lower(className) == "boolean"
				and c4Input == nil
				and c4Input ~= mod.MODID .. ":types.boolean"
			then
				newBlockData.row[1][4].input = { mod.MODID .. ":types.boolean", false }
			elseif string.lower(className) == "table" and c4Input == nil and c4Input ~= mod.MODID .. ":types.table" then
				newBlockData.row[1][4].input = { mod.MODID .. ":types.table", {} }
			end

			local NameInput = newBlockData.row[1][6].input
			if not NameInput:match("^[%a_][%w_]*$") then
				table.insert(
					Analysis,
					{ 1, 4, "Invalid variable name format / starting character cannot be a number", 2 }
				)
				--onROW, Column, Message, SeverityLevel (1 = Warning, 2 = Error (>=1 Error = Block Compile Button))
			end

			return {
				updateBlockData = newBlockData,
				updateAnalysis = Analysis, -- Similar to Roblox Built-in features
			}
		end,

		compile = function(blockData) -- Compile this Block to LUA
			local varName = blockData.row[1][6].input or "Var"
			local selectedClass = blockData.row[1][2].selected or "any"
			local Value = blockData.row[1][4].selected or nil

			if selectedClass then
				return 0, { "local " .. varName .. ":" .. selectedClass .. " = " .. mod.api.convertVariable(Value) }
			else
				return 0, { "local " .. varName .. " = " .. mod.api.convertVariable(Value) }
			end
			--Can return either one string for one line (then skip line) or {string} as place-each-line.
			--return StatusCode (0 = 0K), Code (in string or table)
		end,

		convert = function(lineData) -- Convert LUA to (Code)Block
			if lineData[1] ~= "local" then
				return nil
			end -- If doesn't match, return nil to let Processor continue asking another Block until it matches.
		end,

		--Compact under rework
	}

	mod.api.registry:buildBlock(mod.MODID .. ":variables.local", block)
	return
end
