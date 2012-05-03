require "rt_task"

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

-- Print anything - including nested tables
function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => %s\n", tostring (key), tostring(value)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        table_print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

-- This function must called when you create a new light,
-- its contained the mecanisme to store if data have changed
-- since the last read

-- The table pirv will be added to class table like private data
function new_light(class, priv)
    -- setter will be called every time you write somethings in priv
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

-- This task refresh the dmx line (little more than 50hz)
add_task(function() update_lights("u") end, 0.9, 0.02)

