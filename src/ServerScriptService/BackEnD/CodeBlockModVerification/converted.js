// Assuming HLS module is available in your project
// const HLS = require('./HashLib'); // Adjust path as needed based on your project structure

// Note: TestService from Roblox is not used in the functional code, only imported
// const TS = game.GetService("TestService");

function enc(AD, Passkey, Salt, plainkey) {
	let cat = AD.join("");
	let encrypted = "";

	if (Passkey === "") Passkey = "0";
	if (Salt === "") Salt = "NoSalt";
	if (plainkey === "") plainkey = "zerokey";

	let PK256, S256, PLK256, TO, RODS;
	PK256 = "";
	S256 = "";
	PLK256 = "";
	TO = 0;
	RODS = [];
	
	PK256 = HLS.shake256(Passkey, Math.floor((Passkey.length / 8) * 16));
	S256 = HLS.shake256(Salt, Math.floor((Passkey.length / 8) * 16));
	PLK256 = HLS.shake256(plainkey, Math.floor((Passkey.length / 8) * 16));
	TO = PK256.length + S256.length + PLK256.length;

	let GF = 0; // JavaScript uses 0-based indexing
	for (let i = 1; i <= TO; i++) {
		let rd = (i - 1) % 3;
		let sk = 0;

		if (rd === 0) {
			sk = PK256.charCodeAt(GF);
		} else if (rd === 1) {
			sk = S256.charCodeAt(GF);
		} else if (rd === 2) {
			sk = PLK256.charCodeAt(GF);
			GF += 1;
		}

		if (!isNaN(sk) && sk !== undefined) {
			if (i > 1) sk = sk + RODS[i - 2]; // Adjusted for 0-based indexing
			sk = sk + i;
			sk = (sk % 255) + 1;
			RODS.push(sk);
		} else {
			console.warn("REFERENCE #" + i, "SKIPPED DUE TO NIL BEHAVIOUR.");
			continue;
		}
	}

	console.log(RODS.length + ":", RODS.join("|"));

	for (let i = 1; i <= cat.length; i++) {
		let PK, ST, plk;

		PK = Passkey.charCodeAt(((i - 1) % Passkey.length)) * 4;
		ST = Salt.charCodeAt(((i - 1) % Salt.length)) * 8;
		plk = plainkey.charCodeAt(((i - 1) % plainkey.length));

		let byte = cat.charCodeAt(i - 1); // Adjusted for 0-based indexing
		let PKED = ((byte + PK) % 94) + 32;
		let STED = ((PKED + ST) % 94) + 32;
		let BOTH = ((STED + PK + ST + i + plk + (i % 2)) % 94) + 32;
		let ROND = ((BOTH + RODS[((i - 1) % RODS.length)]) % 94) + 32;
		let f = ROND;
		encrypted = encrypted + String.fromCharCode(f);
	}

	return encrypted;
}

