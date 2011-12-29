pars ={}
for i=1, 10 do
	pars[i] = parled:new(i, rgb:from_hsv({h=i/10, s=1, v=1}));
	print(pars[i]:to_html());
end

a = rgb:new(0.25, 0.5, 0.75);
b = rgb:new(0.6, 0.1, 0.2);

print();

print(a:to_html())
for i=1, 9 do
	d = gradiant(a, b, i/10);
	print(d:to_html());
end
print(b:to_html())

