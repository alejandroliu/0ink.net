/***************************************************************************** 
 *
 * chartbl.h is a character table for the xmacroplay utility
 * Copyright (C) 2000 Gabor Keresztfalvi <keresztg@mail.com>
 *
 * Contains character to keysym name conversion tables.
 *
 * This program is free software; you can redistribute it and/or modify it  
 * under the terms of the GNU General Public License as published by the  
 * Free Software Foundation; either version 2 of the License, or (at your 
 * option) any later version.
 *	
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
 * for more details.
 *	
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 ****************************************************************************/

/* Version 0.1 (20000817) probably still incomplete... */

char *chartbl_lat1[] =
{
	"",		//   0  0
	"",		//   1  1
	"",		//   2  2
	"",		//   3  3
	"",		//   4  4
	"",		//   5  5
	"",		//   6  6
	"",		//   7  7
	"BackSpace",	//   8  8
	"Tab",		//   9  9
	"",		//  10  A
	"",		//  11  B
	"",		//  12  C
	"Return",	//  13  D
	"",		//  14  E
	"",		//  15  F
	"",		//  16 10
	"",		//  17 11
	"",		//  18 12
	"",		//  19 13
	"",		//  20 14
	"",		//  21 15
	"",		//  22 16
	"",		//  23 17
	"",		//  24 18
	"",		//  25 19
	"",		//  26 1A
	"Escape",	//  27 1B
	"",		//  28 1C
	"",		//  29 1D
	"",		//  30 1E
	"",		//  31 1F
	"space",	//  32 20
	"exclam",	//  33 21
	"quotedbl",	//  34 22
	"numbersign",	//  35 23
	"dollar",	//  36 24
	"percent",	//  37 25
	"ampersand",	//  38 26
	"apostrophe",	//  39 27
	"parenleft",	//  40 28
	"parenright",	//  41 29
	"asterisk",	//  42 2A
	"plus",		//  43 2B
	"comma",	//  44 2C
	"minus",	//  45 2D
	"period",	//  46 2E
	"slash",	//  47 2F
	"0",		//  48 30
	"1",		//  49 31
	"2",		//  50 32
	"3",		//  51 33
	"4",		//  52 34
	"5",		//  53 35
	"6",		//  54 36
	"7",		//  55 37
	"8",		//  56 38
	"9",		//  57 39
	"colon",	//  58 3A
	"semicolon",	//  59 3B
	"less",		//  60 3C
	"equal",	//  61 3D
	"greater",	//  62 3E
	"question",	//  63 3F
	"at",		//  64 40
	"A",		//  65 41
	"B",		//  66 42
	"C",		//  67 43
	"D",		//  68 44
	"E",		//  69 45
	"F",		//  70 46
	"G",		//  71 47
	"H",		//  72 48
	"I",		//  73 49
	"J",		//  74 4A
	"K",		//  75 4B
	"L",		//  76 4C
	"M",		//  77 4D
	"N",		//  78 4E
	"O",		//  79 4F
	"P",		//  80 50
	"Q",		//  81 51
	"R",		//  82 52
	"S",		//  83 53
	"T",		//  84 54
	"U",		//  85 55
	"V",		//  86 56
	"W",		//  87 57
	"X",		//  88 58
	"Y",		//  89 59
	"Z",		//  90 5A
	"bracketleft",	//  91 5B
	"backslash",	//  92 5C
	"bracketright",	//  93 5D
	"asciicircum",	//  94 5E
	"underscore",	//  95 5F
	"grave",	//  96 60
	"a",		//  97 61
	"b",		//  98 62
	"c",		//  99 63
	"d",		// 100 64
	"e",		// 101 65
	"f",		// 102 66
	"g",		// 103 67
	"h",		// 104 68
	"i",		// 105 69
	"j",		// 106 6A
	"k",		// 107 6B
	"l",		// 108 6C
	"m",		// 109 6D
	"n",		// 110 6E
	"o",		// 111 6F
	"p",		// 112 70
	"q",		// 113 71
	"r",		// 114 72
	"s",		// 115 73
	"t",		// 116 74
	"u",		// 117 75
	"v",		// 118 76
	"w",		// 119 77
	"x",		// 120 78
	"y",		// 121 79
	"z",		// 122 7A
	"braceleft",	// 123 7B
	"bar",		// 124 7C
	"braceright",	// 125 7D
	"asciitilde",	// 126 7E
	"Delete",	// 127 7F
	"",		// 128 80
	"",		// 129 81
	"",		// 130 82
	"",		// 131 83
	"",		// 132 84
	"",		// 133 85
	"",		// 134 86
	"",		// 135 87
	"",		// 136 88
	"",		// 137 89
	"",		// 138 8A
	"",		// 139 8B
	"",		// 140 8C
	"",		// 141 8D
	"",		// 142 8E
	"",		// 143 8F
	"",		// 144 90
	"",		// 145 91
	"",		// 146 92
	"",		// 147 93
	"",		// 148 94
	"",		// 149 95
	"",		// 150 96
	"",		// 151 97
	"",		// 152 98
	"",		// 153 99
	"",		// 154 9A
	"",		// 155 9B
	"",		// 156 9C
	"",		// 157 9D
	"",		// 158 9E
	"",		// 159 9F
	"nobreakspace",	// 160 A0
	"exclamdown",	// 161 A1
	"cent",		// 162 A2
	"sterling",	// 163 A3
	"currency",	// 164 A4
	"yen",		// 165 A5
	"brokenbar",	// 166 A6
	"section",	// 167 A7
	"diaeresis",	// 168 A8
	"copyright",	// 169 A9
	"ordfeminine",	// 170 AA
	"guillemotleft",// 171 AB
	"notsign",	// 172 AC
	"hyphen",	// 173 AD
	"registered",	// 174 AE
	"macron",	// 175 AF
	"degree",	// 176 B0
	"plusminus",	// 177 B1
	"twosuperior",	// 178 B2
	"threesuperior",// 179 B3
	"acute",	// 180 B4
	"mu",		// 181 B5
	"paragraph",	// 182 B6
	"periodcentered",// 183 B7
	"cedilla",	// 184 B8
	"onesuperior",	// 185 B9
	"masculine",	// 186 BA
	"guillemotright",// 187 BB
	"onequarter",	// 188 BC
	"onehalf",	// 189 BD
	"threequarters",// 190 BE
	"questiondown",	// 191 BF
	"Agrave",	// 192 C0
	"Aacute",	// 193 C1
	"Acircumflex",	// 194 C2
	"Atilde",	// 195 C3
	"Adiaeresis",	// 196 C4
	"Aring",	// 197 C5
	"AE",		// 198 C6
	"Ccedilla",	// 199 C7
	"Egrave",	// 200 C8
	"Eacute",	// 201 C9
	"Ecircumflex",	// 202 CA
	"Ediaeresis",	// 203 CB
	"Igrave",	// 204 CC
	"Iacute",	// 205 CD
	"Icircumflex",	// 206 CE
	"Idiaeresis",	// 207 CF
	"ETH",		// 208 D0
	"Ntilde",	// 209 D1
	"Ograve",	// 210 D2
	"Oacute",	// 211 D3
	"Ocircumflex",	// 212 D4
	"Otilde",	// 213 D5
	"Odiaeresis",	// 214 D6
	"multiply",	// 215 D7
	"Ooblique",	// 216 D8
	"Ugrave",	// 217 D9
	"Uacute",	// 218 DA
	"Ucircumflex",	// 219 DB
	"Udiaeresis",	// 220 DC
	"Yacute",	// 221 DD
	"THORN",	// 222 DE
	"ssharp",	// 223 DF
	"agrave",	// 224 E0
	"aacute",	// 225 E1
	"acircumflex",	// 226 E2
	"atilde",	// 227 E3
	"adiaeresis",	// 228 E4
	"aring",	// 229 E5
	"ae",		// 230 E6
	"ccedilla",	// 231 E7
	"egrave",	// 232 E8
	"eacute",	// 233 E9
	"ecircumflex",	// 234 EA
	"ediaeresis",	// 235 EB
	"igrave",	// 236 EC
	"iacute",	// 237 ED
	"icircumflex",	// 238 EE
	"idiaeresis",	// 239 EF
	"eth",		// 240 F0
	"ntilde",	// 241 F1
	"ograve",	// 242 F2
	"oacute",	// 243 F3
	"ocircumflex",	// 244 F4
	"otilde",	// 245 F5
	"odiaeresis",	// 246 F6
	"division",	// 247 F7
	"oslash",	// 248 F8
	"ugrave",	// 249 F9
	"uacute",	// 250 FA
	"ucircumflex",	// 251 FB
	"udiaeresis",	// 252 FC
	"yacute",	// 253 FD
	"thorn",	// 254 FE
	"ydiaeresis",	// 255 FF
};

