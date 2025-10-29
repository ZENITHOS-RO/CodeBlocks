--!nocheck

--TAKE A REMINDER--
-- BaseEncrypt 3 (BE3) is NOT ABSOLUTELY SECURE. DO NOT USE IT FOR SENSITIVE DATA!
--
-- This system was designed to ensure blazing-fast, smooth experiences for all ZENITHOS Plugins and In-Game Experiences.
-- BE3 does not use padding like AES. It maintains the original file size (though Base64 may add minimal padding).
--
-- Please acknowledge that we are not responsible for any data loss if BE3 is inappropriately used for sensitive information.
-- If you need to encrypt highly sensitive data, consider using established encryption standards like AES with proper key management.
--END--

--WHAT BE3 OFFER--
-- Blazing-Fast encryption and decryption suitable for real-time applications. (Benchmark: ~0.5ms per 1KB on average plugin.)
-- Easily customizable parameters for enhanced security. (Depending on your need. This source was provided "AS-IS".)
-- Base64 encoding with a remixable alphabet for added obfuscation.
-- Lightweight implementation with minimal dependencies.
--END--

--HOW CAN BE3 BE SECURE?--
-- BE3 employs multiple layers of obfuscation and transformation to enhance security.
-- It uses SHA-256 and SHAKE-256 hashing algorithms to derive keys from user-provided passkeys, salts, and plain keys.
-- -- THIS MEAN LONGER KEYS, RODS IS LONGER.
-- The encryption process involves byte-wise transformations based on these derived keys, making it challenging to reverse engineer without the correct parameters.
-- The Base64 encoding step further obfuscates the encrypted data by using a remixable alphabet.
--END--

-- SECURITY REFERENCE: Key Length vs Brute-Force Time
-- ===================================================================
-- Time to Decrypt is CALCULATED BY DEEPSEEK (AI), FOR REFERENCE PURPOSES ONLY.
-- Key length is Combined with PassKey, Salt, and PLainKey lengths.
-- ===================================================================
-- ORIGINAL DATA TESTED BY ZENITHOS:
--[[LANGUAGE SLC IN LUA ADD ROBLOX VERSION LATEST
AND POINT -> UPDATE
DECLARE SELF AS "STRUCTURED LANGUAGE COMMAND" IN "SLC";

TYPE INSTANCE | MODULE | STRING OR CHAR | INTEGER OR INT | NUMBER OR DOUBLE OR FLOAT | BOOLEAN OR BOOL | DATE OR TIME OR DATETIME;
-- Basically all Roblox Globals: Color3, Udim2, Vector3

DECLARE GLOBAL DOUBLE (5) AS STARTING_POINT; -- STARTING_POINT = 5
DECLARE LOCAL INSTANCE (CREATE NEW INSTANCE PART ( (Name, Parent) VALUE ("DUNNO", Workspace/Folder) )) AS NEW_PARTS; 
-- local NEW_PARTS = Instance.new("Part"); NEW_PARTS["Name"] = "DUNNO"; NEW_PARTS["Parent"] = workspace.folder

DECLARE GLOBAL MODULE (REQUIRE MODULE (FROM Workspace/Timecode) ) AS TC; -- TC = require(workspace.timecode)

PRINT INFO "Hello, World!"; -- print("Hello, World!")
PRINT WARN "Warning, the code may be deprecated"; -- warn("Warning, the code may be deprecated")
PRINT ERROR "Oh no!" STACKTRACE () LEVEL 0; -- error("Oh no!", 0) (Stacktrace are for CREATE Console only)

FOR I IN RANGE (FROM 50 UNTIL 5 STEP -5) (
    PRINT INFO (I)
);
-- for i in 50, 5, -5 do
--  print(i)
-- end

FOR I IN RANGE (50, 5, -5) (
    PRINT INFO (I-1)
);
-- for i in 50, 5, -5 do
--  print(i-1)
-- end

WHILE TRUE (
    PRINT(STARTING_POINT)
    UPDATE STARTING_POINT INTO (STARTING_POINT+1)
)
-- while true do
--  print(STARTING_POINT)
--  STARTING_POINT = STARTING_POINT + 1
-- end
]]
-- ===================================================================
-- Key Length   		RODS Size		Time to Decrypt				Example Key (Combined)
-- ----------   		---------		-----------------			-----------------
-- 36 chars (0.063s)	204 objects		"Only" billions of years	8ttyu-crby-tyuig2r668-crbb7uZENITHYHS (ORINGAL CHAR SIZE TESTED BY ZENITHOS)
-- 96 chars (0.059s)	648 objects		10¹⁵³³ universe lifetimes	9ssiv-dscz-uzvjh3s779-dscc8v-QWEROP-0rqm3-nocw9-xyza584302-lkie7s779-dscc8v-PLKJMN-0rqm3-nocw9-x
-- 256 chars (0.062s)	1008 objects	10²⁴⁰³ universe lifetimes	9ssiv-dscz-uzvjh3s779-dscc8v-QWEROP-0rqm3-nocw9-xyza584302-lkie7-BNMABC-5hgfd-sdxw6s779-dscc8v-PLKJMN-0rqm3-nocw9-xyza584302-lkie7-BNMABC-5hgfd-sdxw6-QWEROP-9ssiv-dsczPLKJMNBVCXZ-0rqm3-nocw9-xyza584302-lkie7-BNMABC-5hgfd-sdxw6-9ssiv-dscz-uzvjh3s779
--
-- Note: Longer keys generate exponentially larger RODS arrays, making brute-force attacks computationally impossible with ReMixBase64 integration.
-- ===================================================================

