rgb={r=0, g=0, b=0}
rgb_mt={__index=rgb}

function rgb:set(rgb)
    self.r = rgb.r;
    self.g = rgb.g;
    self.b = rgb.b;

    return self;
end

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

function rgb.from_hsv(new, old)

    local h, s, v = new.h, new.s, new.v;

    if old == nil then old = rgb.new(1, 1, 1); end
    old = old:to_hsv();

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

function gradiant(left, right, pos, cross)

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

function linearize(value)
    return math.pow(10, value*1.041392 - 1) - 0.1
end

math.two_pi = 2 * math.pi

function shift(p, offset)
    -- Transform p in radian
    p = p * math.two_pi

    -- Transform offset in phase (radian too)
    offset = offset * math.two_pi

    cosf, sinf = math.cos(p), math.sin(p)
    coso, sino = math.cos(offset), math.sin(offset)

    -- Transform sawtooth wave into sin and cos with shifting
    sinp = sinf*coso + cosf*sino
    cosp = cosf*coso - sinf*sino

    -- This part transform cos and sin of input to a sawtooth.
    -- Needs three different calculation section
    if sinp >= 0 and cosp >= 0 then
        p = math.asin(sinp)/math.two_pi
    elseif sinp >= 0 then
        p = math.acos(cosp)/math.two_pi
    else
        p = math.asin(cosp)/math.two_pi + 0.75
    end

    return p
end

function triangle(p, width, duty_cycle, min, max)
    duty_cycle = duty_cycle or 0.5
    width = width or 1
    max = max or 1
    min = min or 0

    -- Apply the scale
    p = p * width

    if p > 1 or p < 0 then
        p = 0
    end

    if p <= duty_cycle then
        return min + p * (max - min) / duty_cycle
    else
        return min + (1 - p) * (max - min) / (1 - duty_cycle)
    end
end
