return function()
	local mod = require(script.Parent.Parent)
	
	local block = {
		group = "Variables",
		
		-- Block type classification system
		-- Block (Normal LUA Block), EndBlock (Return Block, ect..), ProcedureBlock (Define function, ect..), VariableBlock (String, Num, ect..)
		-- Block // Allow Connection Above: true, Allow Connection Below: true, Can Stack Inside: false, Can Input: false
		-- EndBlock // Allow Connection Above: true, Allow Connection Below: false, Can Stack Inside: false, Can Input: false  
		-- ProcedureBlock // Allow Connection Above: true, Allow Connection Below: true, Can Stack Inside: true, Can Input: false
		-- VariableBlock // Allow Connection Above: false, Allow Connection Below: false, Can Stack Inside: false, Can Input: true
		type = "Block", -- Explicit block type
		
		render = {
			color = Color3.fromRGB(255, 180, 0),
			size = "AUTO", -- AUTO, SMALL, MEDIUM, LARGE, XLARGE
			icon = "🔗", -- Optional icon
			
			connections = {
				allow_connection_above = true,
				allow_connection_below = true,
				can_stack_inside = false,
				can_input = false,
			},
			
			contents = { -- ROW:COLUMNS
				[1] = {
					[1] = {
						type = "label", 
						position = "AUTO", 
						text = "Set local variable",
						id = "declaration_label"
					},
					[2] = {
						type = "menu", 
						position = "AUTO", 
						id = "var_type",
						options = function() 
							local types = mod.api.getAllTypes() or {}
							local classes = mod.api.getAllClasses() or {}
							
							local options = {}
							
							-- Add primitive types first
							for _, typeName in ipairs(types) do
								if type(typeName) == "string" then
									table.insert(options, typeName)
								end
							end
							
							-- Add "any" type
							table.insert(options, "any")
							
							-- Add Roblox classes
							for _, className in ipairs(classes) do
								if type(className) == "string" then
									table.insert(options, className)
								end
							end
							
							return options
						end,
						default = "any",
						tooltip = "Select variable type"
					},
					[3] = {
						type = "label", 
						position = "AUTO", 
						text = "to",
						id = "to_label"
					},
					[4] = {
						type = "inbox", 
						position = "AUTO", 
						id = "value_input",
						value = nil,
						accepts = {"any"}, -- Will be updated dynamically
						tooltip = "Connect value or enter literal"
					},
					[5] = {
						type = "label", 
						position = "AUTO", 
						text = "as",
						id = "as_label" 
					},
					[6] = {
						type = "textbox", 
						position = "AUTO", 
						id = "var_name",
						placeholder = "variableName",
						validate = function(text)
							if not text or text == "" then
								return false, "Variable name cannot be empty"
							end
							if not text:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
								return false, "Invalid variable name format"
							end
							-- Check for Lua reserved keywords
							local reserved = {
								"and", "break", "do", "else", "elseif", "end",
								"false", "for", "function", "goto", "if", "in",
								"local", "nil", "not", "or", "repeat", "return",
								"then", "true", "until", "while"
							}
							for _, keyword in ipairs(reserved) do
								if text:lower() == keyword then
									return false, "Cannot use reserved keyword: " .. keyword
								end
							end
							return true
						end,
						tooltip = "Enter variable name"
					},
				}
			}
		},
		
		onAttemptUpdate = function(blockAttempting, targetBlock, connectionType)
			-- connectionType: "above", "below", "inside", "input"
			
			if connectionType == "input" then
				local targetInput = targetBlock.render.contents[1][4] -- value_input
				local attemptingType = blockAttempting.type
				
				-- Check if the attempting block type is accepted
				if targetInput.accepts and #targetInput.accepts > 0 then
					if not table.find(targetInput.accepts, "any") then
						local isAccepted = false
						for _, acceptedType in ipairs(targetInput.accepts) do
							if attemptingType == acceptedType or blockAttempting.group == acceptedType then
								isAccepted = true
								break
							end
						end
						if not isAccepted then
							return false, "Block type not accepted for this input"
						end
					end
				end
			end
			
			return true -- Allow connection
		end,

		onUpdate = function(blockData)
			local newBlockData = table.clone(blockData)
			local className = newBlockData.rows[1].columns[2].selected or "any"
			
			-- Update accepted input types based on selected type
			local typeMap = {
				["string"] = mod.MODID..":types.string",
				["number"] = mod.MODID..":types.number",
				["boolean"] = mod.MODID..":types.boolean",
				["table"] = mod.MODID..":types.table",
				["function"] = mod.MODID..":types.function"
			}
			
			if className == "any" then
				newBlockData.rows[1].columns[4].accepts = {"any"}
			else
				local expectedType = typeMap[string.lower(className)] or mod.MODID..":types.instance"
				newBlockData.rows[1].columns[4].accepts = {expectedType}
			end
			
			-- Set default values only if input is empty and not connected
			local currentInput = newBlockData.rows[1].columns[4].input
			local currentConnection = newBlockData.rows[1].columns[4].connectedTo
			local isEmpty = not currentInput or (#currentInput == 0) or (currentInput[1] == nil)
			
			if isEmpty and not currentConnection then
				local defaultValueMap = {
					["string"] = {mod.MODID..":types.string", '""'},
					["number"] = {mod.MODID..":types.number", "0"},
					["boolean"] = {mod.MODID..":types.boolean", "false"},
					["table"] = {mod.MODID..":types.table", "{}"},
					["function"] = {mod.MODID..":types.function", "function() end"}
				}
				
				local defaultValues = defaultValueMap[string.lower(className)]
				if defaultValues then
					newBlockData.rows[1].columns[4].input = defaultValues
				else
					-- For Roblox classes or "any", clear the default
					newBlockData.rows[1].columns[4].input = nil
				end
			end
			
			return newBlockData
		end,
		
		compile = function(blockData, context)
			local varName = blockData.rows[1].columns[6].text
			local varType = blockData.rows[1].columns[2].selected or "any"
			local valueInput = blockData.rows[1].columns[4]
			
			-- Validation
			if not varName or varName == "" then
				return nil, "Variable name is required"
			end
			
			if not varName:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
				return nil, "Invalid variable name: " .. varName
			end
			
			-- Compile the value
			local valueCode
			if valueInput.connectedTo then
				-- Get code from connected block
				local success, result = pcall(context.compileConnectedBlock, context, valueInput.connectedTo)
				if not success then
					return nil, "Failed to compile value: " .. tostring(result)
				end
				valueCode = result
			elseif valueInput.input and valueInput.input[2] then
				-- Use literal value (handle different types appropriately)
				local literalValue = valueInput.input[2]
				if type(literalValue) == "string" then
					valueCode = string.format("%q", literalValue) -- Add quotes for strings
				else
					valueCode = tostring(literalValue)
				end
			else
				return nil, "Variable value is required"
			end
			
			-- Generate Lua code
			if varType == "any" then
				return string.format("local %s = %s", varName, valueCode)
			else
				-- Luau type annotation
				return string.format("local %s: %s = %s", varName, varType, valueCode)
			end
		end,
		
		convert = function(lineData, context)
			-- Handle both regular Lua and Luau type annotations
			local patterns = {
				-- Luau typed: "local name: type = value"
				"^%s*local%s+([%w_]+)%s*:%s*([%w%.%[%]%s]+)%s*=%s*(.+)$",
				-- Regular Lua: "local name = value"  
				"^%s*local%s+([%w_]+)%s*=%s*(.+)$"
			}
			
			local varName, varType, value
			
			for _, pattern in ipairs(patterns) do
				local match = {lineData:match(pattern)}
				if #match > 0 then
					if #match == 3 then -- Typed version
						varName, varType, value = match[1], match[2], match[3]
					else -- Untyped version
						varName, value = match[1], match[2]
						varType = "any"
					end
					break
				end
			end
			
			if not varName then
				return nil -- Doesn't match variable declaration pattern
			end
			
			-- Validate variable name
			if not varName:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
				return nil
			end
			
			-- Try to reverse-compile the value
			local valueBlock = nil
			if context and context.reverseCompile then
				valueBlock = context.reverseCompile(value:gsub(";%s*$", "")) -- Remove trailing semicolon
			end
			
			return {
				blockId = mod.MODID..":variables.local",
				rows = {
					[1] = {
						columns = {
							[2] = {selected = varType}, -- var_type
							[4] = valueBlock and {connectedTo = valueBlock} or {input = {nil, value}}, -- value_input
							[6] = {text = varName} -- var_name
						}
					}
				}
			}
		end,
		
		compact = function(blockData, targetLanguage)
			if not targetLanguage or targetLanguage == "Lua" then
				return nil -- Use default compile for Lua
			end
			
			local varName = blockData.rows[1].columns[6].text
			local varType = blockData.rows[1].columns[2].selected or "any"
			local valueInput = blockData.rows[1].columns[4]
			
			-- For now, return placeholder as this feature is under planning
			if targetLanguage == "C++" then
				return "// C++ export for variable: " .. varName
			elseif targetLanguage == "JavaScript" then
				return "// JavaScript export for variable: " .. varName
			elseif targetLanguage == "Python" then
				return "# Python export for variable: " .. varName
			else
				return "-- Unsupported language: " .. targetLanguage
			end
		end,
		
		-- Additional metadata
		metadata = {
			description = "Creates a local variable with optional type annotation",
			version = "1.0.0",
			author = mod.MODID,
			category = "Variables",
			tags = {"variable", "declaration", "local", "type"},
			difficulty = 1, -- 1-5 scale
			
			examples = {
				"local playerName = \"John\"",
				"local health: number = 100",
				"local isAlive: boolean = true",
				"local character: Part = workspace.Part"
			},
			
			documentation = {
				summary = "Declares a local variable in the current scope",
				usage = "Use this block to create variables that are only accessible within the current block or function",
				notes = {
					"Variables are scoped to the current block",
					"Use type annotations for better Luau support",
					"Avoid using reserved keywords as variable names"
				}
			}
		}
	}

	mod.api.registry.blocks:build(mod.MODID..":variables.local", block)
	return block
end