local HLS = require(script.Parent:WaitForChild("HashLib")) --HASLIB
local TS = game:GetService("TestService")

function enc(AD : {}, Passkey : string, Salt : string, plainkey : string, length : number) : string
	local cat = table.concat(AD, "")
	local encrypted = ""

	if Passkey == "" then Passkey = "0" end
	if Salt == "" then Salt = "NoSalt" end
	if plainkey == "" then plainkey = "zerokey" end

	local PK256, S256, PLK256, TO, RODS = "", "", "", 0, {}
	PK256, S256, PLK256 = HLS.shake256(Passkey, (#Passkey/8)*16), HLS.shake256(Salt, (#Passkey/8)*16), HLS.shake256(plainkey, (#Passkey/8)*16)
	TO = #PK256+#S256+#PLK256

	local GF = 1
	for i = 1, TO do
		local rd = (i-1)%3
		local sk = 0

		if rd == 0 then
			sk = string.byte(PK256:sub(GF,GF))
		elseif rd == 1 then
			sk = string.byte(S256:sub(GF,GF))
		elseif rd == 2 then
			sk = string.byte(PLK256:sub(GF,GF))
			GF += 1
		end

		if sk then
			if i > 1 then sk = sk + RODS[i-1] end
			sk = sk + i
			sk = (sk%255)+1
			table.insert(RODS, sk)
		else
			warn("REFERENCE #"..i,"SKIPPED DUE TO NIL BEHAVIOUR.")
			continue
		end
	end

	print(table.concat(RODS,"|"))

	for i = 1, #cat do
		local PK, ST, plk

		PK = string.byte(Passkey:sub((i%#Passkey)+1, (i%#Passkey)+1))*4
		ST = string.byte(Salt:sub((i%#Salt)+1, (i%#Salt)+1))*8
		plk = string.byte(plainkey:sub((i%#plainkey)+1, (i%#plainkey)+1))

		local byte = string.byte(cat:sub(i,i))
		local PKED = ((byte + PK)%94)+32
		local STED = ((PKED + ST)%94)+32
		local BOTH = ((STED + PK + ST + i + plk + (i%2) )%94)+32
		local ROND = ((BOTH + RODS[(i%#RODS)+1])%94)+32
		local f = ROND
		encrypted = encrypted..string.char(f)
	end

	return encrypted
end

function dec(AD : string, Passkey : string, Salt : string, plainkey : string, length : number) : string
	local cat = AD
	local decrypted = ""

	if Passkey == "" then Passkey = "0" end
	if Salt == "" then Salt = "NoSalt" end
	if plainkey == "" then plainkey = "zerokey" end

	local PK256, S256, PLK256, TO, RODS = "", "", "", 0, {}
	PK256, S256, PLK256 = HLS.shake256(Passkey, (#Passkey/8)*16), HLS.shake256(Salt, (#Passkey/8)*16), HLS.shake256(plainkey, (#Passkey/8)*16)
	TO = #PK256+#S256+#PLK256

	local GF = 1
	for i = 1, TO do
		local rd = (i-1)%3
		local sk = 0

		if rd == 0 then
			sk = string.byte(PK256:sub(GF,GF))
		elseif rd == 1 then
			sk = string.byte(S256:sub(GF,GF))
		elseif rd == 2 then
			sk = string.byte(PLK256:sub(GF,GF))
			GF += 1
		end

		if sk then
			if i > 1 then sk = sk + RODS[i-1] end
			sk = sk + i
			sk = (sk%255)+1
			table.insert(RODS, sk)
		else
			warn("REFERENCE #"..i,"SKIPPED DUE TO NIL BEHAVIOUR.")
			continue
		end
	end

	print(table.concat(RODS,"|"))

	for i = 1, #cat do
		local PK, ST, plk

		PK = string.byte(Passkey:sub((i%#Passkey)+1, (i%#Passkey)+1))*4
		ST = string.byte(Salt:sub((i%#Salt)+1, (i%#Salt)+1))*8
		plk = string.byte(plainkey:sub((i%#plainkey)+1, (i%#plainkey)+1))

		local byte = string.byte(cat:sub(i,i))
		local PKED = ((byte - PK)%94)+32
		local STED = ((PKED - ST)%94)+32
		local BOTH = ((STED - PK - ST - i - plk - (i%2) )%94)+32
		local ROND = ((BOTH - RODS[(i%#RODS)+1])%94)+32
		local f = ROND
		local c = f-4

		c = ((c-2)%94)+32
		if c == 28 then
			c = 122
		end

		decrypted = decrypted..string.char(c)
	end
	
	return decrypted
end

local function remixBase64Alphabet(keyHex:{})
	local standardAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local alphabetList = {}
	for char in standardAlphabet:gmatch(".") do
		table.insert(alphabetList, char)
	end

	local keyBytes = ""
	for i = 1, #keyHex, 2 do
		local byteStr = keyHex:sub(i, i+1)
		keyBytes ..= string.char(tonumber(byteStr, 16))
	end

	local seedHash = HLS.sha256(keyBytes)
	local seedBytes = ""
	for i = 1, #seedHash, 2 do
		local byteStr = seedHash:sub(i, i+1)
		seedBytes ..= string.char(tonumber(byteStr, 16))
	end

	local prng = {}
	prng.buffer = seedBytes
	prng.index = 1

	function prng:getNextByte()
		local buffer:{}|string = self.buffer --UNUSED, ONLY FOR ANTI-ERROR (yes Luau is dumb when I added it)
		if self.index > #self.buffer then
			local newHash = HLS.sha256(self.buffer)
			self.buffer = ""
			for i = 1, #newHash, 2 do
				local byteStr = newHash:sub(i, i+1)
				self.buffer ..= string.char(tonumber(byteStr, 16))
			end
			self.index = 1
		end
		local byteVal = self.buffer:byte(self.index)
		self.index += 1
		return byteVal
	end

	function prng:nextInt(minVal, maxVal)
		local range = maxVal - minVal + 1
		local threshold = 256 - (256 % range)
		local candidate
		repeat
			candidate = self:getNextByte()
		until candidate < threshold
		return minVal + (candidate % range)
	end

	local n = #alphabetList
	for i = n, 2, -1 do
		local j = prng:nextInt(1, i)
		alphabetList[i], alphabetList[j] = alphabetList[j], alphabetList[i]
	end
	
	local requiredChars = {
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M","N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m","n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"
	}

	for _, char in ipairs(requiredChars) do
		if not table.concat(alphabetList):find(char) then
			return error("ReMixBase couldn't remix the B64 Char, Execution Dismissed")
		end
	end

	return table.concat(alphabetList)
end

local function Encode(Data : string, B64KEY:string, Passkey : string, Salt : string, plainkey : string, len : number, iteration : number?) : string
	if Data == "" or Data == nil then return "CANNOT-RESOLVE" end
	if len <= 0 then return "LENGTH-ERROR" end
	
	--local alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
	local alphabet = remixBase64Alphabet(HLS.sha256(B64KEY))
	local base = {} --BASE 16-64 IN UNICODE

	for i = 0, 63 do
		base[i] = alphabet:sub(i+1,i+1)
		base[alphabet:sub(i+1,i+1)] = i
	end

	local S1 = {}
	local S2 = {}
	local S3 = {}
	local S4 = {}
	local S5 = {}

	local C1 = 0
	local C2 = 0
	local C3 = 0

	for C1 = 0, 255 do
		for C2 = 0, 255 do
			local Sum = C3 * 65536 + C2 * 256 + C1

			local B1 = base[ bit32.extract(Sum, 0,6) ]
			local B2 = base[ bit32.extract(Sum, 6,6) ]

			S1[string.char(C1, C2)] = B1 .. B2
			S3[B1 .. B2] = string.char(C1)
		end
	end

	for C2 = 0, 255 do
		for C3 = 0, 255 do
			local Sum = C3 * 65536 + C2 * 256 + C1

			local B3 = base[ bit32.extract(Sum,12,6) ]
			local B4 = base[ bit32.extract(Sum,18,6) ]

			S2[string.char(C2, C3)] = B3 .. B4
			S5[B3 .. B4] = string.char(C3)
		end
	end

	for C1 = 0, 192, 64 do
		for C2 = 0, 255 do
			for C3 = 0, 3 do
				local Sum = C3 * 65536 + C2 * 256 + C1

				local B2 = base[ bit32.extract(Sum, 6,6) ]
				local B3 = base[ bit32.extract(Sum,12,6) ]

				S4[B2 .. B3] = string.char(C2)
			end
		end
	end

	local padding = -#Data % 3
	Data ..= string.rep("\0", padding)

	local resault = table.create(#Data/3*2+1, "    ")
	resault[1] = base[padding]

	local index = 2
	for i = 1, #Data, 3 do
		resault[index  ] = S1[Data:sub(i,  i+1)]
		resault[index+1] = S2[Data:sub(i+1,i+2)]
		index += 2
	end

	local encrypted = ""
	if iteration == nil or iteration == 0 then iteration = 1 end

	for i = 1, iteration do
		if i > 1 then
			local function j(input:string) return input:split("") end
			encrypted = enc(j(encrypted), Passkey..tostring(i), Salt..tostring(i), plainkey..tostring(i), len)
		else
			encrypted = enc(resault, Passkey..tostring(i), Salt..tostring(i), plainkey..tostring(i), len)
		end
	end

	return encrypted
end

local function Decode(Data : string, B64KEY:string, Passkey : string, Salt : string, plainkey : string, len : number, iteration : number?) : string
	if Data == "E" or Data == "" or Data == nil then return "CANNOT-RESOLVE" end
	if len <= 0 then return "LENGTH-ERROR" end
	if iteration == nil or iteration == 0 then iteration = 1 end

	for i = 1, iteration do
		Data = dec(Data, Passkey..tostring(i), Salt..tostring(i), plainkey..tostring(i), len)
	end
	
	--local alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
	local alphabet = remixBase64Alphabet(HLS.sha256(B64KEY))
	local base = {} --BASE 16-64 IN UNICODE

	for i = 0, 63 do
		base[i] = alphabet:sub(i+1,i+1)
		base[alphabet:sub(i+1,i+1)] = i
	end

	local S1 = {}
	local S2 = {}
	local S3 = {}
	local S4 = {}
	local S5 = {}

	local C1 = 0
	local C2 = 0
	local C3 = 0

	for C1 = 0, 255 do
		for C2 = 0, 255 do
			local Sum = C3 * 65536 + C2 * 256 + C1

			local B1 = base[ bit32.extract(Sum, 0,6) ]
			local B2 = base[ bit32.extract(Sum, 6,6) ]

			S1[string.char(C1, C2)] = B1 .. B2
			S3[B1 .. B2] = string.char(C1)
		end
	end

	for C2 = 0, 255 do
		for C3 = 0, 255 do
			local Sum = C3 * 65536 + C2 * 256 + C1

			local B3 = base[ bit32.extract(Sum,12,6) ]
			local B4 = base[ bit32.extract(Sum,18,6) ]

			S2[string.char(C2, C3)] = B3 .. B4
			S5[B3 .. B4] = string.char(C3)
		end
	end

	for C1 = 0, 192, 64 do
		for C2 = 0, 255 do
			for C3 = 0, 3 do
				local Sum = C3 * 65536 + C2 * 256 + C1

				local B2 = base[ bit32.extract(Sum, 6,6) ]
				local B3 = base[ bit32.extract(Sum,12,6) ]

				S4[B2 .. B3] = string.char(C2)
			end
		end
	end

	local padding = base[Data:sub(1,1)]
	local resault = table.create((#Data-1)/4*3, "   ")

	local index = 1
	for i = 2, #Data, 4 do
		resault[index  ] = S3[Data:sub(i,  i+1)]
		resault[index+1] = S4[Data:sub(i+1,i+2)]
		resault[index+2] = S5[Data:sub(i+2,i+3)]
		index += 3
	end
	
	for i = 1, #resault do
		resault[i] = resault[i] or string.char(math.random(32,122))
	end
	
	local concatted
	local caller = pcall(function() concatted = table.concat(resault) end)
	if caller then
		return concatted:sub(1, #concatted-padding)
	else
		return "DECODE-FAILED"
	end
end

return {
	encode = Encode,
	decode = Decode,
}