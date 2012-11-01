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
    local spectre = function(p)
        u.test1.hsv.h = p
        nop, u.test2.hsv.h = math.modf(p + 0.1);
                
        u.test1.rgb = rgb.from_hsv(u.test1.hsv)
        u.test2.rgb = rgb.from_hsv(u.test2.hsv)
    end

    local wave = function(p)
        u.test1.hsv.v = linearize(triangle(p, 0.00, 0.7, 0.1))
        u.test1.rgb = rgb.from_hsv(u.test1.hsv)

        nop, p2 = math.modf(p + 0.25)
        u.test2.hsv.v = linearize(triangle(p2, 0.00, 0.7, 0.1))
        u.test2.rgb = rgb.from_hsv(u.test2.hsv)
    end

    local flash = function(p)
        if math.random() > 0.95 then
            u.test1.hsv.v = 0.5
        else
            u.test1.hsv.v = 0
        end
        u.test1.rgb = rgb.from_hsv(u.test1.hsv)
        
        if math.random() > 0.95 then
            u.test2.hsv.v = 0.5
        else
            u.test2.hsv.v = 0
        end
        u.test2.rgb = rgb.from_hsv(u.test2.hsv)
    end

    local rgb_test = function(p)
        u.test1.rgb.b = triangle(p);
    end

    u.test1.hsv = {h=1, s=0.75, v=1};
    u.test2.hsv = {h=0.2, s=1, v=1};
    
    --add_task(spectre, 0.001, 5, "spectre")
    --add_task(wave, 0.01, 0.5, "wave")
    add_task(flash, 1, 0.05, "flash")
    --add_task(rgb_test, 0.01, 10, "test")

    start_task()

    

--[[
    if math.random() * 10 < 2 then
        u.test1.rgb = rgb.from_hsv{h=p, s=1, v=1};
    else
        u.test1.rgb = rgb.from_hsv{h=0, s=0, v=0};
    end
--]]
    --u.test1.rgb = light.gradiant(a, b, p, 0.5)
    --print(u.test1.rgb);
end