char *chartbl_lat2[] =
{
	"",		//   0  0
	"",		//   1  1
	"",		//   2  2
	"",		//   3  3
	"",		//   4  4
	"",		//   5  5
	"",		//   6  6
	"",		//   7  7
	"BackSpace",	//   8  8
	"Tab",		//   9  9
	"",		//  10  A
	"",		//  11  B
	"",		//  12  C
	"Return",	//  13  D
	"",		//  14  E
	"",		//  15  F
	"",		//  16 10
	"",		//  17 11
	"",		//  18 12
	"",		//  19 13
	"",		//  20 14
	"",		//  21 15
	"",		//  22 16
	"",		//  23 17
	"",		//  24 18
	"",		//  25 19
	"",		//  26 1A
	"Escape",	//  27 1B
	"",		//  28 1C
	"",		//  29 1D
	"",		//  30 1E
	"",		//  31 1F
	"space",	//  32 20
	"exclam",	//  33 21
	"quotedbl",	//  34 22
	"numbersign",	//  35 23
	"dollar",	//  36 24
	"percent",	//  37 25
	"ampersand",	//  38 26
	"apostrophe",	//  39 27
	"parenleft",	//  40 28
	"parenright",	//  41 29
	"asterisk",	//  42 2A
	"plus",		//  43 2B
	"comma",	//  44 2C
	"minus",	//  45 2D
	"period",	//  46 2E
	"slash",	//  47 2F
	"0",		//  48 30
	"1",		//  49 31
	"2",		//  50 32
	"3",		//  51 33
	"4",		//  52 34
	"5",		//  53 35
	"6",		//  54 36
	"7",		//  55 37
	"8",		//  56 38
	"9",		//  57 39
	"colon",	//  58 3A
	"semicolon",	//  59 3B
	"less",		//  60 3C
	"equal",	//  61 3D
	"greater",	//  62 3E
	"question",	//  63 3F
	"at",		//  64 40
	"A",		//  65 41
	"B",		//  66 42
	"C",		//  67 43
	"D",		//  68 44
	"E",		//  69 45
	"F",		//  70 46
	"G",		//  71 47
	"H",		//  72 48
	"I",		//  73 49
	"J",		//  74 4A
	"K",		//  75 4B
	"L",		//  76 4C
	"M",		//  77 4D
	"N",		//  78 4E
	"O",		//  79 4F
	"P",		//  80 50
	"Q",		//  81 51
	"R",		//  82 52
	"S",		//  83 53
	"T",		//  84 54
	"U",		//  85 55
	"V",		//  86 56
	"W",		//  87 57
	"X",		//  88 58
	"Y",		//  89 59
	"Z",		//  90 5A
	"bracketleft",	//  91 5B
	"backslash",	//  92 5C
	"bracketright",	//  93 5D
	"asciicircum",	//  94 5E
	"underscore",	//  95 5F
	"grave",	//  96 60
	"a",		//  97 61
	"b",		//  98 62
	"c",		//  99 63
	"d",		// 100 64
	"e",		// 101 65
	"f",		// 102 66
	"g",		// 103 67
	"h",		// 104 68
	"i",		// 105 69
	"j",		// 106 6A
	"k",		// 107 6B
	"l",		// 108 6C
	"m",		// 109 6D
	"n",		// 110 6E
	"o",		// 111 6F
	"p",		// 112 70
	"q",		// 113 71
	"r",		// 114 72
	"s",		// 115 73
	"t",		// 116 74
	"u",		// 117 75
	"v",		// 118 76
	"w",		// 119 77
	"x",		// 120 78
	"y",		// 121 79
	"z",		// 122 7A
	"braceleft",	// 123 7B
	"bar",		// 124 7C
	"braceright",	// 125 7D
	"asciitilde",	// 126 7E
	"Delete",	// 127 7F
	"",		// 128 80
	"",		// 129 81
	"",		// 130 82
	"",		// 131 83
	"",		// 132 84
	"",		// 133 85
	"",		// 134 86
	"",		// 135 87
	"",		// 136 88
	"",		// 137 89
	"",		// 138 8A
	"",		// 139 8B
	"",		// 140 8C
	"",		// 141 8D
	"",		// 142 8E
	"",		// 143 8F
	"",		// 144 90
	"",		// 145 91
	"",		// 146 92
	"",		// 147 93
	"",		// 148 94
	"",		// 149 95
	"",		// 150 96
	"",		// 151 97
	"",		// 152 98
	"",		// 153 99
	"",		// 154 9A
	"",		// 155 9B
	"",		// 156 9C
	"",		// 157 9D
	"",		// 158 9E
	"",		// 159 9F
	"nobreakspace",	// 160 A0
	"Aogonek",	// 161 A1
	"breve",	// 162 A2
	"Lstroke",	// 163 A3
	"currency",	// 164 A4
	"Lcaron",	// 165 A5
	"Sacute",	// 166 A6
	"section",	// 167 A7
	"diaeresis",	// 168 A8
	"Scaron",	// 169 A9
	"Scedilla",	// 170 AA
	"Tcaron",	// 171 AB
	"Zacute",	// 172 AC
	"hyphen",	// 173 AD
	"Zcaron",	// 174 AE
	"Zabovedot",	// 175 AF
	"degree",	// 176 B0
	"aogonek",	// 177 B1
	"ogonek",	// 178 B2
	"lstroke",	// 179 B3
	"acute",	// 180 B4
	"lcaron",	// 181 B5
	"sacute",	// 182 B6
	"caron",	// 183 B7
	"cedilla",	// 184 B8
	"scaron",	// 185 B9
	"scedilla",	// 186 BA
	"tcaron",	// 187 BB
	"zacute",	// 188 BC
	"doubleacute",	// 189 BD
	"zcaron",	// 190 BE
	"zabovedot",	// 191 BF
	"Racute",	// 192 C0
	"Aacute",	// 193 C1
	"Acircumflex",	// 194 C2
	"Abreve",	// 195 C3
	"Adiaeresis",	// 196 C4
	"Lacute",	// 197 C5
	"Cacute",	// 198 C6
	"Ccedilla",	// 199 C7
	"Ccaron",	// 200 C8
	"Eacute",	// 201 C9
	"Eogonek",	// 202 CA
	"Ediaeresis",	// 203 CB
	"Ecaron",	// 204 CC
	"Iacute",	// 205 CD
	"Icircumflex",	// 206 CE
	"Dacron",	// 207 CF
	"Dstroke",	// 208 D0
	"Nacute",	// 209 D1
	"Ncaron",	// 210 D2
	"Oacute",	// 211 D3
	"Ocircumflex",	// 212 D4
	"Odoubleacute",	// 213 D5
	"Odiaeresis",	// 214 D6
	"multiply",	// 215 D7
	"Rcaron",	// 216 D8
	"Uring",	// 217 D9
	"Uacute",	// 218 DA
	"Udoubleacute",	// 219 DB
	"Udiaeresis",	// 220 DC
	"Yacute",	// 221 DD
	"Tcedilla",	// 222 DE
	"ssharp",	// 223 DF
	"racute",	// 224 E0
	"aacute",	// 225 E1
	"acircumflex",	// 226 E2
	"abreve",	// 227 E3
	"adiaeresis",	// 228 E4
	"lacute",	// 229 E5
	"cacute",	// 230 E6
	"ccedilla",	// 231 E7
	"ccaron",	// 232 E8
	"eacute",	// 233 E9
	"eogonek",	// 234 EA
	"ediaeresis",	// 235 EB
	"ecaron",	// 236 EC
	"iacute",	// 237 ED
	"icircumflex",	// 238 EE
	"dcaron",	// 239 EF
	"dstroke",	// 240 F0
	"nacute",	// 241 F1
	"ncaron",	// 242 F2
	"oacute",	// 243 F3
	"ocircumflex",	// 244 F4
	"odoubleacute",	// 245 F5
	"odiaeresis",	// 246 F6
	"division",	// 247 F7
	"rcaron",	// 248 F8
	"uring",	// 249 F9
	"uacute",	// 250 FA
	"udoubleacute",	// 251 FB
	"udiaeresis",	// 252 FC
	"yacute",	// 253 FD
	"tcedilla",	// 254 FE
	"abovedot",	// 255 FF
};

char **chartbl[]={ chartbl_lat1, chartbl_lat2 };