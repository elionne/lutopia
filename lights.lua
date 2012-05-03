require "api"
require "color"

-- You can declare all lights you want here

-- You must implement 'dmx', 'new' functions like parled.

-- \brief Returns all needed data to send on the wire

-- 'dmx' is used each time refresh dmx line is called (44Hz). This function
-- returns a table that contains the 'addr' field for address of the device. The
-- rest of the table are value for the corresponding canal of the device. Each
-- index start from 0, and unsed index should not be write

--\brief Creates a new instance of the light

-- Every time you want to create a new instance of a light, you have to call
-- this function. This reference the new intance internaly, its will be
-- automaticly refresh by by the kernel:. When you create a new light type, you
-- have to follow exactly the same pattern descibe by parled.new


-- first implemented light type
parled = {};

function parled:value()
    return math.max(self.rgb.r, self.rgb.g, self.rgb.b)
end

function parled:set_value(v)
    self.rgb = self.rgb:from_hsv({v=v})
end

function parled:dmx()
    return {addr=self.addr,
            -- Start at 0 (index 0 and 4 are unsed)
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