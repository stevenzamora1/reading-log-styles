-- Gothic drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

local CRIMSON, BRIGHT, DEEP, WINE = { 204, 34, 68 }, { 221, 51, 85 }, { 136, 17, 51 }, { 85, 17, 34 }
local STEM, THORN, LEAF = { 51, 102, 68 }, { 34, 68, 51 }, { 34, 85, 51 }
local IVY, LILAC, LILAC_DEEP = { 119, 102, 153 }, { 187, 153, 238 }, { 136, 102, 187 }
local SILVER, IRON = { 204, 187, 204 }, { 136, 119, 153 }
local FLAME, FLAME_IN = { 238, 170, 51 }, { 255, 238, 153 }
local WHITE = { 255, 255, 255 }
local ARROW = { 238, 51, 85 }   -- a touch lighter, for greyscale screens

-- the petals' shades, from the heart of the rose out
local ROSE = { WINE, DEEP, { 170, 34, 60 }, CRIMSON, BRIGHT }
local LILAC_ROSE = { { 68, 51, 102 }, { 102, 68, 153 }, LILAC_DEEP, { 170, 136, 221 }, LILAC }

local function at(cx, cy, r, a) return cx + r * cos(a), cy + r * sin(a) end
local function mix(a, b, t) return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t } end

-- A shape filled row by row between y0 and y1: half(y) is its half width at
-- that height, round cx.
local function fillRows(c, cx, y0, y1, half, col)
    if y1 - y0 < 0.5 then return end
    local step = max(1, floor((y1 - y0) / 60))
    local yy = floor(y0)
    while yy < y1 do
        local hw = half(yy + step / 2)
        if hw > 0.4 then c:rect(floor(cx - hw + 0.5), yy, max(1, floor(2 * hw + 0.5)), step, col) end
        yy = yy + step
    end
end

-- A pointed (lancet) arch from top to bottom, half width a; the pointed part
-- is ah tall, the sides straight below it.
local function archHalf(a, ah, top, yy)
    if yy >= top + ah then return a end
    local u = 1 - (yy - top) / ah          -- 1 at the point, 0 at the spring line
    return a * (sqrt(max(0, 4 - 3 * u * u)) - 1)
end

