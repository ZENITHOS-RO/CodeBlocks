--!strict
local export = {}
local this = {}

local ForcePrint_toOutput = true
local ForceDebugCML = true
local ForceRecallAsyncPrintOut = true

local Active = false --CML Active State

local TestSV = game:GetService("TestService")
--

local selectedBlock = {} -- {BlockID}

local CommandRegistry = {
    clear = function(args:{}) -- CLEAR
        selectedBlock = {}
        return true
    end,

    select = function(args:{}) -- SELECT <blockID>
        return true
    end
}

function export.print(level:number, msg:string)
	--Soon (need UI)
end

function export.cprint(msg:string)
	--Soon (need UI)
end

function export.parseRange(v:{}|string)
	if type(v) == "table" then
		return tonumber(v[1]), tonumber(v[#v])
	else
		this.info(2, "Expected value In <table>; Got <"..type(v)..">.")
	end
end

function this.RePhraseOperator(operator:string)
	if this.assert(operator, "Expected <Operator>; Got <nil>") then return nil end
	if this.assert(type(operator) == "string", "Expected <Operator> in <string>; Got <"..type(operator)..">.") then return nil end

	operator = string.split(operator:gsub("[()]", ""), " ")
	if not operator or operator == "" then this.info(2, "Expected <Operator> Operator; Got EMPTY.") return nil end
	if not operator[2] then this.info(2, "Illegal Operator: ("..table.concat(operator, " ")..")") return nil end

	--TO DEVELOPER: TAKE A REMINDER! HIGHEST INDEX BEFORE LOWEST INDEX FOR OPERATOR CHECKING!
	local result = {}
	if string.lower(operator[2]) == string.lower("thru") then

		local startVal = operator[1]
		local endVal = operator[3]

		-- Numeric Range
		if tonumber(startVal) and tonumber(endVal) then
			local startNum = tonumber(startVal)
			local endNum = tonumber(endVal)

			if startNum > endNum then this.info(2, "Illegal Operator: Start Value greater than End Value") return nil end
			for i = startNum, endNum do
				table.insert(result, i)
			end
		end

		-- Alphabetic Range
		if #startVal == 1 and #endVal == 1 then
			local startByte = string.byte(startVal)
			local endByte = string.byte(endVal)
			if startByte > endByte then this.info(2, "Illegal Operator: Start Character comes after End Character") return nil end
			for i = startByte, endByte do
				local char = string.char(i)
				if char:match("%a") then
					table.insert(result, char)
				end
			end
		end

	end

	if result and result ~= {} then
		return result
	else
		this.info(2, "Illegal Operator: "..table.concat(operator, " "))
		return nil
	end
end

function this.RePhraseTable(tbl:string)
	if this.assert(tbl, "Expected <Table>; Got <nil>") then return nil end
	if this.assert(type(tbl) == "string", "Expected <Table> in <string>; Got <"..type(tbl)..">.") then return nil end

	local rawTable = string.split(tbl:gsub("[{}]", ""), ",")
	if not rawTable or rawTable == "" then this.info(2, "Expected <Table> Table; Got EMPTY.") return nil end

	local result = {}
	for idx, item in ipairs(rawTable) do
		local trimmed = item:match("^%s*(.-)%s*$") -- trim leading/trailing whitespace
		if trimmed ~= "" and not item:match("[^%w%s]") then
			table.insert(result, trimmed)
		elseif item:match("[^%w%s]") then
			this.info(2, "Illegal Table: Index <"..tostring(idx)..">, Item <"..tostring(item).."> included Illegal Character.")
			return nil
		else
			this.info(2, "Illegal Table: Index <"..tostring(idx)..">, Item <"..tostring(item).."> was EMPTY.")
			return nil
		end
	end

	return result
end

function this.RePhraseCMD(cmd:string)
	cmd = cmd:split(" ")

	local final = {}
	local ho, tmp = false, {} -- ho = HadOperator?

	for _, str in ipairs(cmd) do

		if str == "()" then
			this.info(2, "Illegal Operator: ()")
			return nil
		elseif str == "{}" then
			table.insert(final, {})
		elseif str:match("^%(.+%)$") and not ho then

			local inner = str:match("^%((.+)%)$")
			local success, repedOP = pcall(this.RePhraseOperator, inner)
			if success and repedOP then
				table.insert(final, repedOP)
			else
				return nil
			end

			-- Handle single-token table: {something}
		elseif str:match("^{.+}$") and not ho then

			local inner = str:match("^{(.+)}$")
			local success, repedTBL = pcall(this.RePhraseTable, inner)
			if success and repedTBL then
				table.insert(final, repedTBL)
			else
				return nil
			end

		elseif str:match("^%(") and not ho then
			ho = "op"
			tmp = {str:match("^%((.+)")}
		elseif str:match("^{") and not ho then
			ho = "tbl"
			tmp = {str:match("^{(.+)")}
		elseif ho then
			if ho == "op" and str:match("%)$") then

				table.insert(tmp, str:match("(.+)%)$"))
				local success, repedOP = pcall(this.RePhraseOperator, table.concat(tmp, " "))
				if success and repedOP then
					table.insert(final, repedOP)
				else
					return nil
				end
				ho, tmp = false, {}

			elseif ho == "tbl" and str:match("}$") then

				table.insert(tmp, str:match("(.+)}$"))
				local success, repedTBL = pcall(this.RePhraseTable, table.concat(tmp, " "))
				if success and repedTBL then
					table.insert(final, repedTBL)
				else
					return nil
				end
				ho, tmp = false, {}

			else
				table.insert(tmp, str)
			end

		else
			table.insert(final, str)
		end

	end

	return final
end

function export:execute(cmd:string)
	if not cmd or cmd == "" then return end

	local pcmd = this.RePhraseCMD(cmd) --PhrasedCMD
	if ForceDebugCML and pcmd then
		print("> "..tostring(cmd))
		for i, v in ipairs(pcmd) do
			if type(v) == "table" then
				print("[" .. i .. "] {" .. table.concat(v, ",") .. "}")
			else
				print("[" .. i .. "] " .. tostring(v))
			end
		end
	end

	if pcmd and pcmd[1] and string.match(pcmd[1], "^%w+") and CommandRegistry[string.lower(pcmd[1])] then
		local run = pcmd[1]
		table.remove(pcmd, 1)
		if CommandRegistry[string.lower(run)](pcmd) then
			this.cinfo("OK: "..cmd)
            return "OK: "..cmd
		end
	else
		this.info(2, "Illegal Object: "..cmd)
        return "Illegal Object: "..cmd
	end
end

local Prefix = "[GLTK] "
function export.info(level:number, msg:string)

	if Active and not ForcePrint_toOutput then

		return

			--CML:Print - Normal Print (Label)
			--or
			--CML:cPrint - CommandPrint (Button for re-execution)

	else

		if level <= 0 then
			return print(Prefix..msg)
		elseif level == 1 then
			return warn(Prefix..msg)
		elseif level >= 2 then
			return TestSV:Error(Prefix..msg)
		end

	end

end

function export.cinfo(msg:string)

	if Active and not ForcePrint_toOutput then

		return export.cprint(msg)

	else

		return print(Prefix..msg)

	end

end

function export.assert(value, msg:string)

	if not value then --Either nil or false

		if Active and not ForcePrint_toOutput then

			--here
			return true

			--CML:Print - Normal Print (Label)
			--or
			--CML:cPrint - CommandPrint (Button for re-execution)

		else

			TestSV:Error(Prefix..msg)
			return true

		end

	end

	return false
end

function export:Listen(textbox:TextBox)
    textbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Return then
            textbox.PlaceholderText = export:execute(textbox.Text)
            textbox.Text = ""
        end
    end)
end

function export:SubscribeLogging(cmlUI:Frame)
    
end

return export