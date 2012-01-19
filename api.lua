rgb={r=0, g=0, b=0}
rgb_mt={__index=rgb}

function rgb:to_hsv()
	local r, g, b = self.r, self.g, self.b;
	local h, s, v;
	local max = math.max(r, g, b);
	local min = math.min(r, g, b);

	if max == min then h = 0
	elseif max == r then h = (g-b)/(max-min)/6
	elseif max == g then h = (b-r)/(max-min)/6 + 1/3
	elseif max == b then h = (r-g)/(max-min)/6 + 2/3 end

	if max == 0 then s = 0 else s = 1 - min/max end
	v = max;

	return {h=h, s=s, v=v}
end

function rgb:from_hsv(new)

	local old = self:to_hsv();
	local h, s, v = new.h, new.s, new.v;

	if new.h == nil then h = old.h end
	if new.s == nil then s = old.s end
	if new.v == nil then v = old.v end

	local ti, f = math.modf(h * 6);
	local l = v*(1 - s);
	local m = v*(1 - f*s);
	local n = v*(1 - (1 - f)*s);

	if ti == 0 or ti == 6 then return rgb.new(v, n, l) end
	if ti == 1 then return rgb.new(m, v, l) end
	if ti == 2 then return rgb.new(l, v, n) end
	if ti == 3 then return rgb.new(l, m, v) end
	if ti == 4 then return rgb.new(n, l, v) end
	if ti == 5 then return rgb.new(v, l, m) end

end

function rgb:to_html()
	return string.format('#%02x%02x%02x', self.r*255, self.g*255, self.b*255)
end

function rgb:tostring()
	return string.format('r=%f, g=%f, b=%f', self.r, self.g, self.b);
end
rgb_mt.__tostring = rgb.tostring;

function rgb.new(r, g, b)
	local n = {r=r, g=g, b=b};
	setmetatable(n, rgb_mt);
	return n;
end

function light.gradiant(left, right, pos, cross)

	if cross == nil then cross = 0.5 end

	local function grad_one(l, r)
		if pos < cross then
			return (r - l)*pos/(2*cross) + l;
		else
			return (r - l)*(pos-cross)/(2*(1-cross)) + (l+r)/2;
		end
	end

	local r = grad_one(left.r, right.r);
	local g = grad_one(left.g, right.g);
	local b = grad_one(left.b, right.b);

	return rgb.new(r, g, b);

end

light.parled = {addr=0, rgb=rgb.new()}
light.parled_mt = {__index=light.parled}

function light.parled:value()
	return math.max(self.rgb.r, self.rgb.g, self.rgb.b)
end

function light.parled:set_value(v)
	self.rgb = self.rgb:from_hsv({v=v})
end

function light.parled:tostring()
	return self.rgb:tostring();
end

light.parled_mt.__tostring = light.parled.tostring;

function light.parled.new(addr, rgb)
	local n = {addr=addr, rgb=rgb};
	setmetatable(n, light.parled_mt);
	return n;
end

light.spot = {addr=0, value=0}

print("ok")