-- The arch's outline as points, up the left side, over the point, down the right.
local function archLine(cx, top, bottom, a, ah)
    local pts = { cx - a, bottom, cx - a, top + ah }
    local n = 12
    for i = 1, n do
        local yy = top + ah - ah * i / n
        pts[#pts + 1] = cx - archHalf(a, ah, top, yy); pts[#pts + 1] = yy
    end
    for i = n - 1, 0, -1 do
        local yy = top + ah - ah * i / n
        pts[#pts + 1] = cx + archHalf(a, ah, top, yy); pts[#pts + 1] = yy
    end
    pts[#pts + 1] = cx + a; pts[#pts + 1] = bottom
    return pts
end

local function arch(c, cx, top, bottom, a, ah, col)
    ah = min(ah, bottom - top)
    fillRows(c, cx, top, top + ah, function(yy) return archHalf(a, ah, top, yy) end, col)
    local spring = floor(top + ah)
    if bottom > spring then c:rect(floor(cx - a + 0.5), spring, max(1, floor(2 * a + 0.5)), floor(bottom - spring + 0.5), col) end
    -- a smooth edge over the stepped rows of the point
    if a >= 4 and ah >= 4 then
        local edge = archLine(cx, top + 0.6, top + ah, a - 0.6, ah - 0.6)
        c:polyline(edge, 1.6, col)
    end
end

-- A leaf: a teardrop pointing along angle ang.
-- A pointed leaf along angle ang: overlapping discs that swell in the middle.
local function leaf(c, x, y, ang, len, wid, col)
    local ca, sa = cos(ang), sin(ang)
    local n = max(4, floor(len / 2))
    for i = 1, n - 1 do
        local f = i / n
        local r = wid * 0.5 * sin(pi * f) ^ 0.8
        if r > 0.4 then c:disc(x + len * f * ca, y + len * f * sa, r, col) end
    end
end

-- A thorn: a spike that narrows to its point.
local function spike(c, x, y, ang, len, wid, col)
    local mx, my = x + len * 0.5 * cos(ang), y + len * 0.5 * sin(ang)
    c:polyline({ x, y, mx, my }, max(1, wid), col)
    c:polyline({ mx, my, x + len * cos(ang), y + len * sin(ang) }, max(1, wid * 0.45), col)
end

-- A rose seen from above, r its radius; bloom 0 (a closed bud) to 1.
local function bud(c, x, y, r, cols)
    local lw = max(1, r * 0.22)
    c:polyline({ x, y + r * 0.55, x - r * 0.55, y + r * 0.05 }, lw, STEM)
    c:polyline({ x, y + r * 0.55, x + r * 0.55, y + r * 0.05 }, lw, STEM)
    c:disc(x, y + r * 0.12, r * 0.46, cols[1])
    c:disc(x, y + r * 0.12, r * 0.4, cols[4])
    c:disc(x, y - r * 0.2, r * 0.3, cols[4])
    c:disc(x, y - r * 0.45, r * 0.15, cols[4])
end

local function rose(c, x, y, r, bloom, cols)
    cols = cols or ROSE
    bloom = max(0, min(1, bloom or 1))
    if bloom < 0.2 then bud(c, x, y, r, cols) return end
    local layers = 1 + floor(bloom * 3.99)
    if r < 9 then layers = min(layers, 2) elseif r < 16 then layers = min(layers, 3) end
    local edge = max(0.8, r * 0.035)
    -- each layer is five petals; the outer layer reaches r, and is the brightest
    for L = layers, 1, -1 do
        local R = r / 1.07 * (6 + 7 * L) / (6 + 7 * layers)
        local shade = cols[min(#cols, L + 1 + (4 - layers))]
        local rot = L * 0.6
        for i = 0, 4 do
            local a = rot + 2 * pi * i / 5
            local px, py = x + R * 0.45 * cos(a), y + R * 0.45 * sin(a)
            c:disc(px, py, R * 0.62 + edge, cols[1])
            c:disc(px, py, R * 0.62, shade)
        end
    end
    c:disc(x, y, max(1, r * 0.12), cols[1])
end

-- ─── rings: a rose vine (pages) and an ivy vine (time) ───────────────────────
-- The vine grows clockwise from the top as far as the day got, with a flower
-- where it has reached.

local function vine(c, cx, cy, R, t, frac, track, ivy, bg)
    local rm = R - t / 2
    local groove = mix(track, bg, 0.45)
    c:ring(cx, cy, rm + t * 0.17, t * 0.34, 0, groove, groove)
    if frac <= 0 then return end
    frac = min(frac, 1)
    local stem = ivy and IVY or STEM
    if R < 22 then
        c:ring(cx, cy, R, t, frac, track, stem)
        local ex, ey = at(cx, cy, rm, -pi / 2 + 2 * pi * frac)
        c:disc(ex, ey, max(2, t * 0.6), ivy and LILAC or CRIMSON)
        return
    end
    local a0 = -pi / 2
    local span = 2 * pi * frac
    local period = max(10, t * 2)                -- one wave of the stem, along the ring
    local amp = t * 0.1
    local len = rm * span
    local function wave(s) return rm + amp * sin(s / period * 2 * pi) end
    local n = max(8, floor(len / (period / 6)))
    local pts = {}
    for i = 0, n do
        local s = len * i / n
        local x, y = at(cx, cy, wave(s), a0 + s / rm)
        pts[#pts + 1] = x; pts[#pts + 1] = y
    end
    local lw = max(1.5, t * 0.2)
    c:polyline(pts, lw, stem)
    -- rose: thorns, a leaf now and then; ivy: leaves. Outside and inside in turn.
    local gap = period * 0.5
    local k = 0
    local s = gap
    local stop = len - t * 1.2
    while s < stop do
        local a = a0 + s / rm
        local side = (k % 2 == 0) and 1 or -1
        local bx, by = at(cx, cy, wave(s), a)
        if ivy then
            leaf(c, bx, by, side == 1 and (a + 0.55) or (a + pi - 0.55), t * 0.62, t * 0.32, LILAC)
        elseif k % 4 == 3 then
            leaf(c, bx, by, side == 1 and (a + 0.55) or (a + pi - 0.55), t * 0.6, t * 0.3, LEAF)
        else
            spike(c, bx, by, side == 1 and (a - 0.45) or (a + pi + 0.45), t * 0.36, lw * 0.9, THORN)
        end
        k = k + 1
        s = s + (ivy and gap * 1.25 or gap)
    end
    local ex, ey = at(cx, cy, wave(len), a0 + span)
    local fr = max(t * 0.6, min(R * 0.16, t * 1.1))
    if ivy then rose(c, ex, ey, fr * 0.8, 0.7, LILAC_ROSE) else rose(c, ex, ey, fr, 1, ROSE) end
end

-- The third ring (the streak): a thin silver band with a bead at its end.
local function band(c, cx, cy, R, t, frac, track, bg)
    local groove = mix(track, bg, 0.3)
    local rm = R - t / 2
    c:ring(cx, cy, rm + t * 0.17, t * 0.34, 0, groove, groove)
    if frac <= 0 then return end
    c:ring(cx, cy, rm + t * 0.12, t * 0.24, min(1, frac), groove, IRON)
    local ex, ey = at(cx, cy, rm, -pi / 2 + 2 * pi * min(1, frac))
    local s = max(2.5, t * 0.32)
    fillRows(c, ex, ey - s, ey + s, function(yy) return s * 0.7 * (1 - abs(yy - ey) / s) end, SILVER)
end

local D = {}

-- ─── the rings: a rose in a ring of thorns ──────────────────────────────────
-- One big rose in the middle whose petals fill in, the heart first, as the
-- day's pages add up, and a thorny vine that grows round it with the minutes,
-- a curled tendril at its tip. The streak is in the card's figures only.
-- Reading Log draws a set of rings outer first at one centre, so the pages
-- call draws the empty vine and the rose, and the minutes call grows the
-- vine. A ring on its own somewhere else is drawn the usual way.

local VINE, VINE_D, THORN_C = { 47, 107, 58 }, { 29, 63, 36 }, { 63, 138, 74 }
local PETAL_EDGE = { 58, 10, 24 }
-- the rose's petals, layer by layer from the outside in
local LAYERS = { { 255, 92, 120 }, { 221, 51, 85 }, { 176, 24, 58 }, { 122, 16, 48 } }
local DULL = { 58, 40, 58 }

-- a cabbage rose of radius r: 4 layers of 5 round petals; `lit` of the 20
-- are in colour, the heart first
local function bigRose(c, cx, cy, r, lit, tone)
    local order = {}
    for k = 4, 1, -1 do for i = 1, 5 do order[#order + 1] = { k, i } end end
    local on = {}
    for n = 1, min(20, lit) do on[order[n][1] * 10 + order[n][2]] = true end
    for k = 1, 4 do
        local rr = r * (1 - (k - 1) * 0.22)
        for i = 1, 5 do
            local ang = (i - 1) * 2 * pi / 5 + (k - 1) * 0.6 - pi / 2
            local x, y = cx + rr * 0.45 * cos(ang), cy + rr * 0.45 * sin(ang)
            local pr = rr * 0.5
            c:disc(x, y, pr + max(1, r * 0.03), PETAL_EDGE)
            c:disc(x, y, pr, on[k * 10 + i] and LAYERS[k] or mix(DULL, tone.bg, 0.25 * (k - 1)))
        end
    end
    c:disc(cx, cy, r * 0.14, on[41] and { 90, 10, 34 } or DULL)
end

-- a hooked thorn on the vine at angle a, pointing out (side 1) or in (-1):
-- a cone of discs, wide at the vine and sharp at its tip, leaning forward
local function thorn(c, cx, cy, R, a, side, len, col)
    local steps = max(4, floor(len * 1.5))
    for i = 0, steps - 1 do
        local f = i / steps
        local x, y = at(cx, cy, R + side * len * f, a + f * len * 0.5 / R)
        local r = len * 0.32 * (1 - f)
        if r >= 0.5 then c:rect(floor(x - r + 0.5), floor(y - r + 0.5), max(1, floor(2 * r + 0.5)), max(1, floor(2 * r + 0.5)), col) end
    end
end

-- the vine round (cx, cy) at radius R, grown `frac` of the way round
local function thornVine(c, cx, cy, R, lw, frac, tone)
    c:ring(cx, cy, R + lw / 2, lw, 0, mix(DULL, tone.bg, 0.3), mix(DULL, tone.bg, 0.3))
    if frac <= 0 then return end
    frac = min(1, frac)
    local a0 = -pi / 2
    local a1 = a0 + 2 * pi * frac
    local n = max(24, floor(R * 2 * pi * frac / 2))
    local pts = {}
    local wob = max(1, lw * 0.35)
    for i = 0, n do
        local a = a0 + (a1 - a0) * i / n
        local x, y = at(cx, cy, R + wob * sin(i * 0.9), a)
        pts[#pts + 1] = x; pts[#pts + 1] = y
    end
    c:polyline(pts, lw * 1.2, VINE_D)
    c:polyline(pts, lw, VINE)
    local count = max(5, floor(R * 2 * pi * frac / max(8, lw * 4.2)))
    local len = max(3, lw * 1.9)
    for i = 0, count - 1 do
        local a = a0 + (a1 - a0) * (i + 0.5) / count
        thorn(c, cx, cy, R, a, (i % 2 == 0) and 1 or -1, len, THORN_C)
    end
    -- a curled tendril at the growing tip
    if frac < 1 then
        local tx, ty = at(cx, cy, R, a1)
        local cr = max(3, lw * 2.2)
        local ctr_x, ctr_y = at(cx, cy, R + cr, a1)
        local spts = {}
        for i = 0, 28 do
            local t = i / 28
            local ang = a1 + pi + t * 3.4 * pi
            local rr = cr * (1 - t * 0.8)
            spts[#spts + 1] = ctr_x + rr * cos(ang); spts[#spts + 1] = ctr_y + rr * sin(ang)
        end
        spts[1], spts[2] = tx, ty
        c:polyline(spts, max(1, lw * 0.45), VINE)
    end
end

local tri

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    frac = max(0, frac or 0)
    if which == 1 then
        local lw = max(2, R * 0.07)
        local vr = R - lw * 1.6
        tri = { c = c, cx = cx, cy = cy, R = R, vr = vr, lw = lw }
        thornVine(c, cx, cy, vr, lw, 0, tone)
        bigRose(c, cx, cy, R * 0.56, floor(min(1, frac) * 20 + 0.5), tone)
        return true
    end
    if not (tri and tri.c == c and tri.cx == cx and tri.cy == cy) then return false end
    if which == 2 then
        thornVine(c, cx, cy, tri.vr, tri.lw, frac, tone)
    else
        -- the streak: in the figures beside it
        tri = nil
    end
    return true
end

-- ─── a day: a rose ───────────────────────────────────────────────────────────
-- Its petals fill in, the heart first, with the day's pages; a green ring of
-- thorns grows round it once the day's pages and minutes are both done.
-- Days still to come are a small grey bud.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    if o.future then
        c:disc(cx, cy, max(1.5, d * 0.09), mix(DULL, tone.bg, 0.2))
        return true
    end
    local done = (fp or 0) >= 1 and (fm or 0) >= 1
    local lw = max(1.5, d * 0.06)
    local vr = d * 0.5 - lw * 1.4
    if done then
        thornVine(c, cx, cy, vr, lw, 1, tone)
    else
        c:ring(cx, cy, vr + lw / 2, max(1, lw * 0.5), 0, mix(DULL, tone.bg, 0.3), mix(DULL, tone.bg, 0.3))
    end
    bigRose(c, cx, cy, d * 0.33, floor(min(1, fp or 0) * 20 + 0.5), tone)
    if o.today then c:rect(floor(cx - d * 0.2), floor(cy + d * 0.5), max(2, floor(d * 0.4)), max(1, floor(d * 0.05)), SILVER) end
    return true
end

-- ─── the year goal: a marked vial in a pointed arch ─────────────────────────

function D.goal(c, x, y, w, h, done, target, tone)
    local cx = x + w / 2
    local a = min(w * 0.46, h * 0.3)
    local top, bottom = y + h * 0.02, y + h * 0.98
    local ah = a * 1.73
    local lw = max(2, floor(a * 0.09))
    arch(c, cx, top, bottom, a, ah, IRON)
    arch(c, cx, top + lw * 1.8, bottom - lw, a - lw, ah - lw * 1.8, mix(tone.bg, { 0, 0, 0 }, 0.3))
    c:polyline(archLine(cx, top + lw * 3.6, bottom - lw * 2, a - lw * 2.4, ah - lw * 3.6), max(1, lw * 0.4), mix(IRON, tone.bg, 0.55))
    -- the vial: a tube with a round bottom
    local vw = a * 0.5
    local vt = top + ah * 0.62
    local vb = bottom - lw * 3
    local r = vw / 2
    local function half(yy)
        if yy <= vb - r then return r end
        local dy = yy - (vb - r)
        return sqrt(max(0, r * r - dy * dy))
    end
    local vx = cx - a * 0.12
    fillRows(c, vx, vt, vb, half, mix(tone.bg, { 0, 0, 0 }, 0.5))
    local frac = (target and target > 0) and min(1, done / target) or 0
    local lvl = vb - (vb - vt) * frac
    if frac > 0 then
        fillRows(c, vx, lvl, vb, half, DEEP)
        fillRows(c, vx - r * 0.12, lvl, vb, function(yy) return half(yy) * 0.55 end, CRIMSON)
        c:rect(floor(vx - r * 0.45), floor(lvl + 2), max(1, floor(r * 0.14)), max(1, floor((vb - r) - lvl - 2)), BRIGHT)
    end
    -- the glass and its cap
    local gl = max(1, lw * 0.55)
    local outline = { vx - r, vt, vx - r, vb - r }
    for i = 1, 11 do
        local ang = pi - pi * i / 12
        outline[#outline + 1] = vx + r * cos(ang); outline[#outline + 1] = (vb - r) + r * sin(ang)
    end
    outline[#outline + 1] = vx + r; outline[#outline + 1] = vb - r
    outline[#outline + 1] = vx + r; outline[#outline + 1] = vt
    c:polyline(outline, gl, SILVER)
    c:rrect(floor(vx - r - lw * 0.8), floor(vt - lw * 2.4), floor(2 * r + lw * 1.6), floor(lw * 2.4), max(1, lw * 0.4), SILVER)
    if frac >= 1 then c:disc(vx, vt - lw * 1.2, max(2, lw * 0.9), CRIMSON) end
    -- a mark per book (per tenth past 40), longer every sixth
    local marks = (target and target > 0 and target <= 40) and target or 10
    local major = (marks == 10) and 5 or 6
    for k = 0, marks do
        local yy = vb - (vb - vt) * k / marks
        local L = (k % major == 0) and r * 0.9 or r * 0.45
        c:rect(floor(vx + r + lw), floor(yy), max(1, floor(L)), max(1, floor(gl)), mix(SILVER, tone.bg, 0.2))
    end
    -- the pointer at the level
    if frac > 0 then
        local px_ = vx - r - lw * 0.8
        local s = max(3, r * 0.4)
        fillRows(c, px_ - s * 0.5, lvl - s * 0.6, lvl + s * 0.6, function(yy) return s * 0.5 * (1 - abs(yy - lvl) / (s * 0.6)) end, CRIMSON)
    end
    return true
end

-- ─── bars: lancet windows ────────────────────────────────────────────────────

function D.chartBar(c, x, y, w, h, tone, fill, o)
    if h < 3 or w < 3 then return false end
    local col = o.current and fill or mix(fill, tone.bg, 0.45)
    local a = w / 2
    local ah = min(h, a * 1.6)
    arch(c, x + a, y, y + h, a, ah, col)
    if w >= 8 and h > ah * 0.7 + 4 then
        local mw = max(1, floor(w * 0.08))
        c:rect(floor(x + a - mw / 2), floor(y + ah * 0.55), mw, floor(h - ah * 0.55), mix(col, tone.bg, 0.55))
    end
    return true
end

-- ─── lines: dashes and crosses (pages), a line with diamonds (books) ────────

local function dashed(c, pts, lw, col, on, off)
    local draw, left = true, on
    local px_, py_ = pts[1], pts[2]
    local seg = { px_, py_ }
    for i = 3, #pts, 2 do
        local qx, qy = pts[i], pts[i + 1]
        local dx, dy = qx - px_, qy - py_
        local L = sqrt(dx * dx + dy * dy)
        local pos = 0
        if L > 0 then
            while L - pos > left do
                pos = pos + left
                local ex, ey = px_ + dx * pos / L, py_ + dy * pos / L
                if draw then
                    seg[#seg + 1] = ex; seg[#seg + 1] = ey
                    c:polyline(seg, lw, col)
                end
                draw = not draw
                left = draw and on or off
                seg = { ex, ey }
            end
            left = left - (L - pos)
            if draw then seg[#seg + 1] = qx; seg[#seg + 1] = qy end
        end
        px_, py_ = qx, qy
    end
    if draw and #seg >= 4 then c:polyline(seg, lw, col) end
end

local function diamond(c, x, y, s, col)
    fillRows(c, x, y - s, y + s, function(yy) return s * 0.7 * (1 - abs(yy - y) / s) end, col)
end

function D.line(c, pts, xs, ys, n, lw, fill, tone, o)
    local s = max(4, lw * 2.4)
    if o.series == 2 then
        dashed(c, pts, max(1.5, lw * 0.8), fill, max(4, lw * 3.5), max(3, lw * 2.5))
        local cw = max(2, lw)
        local cs = s * 1.1
        for i = 1, n do
            local x, y = xs[i], ys[i]
            c:polyline({ x, y, x, y - cs * 2.1 }, cw, fill)
            c:polyline({ x - cs * 0.6, y - cs * 1.45, x + cs * 0.6, y - cs * 1.45 }, cw, fill)
        end
    else
        c:polyline(pts, max(1.5, lw * 0.7), mix(fill, tone.bg, 0.25))
        for i = 1, n do
            diamond(c, xs[i], ys[i], s * 0.95, tone.bg)
            diamond(c, xs[i], ys[i], s * 0.8, fill)
        end
    end
    return true
end

-- ─── Today's timeline: a dark strip, a candle over each sitting ─────────────

local function flame(c, x, base, fh)
    c:disc(x, base - fh * 0.3, fh * 0.28, FLAME)
    c:disc(x, base - fh * 0.55, fh * 0.18, FLAME)
    c:disc(x, base - fh * 0.76, fh * 0.09, FLAME)
    c:disc(x, base - fh * 0.3, fh * 0.15, FLAME_IN)
end

local function moon(c, x, y, r, bg)
    c:disc(x, y, r, SILVER)
    c:disc(x + r * 0.45, y - r * 0.2, r * 0.82, bg)
end

function D.timeline(c, x, y, w, h, spans, now, tone)
    local top = floor(h * 0.55)
    local ty, th = y + top, max(4, h - top)
    c:rrect(x, ty, w, th, th / 2, tone.track)
    local fh = max(8, h * 0.62)
    local last = -1e9
    for _, sp in ipairs(spans) do
        local x1, x2 = x + w * sp[1], x + w * sp[2]
        local bw = max(th, x2 - x1)
        local bx = min(x1, x + w - bw)
        c:rrect(floor(bx), ty, floor(bw), th, th / 2, sp[3] or CRIMSON, tone.track)
        -- a candle flame over the sitting (not crowding the one before)
        local mx = bx + bw / 2
        if mx - last >= fh * 0.8 then
            flame(c, mx, ty - 1, fh)
            last = mx
        end
    end
    if now then
        local nx = x + w * now
        local r = max(3, h * 0.2)
        c:rect(floor(nx - max(1, th * 0.12)), floor(y + r * 2), max(2, floor(th * 0.24)), floor(ty + th + 3 - (y + r * 2)), SILVER)
        moon(c, nx, y + r * 0.6, r, tone.bg)
    end
    return true
end

-- ─── Reading trends: framed tiles, diamonds for the marks ───────────────────

local function quatrefoil(c, cx, cy, s, col, bg)
    local lw = max(1, s * 0.22)
    for i = 0, 3 do
        local px_, py_ = at(cx, cy, s * 0.5, i * pi / 2)
        c:disc(px_, py_, s * 0.5, col)
        c:disc(px_, py_, max(0.5, s * 0.5 - lw), bg)
    end
    c:disc(cx, cy, max(1, s * 0.18), col)
end

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, CRIMSON, 0.08) or mix(tone.bg, LILAC, 0.07)
    c:frame(x, y, w, h, min(h * 0.12, 10), max(1, floor(min(w, h) * 0.012)), mix(IRON, tone.bg, 0.35), base)
    local s = max(3, min(w, h) * 0.05)
    quatrefoil(c, x + w - s * 2.2, y + s * 2.2, s, mix(IRON, base, 0.2), base)
    return true
end

function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local col = (dir == "up") and LILAC or ((dir == "down") and CRIMSON or IRON)
    diamond(c, cx, cy, r * 1.3, SILVER)
    diamond(c, cx, cy, r * 1.3 - max(1.5, r * 0.12), col)
    local a = r * 0.4
    local lw = max(2, r * 0.2)
    local ink = (dir == "up") and { 34, 17, 51 } or WHITE
    if dir == "up" then
        c:polyline({ cx - a, cy + a * 0.45, cx, cy - a * 0.5, cx + a, cy + a * 0.45 }, lw, ink)
    elseif dir == "down" then
        c:polyline({ cx - a, cy - a * 0.45, cx, cy + a * 0.5, cx + a, cy - a * 0.45 }, lw, ink)
    else
        c:rect(floor(cx - a), floor(cy - lw / 2), floor(2 * a), max(2, floor(lw)), ink)
    end
    return true
end

-- ─── the calendar: lancet windows ────────────────────────────────────────────
-- A day without reading is a dark window with its number; a day you read
-- gets a wax seal on its cover; today has a crimson frame, or a candle over
-- its cover.

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local m = max(2, floor(min(w, h) * 0.08))
    local dw, dh = w - 2 * m, h - 2 * m
    if dw < 8 or dh < 8 then return false end
    local a = dw / 2
    local ah = min(dh * 0.42, a * 1.5)
    local lw = max(1, floor(min(dw, dh) * 0.06))
    local frame = o.today and CRIMSON or mix(IRON, tone.bg, o.future and 0.6 or 0.2)
    local glass = mix(tone.bg, LILAC, o.future and 0.03 or 0.09)
    local cx = x + w / 2
    arch(c, cx, y + m, y + m + dh, a, ah, frame)
    arch(c, cx, y + m + lw * 1.7, y + m + dh - lw, a - lw, ah - lw * 1.7, glass)
    if ah >= 12 and a >= 8 then
        local oy = y + m + ah * 0.62
        c:ring(cx, oy, max(2, a * 0.22), max(1, lw * 0.6), 1, mix(frame, glass, 0.4), mix(frame, glass, 0.4))
    end
    local lower = y + m + ah
    local size = o.num_px or max(10, floor((dh - ah) * 0.55))
    c:label(tostring(n), size, cx, lower + (y + m + dh - lower) / 2, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

-- ─── blood dripping from the top of a cover ─────────────────────────────────

local DRIPS = { { 0.07, 0.2, 0.05 }, { 0.19, 0.11, 0.04 }, { 0.33, 0.3, 0.055 }, { 0.48, 0.15, 0.04 },
                { 0.62, 0.25, 0.05 }, { 0.77, 0.09, 0.035 }, { 0.9, 0.36, 0.06 } }

local function blood(c, x, y, w, h)
    local band = max(2, h * 0.035)
    c:rect(floor(x), floor(y), floor(w), floor(band), DEEP)
    -- a wavy edge under the band
    local r = band * 0.8
    local n = max(3, floor(w / (r * 1.7)))
    for i = 0, n do c:disc(x + w * i / n, y + band, r * (0.7 + 0.3 * ((i * 7) % 3) / 2), DEEP) end
    for _, d in ipairs(DRIPS) do
        local dw = max(2, w * d[3])
        local dx = x + w * d[1]
        local len = max(band * 2, h * d[2])
        c:rect(floor(dx - dw / 2), floor(y), max(2, floor(dw)), floor(len), DEEP)
        c:disc(dx, y + len, dw * 0.85, DEEP)
        -- a little shine down the drip and on the drop
        c:rect(floor(dx - dw * 0.3), floor(y + band), max(1, floor(dw * 0.22)), floor(len * 0.75), CRIMSON)
        c:disc(dx - dw * 0.3, y + len - dw * 0.15, max(1, dw * 0.22), mix(CRIMSON, WHITE, 0.45))
    end
end

function D.calendarCover(c, x, y, w, h, tone, o)
    blood(c, x, y, w, h)
    local r = max(3, min(w, h) * 0.12)
    local sx, sy = x + w - r * 0.95, y + h - r * 0.95
    c:disc(sx, sy, r * 1.1, WINE)
    c:disc(sx, sy, r, CRIMSON)
    c:ring(sx, sy, r * 0.72, max(1, r * 0.12), 1, DEEP, DEEP)
    local cl = max(1, r * 0.14)
    c:polyline({ sx, sy - r * 0.42, sx, sy + r * 0.42 }, cl, DEEP)
    c:polyline({ sx - r * 0.3, sy - r * 0.1, sx + r * 0.3, sy - r * 0.1 }, cl, DEEP)
    if o.today then flame(c, x + w / 2, y + max(2, r * 0.2), max(6, r * 2)) end
    return true
end

-- ─── the challenge: a spider spinning its web ────────────────────────────────
-- The spokes are there from the start; the spiral is spun from the outside
-- in as the month's goal fills, the spider at the thread it is spinning.
-- Done: the spider sits in the middle.

local function spider(c, x, y, s, ang, tone)
    local lw = max(1, s * 0.13)
    for side = -1, 1, 2 do
        for k = 0, 3 do
            local a = ang + side * (0.55 + k * 0.42)
            local kx, ky = x + s * 0.75 * cos(a), y + s * 0.75 * sin(a)
            local fx, fy = kx + s * 0.6 * cos(a + side * 0.6), ky + s * 0.6 * sin(a + side * 0.6)
            c:polyline({ x, y, kx, ky, fx, fy }, lw, IRON)
        end
    end
    -- the abdomen behind, the head in front (facing ang)
    local bx, by = x - s * 0.45 * cos(ang), y - s * 0.45 * sin(ang)
    c:disc(bx, by, s * 0.5, SILVER)
    c:disc(x + s * 0.18 * cos(ang), y + s * 0.18 * sin(ang), s * 0.28, SILVER)
    -- a crimson mark on its back
    c:disc(bx, by, max(1, s * 0.17), CRIMSON)
end

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local spokes, turns = 12, 7
    local Rw = R * 0.92
    local thin = max(1, R * 0.012)
    local lw = max(1, R * 0.022)
    local frame = mix(IRON, tone.bg, 0.45)
    local function ang(i) return -pi / 2 + 2 * pi * i / spokes end
    -- the frame and the spokes
    for i = 0, spokes - 1 do
        local ex, ey = at(cx, cy, Rw, ang(i))
        c:polyline({ cx, cy, ex, ey }, thin, frame)
    end
    -- the spiral, ring by ring from the outside, each sagging a little
    -- between spokes; the unspun part faint
    local function radius(k) return Rw * (0.18 + 0.8 * (turns - k) / turns) end
    local function seg(r, i, col, w)
        local a0, a1 = ang(i), ang(i + 1)
        local x0, y0 = at(cx, cy, r, a0)
        local xm, ym = at(cx, cy, r * 0.93, (a0 + a1) / 2)
        local x1, y1 = at(cx, cy, r, a1)
        c:polyline({ x0, y0, xm, ym, x1, y1 }, w, col)
    end
    local spun = frac * turns * spokes
    local done_segs = floor(spun + 0.5)
    local last_r, last_i = nil, nil
    for k = 0, turns - 1 do
        local r = radius(k)
        for i = 0, spokes - 1 do
            local n = k * spokes + i
            if n < done_segs then
                seg(r, i, SILVER, lw)
                last_r, last_i = r, i + 1
            else
                seg(r, i, mix(frame, tone.bg, 0.5), thin)
            end
        end
    end
    -- the hub
    c:disc(cx, cy, max(1.5, R * 0.035), SILVER)
    local s = max(5, R * 0.16)
    if frac >= 1 then
        spider(c, cx, cy, s, -pi / 2, tone)
    elseif last_r then
        local a = ang(last_i)
        local sx, sy = at(cx, cy, last_r, a)
        spider(c, sx, sy, s, a + pi / 2, tone)
    else
        -- not started: hanging from a thread at the top
        local sx, sy = cx, cy - Rw - s * 0.2
        c:polyline({ sx, cy - R * 1.02, sx, sy }, thin, SILVER)
        spider(c, sx, sy + s * 0.6, s, pi / 2, tone)
    end
end

-- ─── progress bars: a crimson arrow ──────────────────────────────────────────

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local mid = y + h / 2
    local th = max(2, floor(h * 0.5))
    c:rrect(x, floor(mid - th / 2), w, th, th / 2, tone.track)
    local gap = max(10, h * 2.4)
    local tw = max(1, floor(h * 0.16))
    local tx = x + gap
    while tx < x + w - 2 do
        c:rect(floor(tx), floor(mid - h * 0.4), tw, max(2, floor(h * 0.8)), tone.track)
        tx = tx + gap
    end
    if frac <= 0 then return end
    local e = x + w * frac
    local hh = max(4, h * 0.95)
    local hl = hh * 1.6
    local shaft_end = max(x + 1, e - hl * 0.6)
    local sh = max(2, floor(h * 0.7))
    c:rrect(x, floor(mid - sh / 2), max(2, floor(shaft_end - x)), sh, sh / 2, ARROW, tone.track)
    tx = x + gap
    while tx < shaft_end - 2 do
        c:rect(floor(tx), floor(mid - h * 0.65), tw, max(2, floor(h * 1.3)), ARROW)
        tx = tx + gap
    end
    -- the fletching at the back
    if shaft_end - x > h * 3 then
        local fw = max(1, h * 0.2)
        for k = 0, 1 do
            local fx = x + h * 0.1 + k * h * 0.7
            c:polyline({ fx, mid - h * 0.8, fx + h * 0.65, mid, fx, mid + h * 0.8 }, fw, LILAC)
        end
    end
    -- the head
    local hx = min(e, x + w) - hl
    local step = max(1, floor(hh / 12))
    local yy = floor(mid - hh)
    while yy < mid + hh do
        local k = 1 - abs(yy + step / 2 - mid) / hh
        local len = hl * k
        if len > 0.5 then c:rect(floor(hx), yy, max(1, floor(len + 0.5)), step, SILVER) end
        yy = yy + step
    end
end

function D.bookCover(c, x, y, w, h, tone, o)
    blood(c, x, y, w, h)
    return true
end

return D