function dec(AD, Passkey, Salt, plainkey) {
	let cat = AD;
	if (Array.isArray(cat)) cat = cat.join("");
	
	let decrypted = "";

	if (Passkey === "") Passkey = "0";
	if (Salt === "") Salt = "NoSalt";
	if (plainkey === "") plainkey = "zerokey";

	let PK256, S256, PLK256, TO, RODS;
	PK256 = "";
	S256 = "";
	PLK256 = "";
	TO = 0;
	RODS = [];
	
	PK256 = HLS.shake256(Passkey, Math.floor((Passkey.length / 8) * 16));
	S256 = HLS.shake256(Salt, Math.floor((Passkey.length / 8) * 16));
	PLK256 = HLS.shake256(plainkey, Math.floor((Passkey.length / 8) * 16));
	TO = PK256.length + S256.length + PLK256.length;

	let GF = 0; // JavaScript uses 0-based indexing
	for (let i = 1; i <= TO; i++) {
		let rd = (i - 1) % 3;
		let sk = 0;

		if (rd === 0) {
			sk = PK256.charCodeAt(GF);
		} else if (rd === 1) {
			sk = S256.charCodeAt(GF);
		} else if (rd === 2) {
			sk = PLK256.charCodeAt(GF);
			GF += 1;
		}

		if (!isNaN(sk) && sk !== undefined) {
			if (i > 1) sk = sk + RODS[i - 2]; // Adjusted for 0-based indexing
			sk = sk + i;
			sk = (sk % 255) + 1;
			RODS.push(sk);
		} else {
			console.warn("REFERENCE #" + i, "SKIPPED DUE TO NIL BEHAVIOUR.");
			continue;
		}
	}

	for (let i = 1; i <= cat.length; i++) {
		let PK, ST, plk;

		PK = Passkey.charCodeAt(((i - 1) % Passkey.length)) * 4;
		ST = Salt.charCodeAt(((i - 1) % Salt.length)) * 8;
		plk = plainkey.charCodeAt(((i - 1) % plainkey.length));

		let byte = cat.charCodeAt(i - 1); // Adjusted for 0-based indexing
		// JavaScript modulo behavior with negative numbers differs from Lua
		let PKED = ((((byte - PK) % 94) + 94) % 94) + 32;
		let STED = ((((PKED - ST) % 94) + 94) % 94) + 32;
		let BOTH = ((((STED - PK - ST - i - plk - (i % 2)) % 94) + 94) % 94) + 32;
		let ROND = ((((BOTH - RODS[((i - 1) % RODS.length)]) % 94) + 94) % 94) + 32;
		let f = ROND;
		let c = f - 4;

		c = ((((c - 2) % 94) + 94) % 94) + 32;
		if (c === 28) {
			c = 122;
		}

		decrypted = decrypted + String.fromCharCode(c);
	}
	
	return decrypted;
}

const standardAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

function remixBase64Alphabet(keyHex) {
	let alphabetList = [];
	for (let i = 0; i < standardAlphabet.length; i++) {
		alphabetList.push(standardAlphabet[i]);
	}

	let keyBytes = "";
	for (let i = 0; i < keyHex.length; i += 2) {
		let byteStr = keyHex.substring(i, i + 2);
		keyBytes += String.fromCharCode(parseInt(byteStr, 16));
	}

	let seedHash = HLS.sha256(keyBytes);
	let seedBytes = "";
	for (let i = 0; i < seedHash.length; i += 2) {
		let byteStr = seedHash.substring(i, i + 2);
		seedBytes += String.fromCharCode(parseInt(byteStr, 16));
	}

	let prng = {};
	prng.buffer = seedBytes;
	prng.index = 0; // JavaScript uses 0-based indexing

	prng.getNextByte = function() {
		// UNUSED, ONLY FOR ANTI-ERROR (yes Luau is dumb when I added it)
		let buffer = this.buffer;
		if (this.index >= this.buffer.length) {
			let newHash = HLS.sha256(this.buffer);
			this.buffer = "";
			for (let i = 0; i < newHash.length; i += 2) {
				let byteStr = newHash.substring(i, i + 2);
				this.buffer += String.fromCharCode(parseInt(byteStr, 16));
			}
			this.index = 0;
		}
		let byteVal = this.buffer.charCodeAt(this.index);
		this.index += 1;
		return byteVal;
	};

	prng.nextInt = function(minVal, maxVal) {
		let range = maxVal - minVal + 1;
		let threshold = 256 - (256 % range);
		let candidate;
		do {
			candidate = this.getNextByte();
		} while (candidate >= threshold);
		return minVal + (candidate % range);
	};

	let n = alphabetList.length;
	for (let i = n - 1; i >= 1; i--) {
		let j = prng.nextInt(0, i); // Adjusted for 0-based indexing
		[alphabetList[i], alphabetList[j]] = [alphabetList[j], alphabetList[i]];
	}
	
	let requiredChars = [
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"
	];

	for (let char of requiredChars) {
		if (!alphabetList.join("").includes(char)) {
			throw new Error("ReMixBase couldn't remix the B64 Char, Further Execution Dismissed");
		}
	}

	return alphabetList.join("");
}

