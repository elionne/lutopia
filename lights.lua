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
-- have to follow exactly the same pattern describe by parled.new


-- first implemented light type
parled = {};

function parled:get_value()
    return math.max(self.rgb.r, self.rgb.g, self.rgb.b)
end

function parled:set_value(v)
    self.rgb = rgb.from_hsv({v=linearize(v)}, self.rgb)
end

function parled:set(rgb)
    self.rgb:set(rgb)
end

function parled:transition(rgb, cross, p)
    gradiant(self, rgb, p, cross);
end

function parled:dmx()
    return {addr=self.addr,
            -- Start at 0 (index 0 and 4 are unsed)
            [1] = self.rgb.r*255, [2] = self.rgb.g*255, [3] = self.rgb.b*255};
end

function parled:tostring()
    return self.rgb:tostring();
end

function parled.new(addr, color)
    local data = {addr = addr, rgb = color or rgb.new()};
    return new_light(parled, data);
end


spot = {};

function spot.new(addr)
    local data = {addr=addr, value=0};
    return new_light(spot, data);
end

function spot:dmx()
    return {addr=self.addr, [0] = self.value*255};
end


lspot = inherit(spot)

function lspot:set_value(v)
    self.lin = linearize(v)
end

function lspot:get_value()
    return self.lin
end

function lspot.new(addr)
    local data = {addr = addr, lin = 0}
    return new_light(lspot, data)
end


