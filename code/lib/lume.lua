--
-- lume
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local lume = { _version = "2.3.0" }

local pairs, ipairs = pairs, ipairs
local type, assert, unpack = type, assert, unpack or table.unpack
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2 or math.atan
local math_sqrt = math.sqrt
local math_abs = math.abs

local noop = function() end
lume.noop = noop -- @muu:追加

local identity = function(x)
  return x
end

local patternescape = function(str)
  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

local absindex = function(len, i)
  return i < 0 and (len + i + 1) or i
end

local iscallable = function(x)
  if type(x) == "function" then return true end
  local mt = getmetatable(x)
  return mt and mt.__call ~= nil
end

local getiter = function(x)
  if lume.isarray(x) then
    return ipairs
  elseif type(x) == "table" then
    return pairs
  end
  error("expected table", 3)
end

local iteratee = function(x)
  if x == nil then return identity end
  if iscallable(x) then return x end
  if type(x) == "table" then
    return function(z)
      for k, v in pairs(x) do
        if z[k] ~= v then return false end
      end
      return true
    end
  end
  return function(z) return z[x] end
end



function lume.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end


function lume.round(x, increment)
  if increment then return lume.round(x / increment) * increment end
  return x >= 0 and math_floor(x + .5) or math_ceil(x - .5)
end


function lume.sign(x)
  return x < 0 and -1 or 1
end


function lume.lerp(a, b, amount)
  return a + (b - a) * lume.clamp(amount, 0, 1)
end


function lume.smooth(a, b, amount)
  local t = lume.clamp(amount, 0, 1)
  local m = t * t * (3 - 2 * t)
  return a + (b - a) * m
end


function lume.pingpong(x)
  return 1 - math_abs(1 - x % 2)
end


function lume.distance(x1, y1, x2, y2, squared)
  local dx = x1 - x2
  local dy = y1 - y2
  local s = dx * dx + dy * dy
  return squared and s or math_sqrt(s)
end


function lume.angle(x1, y1, x2, y2)
  return math_atan2(y2 - y1, x2 - x1)
end


function lume.vector(angle, magnitude)
  return math.cos(angle) * magnitude, math.sin(angle) * magnitude
end


function lume.random(a, b)
  if not a then a, b = 0, 1 end
  if not b then b = 0 end
  return a + math.random() * (b - a)
end