// Helper function to implement bit32.extract equivalent
function bit32Extract(n, field, width) {
	return (n >> field) & ((1 << width) - 1);
}

function Base64Encode(alphabet, Data) {
	let base = {}; // BASE 16-64 IN UNICODE

	for (let i = 0; i <= 63; i++) {
		base[i] = alphabet[i];
		base[alphabet[i]] = i;
	}

	let S1 = {};
	let S2 = {};
	let S3 = {};
	let S4 = {};
	let S5 = {};

	let C1 = 0;
	let C2 = 0;
	let C3 = 0;

	for (C1 = 0; C1 <= 255; C1++) {
		for (C2 = 0; C2 <= 255; C2++) {
			let Sum = C3 * 65536 + C2 * 256 + C1;

			let B1 = base[bit32Extract(Sum, 0, 6)];
			let B2 = base[bit32Extract(Sum, 6, 6)];

			S1[String.fromCharCode(C1, C2)] = B1 + B2;
			S3[B1 + B2] = String.fromCharCode(C1);
		}
	}

	for (C2 = 0; C2 <= 255; C2++) {
		for (C3 = 0; C3 <= 255; C3++) {
			let Sum = C3 * 65536 + C2 * 256 + C1;

			let B3 = base[bit32Extract(Sum, 12, 6)];
			let B4 = base[bit32Extract(Sum, 18, 6)];

			S2[String.fromCharCode(C2, C3)] = B3 + B4;
			S5[B3 + B4] = String.fromCharCode(C3);
		}
	}

	for (C1 = 0; C1 <= 192; C1 += 64) {
		for (C2 = 0; C2 <= 255; C2++) {
			for (C3 = 0; C3 <= 3; C3++) {
				let Sum = C3 * 65536 + C2 * 256 + C1;

				let B2 = base[bit32Extract(Sum, 6, 6)];
				let B3 = base[bit32Extract(Sum, 12, 6)];

				S4[B2 + B3] = String.fromCharCode(C2);
			}
		}
	}

	let padding = (-(Data.length) % 3 + 3) % 3; // Adjusted for JavaScript modulo behavior
	Data += "\0".repeat(padding);

	let resault = new Array(Math.floor(Data.length / 3) * 2 + 1);
	for (let i = 0; i < resault.length; i++) {
		resault[i] = "    ";
	}
	resault[0] = base[padding];

	let index = 1;
	for (let i = 0; i < Data.length; i += 3) {
		resault[index] = S1[Data.substring(i, i + 2)];
		resault[index + 1] = S2[Data.substring(i + 1, i + 3)];
		index += 2;
	}

	return resault;
}

