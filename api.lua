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
-- This a simple, naive implementation. It only copies the top level value and
-- its direct children; there is no handling of deeper children, metatables or
-- special types such as userdata or coroutines. It is also susceptible to
-- influence by the __pairs metamethod.
--
-- from http://lua-users.org/wiki/CopyTable
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
    copy = orig
end
return copy
end

-- Alias for shallowcopy
function inherit(super)
    return shallowcopy(super)
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

function export_to_lua(tt, name, done)
    done = done or {}
    name = name or ""

    io.write(string.format("%s={\n", name))
    local function print_has_table(tt, name, done)
        local comma, newline, space
        if type(tt) == "table" then
            for key, value in pairs(tt) do
                --print(comma, space, newline)
                if comma then
                    io.write(",")
                    comma = false
                end
                if space then
                    io.write(" ")
                    space = false
                end
                if newline then
                    io.write("\n")
                    newline = false
                end

                if type(value) == "table" then
                    if done[value] == nil then
                        done[value] = true
                        if getmetatable(value) == nil then
                            -- no metatable
                            io.write(string.format("%8s = {", key))
                            print_has_table(value, name, done)
                            io.write("}")
                            newline, comma = true, true

                        elseif getmetatable(value)["__tostring"] == nil then
                            -- no __tostring function
                            print_has_table(value, name, done)
                        else
                            -- call __tostring function
                            io.write(string.format("%8s = {%s}",
                                    tostring(key), tostring(value)));
                            newline, comma = true, true
                        end
                    else -- if table is already set
                        io.write(string.format("%s=%s.%s", key, name, key))
                        comma, space = true, true
                    end
                end
            end
        else
            io.write(tt .. "\n")
        end
    end
    print_has_table(tt, name, done)
    io.write("\n};\n")

end

-- This function must be called when you create a new light,
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

function set_cue(seq)
    for universe, snap in pairs(seq) do
        if universe == "param" then
        else
            for light, value in pairs(snap) do
                _G[universe][light]:set(value);
                print( universe, light, value);
            end
        end
    end
end

function set_cue_transition(seq)
    for universe, snap in pairs(seq) do
        for light, value in pairs(snap) do
            _G[universe][light]:transition(value, seq.param.cross);
        end
    end
end

-- This task refresh the dmx line (little more than 50hz)
add_task(function() update_lights("u") end, 1, 0.02)


