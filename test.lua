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

print('un1.test1', un1.test1);
un1.test1.rgb.r = 0.345;
print('un1.group1.test1', un1.group1.test1);

a = rgb.new(0.25, 0.5, 0.75);
b = rgb.new(0.6, 0.1, 0.2);

for k,v in pairs(un1.test1) do print(k, v) end

print(un1.test1.addr);
print(un1.test1.rgb);

print(a:to_html())
for i=1, 9 do
	d = light.gradiant(a, b, i/10);
	print(d:to_html());
end
print(b:to_html())