function Base64Decode(alphabet, Data) {
	let base = {}; // BASE 16-64 IN UNICODE

	for (let i = 0; i <= 63; i++) {
		base[i] = alphabet[i];
		base[alphabet[i]] = i;
	}

	let S1 = {};
	let S2 = {};
	let S3 = {};
	let S4 = {};
	let S5 = {};

	let C1 = 0;
	let C2 = 0;
	let C3 = 0;

	for (C1 = 0; C1 <= 255; C1++) {
		for (C2 = 0; C2 <= 255; C2++) {
			let Sum = C3 * 65536 + C2 * 256 + C1;

			let B1 = base[bit32Extract(Sum, 0, 6)];
			let B2 = base[bit32Extract(Sum, 6, 6)];

			S1[String.fromCharCode(C1, C2)] = B1 + B2;
			S3[B1 + B2] = String.fromCharCode(C1);
		}
	}

	for (C2 = 0; C2 <= 255; C2++) {
		for (C3 = 0; C3 <= 255; C3++) {
			let Sum = C3 * 65536 + C2 * 256 + C1;

			let B3 = base[bit32Extract(Sum, 12, 6)];
			let B4 = base[bit32Extract(Sum, 18, 6)];

			S2[String.fromCharCode(C2, C3)] = B3 + B4;
			S5[B3 + B4] = String.fromCharCode(C3);
		}
	}

	for (C1 = 0; C1 <= 192; C1 += 64) {
		for (C2 = 0; C2 <= 255; C2++) {
			for (C3 = 0; C3 <= 3; C3++) {
				let Sum = C3 * 65536 + C2 * 256 + C1;

				let B2 = base[bit32Extract(Sum, 6, 6)];
				let B3 = base[bit32Extract(Sum, 12, 6)];

				S4[B2 + B3] = String.fromCharCode(C2);
			}
		}
	}
	
	// if type(Data) == "table" then Data = table.concat(Data) end
	let padding = base[Data[0]] || 1;
	let resault = new Array(Math.floor((Data.length - 1) / 4) * 3);
	for (let i = 0; i < resault.length; i++) {
		resault[i] = "   ";
	}

	let index = 0;
	for (let i = 1; i < Data.length; i += 4) {
		resault[index] = S3[Data.substring(i, i + 2)];
		resault[index + 1] = S4[Data.substring(i + 1, i + 3)];
		resault[index + 2] = S5[Data.substring(i + 2, i + 4)];
		index += 3;
	}
	
	return { resault, padding };
}

function Encode(Data, B64KEY, Passkey, Salt, plainkey, iteration) {
	if (Data === "" || Data === null || Data === undefined) return "CANNOT-RESOLVE";
	
	// let alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
	B64KEY = B64KEY || "no_b64key";
	Data = Base64Encode(remixBase64Alphabet(HLS.sha256(B64KEY)), Data);

	let encrypted = "";
	if (iteration === null || iteration === undefined || iteration === 0) iteration = 1;

	for (let i = 1; i <= iteration; i++) {
		if (i > 1) {
			let j = function(input) { return input.split(""); };
			encrypted = enc(j(encrypted), Passkey + i.toString(), Salt + i.toString(), plainkey + i.toString());
		} else {
			encrypted = enc(Data, Passkey + i.toString(), Salt + i.toString(), plainkey + i.toString());
		}
	}

	return encrypted;
}

function Decode(Data, B64KEY, Passkey, Salt, plainkey, iteration) {
	if (Data === "E" || Data === "" || Data === null || Data === undefined) return "CANNOT-RESOLVE";
	if (iteration === null || iteration === undefined || iteration === 0) iteration = 1;

	for (let i = 1; i <= iteration; i++) {
		Data = dec(Data, Passkey + i.toString(), Salt + i.toString(), plainkey + i.toString());
	}
	
	// let alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
	B64KEY = B64KEY || "no_b64key";
	let result = Base64Decode(remixBase64Alphabet(HLS.sha256(B64KEY)), Data);
	Data = result.resault;
	let padding = result.padding;
	
	for (let i = 0; i < Data.length; i++) {
		Data[i] = Data[i] || String.fromCharCode(Math.floor(Math.random() * (122 - 32 + 1)) + 32);
	}
	
	let concatted;
	try {
		concatted = Data.join("");
		return concatted.substring(0, concatted.length - padding);
	} catch (error) {
		return "DECODE-FAILED";
	}
}

// named as En/Decode for easier reference since it was first made based on Base64, then encrypted.
module.exports = {
	encode: Encode,
	decode: Decode,
	
	standardB64A: standardAlphabet,
	ReMixBase64: remixBase64Alphabet,
	cBase64Encode: Base64Encode,
	cBase64Decode: Base64Decode,
	
	// HLS: HLS, // Uncomment if you want to expose HLS
	// fHLS: script.Parent:WaitForChild("HashLib"), // Roblox specific - not applicable in JavaScript
};
