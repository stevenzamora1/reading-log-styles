-- Space drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

local VIOLET, VIOLET_L, VIOLET_D = { 153, 119, 238 }, { 199, 179, 255 }, { 102, 68, 187 }
local CYAN, CYAN_L, CYAN_D = { 85, 204, 238 }, { 174, 232, 246 }, { 34, 136, 170 }
local GOLD, GOLD_D = { 238, 204, 85 }, { 187, 150, 40 }
local MOON = { 232, 228, 212 }
local PINK, RED = { 238, 136, 204 }, { 238, 102, 85 }
local HULL = { 223, 227, 245 }
local WHITE = { 255, 255, 255 }

local function at(cx, cy, r, a) return cx + r * cos(a), cy + r * sin(a) end
local function mix(a, b, t) return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t } end

-- A shape filled row by row between y0 and y1: half(y) is its half width at
-- that height, round cx.
local function fillRows(c, cx, y0, y1, half, col)
    if y1 - y0 < 0.5 then return end
    local step = max(1, floor((y1 - y0) / 120))
    local yy = floor(y0)
    while yy < y1 do
        local hw = half(yy + step / 2)
        if hw > 0.4 then c:rect(floor(cx - hw + 0.5), yy, max(1, floor(2 * hw + 0.5)), step, col) end
        yy = yy + step
    end
end

local function oval(c, cx, cy, a, b, col)
    fillRows(c, cx, cy - b, cy + b, function(yy)
        local k = (yy - cy) / b
        return a * sqrt(max(0, 1 - k * k))
    end, col)
end

