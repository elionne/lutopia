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

u.test1.rgb = off;

--for k,v in pairs(u.test1) do print(k, v) end

--print(u.test1.addr);
--print(u.test1.rgb);

--print(a:to_html())
--for i=1, 9 do
--	d = light.gradiant(a, b, i/10);
--	print(d:to_html());
--end

function main(p)
    u.test1.rgb = rgb.from_hsv{h=p, s=1, v=1};

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
