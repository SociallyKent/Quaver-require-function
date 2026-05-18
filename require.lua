local Reader = read()
function require(CODE)
	local Code = Reader[CODE]
	Code = Code
		:gsub("%-%-%[%[.-%]%]", "")--remove --[[]] comments
		:gsub("%-%-.-\n", "\n")--remove -- comments
		:gsub("%\n#.-\n", "\n")--remove # comments
		:gsub("\n?return%s+"..CODE.."%s*$", "")--remove "return CODE"
	eval(Code)
	return expr(Code) end
