require "cue"

--[[
pars ={}
for i=1, 10 do
	pars[i] = light.parled.new(i, rgb:from_hsv({h=i/10, s=1, v=1}) );
end
for k, v in pairs(light.parled) do
	print(k, v);
end

for index, par in pairs(pars) do
	print(par.addr, par:to_html())
end
--]]
print('u.test1', u.test1);
u.test1.rgb.r = 0.1;
print('u.group1.test1', u.group1.test1);


a = rgb.from_hsv({h=0.25, s=1, v=1});
b = rgb.from_hsv({h=0.6, s=1, v=1});
blanc = rgb.new(1, 1, 1);
off = rgb.new(0, 0, 0);

--u.test1.rgb = off
print('u.test1', u.test1);

u.test2.rgb = off
u.test2.hsv = u.test2.rgb:to_hsv()

u.test1.rgb = off
u.test1.hsv = u.test1.rgb:to_hsv()

--for k,v in pairs(u.test1) do print(k, v) end

--print(u.test1.addr);
--print(u.test1.rgb);

--print(a:to_html())
--for i=1, 9 do
--	d = light.gradiant(a, b, i/10);
--	print(d:to_html());
--end

function main(p)
    local pretty = function(p, offset, width)
        p = shift(p, offset)
        return triangle(p, width)
    end

    local spectre = function(p)
        u.test1.rgb = rgb.from_hsv({h=p, s=1}, u.test1.rgb)
        u.test2.rgb = rgb.from_hsv({h=shift(p, 0.1), s=1}, u.test2.rgb)
    end

    ---- Wave
    local wave = {}
    local wave_mt = {}

    wave_mt.__index = wave
    wave_mt.__call = function(self, ...)
        p, total_time, step = ...

        --u.test1.hsv.v = pretty(p)
        --u.test1.rgb = rgb.from_hsv(u.test1.hsv)

        local len = #self.lights

        for index, light in pairs(self.lights) do
            light.value = pretty(p, index / len, self.speed)
        end
    end

    wave.add = function(self, light)
        table.insert(self.lights, light)
        self.speed = #self.lights
    end

    wave.new = function(speed)
        return setmetatable({lights={}, speed=speed or 1}, wave_mt)
    end
    -----

    ---- Flash
    local flash = {}
    local flash_mt = {}

    flash_mt.__index = flash
    flash_mt.__call = function(self, ...)
        p, total_time, step = ...
        local rand = function()
            if math.random() > self.rate then
                return 1
            else
                return 0
            end
        end

        for index, light in pairs(self.lights) do
            light.value = (light.value > 0.5) * rand()
        end
    end

    flash.add = function(self, light)
        table.insert(self.lights, light)
    end

    flash.new = function(rate)
        return setmetatable({lights={}, rate=rate or 0.90}, flash_mt)
    end
    ----

    local cue_test = function(p)
        if p == 0 then
            set_cue(cue.seq4)
        elseif p < 1/3 then
            set_cue(cue.seq1)
        elseif p < 2/3 then
            set_cue(cue.seq2)
        elseif p < 1 then
            set_cue(cue.seq3)
        end
        --export_to_lua(u, "u");
    end


    u.test1.hsv = {h=1, s=1, v=1};
    u.test2.hsv = {h=0.52, s=1, v=1};

    wave1 = wave.new()
    flash1 = flash.new(0.92)

    flash1:add(u.spot2)
    flash1:add(u.spot3)
    flash1:add(u.spot4)
    flash1:add(u.test2)
    flash1:add(u.test1)

    --add_task(spectre, 0.01, 30, "spectre")
    add_task(flash1, 1, 0.05, "flash")
    add_task(wave1, 0.01, 3, "wave")
    --add_task(cue_test, 0.33, 1, "test")


    start_task()

end
