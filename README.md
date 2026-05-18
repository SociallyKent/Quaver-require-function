say I want this custom table function 
```
table.copy = function(TABLE)
	local Table = {}
	if next(TABLE) == 1 then
		for i, v in ipairs(TABLE) do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	else--if table has keys, clone that too
		for i, v in next, TABLE do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	end
	return Table end
```
; turn it to a string
```lua
[[ ]]
```
```lua
" "
```
```lua
' '
```
Any of these work

[[ ]] is what I personally like, no formating needed  ( it also looks quite pretty in the .yaml)
```lua
[[
table.copy = function(TABLE)
	local Table = {}
	if next(TABLE) == 1 then
		for i, v in ipairs(TABLE) do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	else--if table has keys, clone that too
		for i, v in next, TABLE do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	end
	return Table end
]]
```
, and add it's call to return it's values
```lua
[[
table.copy = function(TABLE)
	local Table = {}
	if next(TABLE) == 1 then
		for i, v in ipairs(TABLE) do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	else--if table has keys, clone that too
		for i, v in next, TABLE do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	end
	return Table end
	
return table
]]
```
done!

Though, it's not very useful just yet.
```lua
code = {}
```
```lua
code.table =
[[
table.copy = function(TABLE)
	local Table = {}
	if next(TABLE) == 1 then
		for i, v in ipairs(TABLE) do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	else--if table has keys, clone that too
		for i, v in next, TABLE do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	end
	return Table end
	
return table
]]
```
```lua
write(code)--write to yaml file
```
Now it's in your .yaml file, sorted and ready for the function call!

You can kill all of it and replace with the require script (if not already prior)
```lua
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
```
The local varable outside function require, is optional
```lua
local Reader = read()
function require(CODE)
	local Code = Reader[CODE]
```
```lua
function require(CODE)
	local Code = read()[CODE]--though here read() would call every time require does
```
For custom tables
```lua
gather = {}

code.gather =
[[

return gather
]]
```
```lua
code.gather =
[[
gather = {}

return gather
]]
```
just needs to be defined prior or within the code.

These are a few favorites of mine
```lua
code = {}
code.mouse =--[[requires math.minmax]]
[[
mouse = {}
local MouseRelease, MousePress, MousePos
MouseRelease = imgui.IsMouseReleased
MousePress = imgui.IsMouseClicked
MousePos = imgui.GetMousePos

mouse.down = imgui.IsMouseDown
mouse.x, mouse.y =
	function() return MousePos()[1] end,
	function() return MousePos()[2] end
mouse.pos = function()
	local Pos = MousePos()
	return Pos[1], Pos[2]
end
--[numeric]
mouse.release = function(MOUSE)
	if MouseRelease(MOUSE) then
		return true, mouse.pos() end
end
--[numeric]
mouse.press = function(MOUSE)
	if MousePress(MOUSE) then
		return true, mouse.pos() end
end
mouse.rect = function(BOOLEAN, X, Y, Z, W)
	if not BOOLEAN then return false end
	local Xm, Ym = mouse.pos()
	Y, W = math.minmax(Y, Y + W)
	X, Z = math.minmax(X, X + Z)
	return (Xm >= X) and (Xm <= Z) and (Ym >= Y) and (Ym <= W)
end
return mouse
]]
code.board =
[[
board = {}
local BoardDown, KeyIndex
local KeyIndex = {}
BoardDown = utils.IsKeyDown
board.down = BoardDown
--[string]
board.press = function(KEY)
	local Prev = KeyIndex[KEY]
	KeyIndex[KEY] = BoardDown(KEY:upper())
	local Held = KeyIndex[KEY]
	return (Held and not Prev), Held
end
--[string]
function board.release(KEY)
	local Prev = KeyIndex[KEY]
	KeyIndex[KEY] = BoardDown(KEY:upper())
	local Held = KeyIndex[KEY]
	return (not Held and Prev), Held
end
return board
]]
code.math =
[[
--[numeric, numeric]
math.binary = function(NUM, PRECISION)
	return math.floor(NUM*PRECISION + 0.5)/PRECISION end
--[numeric]
math.factor = function(NUM)
	if NUM == 1 then return 1 end
	local Max = math.ceil(math.sqrt(NUM))
	for i = 2, Max do
		if NUM % i == 0 then
			return NUM/i, i
	end end
	return NUM, 1 end
# linear interpolation
--[numeric, numreic, numeric]
math.lerp = function(A, B, T)
	return A + (B - A)*T end
# Returns both the min and max of given numbers
--[numerics¿...]
math.minmax = function(...)
	return math.min(...), math.max(...) end
--[numeric, ¿numeric]
math.round = function(NUM, DECIMAL)
	local Notation = 10^(DECIMAL or 0)
	return math.floor(NUM*Notation + 0.5)/Notation end
# wrapper, keeps negative values
--[numeric, numeric]
math.wrap = function(A, B)
	local a, b = math.modf(A/B)
	return math.round(B*b, 12), a end
# wrapper, always positive
--[numeric, numeric]
math.wrapAbs = function(A, B)
	return A%B, A/B end


math.infinity = 1/0
math.tiniest = -math.infinity
math.tiny = -math.huge
math.null = 0/0--Not a Number (NaN)
# renames
math.split = math.modf
# shortcuts
abs = math.abs
ceil = math.ceil
floor = math.floor
max = math.max
min = math.min
modf = math.modf
fmod = math.fmod
random = math.random
return math
]]

write(code)
```
```lua
function awake()
	require("math")
	mouse = require("mouse")
	board = require("board")
end
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
```
Currently,
```lua
[table] = require("[table]")
```
is just equal to
```lua
[tableA] = [tableB]
```
As [table] was already defined globally inside the code.

I plan to add support for defining your's as a local
```
local [table] = {}
```
But, for now it's always globel

Supports native lua notes
```lua
single line
-- Hi!
```
```lua
mutli line
--[[
I'm a
comment!
]]
```
and also .yaml too
```yaml
single line
# and me too!
```

While testing it yourself, you might find that you can't use multi line comments.

This is because
```lua
[[
]]
```
```lua
--[[
]]
```
both expect
```
]]
```
as their end. And will have a battle to death with each other for who gets it (metaphorically)

to midigate this,
```lua
[=[
--[[
]]
]=]
```
now it works! 

Currently there is no support for it the other way around
```lua
[[
--[=[
]=]
]]
```
It's not hard to add I'm just tired of working with strings right now.