function lume.randomchoice(t)
  return t[math.random(#t)]
end


function lume.weightedchoice(t)
  local sum = 0
  for _, v in pairs(t) do
    assert(v >= 0, "weight value less than zero")
    sum = sum + v
  end
  assert(sum ~= 0, "all weights are zero")
  local rnd = lume.random(sum)
  for k, v in pairs(t) do
    if rnd < v then return k end
    rnd = rnd - v
  end
end


function lume.isarray(x)
  return type(x) == "table" and x[1] ~= nil
end


function lume.push(t, ...)
  local n = select("#", ...)
  for i = 1, n do
    t[#t + 1] = select(i, ...)
  end
  return ...
end


function lume.remove(t, x)
  local iter = getiter(t)
  for i, v in iter(t) do
    if v == x then
      if lume.isarray(t) then
        table.remove(t, i)
        break
      else
        t[i] = nil
        break
      end
    end
  end
  return x
end


function lume.clear(t)
  local iter = getiter(t)
  for k in iter(t) do
    t[k] = nil
  end
  return t
end


function lume.extend(t, ...)
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if x then
      for k, v in pairs(x) do
        t[k] = v
      end
    end
  end
  return t
end


function lume.shuffle(t)
  local rtn = {}
  for i = 1, #t do
    local r = math.random(i)
    if r ~= i then
      rtn[i] = rtn[r]
    end
    rtn[r] = t[i]
  end
  return rtn
end


function lume.sort(t, comp)
  local rtn = lume.clone(t)
  if comp then
    if type(comp) == "string" then
      table.sort(rtn, function(a, b) return a[comp] < b[comp] end)
    else
      table.sort(rtn, comp)
    end
  else
    table.sort(rtn)
  end
  return rtn
end


function lume.array(...)
  local t = {}
  for x in ... do t[#t + 1] = x end
  return t
end


function lume.each(t, fn, ...)
  local iter = getiter(t)
  if type(fn) == "string" then
    for _, v in iter(t) do v[fn](v, ...) end
  else
    for _, v in iter(t) do fn(v, ...) end
  end
  return t
end


function lume.map(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  local rtn = {}
  for k, v in iter(t) do rtn[k] = fn(v) end
  return rtn
end


function lume.all(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  for _, v in iter(t) do
    if not fn(v) then return false end
  end
  return true
end


function lume.any(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  for _, v in iter(t) do
    if fn(v) then return true end
  end
  return false
end


function lume.reduce(t, fn, first)
  local started = first ~= nil
  local acc = first
  local iter = getiter(t)
  for _, v in iter(t) do
    if started then
      acc = fn(acc, v)
    else
      acc = v
      started = true
    end
  end
  assert(started, "reduce of an empty table with no first value")
  return acc
end


function lume.unique(t)
  local rtn = {}
  for k in pairs(lume.invert(t)) do
    rtn[#rtn + 1] = k
  end
  return rtn
end


function lume.filter(t, fn, retainkeys)
  fn = iteratee(fn)
  local iter = getiter(t)
  local rtn = {}
  if retainkeys then
    for k, v in iter(t) do
      if fn(v) then rtn[k] = v end
    end
  else
    for _, v in iter(t) do
      if fn(v) then rtn[#rtn + 1] = v end
    end
  end
  return rtn
end


function lume.reject(t, fn, retainkeys)
  fn = iteratee(fn)
  local iter = getiter(t)
  local rtn = {}
  if retainkeys then
    for k, v in iter(t) do
      if not fn(v) then rtn[k] = v end
    end
  else
    for _, v in iter(t) do
      if not fn(v) then rtn[#rtn + 1] = v end
    end
  end
  return rtn
end


function lume.merge(...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    local iter = pairs--getiter(t) @muu変更 辞書専用とした。
    for k, v in iter(t) do
      rtn[k] = v
    end
  end
  return rtn
end


function lume.concat(...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    if t ~= nil then
      local iter = ipairs --getiter(t) @muu変更 配列専用とした
      for _, v in iter(t) do
        rtn[#rtn + 1] = v
      end
    end
  end
  return rtn
end


function lume.find(t, value)
  local iter = getiter(t)
  for k, v in iter(t) do
    if v == value then return k end
  end
  return nil
end


function lume.match(t, fn)
  fn = iteratee(fn)
  local iter = getiter(t)
  for k, v in iter(t) do
    if fn(v) then return v, k end
  end
  return nil
end


function lume.count(t, fn)
  local count = 0
  local iter = getiter(t)
  if fn then
    fn = iteratee(fn)
    for _, v in iter(t) do
      if fn(v) then count = count + 1 end
    end
  else
    if lume.isarray(t) then
      return #t
    end
    for _ in iter(t) do count = count + 1 end
  end
  return count
end


function lume.slice(t, i, j)
  i = i and absindex(#t, i) or 1
  j = j and absindex(#t, j) or #t
  local rtn = {}
  for x = i < 1 and 1 or i, j > #t and #t or j do
    rtn[#rtn + 1] = t[x]
  end
  return rtn
end


function lume.first(t, n)
  if not n then return t[1] end
  return lume.slice(t, 1, n)
end


function lume.last(t, n)
  if not n then return t[#t] end
  return lume.slice(t, -n, -1)
end


function lume.invert(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[v] = k end
  return rtn
end


function lume.pick(t, ...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local k = select(i, ...)
    rtn[k] = t[k]
  end
  return rtn
end


function lume.keys(t)
  local rtn = {}
  local iter = getiter(t)
  for k in iter(t) do rtn[#rtn + 1] = k end
  return rtn
end


function lume.clone(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[k] = v end
  return rtn
end


function lume.fn(fn, ...)
  assert(iscallable(fn), "expected a function as the first argument")
  local args = { ... }
  return function(...)
    local a = lume.concat(args, { ... })
    return fn(unpack(a))
  end
end


function lume.once(fn, ...)
  local f = lume.fn(fn, ...)
  local done = false
  return function(...)
    if done then return end
    done = true
    return f(...)
  end
end


local memoize_fnkey = {}
local memoize_nil = {}

function lume.memoize(fn)
  local cache = {}
  return function(...)
    local c = cache
    for i = 1, select("#", ...) do
      local a = select(i, ...) or memoize_nil
      c[a] = c[a] or {}
      c = c[a]
    end
    c[memoize_fnkey] = c[memoize_fnkey] or {fn(...)}
    return unpack(c[memoize_fnkey])
  end
end


function lume.combine(...)
  local n = select('#', ...)
  if n == 0 then return noop end
  if n == 1 then
    local fn = select(1, ...)
    if not fn then return noop end
    assert(iscallable(fn), "expected a function or nil")
    return fn
  end
  local funcs = {}
  for i = 1, n do
    local fn = select(i, ...)
    if fn ~= nil then
      assert(iscallable(fn), "expected a function or nil")
      funcs[#funcs + 1] = fn
    end
  end
  return function(...)
    for _, f in ipairs(funcs) do f(...) end
  end
end


function lume.call(fn, ...)
  if fn then
    return fn(...)
  end
end


function lume.time(fn, ...)
  local start = os.clock()
  local rtn = {fn(...)}
  return (os.clock() - start), unpack(rtn)
end


local lambda_cache = {}

function lume.lambda(str)
  if not lambda_cache[str] then
    local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
    assert(args and body, "bad string lambda")
    local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
    lambda_cache[str] = lume.dostring(s)
  end
  return lambda_cache[str]
end


local serialize

local serialize_map = {
  [ "boolean" ] = tostring,
  [ "nil"     ] = tostring,
  [ "string"  ] = function(v) return string.format("%q", v) end,
  [ "number"  ] = function(v)
    if      v ~=  v     then return  "0/0"      --  nan
    elseif  v ==  1 / 0 then return  "1/0"      --  inf
    elseif  v == -1 / 0 then return "-1/0" end  -- -inf
    return tostring(v)
  end,
  [ "table"   ] = function(t, stk)
    stk = stk or {}
    if stk[t] then error("circular reference") end
    local rtn = {}
    stk[t] = true
    for k, v in pairs(t) do
      rtn[#rtn + 1] = "[" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
    end
    stk[t] = nil
    return "{" .. table.concat(rtn, ",") .. "}"
  end
}

setmetatable(serialize_map, {
  __index = function(_, k) error("unsupported serialize type: " .. k) end
})

serialize = function(x, stk)
  return serialize_map[type(x)](x, stk)
end

function lume.serialize(x)
  return serialize(x)
end


function lume.deserialize(str)
  return lume.dostring("return " .. str)
end


function lume.split(str, sep)
  if not sep then
    return lume.array(str:gmatch("([%S]+)"))
  else
    assert(sep ~= "", "empty separator")
    local psep = patternescape(sep)
    return lume.array((str..sep):gmatch("(.-)("..psep..")"))
  end
end


function lume.trim(str, chars)
  if not chars then return str:match("^[%s]*(.-)[%s]*$") end
  chars = patternescape(chars)
  return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end


function lume.wordwrap(str, limit)
  limit = limit or 72
  local check
  if type(limit) == "number" then
    check = function(s) return #s >= limit end
  else
    check = limit
  end
  local rtn = {}
  local line = ""
  for word, spaces in str:gmatch("(%S+)(%s*)") do
    local s = line .. word
    if check(s) then
      table.insert(rtn, line .. "\n")
      line = word
    else
      line = s
    end
    for c in spaces:gmatch(".") do
      if c == "\n" then
        table.insert(rtn, line .. "\n")
        line = ""
      else
        line = line .. c
      end
    end
  end
  table.insert(rtn, line)
  return table.concat(rtn)
end


function lume.format(str, vars)
  if not vars then return str end
  local f = function(x)
    return tostring(vars[x] or vars[tonumber(x)] or "{" .. x .. "}")
  end
  return (str:gsub("{(.-)}", f))
end


function lume.trace(...)
  local info = debug.getinfo(2, "Sl")
  local t = { info.short_src .. ":" .. info.currentline .. ":" }
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = string.format("%g", lume.round(x, .01))
    end
    t[#t + 1] = tostring(x)
  end
  print(table.concat(t, " "))
end


function lume.dostring(str)
  return assert((loadstring or load)(str))()
end


function lume.uuid()
  local fn = function(x)
    local r = math.random(16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
  end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end


function lume.hotswap(modname)
  local oldglobal = lume.clone(_G)
  local updated = {}
  local function update(old, new)
    if updated[old] then return end
    updated[old] = true
    local oldmt, newmt = getmetatable(old), getmetatable(new)
    if oldmt and newmt then update(oldmt, newmt) end
    for k, v in pairs(new) do
      if type(v) == "table" then update(old[k], v) else old[k] = v end
    end
  end
  local err = nil
  local function onerror(e)
    for k in pairs(_G) do _G[k] = oldglobal[k] end
    err = lume.trim(e)
  end
  local ok, oldmod = pcall(require, modname)
  oldmod = ok and oldmod or nil
  xpcall(function()
    package.loaded[modname] = nil
    local newmod = require(modname)
    if type(oldmod) == "table" then update(oldmod, newmod) end
    for k, v in pairs(oldglobal) do
      if v ~= _G[k] and type(v) == "table" then
        update(v, _G[k])
        _G[k] = v
      end
    end
  end, onerror)
  package.loaded[modname] = oldmod
  if err then return nil, err end
  return oldmod
end


local ripairs_iter = function(t, i)
  i = i - 1
  local v = t[i]
  if v ~= nil then
    return i, v
  end
end

function lume.ripairs(t)
  return ripairs_iter, t, (#t + 1)
end


function lume.color(str, mul)
  mul = mul or 1
  local r, g, b, a
  r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
  if r then
    r = tonumber(r, 16) / 0xff
    g = tonumber(g, 16) / 0xff
    b = tonumber(b, 16) / 0xff
    a = 1
  elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
    local f = str:gmatch("[%d.]+")
    r = (f() or 0) / 0xff
    g = (f() or 0) / 0xff
    b = (f() or 0) / 0xff
    a = f() or 1
  else
    error(("bad color string '%s'"):format(str))
  end
  return r * mul, g * mul, b * mul, a * mul
end


local chain_mt = {}
chain_mt.__index = lume.map(lume.filter(lume, iscallable, true),
  function(fn)
    return function(self, ...)
      self._value = fn(self._value, ...)
      return self
    end
  end)
chain_mt.__index.result = function(x) return x._value end

function lume.chain(value)
  return setmetatable({ _value = value }, chain_mt)
end

setmetatable(lume,  {
  __call = function(_, ...)
    return lume.chain(...)
  end
})


--
-- @muu:以下追記
--
_G.pp = lume.noop -- inspectが読み込まれ無いときでもエラーにならないように
os.sep = package.config:sub(1,1) -- パスの区切り文字
_G.unpack = _G.unpack or table.unpack
-- math.huge = math.huge or tonumber('inf')
math.maxinteger = math.maxinteger or 9007199254740991 -- 53bit on luajit (lua5.3には64bitのものが定義してある)
-- math.mininteger = math.mininteger or -9007199254740991 -- 53bit on luajit
-- math.epsilon = 2.220446049250313e-16 -- tween.luaでは1フレームより細かい時間は扱わないと思うので不要
-- ffi.llmax
-- ffi.llmin
-- ffi.ullmax
-- string.split = lume.split
math['＋'] = function(a,b) return a+b end -- reduceで使う
-- 文字列の連結はreduceを使うよりtable.concatを使う

-- 回転行列を掛ける
lume.rotate = function(x, y, rad) return x*math.cos(rad)-y*math.sin(rad), x*math.sin(rad)+y*math.cos(rad) end
math.rotate = lume.rotate

-- 整数除算(freecelの乱数生成などでつかう)
_G.idiv = function(a, b)
	local q = a/b
	return (q > 0) and math.floor(q) or math.ceil(q)
end

lume.wrap = function(x, min, max)
	if nil == max then min, max = 1, min end
	return (x-min)%(max-min+1)+min
end


math.bezier_magic = 0.55228474983 -- 正円の近似に使う値
math.bezier_circle = function(a) -- 正円を４つのbezier曲線で作るデータを返す(aを変えると四角に近づいていく)
	if nil == a then a = math.bezier_magic end
	return {
		{0.0, -1.0,  a, -1.0,  1.0, -a,  1.0, 0.0},
		{1.0, 0.0,  1.0, a,  a, 1.0,  0.0, 1.0},
		{0.0, 1.0,  -a, 1.0,  -1.0, a,  -1.0, 0.0},
		{-1.0, 0.0, -1.0, -a,  -a, -1.0,  0.0, -1.0} }
end
-- love.math.circle_points = lume.concat(unpack [lume.slice(love.math.newBezierCurve(curve)\render(), 1, -3) for curve in *math.bezier_circle()])
-- pp love.math.circle_points
math.circle_points = { 0, -1, 0.017258899286389, -1, 0.034415677189827, -0.99956274032593, 0.051459867507219, -0.99869877099991, 0.068504057824612, -0.99783480167389, 0.085435658693314, -0.99654412269592, 0.10224419087172, -0.9948371052742, 0.11905272305012, -0.99313008785248, 0.1357381939888, -0.99100685119629, 0.15229013562202, -0.98847776651382, 0.16884207725525, -0.98594868183136, 0.18526047468185, -0.98301374912262, 0.20153486728668, -0.97968351840973, 0.21780925989151, -0.97635328769684, 0.23393964767456, -0.9726277589798, 0.24991555511951, -0.9685173034668, 0.26589146256447, -0.9644068479538, 0.28171288967133, -0.95991158485413, 0.29736939072609, -0.95504194498062, 0.31302589178085, -0.95017230510712, 0.3285174369812, -0.94492822885513, 0.34383353590965, -0.93932020664215, 0.3591496348381, -0.93371224403381, 0.3742903470993, -0.92774033546448, 0.38924512267113, -0.92141503095627, 0.40419989824295, -0.91508972644806, 0.41896879673004, -0.90841090679169, 0.43354135751724, -0.90138912200928, 0.44811391830444, -0.89436733722687, 0.46249008178711, -0.88700258731842, 0.4766594171524, -0.87930536270142, 0.4908287525177, -0.87160813808441, 0.50479125976563, -0.86357837915421, 0.5185364484787, -0.85522663593292, 0.53228163719177, -0.84687483310699, 0.54580950737, -0.83820104598999, 0.55910956859589, -0.8292156457901, 0.57240962982178, -0.82023030519485, 0.58548194169998, -0.81093335151672, 0.59831595420837, -0.80133533477783, 0.61115002632141, -0.79173737764359, 0.62374579906464, -0.78183829784393, 0.63609290122986, -0.77164858579636, 0.64844000339508, -0.76145887374878, 0.66053831577301, -0.75097852945328, 0.67237746715546, -0.74021804332733, 0.68421655893326, -0.72945761680603, 0.69579648971558, -0.71841704845428, 0.70710676908493, -0.70710676908493, 0.71841704845428, -0.69579648971558, 0.72945761680603, -0.68421655893326, 0.74021804332733, -0.67237746715546, 0.75097852945328, -0.66053831577301, 0.76145887374878, -0.64844000339508, 0.77164858579636, -0.63609290122986, 0.78183829784393, -0.62374579906464, 0.79173737764359, -0.61115002632141, 0.80133533477783, -0.59831595420837, 0.81093335151672, -0.58548194169998, 0.82023030519485, -0.57240962982178, 0.8292156457901, -0.55910956859589, 0.83820104598999, -0.54580950737, 0.84687483310699, -0.53228163719177, 0.85522663593292, -0.5185364484787, 0.86357837915421, -0.50479125976563, 0.87160813808441, -0.4908287525177, 0.87930536270142, -0.4766594171524, 0.88700258731842, -0.46249008178711, 0.89436733722687, -0.44811391830444, 0.90138912200928, -0.43354135751724, 0.90841090679169, -0.41896879673004, 0.91508972644806, -0.40419989824295, 0.92141503095627, -0.38924512267113, 0.92774033546448, -0.3742903470993, 0.93371224403381, -0.3591496348381, 0.93932020664215, -0.34383353590965, 0.94492822885513, -0.3285174369812, 0.95017230510712, -0.31302589178085, 0.95504194498062, -0.29736939072609, 0.95991158485413, -0.28171288967133, 0.9644068479538, -0.26589146256447, 0.9685173034668, -0.24991555511951, 0.9726277589798, -0.23393964767456, 0.97635328769684, -0.21780925989151, 0.97968351840973, -0.20153486728668, 0.98301374912262, -0.18526047468185, 0.98594868183136, -0.16884207725525, 0.98847776651382, -0.15229013562202, 0.99100685119629, -0.1357381939888, 0.99313008785248, -0.11905272305012, 0.9948371052742, -0.10224419087172, 0.99654412269592, -0.085435658693314, 0.99783480167389, -0.068504057824612, 0.99869877099991, -0.051459867507219, 0.99956274032593, -0.034415677189827, 1, -0.017258899286389, 1, 0, 1, 0.017258899286389, 0.99956274032593, 0.034415677189827, 0.99869877099991, 0.051459867507219, 0.99783480167389, 0.068504057824612, 0.99654412269592, 0.085435658693314, 0.9948371052742, 0.10224419087172, 0.99313008785248, 0.11905272305012, 0.99100685119629, 0.1357381939888, 0.98847776651382, 0.15229013562202, 0.98594868183136, 0.16884207725525, 0.98301374912262, 0.18526047468185, 0.97968351840973, 0.20153486728668, 0.97635328769684, 0.21780925989151, 0.9726277589798, 0.23393964767456, 0.9685173034668, 0.24991555511951, 0.9644068479538, 0.26589146256447, 0.95991158485413, 0.28171288967133, 0.95504194498062, 0.29736939072609, 0.95017230510712, 0.31302589178085, 0.94492822885513, 0.3285174369812, 0.93932020664215, 0.34383353590965, 0.93371224403381, 0.3591496348381, 0.92774033546448, 0.3742903470993, 0.92141503095627, 0.38924512267113, 0.91508972644806, 0.40419989824295, 0.90841090679169, 0.41896879673004, 0.90138912200928, 0.43354135751724, 0.89436733722687, 0.44811391830444, 0.88700258731842, 0.46249008178711, 0.87930536270142, 0.4766594171524, 0.87160813808441, 0.4908287525177, 0.86357837915421, 0.50479125976563, 0.85522663593292, 0.5185364484787, 0.84687483310699, 0.53228163719177, 0.83820104598999, 0.54580950737, 0.8292156457901, 0.55910956859589, 0.82023030519485, 0.57240962982178, 0.81093335151672, 0.58548194169998, 0.80133533477783, 0.59831595420837, 0.79173737764359, 0.61115002632141, 0.78183829784393, 0.62374579906464, 0.77164858579636, 0.63609290122986, 0.76145887374878, 0.64844000339508, 0.75097852945328, 0.66053831577301, 0.74021804332733, 0.67237746715546, 0.72945761680603, 0.68421655893326, 0.71841704845428, 0.69579648971558, 0.70710676908493, 0.70710676908493, 0.69579648971558, 0.71841704845428, 0.68421655893326, 0.72945761680603, 0.67237746715546, 0.74021804332733, 0.66053831577301, 0.75097852945328, 0.64844000339508, 0.76145887374878, 0.63609290122986, 0.77164858579636, 0.62374579906464, 0.78183829784393, 0.61115002632141, 0.79173737764359, 0.59831595420837, 0.80133533477783, 0.58548194169998, 0.81093335151672, 0.57240962982178, 0.82023030519485, 0.55910956859589, 0.8292156457901, 0.54580950737, 0.83820104598999, 0.53228163719177, 0.84687483310699, 0.5185364484787, 0.85522663593292, 0.50479125976563, 0.86357837915421, 0.4908287525177, 0.87160813808441, 0.4766594171524, 0.87930536270142, 0.46249008178711, 0.88700258731842, 0.44811391830444, 0.89436733722687, 0.43354135751724, 0.90138912200928, 0.41896879673004, 0.90841090679169, 0.40419989824295, 0.91508972644806, 0.38924512267113, 0.92141503095627, 0.3742903470993, 0.92774033546448, 0.3591496348381, 0.93371224403381, 0.34383353590965, 0.93932020664215, 0.3285174369812, 0.94492822885513, 0.31302589178085, 0.95017230510712, 0.29736939072609, 0.95504194498062, 0.28171288967133, 0.95991158485413, 0.26589146256447, 0.9644068479538, 0.24991555511951, 0.9685173034668, 0.23393964767456, 0.9726277589798, 0.21780925989151, 0.97635328769684, 0.20153486728668, 0.97968351840973, 0.18526047468185, 0.98301374912262, 0.16884207725525, 0.98594868183136, 0.15229013562202, 0.98847776651382, 0.1357381939888, 0.99100685119629, 0.11905272305012, 0.99313008785248, 0.10224419087172, 0.9948371052742, 0.085435658693314, 0.99654412269592, 0.068504057824612, 0.99783480167389, 0.051459867507219, 0.99869877099991, 0.034415677189827, 0.99956274032593, 0.017258899286389, 1, 0, 1, -0.017258899286389, 1, -0.034415677189827, 0.99956274032593, -0.051459867507219, 0.99869877099991, -0.068504057824612, 0.99783480167389, -0.085435658693314, 0.99654412269592, -0.10224419087172, 0.9948371052742, -0.11905272305012, 0.99313008785248, -0.1357381939888, 0.99100685119629, -0.15229013562202, 0.98847776651382, -0.16884207725525, 0.98594868183136, -0.18526047468185, 0.98301374912262, -0.20153486728668, 0.97968351840973, -0.21780925989151, 0.97635328769684, -0.23393964767456, 0.9726277589798, -0.24991555511951, 0.9685173034668, -0.26589146256447, 0.9644068479538, -0.28171288967133, 0.95991158485413, -0.29736939072609, 0.95504194498062, -0.31302589178085, 0.95017230510712, -0.3285174369812, 0.94492822885513, -0.34383353590965, 0.93932020664215, -0.3591496348381, 0.93371224403381, -0.3742903470993, 0.92774033546448, -0.38924512267113, 0.92141503095627, -0.40419989824295, 0.91508972644806, -0.41896879673004, 0.90841090679169, -0.43354135751724, 0.90138912200928, -0.44811391830444, 0.89436733722687, -0.46249008178711, 0.88700258731842, -0.4766594171524, 0.87930536270142, -0.4908287525177, 0.87160813808441, -0.50479125976563, 0.86357837915421, -0.5185364484787, 0.85522663593292, -0.53228163719177, 0.84687483310699, -0.54580950737, 0.83820104598999, -0.55910956859589, 0.8292156457901, -0.57240962982178, 0.82023030519485, -0.58548194169998, 0.81093335151672, -0.59831595420837, 0.80133533477783, -0.61115002632141, 0.79173737764359, -0.62374579906464, 0.78183829784393, -0.63609290122986, 0.77164858579636, -0.64844000339508, 0.76145887374878, -0.66053831577301, 0.75097852945328, -0.67237746715546, 0.74021804332733, -0.68421655893326, 0.72945761680603, -0.69579648971558, 0.71841704845428, -0.70710676908493, 0.70710676908493, -0.71841704845428, 0.69579648971558, -0.72945761680603, 0.68421655893326, -0.74021804332733, 0.67237746715546, -0.75097852945328, 0.66053831577301, -0.76145887374878, 0.64844000339508, -0.77164858579636, 0.63609290122986, -0.78183829784393, 0.62374579906464, -0.79173737764359, 0.61115002632141, -0.80133533477783, 0.59831595420837, -0.81093335151672, 0.58548194169998, -0.82023030519485, 0.57240962982178, -0.8292156457901, 0.55910956859589, -0.83820104598999, 0.54580950737, -0.84687483310699, 0.53228163719177, -0.85522663593292, 0.5185364484787, -0.86357837915421, 0.50479125976563, -0.87160813808441, 0.4908287525177, -0.87930536270142, 0.4766594171524, -0.88700258731842, 0.46249008178711, -0.89436733722687, 0.44811391830444, -0.90138912200928, 0.43354135751724, -0.90841090679169, 0.41896879673004, -0.91508972644806, 0.40419989824295, -0.92141503095627, 0.38924512267113, -0.92774033546448, 0.3742903470993, -0.93371224403381, 0.3591496348381, -0.93932020664215, 0.34383353590965, -0.94492822885513, 0.3285174369812, -0.95017230510712, 0.31302589178085, -0.95504194498062, 0.29736939072609, -0.95991158485413, 0.28171288967133, -0.9644068479538, 0.26589146256447, -0.9685173034668, 0.24991555511951, -0.9726277589798, 0.23393964767456, -0.97635328769684, 0.21780925989151, -0.97968351840973, 0.20153486728668, -0.98301374912262, 0.18526047468185, -0.98594868183136, 0.16884207725525, -0.98847776651382, 0.15229013562202, -0.99100685119629, 0.1357381939888, -0.99313008785248, 0.11905272305012, -0.9948371052742, 0.10224419087172, -0.99654412269592, 0.085435658693314, -0.99783480167389, 0.068504057824612, -0.99869877099991, 0.051459867507219, -0.99956274032593, 0.034415677189827, -1, 0.017258899286389, -1, 0, -1, -0.017258899286389, -0.99956274032593, -0.034415677189827, -0.99869877099991, -0.051459867507219, -0.99783480167389, -0.068504057824612, -0.99654412269592, -0.085435658693314, -0.9948371052742, -0.10224419087172, -0.99313008785248, -0.11905272305012, -0.99100685119629, -0.1357381939888, -0.98847776651382, -0.15229013562202, -0.98594868183136, -0.16884207725525, -0.98301374912262, -0.18526047468185, -0.97968351840973, -0.20153486728668, -0.97635328769684, -0.21780925989151, -0.9726277589798, -0.23393964767456, -0.9685173034668, -0.24991555511951, -0.9644068479538, -0.26589146256447, -0.95991158485413, -0.28171288967133, -0.95504194498062, -0.29736939072609, -0.95017230510712, -0.31302589178085, -0.94492822885513, -0.3285174369812, -0.93932020664215, -0.34383353590965, -0.93371224403381, -0.3591496348381, -0.92774033546448, -0.3742903470993, -0.92141503095627, -0.38924512267113, -0.91508972644806, -0.40419989824295, -0.90841090679169, -0.41896879673004, -0.90138912200928, -0.43354135751724, -0.89436733722687, -0.44811391830444, -0.88700258731842, -0.46249008178711, -0.87930536270142, -0.4766594171524, -0.87160813808441, -0.4908287525177, -0.86357837915421, -0.50479125976563, -0.85522663593292, -0.5185364484787, -0.84687483310699, -0.53228163719177, -0.83820104598999, -0.54580950737, -0.8292156457901, -0.55910956859589, -0.82023030519485, -0.57240962982178, -0.81093335151672, -0.58548194169998, -0.80133533477783, -0.59831595420837, -0.79173737764359, -0.61115002632141, -0.78183829784393, -0.62374579906464, -0.77164858579636, -0.63609290122986, -0.76145887374878, -0.64844000339508, -0.75097852945328, -0.66053831577301, -0.74021804332733, -0.67237746715546, -0.72945761680603, -0.68421655893326, -0.71841704845428, -0.69579648971558, -0.70710676908493, -0.70710676908493, -0.69579648971558, -0.71841704845428, -0.68421655893326, -0.72945761680603, -0.67237746715546, -0.74021804332733, -0.66053831577301, -0.75097852945328, -0.64844000339508, -0.76145887374878, -0.63609290122986, -0.77164858579636, -0.62374579906464, -0.78183829784393, -0.61115002632141, -0.79173737764359, -0.59831595420837, -0.80133533477783, -0.58548194169998, -0.81093335151672, -0.57240962982178, -0.82023030519485, -0.55910956859589, -0.8292156457901, -0.54580950737, -0.83820104598999, -0.53228163719177, -0.84687483310699, -0.5185364484787, -0.85522663593292, -0.50479125976563, -0.86357837915421, -0.4908287525177, -0.87160813808441, -0.4766594171524, -0.87930536270142, -0.46249008178711, -0.88700258731842, -0.44811391830444, -0.89436733722687, -0.43354135751724, -0.90138912200928, -0.41896879673004, -0.90841090679169, -0.40419989824295, -0.91508972644806, -0.38924512267113, -0.92141503095627, -0.3742903470993, -0.92774033546448, -0.3591496348381, -0.93371224403381, -0.34383353590965, -0.93932020664215, -0.3285174369812, -0.94492822885513, -0.31302589178085, -0.95017230510712, -0.29736939072609, -0.95504194498062, -0.28171288967133, -0.95991158485413, -0.26589146256447, -0.9644068479538, -0.24991555511951, -0.9685173034668, -0.23393964767456, -0.9726277589798, -0.21780925989151, -0.97635328769684, -0.20153486728668, -0.97968351840973, -0.18526047468185, -0.98301374912262, -0.16884207725525, -0.98594868183136, -0.15229013562202, -0.98847776651382, -0.1357381939888, -0.99100685119629, -0.11905272305012, -0.99313008785248, -0.10224419087172, -0.9948371052742, -0.085435658693314, -0.99654412269592, -0.068504057824612, -0.99783480167389, -0.051459867507219, -0.99869877099991, -0.034415677189827, -0.99956274032593, -0.017258899286389, -1 }


-- local inspect = require 'lib.inspect'
-- _G.pp = (...)-> print unpack [inspect(it) for it in *{...}]
-- _G.pp = function(...) -- 1
--   return print(unpack((function(...) -- 1
--     local _accum_0 = { } -- 1
--     local _len_0 = 1 -- 1
--     local _list_0 = { -- 1
--       ... -- 1
--     } -- 1
--     for _index_0 = 1, #_list_0 do -- 1
--       local it = _list_0[_index_0] -- 1
--       _accum_0[_len_0] = inspect(it) -- 1
--       _len_0 = _len_0 + 1 -- 1
--     end -- 1
--     return _accum_0 -- 1
--   end)(...))) -- 1
-- end -- 1

-- 二つの数値間を余弦補完します。
lume.cerp = function(a, b, t)
	local f=(1-math.cos(t*math.pi))*.5
	return a*(1-f)+b*f
end

lume.bezier = function(s, t)
	if #s <= 1 then
		return s[1];
	else
		local s2 = {}
		for i=1, #s-1 do
			s2[i] = lume.lerp(s[i], s[i+1], t)
		end
		return lume.bezier(s2)--[lume.lerp(s[i], s[i+1], t) for i=1,#s-1], t)
	end
end

lume.zip = function(...) -- 1
  local ss -- 2
  if #{ -- 2
    ... -- 2
  } == 1 then -- 2
    ss = ... -- 2
  else -- 2
    ss = { -- 2
      ... -- 2
    } -- 2
  end -- 2
  local len = math.min(unpack((function() -- 3
    local _accum_0 = { } -- 3
    local _len_0 = 1 -- 3
    for _index_0 = 1, #ss do -- 3
      local row = ss[_index_0] -- 3
      _accum_0[_len_0] = #row -- 3
      _len_0 = _len_0 + 1 -- 3
    end -- 3
    return _accum_0 -- 3
  end)())) -- 3
  local _accum_0 = { } -- 4
  local _len_0 = 1 -- 4
  for i = 1, len do -- 4
    do -- 4
      local _accum_1 = { } -- 4
      local _len_1 = 1 -- 4
      for j, _ in ipairs(ss) do -- 4
        _accum_1[_len_1] = ss[j][i] -- 4
        _len_1 = _len_1 + 1 -- 4
      end -- 4
      _accum_0[_len_0] = _accum_1 -- 4
    end -- 4
    _len_0 = _len_0 + 1 -- 4
  end -- 4
  return _accum_0 -- 4
end -- 1
lume.transpose = lume.zip


lume.reverse = function(s) -- 1
  local _accum_0 = { } -- 1
  local _len_0 = 1 -- 1
  for _, it in lume.ripairs(s) do -- 1
    _accum_0[_len_0] = it -- 1
    _len_0 = _len_0 + 1 -- 1
  end -- 1
  return _accum_0 -- 1
end -- 1


-- os.capture('xsel -b')でclipboardの中身を取れる
-- (windowsのばあいはwinapiを使う?)
-- HTML出力できなくなるので切り離す
-- function os.capture(cmd, raw)
-- 	if nil == raw then raw = true end
-- 	local f = assert(io.popen(cmd, 'r'))
-- 	local s = assert(f:read('*a'))
-- 	f:close()
-- 	if raw then return s else return s:gsub('^%s+', ''):gsub('%s+$', ''):gsub('[\n\r]+', ' ') end
-- end


-- macro(loveなし、lua5.4で実行される)とlove.thread(thread/data/filesystemのみロードされる)で使う
-- lfsとlove.filesystemで関数名などが違う
-- local lfs = love and love.filesystem or require('lfs')
--
if package.loaded['lfs'] then
	local lfs = package.loaded['lfs']
	function lume.getAllFilenames(folder)
		folder = folder or ''
		local s = {}
		for _fn in lfs.dir(folder) do
			local fn = folder .. os.sep .. _fn
			if '.' == _fn or '..' == _fn then -- luacheck: ignore
			elseif 'directory' == lfs.attributes(fn, 'mode') then
				s = lume.concat(s, lume.getAllFilenames(fn))
			elseif 'file' == lfs.attributes(fn, 'mode') then
				table.insert(s, fn)
			end
		end
		return s
	end
end
if package.loaded['love'] and package.loaded['love']['filesystem']then
	function lume.getAllFilenames(folder)
		folder = folder or ''
		local s = {}
		for _, _fn in ipairs(love.filesystem.getDirectoryItems(folder)) do
			local fn = folder .. os.sep .. _fn
			-- if '.' == _fn or '..' == _fn then -- luacheck: ignore
			if 'directory' == love.filesystem.getInfo(fn).type then
				s = lume.concat(s, lume.getAllFilenames(fn))
			elseif 'file' == love.filesystem.getInfo(fn).type then
				table.insert(s, fn)
			end
		end
		return s
	end
end


return lume
