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

u.test2.rgb = rgb.new(255/255, 105/255, 180/255)
u.test2.hsv = u.test2.rgb:to_hsv()

u.test1.rgb = rgb.new(1, 1, 1)
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
        return linearize(triangle(p, width))
    end

    local spectre = function(p)
        u.test1.hsv.h = p
        nop, u.test2.hsv.h = math.modf(p + 0.05);

        u.test1.rgb = rgb.from_hsv(u.test1.hsv)
        u.test2.rgb = rgb.from_hsv(u.test2.hsv)
    end

    local wave = {}
    local wave_mt = {}

    wave_mt.lights = {}
    wave_mt.__call = function(func, ...)
        p = ...

        --u.test1.hsv.v = pretty(p)
        --u.test1.rgb = rgb.from_hsv(u.test1.hsv)

        speed = 1.0
        u.test2.hsv.v = pretty(p, 0.00, speed)
        u.test2.rgb = rgb.from_hsv(u.test2.hsv)

        u.spot2.value = pretty(p, 0.25, speed)
        u.spot3.value = pretty(p, 0.5, speed)
        u.spot4.value = pretty(p, 0.75, speed)

        --print(pretty(p, 0.00, speed), u.spot2.value, u.spot3.value, u.spot4.value)
        --print(triangle(p, 0, speed), triangle(p, 0.5, speed))

    end
    setmetatable(wave, wave_mt)

    wave.add = function(self, light)
        table.insert(getmetatable().lights, light)
    end

    local flash = function(p)
        local rand = function()
            if math.random() > 0.95 then
                return 1
            else
                return 0
            end
        end

        if math.random() > 0.95 then
            u.test1.hsv.v = 0.5
        else
            u.test1.hsv.v = 0
        end
        u.test1.rgb = rgb.from_hsv(u.test1.hsv)

        u.spot1.value = rand();
        u.spot2.value = rand();
        u.spot3.value = rand();
        u.spot4.value = rand();
    end

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

    --add_task(spectre, 0.002, 10, "spectre")
    add_task(wave, 0.01, 3, "wave")
    --add_task(flash, 1, 0.05, "flash")
    --add_task(cue_test, 0.33, 1, "test")


    start_task()

end