-- A five-pointed star: a disc and five thick strokes.
local function star(c, cx, cy, r, col)
    local pts = {}
    for i = 0, 10 do
        local rr = (i % 2 == 0) and r or r * 0.45
        local a = -pi / 2 + pi * i / 5
        pts[#pts + 1] = cx + rr * cos(a)
        pts[#pts + 1] = cy + rr * sin(a)
    end
    c:disc(cx, cy, r * 0.45, col)
    c:polyline(pts, max(1.5, r * 0.3), col)
end

-- A soft glow: discs fading into the card.
local function glow(c, x, y, r, col, bg)
    for k = 3, 1, -1 do c:disc(x, y, r * (1 + k * 0.35), mix(col, bg, 0.55 + k * 0.12)) end
end

-- A twinkle: a four-pointed sparkle.
local function twinkle(c, x, y, r, col)
    c:polyline({ x - r, y, x + r, y }, max(1, r * 0.22), col)
    c:polyline({ x, y - r, x, y + r }, max(1, r * 0.22), col)
    c:disc(x, y, max(1, r * 0.3), col)
end

local function crescent(c, x, y, r, bg)
    c:disc(x, y, r, MOON)
    c:disc(x + r * 0.45, y - r * 0.2, r * 0.82, bg)
end

-- Points round a tilted ellipse, for th from t0 to t1.
local function ellipsePts(cx, cy, rx, ry, tilt, t0, t1, n)
    local pts = {}
    local ct, st = cos(tilt), sin(tilt)
    for i = 0, n do
        local th = t0 + (t1 - t0) * i / n
        local ex, ey = rx * cos(th), ry * sin(th)
        pts[#pts + 1] = cx + ex * ct - ey * st
        pts[#pts + 1] = cy + ex * st + ey * ct
    end
    return pts
end

-- ─── rings: comets (violet for pages, cyan for time) ─────────────────────────
-- A comet flies clockwise from the top as far as the day got, its tail
-- growing brighter and wider up to its head.

local function comet(c, cx, cy, R, t, frac, track, col, tail, tone)
    local rm = R - t / 2
    local orbit = mix(track, tone.bg, 0.1)
    c:ring(cx, cy, rm + t * 0.1, t * 0.2, 0, orbit, orbit)
    if frac <= 0 then return end
    frac = min(frac, 1)
    if R < 22 then
        c:ring(cx, cy, R, t, frac, track, col)
        return
    end
    local span = 2 * pi * frac
    local n = max(12, floor(rm * span / 3))
    for i = 0, n - 1 do
        local f0, f1 = i / n, (i + 1) / n
        local x0, y0 = at(cx, cy, rm, -pi / 2 + span * f0)
        local x1, y1 = at(cx, cy, rm, -pi / 2 + span * f1)
        c:polyline({ x0, y0, x1, y1 }, max(1, t * (0.12 + 0.72 * f1 ^ 1.6)), mix(tone.bg, tail, 0.2 + 0.8 * f1))
    end
    local hx, hy = at(cx, cy, rm, -pi / 2 + span)
    glow(c, hx, hy, t * 0.42, col, tone.bg)
    c:disc(hx, hy, t * 0.5, col)
    c:disc(hx, hy, t * 0.35, WHITE)
end

local D = {}

-- ─── the rings: the moon with a comet round it ──────────────────────────────
-- The moon in the middle waxes from a sliver to full as the day's pages add
-- up; a comet flies round it with the minutes, its tail growing up to its
-- head. The streak is in the card's figures. Reading Log draws a set of rings
-- outer first at one centre, so the pages call draws the moon and the empty
-- orbit and the minutes call sends the comet round. A ring on its own
-- somewhere else is still a comet.

local function waxing(c, cx, cy, r, p, tone)
    c:disc(cx, cy, r + max(1, r * 0.04), mix(tone.track, tone.fg, 0.2))
    c:disc(cx, cy, r, mix(tone.track, MOON, 0.12))
    p = min(1, max(0, p or 0))
    if p > 0 then
        local term = cos(pi * p)            -- the terminator: 1 = new, -1 = full
        local step = max(1, floor(r / 60))
        local yy = floor(cy - r)
        while yy < cy + r do
            local dy = yy + step / 2 - cy
            local hw = sqrt(max(0, r * r - dy * dy))
            local x0 = cx + hw * term
            if cx + hw - x0 > 0.4 then c:rect(floor(x0 + 0.5), yy, max(1, floor(cx + hw - x0 + 0.5)), step, MOON) end
            yy = yy + step
        end
    end
    -- craters, shaded where the light has reached
    if r >= 8 then
        local lit = mix(MOON, tone.track, 0.25)
        for _, cr in ipairs({ { -0.32, -0.22, 0.17 }, { 0.26, 0.3, 0.12 }, { 0.3, -0.36, 0.09 }, { -0.1, 0.45, 0.08 } }) do
            local x = cx + cr[1] * r
            local inlit = p >= 1 or (x >= cx + sqrt(max(0, r * r - (cr[2] * r) ^ 2)) * cos(pi * p))
            c:disc(x, cy + cr[2] * r, max(1, r * cr[3]), inlit and lit or mix(tone.track, tone.bg, 0.25))
        end
    end
end

local tri

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    if which == 1 then
        tri = { c = c, cx = cx, cy = cy, R = R, t = t }
        local orbit = mix(track, tone.bg, 0.1)
        local rm = R - t / 2
        -- a few stars scattered round the orbit
        for k = 0, 5 do
            local sx, sy = at(cx, cy, rm * (0.72 + 0.1 * (k % 2)), k * pi / 3 + 0.5)
            star(c, sx, sy, max(1.5, t * 0.16), mix(GOLD, tone.bg, 0.35))
        end
        c:ring(cx, cy, rm + t * 0.1, t * 0.2, 0, orbit, orbit)
        waxing(c, cx, cy, R * 0.5, frac, tone)
        return true
    end
    if tri and tri.c == c and tri.cx == cx and tri.cy == cy then
        if which == 2 then
            comet(c, cx, cy, tri.R, tri.t, max(0, frac or 0), track, CYAN, CYAN_L, tone)
        else
            tri = nil
        end
        return true
    end
    -- a ring on its own
    comet(c, cx, cy, R, t, max(0, frac or 0), track, which == 2 and CYAN or VIOLET, which == 2 and CYAN_L or VIOLET_L, tone)
    return true
end

-- ─── a day: the moon waxing ──────────────────────────────────────────────────
-- The moon fills from a sliver to full as the day's pages add up; a cyan ring
-- round it shows the minutes. A gold star by today's; days to come are dots.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    if o.future then
        c:disc(cx, cy, max(1.5, d * 0.06), mix(tone.track, tone.fg, 0.15))
        return true
    end
    local r = d * 0.36
    c:ring(cx, cy, d * 0.48, max(1.5, d * 0.07), min(1, fm or 0), mix(tone.track, tone.bg, 0.2), CYAN)
    c:disc(cx, cy, r, mix(tone.track, MOON, 0.12))
    local p = min(1, fp or 0)
    if p > 0 then
        local term = cos(pi * p)            -- the terminator: 1 = new, -1 = full
        local step = max(1, floor(r / 30))
        local yy = floor(cy - r)
        while yy < cy + r do
            local dy = yy + step / 2 - cy
            local hw = sqrt(max(0, r * r - dy * dy))
            local x0 = cx + hw * term
            if cx + hw - x0 > 0.4 then c:rect(floor(x0 + 0.5), yy, max(1, floor(cx + hw - x0 + 0.5)), step, MOON) end
            yy = yy + step
        end
        if p >= 1 and r >= 8 then
            c:disc(cx - r * 0.3, cy - r * 0.2, max(1, r * 0.16), mix(MOON, tone.track, 0.25))
            c:disc(cx + r * 0.25, cy + r * 0.3, max(1, r * 0.11), mix(MOON, tone.track, 0.25))
        end
    end
    if o.today then star(c, cx + r * 0.95, cy - r * 0.95, max(3, d * 0.12), GOLD) end
    return true
end

-- ─── the year goal: a star cluster ──────────────────────────────────────────
-- A star for every book of the goal, packed in a round cluster (a sunflower
-- spiral, so it stays neat at 10 or 200). Read books light up from the bright
-- middle outward; the rest are faint. Past 300 each star stands for several.

local CLUSTER = { VIOLET, CYAN, PINK, VIOLET_L, GOLD, CYAN_L }

function D.goal(c, x, y, w, h, done, target, tone)
    local n = (target and target > 0) and min(target, 300) or 24
    local per = (target and target > 0) and target / n or 1
    local lit = (target and target > 0) and floor(min(done or 0, target) / per + 1e-6) or 0
    local cx, cy = x + w / 2, y + h / 2
    local rx, ry = w * 0.46, h * 0.44
    local d = 0.9 * sqrt(rx * ry / n)
    local r = max(1.2, min(d * 0.48, min(w, h) * 0.07))
    local dim = mix(tone.track, tone.fg, 0.12)
    local core = max(2, min(rx, ry) * 0.12)
    glow(c, cx, cy, core * 1.3, VIOLET, tone.bg)
    for i = 0, n - 1 do
        local f = sqrt((i + 0.5) / n)
        local a = i * 2.39996
        local px = cx + rx * f * cos(a)
        local py = cy + ry * f * sin(a)
        if i < lit then
            local col = CLUSTER[(i % #CLUSTER) + 1]
            if r >= 5 then
                star(c, px, py, r * 1.05, col)
            else
                c:disc(px, py, r * 1.25, mix(col, tone.bg, 0.55))
                c:disc(px, py, r * 0.9, col)
            end
        else
            c:disc(px, py, max(1, r * 0.45), dim)
        end
    end
    c:disc(cx, cy, core * 0.7, mix(GOLD, WHITE, 0.3))
    if target and target > 0 and (done or 0) >= target then
        twinkle(c, cx + rx * 0.9, cy - ry * 0.85, max(4, r * 2), WHITE)
        twinkle(c, cx - rx * 0.88, cy + ry * 0.8, max(3, r * 1.5), GOLD)
    end
    return true
end

-- ─── bars: columns of light with a star on top ───────────────────────────────

function D.chartBar(c, x, y, w, h, tone, fill, o)
    if w < 3 or h < 3 then return false end
    local col = o.current and VIOLET or mix(CYAN, tone.bg, 0.3)
    c:rrect(x, y, w, h, min(w / 2, h / 2), col)
    if w >= 6 then
        c:rect(floor(x + w * 0.42), floor(y + w * 0.5), max(1, floor(w * 0.16)), max(1, floor(h - w * 0.6)), mix(col, WHITE, 0.35))
    end
    if o.current then
        glow(c, x + w / 2, y, max(3, w * 0.35), GOLD, tone.bg)
        star(c, x + w / 2, y, max(3, w * 0.42), GOLD)
    else
        c:disc(x + w / 2, y + max(2, w * 0.25), max(1, w * 0.12), WHITE)
    end
    return true
end

-- ─── lines: stars (books), a dashed line with little planets (pages) ─────────

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

function D.line(c, pts, xs, ys, n, lw, fill, tone, o)
    local s = max(5, lw * 2.4)
    if o.series == 2 then
        dashed(c, pts, max(1.5, lw * 0.8), fill, max(4, lw * 3.5), max(3, lw * 2.5))
        for i = 1, n do
            c:polyline(ellipsePts(xs[i], ys[i], s * 1.1, s * 0.32, -0.3, 0, 2 * pi, 16), max(1, lw * 0.45), GOLD)
            c:disc(xs[i], ys[i], s * 0.55, fill)
        end
    else
        c:polyline(pts, max(1.5, lw * 0.75), fill)
        for i = 1, n do
            c:disc(xs[i], ys[i], s * 0.9, tone.bg)
            star(c, xs[i], ys[i], s * 0.85, fill)
        end
    end
    return true
end

-- ─── Today's timeline: a strip of night, a twinkle over each sitting ─────────

function D.timeline(c, x, y, w, h, spans, now, tone)
    local top = floor(h * 0.55)
    local ty, th = y + top, max(4, h - top)
    c:rrect(x, ty, w, th, th / 2, tone.track)
    local tr = max(4, h * 0.3)
    local last = -1e9
    for _, sp in ipairs(spans) do
        local x1, x2 = x + w * sp[1], x + w * sp[2]
        local bw = max(th, x2 - x1)
        local bx = min(x1, x + w - bw)
        c:rrect(floor(bx), ty, floor(bw), th, th / 2, sp[3] or VIOLET, tone.track)
        local mx = bx + bw / 2
        if mx - last >= tr * 2.2 then
            twinkle(c, mx, ty - tr * 1.1, tr, GOLD)
            last = mx
        end
    end
    if now then
        local nx = x + w * now
        local r = max(3, h * 0.22)
        c:rect(floor(nx - max(1, th * 0.12)), floor(y + r * 2), max(2, floor(th * 0.24)), floor(ty + th + 3 - (y + r * 2)), MOON)
        crescent(c, nx, y + r * 0.8, r, tone.bg)
    end
    return true
end

-- ─── Reading trends: starry tiles, ringed planets for the marks ─────────────

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, VIOLET, 0.12) or mix(tone.bg, CYAN, 0.1)
    c:rrect(x, y, w, h, min(h * 0.18, 14), base)
    local seed = 3 + i * 17
    for _ = 1, 9 do
        seed = (seed * 1103515245 + 12345) % 2147483648
        local fx = (seed % 1000) / 1000
        seed = (seed * 1103515245 + 12345) % 2147483648
        local fy = (seed % 1000) / 1000
        c:disc(x + w * (0.35 + 0.6 * fx), y + h * (0.1 + 0.8 * fy), max(0.8, h * 0.012), mix(base, WHITE, 0.45))
    end
    local s = max(6, min(w, h) * 0.12)
    local px_, py_ = x + w - s * 2, y + s * 1.6
    c:polyline(ellipsePts(px_, py_, s * 1.7, s * 0.5, -0.3, pi, 2 * pi, 12), max(1, s * 0.16), mix(GOLD, base, 0.3))
    c:disc(px_, py_, s, mix(PINK, base, 0.25))
    c:polyline(ellipsePts(px_, py_, s * 1.7, s * 0.5, -0.3, 0, pi, 12), max(1, s * 0.16), mix(GOLD, base, 0.3))
    return true
end

function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local col = (dir == "up") and CYAN or ((dir == "down") and PINK or VIOLET)
    c:polyline(ellipsePts(cx, cy, r * 1.55, r * 0.42, -0.3, pi, 2 * pi, 14), max(1.5, r * 0.14), GOLD)
    c:disc(cx, cy, r, col)
    c:disc(cx - r * 0.4, cy - r * 0.4, max(1, r * 0.16), mix(col, WHITE, 0.6))
    local a = r * 0.42
    local lw = max(2, r * 0.2)
    local ink = { 20, 26, 61 }
    if dir == "up" then
        c:polyline({ cx - a, cy + a * 0.45, cx, cy - a * 0.5, cx + a, cy + a * 0.45 }, lw, ink)
    elseif dir == "down" then
        c:polyline({ cx - a, cy - a * 0.45, cx, cy + a * 0.5, cx + a, cy - a * 0.45 }, lw, ink)
    else
        c:rect(floor(cx - a), floor(cy - lw / 2), floor(2 * a), max(2, floor(lw)), ink)
    end
    c:polyline(ellipsePts(cx, cy, r * 1.55, r * 0.42, -0.3, 0, pi, 14), max(1.5, r * 0.14), GOLD)
    return true
end

-- ─── the calendar: little planets ────────────────────────────────────────────
-- A day without reading is a small planet with its number; a day you read
-- has a gold star by its cover; today has a gold ring, or the moon over its
-- cover.

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local m = max(2, floor(min(w, h) * 0.1))
    local r = (min(w, h) - 2 * m) / 2
    if r < 6 then return false end
    local cx, cy = x + w / 2, y + h / 2
    local fade = o.future and 0.6 or 0
    local planet = mix(mix(tone.track, VIOLET, 0.25), tone.bg, fade)
    local ringc = o.today and GOLD or mix(mix(tone.track, tone.fg, 0.25), tone.bg, fade)
    local rx = min(r * 1.2, w / 2 - 3)
    c:polyline(ellipsePts(cx, cy, rx, r * 0.32, -0.25, pi, 2 * pi, 16), max(1.5, r * 0.1), ringc)
    c:disc(cx, cy, r * 0.82, planet)
    c:polyline(ellipsePts(cx, cy, rx, r * 0.32, -0.25, 0.1, pi - 0.1, 16), max(1.5, r * 0.1), ringc)
    local size = o.num_px or max(10, floor(r * 0.75))
    c:label(tostring(n), size, cx, cy, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

-- Stars spilling over the top edge of a cover and a comet across its lower
-- corner.
local EDGE = { { -0.04, 0.02, 0.11, GOLD }, { 0.24, -0.05, 0.06, WHITE }, { 0.55, 0.03, 0.08, CYAN },
               { 0.86, -0.02, 0.07, PINK }, { 1.04, 0.2, 0.05, WHITE }, { -0.06, 0.32, 0.045, VIOLET_L } }

local function starryEdge(c, x, y, w, h, tone)
    local u = min(w, h * 0.7)
    for _, e in ipairs(EDGE) do
        local sx, sy, r = x + w * e[1], y + h * e[2], max(2.5, u * e[3])
        c:disc(sx, sy, r * 0.75, tone.bg)
        twinkle(c, sx, sy, r, e[4])
    end
    -- the comet: a tail from the right edge down to its head
    local hx, hy = x + w * 0.72, y + h * 0.9
    local tx, ty = x + w * 1.06, y + h * 0.68
    local hr = max(2, u * 0.06)
    local n = 18
    for k = n - 1, 0, -1 do
        local f0, f1 = k / n, (k + 1) / n
        c:polyline({ hx + (tx - hx) * f0, hy + (ty - hy) * f0, hx + (tx - hx) * f1, hy + (ty - hy) * f1 },
            max(1, hr * 1.7 * (1 - f0)), mix(k < 2 and CYAN_L or VIOLET_L, tone.bg, 0.15 + 0.7 * f0))
    end
    c:disc(hx, hy, hr * 1.35, CYAN_L)
    c:disc(hx, hy, hr, WHITE)
end

function D.bookCover(c, x, y, w, h, tone, o)
    starryEdge(c, x, y, w, h, tone)
    return true
end

function D.calendarCover(c, x, y, w, h, tone, o)
    local s = max(4, min(w, h) * 0.13)
    starryEdge(c, x, y, w, h, tone)
    if o.today then crescent(c, x + w * 0.5, y - s * 0.6, max(4, s * 0.9), tone.bg) end
    return true
end

-- ─── the challenge: a spiral galaxy ────────────────────────────────────────
-- Two arms wind out from a bright core; their stars light from the core
-- outward as the month's goal is met. A full galaxy gets a twinkle.

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local bg = tone and tone.bg or { 20, 26, 61 }
    local dim = mix(tone and tone.track or { 42, 50, 102 }, bg, 0.15)
    local N = 24 -- stars per arm
    local turns = 0.95
    local squash = 0.78
    -- a faint haze behind the core
    glow(c, cx, cy, R * 0.18, mix(VIOLET, bg, 0.3), bg)
    local stars = {}
    for arm = 0, 1 do
        for i = 1, N do
            local t = i / N
            local ang = arm * pi + t * turns * 2 * pi - 0.4
            local rr = R * (0.16 + 0.8 * t ^ 0.9)
            stars[#stars + 1] = { cx + rr * cos(ang), cy + rr * squash * sin(ang), t, i }
            -- a little dust beside the arm
            if i % 2 == 0 then
                local da = ang - 0.22
                local dr = rr * 0.86
                stars[#stars + 1] = { cx + dr * cos(da), cy + dr * squash * sin(da), t, i + 100, true }
            end
        end
    end
    -- light the inner stars first; both arms together
    for _, st in ipairs(stars) do
        local on = st[3] <= frac + 1e-6
        local size = max(1.2, R * (0.03 + 0.035 * st[3])) * (st[5] and 0.55 or 1)
        if on then
            local col = (st[4] % 3 == 0) and CYAN or ((st[4] % 5 == 0) and PINK or VIOLET_L)
            c:disc(st[1], st[2], size * 1.6, mix(col, bg, 0.6))
            c:disc(st[1], st[2], size, col)
        else
            c:disc(st[1], st[2], size * 0.8, dim)
        end
    end
    -- the core
    c:disc(cx, cy, R * 0.11, mix(GOLD, WHITE, 0.2))
    c:disc(cx, cy, R * 0.06, WHITE)
    if frac >= 1 then
        twinkle(c, cx + R * 0.72, cy - R * 0.6, R * 0.1, GOLD)
        twinkle(c, cx - R * 0.78, cy + R * 0.55, R * 0.07, CYAN_L)
    end
    return true
end

-- ─── progress bars: a rocket and its trail ───────────────────────────────────

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local mid = y + h / 2
    local th = max(2, floor(h * 0.5))
    c:rrect(x, floor(mid - th / 2), w, th, th / 2, tone.track)
    if frac <= 0 then return end
    local e = x + w * frac
    local sh = max(3, floor(h * 0.7))
    c:rrect(x, floor(mid - sh / 2), max(sh, floor(e - x)), sh, sh / 2, VIOLET_D, tone.track)
    c:rrect(x, floor(mid - sh * 0.18), max(sh, floor(e - x)), max(1, floor(sh * 0.36)), sh * 0.18, VIOLET_L, VIOLET_D)
    -- sparkles along the trail
    local gap = max(14, h * 4)
    local sx = x + gap * 0.6
    local k = 0
    while sx < e - h * 3 do
        twinkle(c, sx, mid + ((k % 2 == 0) and -h * 0.9 or h * 0.9), max(2, h * 0.32), (k % 2 == 0) and GOLD or CYAN_L)
        k = k + 1
        sx = sx + gap
    end
    -- the rocket, nose to the right, flame behind
    local L = max(12, h * 2.6)
    local rx = min(e, x + w) - L * 0.35
    local a, b = L * 0.38, L * 0.17
    c:disc(rx - a * 1.05, mid, b * 0.75, { 255, 170, 51 })
    c:disc(rx - a * 1.35, mid, b * 0.45, GOLD)
    c:polyline({ rx - a * 0.5, mid - b * 0.9, rx - a * 0.85, mid - b * 1.6 }, max(1.5, b * 0.5), RED)
    c:polyline({ rx - a * 0.5, mid + b * 0.9, rx - a * 0.85, mid + b * 1.6 }, max(1.5, b * 0.5), RED)
    oval(c, rx, mid, a + 1, b + 1, { 138, 144, 184 })
    oval(c, rx, mid, a, b, HULL)
    c:disc(rx + a * 0.25, mid, max(1, b * 0.45), CYAN)
end

return D
