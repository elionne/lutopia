-- This function copies deeply a table with recursive methode,
-- it's extracted from http://lua-users.org/wiki/CopyTable

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end


rgb={r=0, g=0, b=0}
rgb_mt={__index=rgb}

function rgb:set(r, g, b)
    self.r = r;
    self.g = g;
    self.b = b;

    return self;
end

function rgb:to_hsv()
    local r, g, b = self.r, self.g, self.b;
    local h, s, v;
    local max = math.max(r, g, b);
    local min = math.min(r, g, b);

    if max == min then h = 0
    elseif max == r then h = (g-b)/(max-min)/6
    elseif max == g then h = (b-r)/(max-min)/6 + 1/3
    elseif max == b then h = (r-g)/(max-min)/6 + 2/3 end

    if max == 0 then s = 0 else s = 1 - min/max end
    v = max;

    return {h=h, s=s, v=v}
end

function rgb.from_hsv(new, old)

    local h, s, v = new.h, new.s, new.v;

    if old == nil then old = rgb.new(1, 1, 1); end
    old = old:to_hsv();

    if new.h == nil then h = old.h end
    if new.s == nil then s = old.s end
    if new.v == nil then v = old.v end

    local ti, f = math.modf(h * 6);
    local l = v*(1 - s);
    local m = v*(1 - f*s);
    local n = v*(1 - (1 - f)*s);

    if ti == 0 or ti == 6 then return rgb.new(v, n, l) end
    if ti == 1 then return rgb.new(m, v, l) end
    if ti == 2 then return rgb.new(l, v, n) end
    if ti == 3 then return rgb.new(l, m, v) end
    if ti == 4 then return rgb.new(n, l, v) end
    if ti == 5 then return rgb.new(v, l, m) end

end

function rgb:to_html()
    return string.format('#%02x%02x%02x', self.r*255, self.g*255, self.b*255)
end

function rgb:tostring()
    return string.format('r=%f, g=%f, b=%f', self.r, self.g, self.b);
end
rgb_mt.__tostring = rgb.tostring;

function rgb.new(r, g, b)
    local n = {r=r, g=g, b=b};
    setmetatable(n, rgb_mt);
    return n;
end

function light.gradiant(left, right, pos, cross)

    if cross == nil then cross = 0.5 end

    local function grad_one(l, r)
        if pos < cross then
            return (r - l)*pos/(2*cross) + l;
        else
            return (r - l)*(pos-cross)/(2*(1-cross)) + (l+r)/2;
        end
    end

    local r = grad_one(left.r, right.r);
    local g = grad_one(left.g, right.g);
    local b = grad_one(left.b, right.b);

    return rgb.new(r, g, b);

end

function new_light(class, priv)
    local setter = function(self, key, value)
        if( type(value) == "function" ) then
            rawset(new_type, key, value);
            return;
        end
        --last = clone(priv);
        priv[key] = value;
        getmetatable(self).changed = true;
    end

    class.ack = function(self)
        getmetatable(self).changed = false;
    end

    class.is_changed = function(self)
        return getmetatable(self).changed;
    end

    setmetatable(priv, {__index = class} );
    local new_light_mt = {
        __index = priv,
        __newindex = setter,
        __tostring = class.tostring,
        priv = priv,
        --last = clone(priv),
        changed = false
    }

    return setmetatable({}, new_light_mt);
end

parled = {};

function parled:value()
    return math.max(self.rgb.r, self.rgb.g, self.rgb.b)
end

function parled:set_value(v)
    self.rgb = self.rgb:from_hsv({v=v})
end

function parled:dmx()
    return {addr=self.addr,
            -- Start at 0
            [1] = self.rgb.r, [2] = self.rgb.g, [3] = self.rgb.b};
end

function parled:tostring()
    return self.rgb:tostring();
end

function parled.new(addr, color)
    local data = {addr = addr, rgb = color or rgb.new()};
    return new_light(parled, data);
end

--[[
spot = create_type_light();

function spot.new(addr)
    local n = {addr=addr, value=0}
    setmetatable(n, { __index = spot });
    return n;
end

function spot:dmx()
    return {addr=self.addr, [0] = value};
end
]]--
