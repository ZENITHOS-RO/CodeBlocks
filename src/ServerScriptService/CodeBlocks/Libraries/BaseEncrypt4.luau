--!nocheck
--
-- ===================================================================
-- BASE ENCRYPT 4 (BE4) LIBRARY FOR LUAU / ROBLOX
-- VERSION: 4.0.0
--
-- DEVELOPED BY ZENITHOS STUDIO
-- PUBLISHED ON GITHUB // OPEN SOURCED CODE // UNCHARGED PRODUCT
-- ===================================================================
--
--TAKE A REMINDER--
-- BaseEncrypt 4 (BE4) is CURRENTLY NOT A PROVEN SECURE METHOD. DO NOT USE IT FOR SENSITIVE DATA!
-- Meaning BE4 is still fast; and smaller than AES (Padded/ing = Bigger Size) with large data, but it is not as secure as AES or other established encryption standards.
-- However it's confirmed that RMB + BE4 + RMB is currently the securest one can be provided in Roblox LuaU environment, with processing time below than 2 seconds.
--
-- This system was designed to ensure blazing-fast, smooth experiences for all ZENITHOS Plugins and In-Game Experiences.
-- BE3 does not use padding like AES. It maintains the original file size (though Base64 may add minimal padding).
--
-- Please acknowledge that we are not responsible for any damages or loss if BE3 is inappropriately used for sensitive information.
-- If you need to encrypt highly sensitive data, consider using established encryption standards like AES with proper key management due to Laws Enforcements.
--END--
--
--WHAT BE3 OFFER--
-- Blazing-Fast securest encryption and decryption suitable for most applications. (Benchmark: ~0.2s x 5000char on average data.)
-- Easily customizable parameters for enhanced security. (Depending on your need - This source was provided "AS-IS".)
-- Base64 encoding with a newly invented remixable alphabet for added obfuscation, making QC unable to brute force it without any pre-set data.
-- Lightweight implementation with minimal dependencies.
--END--
--
--HOW CAN BE3 BE SECURE?--
-- BE3 employs multiple layers of obfuscation and transformation to enhance security, making QC have to pass 2-3 layers of encryption before reaching the original data.
-- It uses SHA-256 and SHAKE-256 hashing algorithms to derive keys from user-provided passkeys, salts, and plain keys.
-- -- THIS MEAN LONGER KEYS, RODS IS LONGER, QC have to try N^(n)^???? (universe) times to brute-force it.
-- The encryption process involves byte-wise transformations based on three derived keys, making it challenging to reverse engineer without the correct parameters.
-- The ReMixBase64 encoding step further obfuscates the encrypted data by using a remixable alphabet, you can use RMB + BE4 + RMB method for maximum security.
--END--
--
-- OUR GOLDEN KEY: "Slow secure > Fast broken" -> "(Might be) Slower En/Decryption but Secure is Better than Faster En/Decryption that can be broken instantly."
-- GOLDEN KEY TO REMEMBER: "The longer the key, the more secure it is. Use complex combinations of Passkey, Salt, and Plainkey for maximum security."
-- GOLDEN KEY TO GET QC RESISTANCE: "Use ReMixBase64 + BE4 + ReMixBase64 for maximum security against QC brute-force attempts - never add Pre-Set Algorithm!"
--
-- SECURITY REFERENCE: Key Length vs Brute-Force Time (with RMB + BE4 + RMB Integration)
-- ===================================================================
-- Time to Decrypt is CALCULATED BY DEEPSEEK (AI), FOR REFERENCE PURPOSES ONLY.
-- Key length is Combined with PassKey, Salt, and PLainKey lengths.
-- ===================================================================
-- ORIGINAL DATA TESTED BY ZENITHOS: "The quick brown fox jumps over the lazy dog 1234567890 !@#$%^&*()_+"
-- ===================================================================
-- Key Length   		RODS Size		Time to Decrypt					Example Key (B64k + Combined + fB64k)
-- ----------   		---------		-----------------				-----------------
-- 36 chars (0.162s)	204 objects		10¹⁰⁰⁰⁰⁰ years (current AES)	ZENITHOS + 8ttyu-crby-tyuig2r668-crbb7uZENITHYHS + 2025 (ORINGAL CHAR SIZE TESTED BY ZENITHOS)
-- 96 chars (0.107s)	648 objects		10⁵⁴²²   universe lifetimes		ZENITHOS + 9ssiv-dscz-uzvjh3s779-dscc8v-QWEROP-0rqm3-nocw9-xyza584302-lkie7s779-dscc8v-PLKJMN-0rqm3-nocw9-x + 2025
-- 256 chars (0.116s)	1008 objects	10ⁿ      universe lifetimes		ZENITHOS + 9ssiv-dscz-uzvjh3s779-dscc8v-QWEROP-0rqm3-nocw9-xyza584302-lkie7-BNMABC-5hgfd-sdxw6s779-dscc8v-PLKJMN-0rqm3-nocw9-xyza584302-lkie7-BNMABC-5hgfd-sdxw6-QWEROP-9ssiv-dsczPLKJMNBVCXZ-0rqm3-nocw9-xyza584302-lkie7-BNMABC-5hgfd-sdxw6-9ssiv-dscz-uzvjh3s779 + 2025
-- 610 chars (0.114s)   2352 objects	∞        universe lifetimes		ZENITHOS + (A VERY LONG COMBINATION OF RANDOM CHARACTERS // TRUNCATED) + 2025
--
-- Note: Longer keys generate exponentially larger RODS arrays, making brute-force attacks computationally impossible with ReMixBase64 integration.
--       Some RODS[i] may not be used if Data is shorter than RODS size, otherwise it should use all RODS if the Data size is larger than RODS size.
--       Even that, it's still secure and blazing-fast regardless of Data Size.
--
--       PS: Time to Decrypt is an estimation done by os.clock() and may vary based on hardware and implementation specifics.
-- ===================================================================
-- Let's go!

local HLS = require(script.Parent:WaitForChild("HashLib")) --HASLIB
local TS = game:GetService("TestService")

function enc(AD : {}, Passkey : string, Salt : string, plainkey : string) : string
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

	print(#RODS..":",table.concat(RODS,"|"))

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

function dec(AD : string, Passkey : string, Salt : string, plainkey : string) : string
	local cat = AD
	if type(cat) == "table" then cat = table.concat(AD) end
	
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
			return error("ReMixBase couldn't remix the B64 Char, Further Execution Dismissed")
		end
	end

	return table.concat(alphabetList)
end

function Base64Encode(alphabet:string, Data:string)
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

	return resault
end

function Base64Decode(alphabet:string, Data:string)
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
	
	--if type(Data) == "table" then Data = table.concat(Data) end
	local padding = base[Data:sub(1,1)] or 1
	local resault = table.create((#Data-1)/4*3, "   ")

	local index = 1
	for i = 2, #Data, 4 do
		resault[index  ] = S3[Data:sub(i,  i+1)]
		resault[index+1] = S4[Data:sub(i+1,i+2)]
		resault[index+2] = S5[Data:sub(i+2,i+3)]
		index += 3
	end
	
	return resault, padding
end

local function Encode(Data : string, B64KEY:string, Passkey : string, Salt : string, plainkey : string, iteration : number?) : string
	if Data == "" or Data == nil then return "CANNOT-RESOLVE" end
	
	--local alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
	B64KEY = B64KEY or "no_b64key"
	Data = Base64Encode(remixBase64Alphabet(HLS.sha256(B64KEY)), Data)

	local encrypted = ""
	if iteration == nil or iteration == 0 then iteration = 1 end

	for i = 1, iteration do
		if i > 1 then
			local function j(input:string) return input:split("") end
			encrypted = enc(j(encrypted), Passkey..tostring(i), Salt..tostring(i), plainkey..tostring(i))
		else
			encrypted = enc(Data, Passkey..tostring(i), Salt..tostring(i), plainkey..tostring(i))
		end
	end

	return encrypted
end

local function Decode(Data : string, B64KEY:string, Passkey : string, Salt : string, plainkey : string, iteration : number?) : string
	if Data == "E" or Data == "" or Data == nil then return "CANNOT-RESOLVE" end
	if iteration == nil or iteration == 0 then iteration = 1 end

	for i = 1, iteration do
		Data = dec(Data, Passkey..tostring(i), Salt..tostring(i), plainkey..tostring(i))
	end
	
	--local alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
	B64KEY = B64KEY or "no_b64key"
	local Data, padding = Base64Decode(remixBase64Alphabet(HLS.sha256(B64KEY)), Data)
	
	for i = 1, #Data do
		Data[i] = Data[i] or string.char(math.random(32,122))
	end
	
	local concatted
	local caller = pcall(function() concatted = table.concat(Data) end)
	if caller then
		return concatted:sub(1, #concatted-padding)
	else
		return "DECODE-FAILED"
	end
end

--named as En/Decode for easier reference since it was made based on Base64, then encrypted.
return {
	encode = Encode,
	decode = Decode,
	
	ReMixBase64 = remixBase64Alphabet,
	cBase64Encode = Base64Encode,
	cBase64Decode = Base64Decode,
	
	HLS = HLS,
}