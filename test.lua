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

print('un1.test1', u.test1);
u.test1.rgb.r = 0.1;
print('un1.group1.test1', u.group1.test1);

a = rgb.new(0.25, 0.5, 0.75);
b = rgb.new(0.6, 0.1, 0.2);
blanc = rgb.new(0.1, 0.1, 0.1);
u.test1.rgb = blanc;

for k,v in pairs(u.test1) do print(k, v) end

print(u.test1.addr);
print(u.test1.rgb);

print(a:to_html())
for i=1, 9 do
	d = light.gradiant(a, b, i/10);
	print(d:to_html());
end
print(b:to_html())

function main(p)
    --print(p);
    --u.test1.rgb:from_hsv{h=p, s=1, v=1};
    u.test1.rgb = light.gradiant(a, b, p, 0.3)
    --print(u.test1.rgb);
end
