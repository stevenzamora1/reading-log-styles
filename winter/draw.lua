-- Winter drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

local SNOW, SNOW_D, SNOW_E = { 214, 232, 248 }, { 168, 202, 232 }, { 120, 160, 200 }
local PACKED = { 182, 212, 242 }  -- snow packed into a snowman, a shade darker than the card
local ICE, ICE_D, ICE_L = { 110, 172, 232 }, { 36, 108, 178 }, { 196, 226, 250 }
local RED, RED_D = { 214, 70, 82 }, { 160, 40, 52 }
local COAL, CARROT, WOOD = { 40, 44, 56 }, { 240, 136, 40 }, { 120, 84, 56 }
local WHITE, NIGHT = { 255, 255, 255 }, { 30, 48, 80 }

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

-- The part of a ball below a level: frac of it, from the bottom.
local function ballFill(c, cx, cy, r, frac, col)
    frac = max(0, min(1, frac or 0))
    if frac <= 0 then return end
    if frac >= 1 then c:disc(cx, cy, r, col) return end
    fillRows(c, cx, cy + r - 2 * r * frac, cy + r, function(yy)
        local dy = yy - cy
        return sqrt(max(0, r * r - dy * dy))
    end, col)
end

-- A six-armed snowflake.
local function flake(c, x, y, r, col)
    local lw = max(1, r * 0.14)
    for k = 0, 5 do
        local a = k * pi / 3 - pi / 2
        local ex, ey = x + r * cos(a), y + r * sin(a)
        c:polyline({ x, y, ex, ey }, lw, col)
        local mx, my = x + r * 0.6 * cos(a), y + r * 0.6 * sin(a)
        for s = -1, 1, 2 do
            local b = a + s * 0.7
            c:polyline({ mx, my, mx + r * 0.3 * cos(b), my + r * 0.3 * sin(b) }, lw, col)
        end
    end
end

local D = {}

-- ─── the rings: a snowman you build ──────────────────────────────────────────
-- One snowman instead of three rings: it packs with snow from the bottom
-- with the day's pages (buttons and stick arms go on when they're done), the
-- minutes give it its face (the scarf wraps on, then the eyes, then the
-- carrot nose grows), and its top hat fills with the streak. Reading Log draws a set of rings
-- outer first at one centre, so the first call draws the snowman empty and
-- fills its body, and the next two do theirs. A ring on its own elsewhere is
-- drawn the usual way.

local BALLS = { { 0.5, 0.42 }, { -0.1, 0.31 }, { -0.56, 0.23 } } -- (centre, radius) in R

local function ball(cy, R, i) return cy + BALLS[i][1] * R, BALLS[i][2] * R end

local function snowmanEmpty(c, cx, cy, R, tone, faint)
    local e = max(1, R * 0.03)
    local pale = mix(SNOW, tone.bg, faint and 0.8 or 0.7)
    for i = 1, 3 do
        local by, br = ball(cy, R, i)
        c:disc(cx, by, br + e, mix(SNOW_E, tone.bg, faint and 0.7 or 0.25))
        c:disc(cx, by, br, pale)
    end
end

local function buttons(c, cx, cy, R)
    local y2, r2 = ball(cy, R, 2)
    for k = -1, 1 do c:disc(cx, y2 + k * r2 * 0.42, max(1, R * 0.035), COAL) end
    -- stick arms
    local lw = max(1, R * 0.03)
    c:polyline({ cx - r2 * 0.9, y2 - r2 * 0.1, cx - r2 * 1.9, y2 - r2 * 0.7 }, lw, WOOD)
    c:polyline({ cx + r2 * 0.9, y2 - r2 * 0.1, cx + r2 * 1.9, y2 - r2 * 0.7 }, lw, WOOD)
end

local function scarf(c, cx, cy, R, frac, col)
    frac = max(0, min(1, frac or 0))
    if frac <= 0 then return end
    local y2, r2 = ball(cy, R, 2)
    local yy = y2 - r2 * 0.92
    local hw = r2 * 0.95
    local th = max(2, R * 0.09)
    local wrap = min(1, frac / 0.7)
    c:rrect(floor(cx - hw), floor(yy - th / 2), max(2, floor(2 * hw * wrap)), floor(th), th * 0.4, col)
    if frac > 0.7 then
        local len = R * 0.32 * (frac - 0.7) / 0.3
        c:rrect(floor(cx + hw * 0.35), floor(yy), max(2, floor(th * 0.9)), max(2, floor(len)), th * 0.3, mix(col, COAL, 0.15))
        if frac >= 1 then
            for k = 0, 2 do c:rect(floor(cx + hw * 0.35 + k * th * 0.32), floor(yy + len), max(1, floor(th * 0.18)), max(1, floor(th * 0.4)), col) end
        end
    end
end

-- the face: eyes, then a carrot nose that grows to full length
local function face(c, cx, cy, R, frac)
    if frac < 0.7 then return end
    local hy, hr = ball(cy, R, 3)
    c:disc(cx - hr * 0.35, hy - hr * 0.2, max(1, R * 0.03), COAL)
    c:disc(cx + hr * 0.35, hy - hr * 0.2, max(1, R * 0.03), COAL)
    local len = hr * 0.75 * min(1, (frac - 0.7) / 0.3)
    if len > 1 then
        fillRows(c, cx + len / 2, hy - hr * 0.08, hy + hr * 0.1, function() return len / 2 end, CARROT)
    end
    if frac >= 1 then
        -- a coal smile
        for k = -2, 2 do c:disc(cx + k * hr * 0.16, hy + hr * 0.34 + (2 - abs(k)) * hr * 0.06, max(1, R * 0.018), COAL) end
    end
end

-- the hat, as (top, bottom, half width) in head radii above the head's centre
local HAT = { { -1.7, -1.1, 0.6 }, { -1.12, -0.96, 0.6 }, { -0.98, -0.82, 0.95 } }

local function hat(c, cx, cy, R, frac, tone)
    local hy, hr = ball(cy, R, 3)
    local top, bottom = hy + HAT[1][1] * hr, hy + HAT[3][2] * hr
    local function half(yy)
        for _, p in ipairs(HAT) do
            if yy >= hy + p[1] * hr and yy <= hy + p[2] * hr then return p[3] * hr end
        end
        return 0
    end
    -- the empty hat: an outline waiting for the streak
    local e = max(1, R * 0.025)
    fillRows(c, cx, top - e, bottom + e, function(yy) local h = half(min(bottom, max(top, yy))); return h > 0 and h + e or 0 end,
        mix(SNOW_E, tone.bg, 0.3))
    fillRows(c, cx, top, bottom, half, mix(SNOW, tone.bg, 0.6))
    frac = max(0, min(1, frac or 0))
    if frac > 0 then fillRows(c, cx, bottom - (bottom - top) * frac, bottom, half, COAL) end
    if frac >= 1 then
        fillRows(c, cx, hy + HAT[2][1] * hr, hy + HAT[2][2] * hr, half, RED)
        c:disc(cx - hr * 0.25, hy - hr * 1.5, max(1, hr * 0.08), mix(COAL, WHITE, 0.35))
    end
end

-- the whole snowman packed with snow from the bottom up, frac of the way
local function snowFill(c, cx, cy, R, frac)
    frac = max(0, min(1, frac or 0))
    if frac <= 0 then return end
    local y1b, r1 = ball(cy, R, 1)
    local hy, hr = ball(cy, R, 3)
    local bottom, top = y1b + r1, hy - hr
    local level = bottom - (bottom - top) * frac
    for i = 1, 3 do
        local by, br = ball(cy, R, i)
        local y0 = max(level, by - br)
        if y0 < by + br then
            fillRows(c, cx, y0, by + br, function(yy)
                local dy = yy - by
                return sqrt(max(0, br * br - dy * dy))
            end, PACKED)
        end
        -- a shine once a ball is packed past its middle
        if level < by and br >= 4 then c:disc(cx - br * 0.55, by - br * 0.5, br * 0.14, WHITE) end
    end
end

local tri

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    frac = max(0, frac or 0)
    if which == 1 then
        -- pages: the snow, and buttons and arms once they're done
        tri = { c = c, cx = cx, cy = cy, R = R }
        snowmanEmpty(c, cx, cy, R, tone)
        snowFill(c, cx, cy, R, frac)
        if frac >= 1 then buttons(c, cx, cy, R) end
        return true
    end
    if not (tri and tri.c == c and tri.cx == cx and tri.cy == cy) then return false end
    local r = tri.R
    if which == 2 then
        -- minutes: the scarf wraps on, then the eyes, then the nose grows
        scarf(c, cx, cy, r, min(1, frac / 0.6), RED)
        face(c, cx, cy, r, min(1, frac))
    else
        -- the streak: the hat
        hat(c, cx, cy, r, frac, tone)
        tri = nil
    end
    return true
end

-- ─── a day: a little snowman ─────────────────────────────────────────────────
-- It packs with snow from the bottom with the day's pages, gets its scarf
-- and face once the day's minutes are read, and its hat once both are done. Days to
-- come are a faint outline.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    local R = d * 0.52
    if o.future then
        snowmanEmpty(c, cx, cy, R, tone, true)
        return true
    end
    snowmanEmpty(c, cx, cy, R, tone)
    snowFill(c, cx, cy, R, fp or 0)
    local mins = min(1, fm or 0)
    if mins >= 1 then
        scarf(c, cx, cy, R, 1, RED)
        face(c, cx, cy, R, 1)
    end
    if (fp or 0) >= 1 and mins >= 1 then
        local hy, hr = ball(cy, R, 3)
        fillRows(c, cx, hy - 1.7 * hr, hy - 0.82 * hr, function(yy)
            if yy >= hy - 0.98 * hr then return 0.95 * hr end
            return 0.6 * hr
        end, COAL)
    end
    if o.today then
        c:rect(floor(cx - 0.55 * R), floor(cy + 0.96 * R), max(2, floor(1.1 * R)), max(2, floor(0.07 * R)), ICE_D)
    end
    return true
end

-- ─── the year goal: an igloo ─────────────────────────────────────────────────
-- An ice block for every book (as many as fit; past 48 each stands for
-- several), laid row by row from the bottom of the dome. A read book's block
-- is solid ice; the rest are faint. A flag goes up once the goal is met.

function D.goal(c, x, y, w, h, done, target, tone)
    local n = (target and target > 0) and min(target, 48) or 12
    local per = (target and target > 0) and target / n or 1
    local lit = (target and target > 0) and floor(min(done or 0, target) / per + 1e-6) or 0
    local W = min(w * 0.96, h * 1.7)
    local H = W * 0.56
    local cx, base = x + w / 2, y + h - (h - H) * 0.35
    -- the fewest rows that hold n blocks
    local rows, layout
    for r = 2, 14 do
        local bh = H / r
        local out, total = {}, 0
        for j = 0, r - 1 do
            local ym = (j + 0.5) / r
            local half = W / 2 * sqrt(max(0, 1 - ym * ym))
            local k = max(1, floor(2 * half / (bh * 1.5) + 0.5))
            out[#out + 1] = { k = k, half = half, y = base - (j + 1) * bh, bh = bh }
            total = total + k
        end
        layout = out
        rows = r
        if total >= n then break end
    end
    -- the dome behind, faint
    fillRows(c, cx, base - H, base, function(yy)
        local k = (base - yy) / H
        return W / 2 * sqrt(max(0, 1 - k * k))
    end, mix(SNOW, tone.bg, 0.6))
    local idx = 0
    for _, row in ipairs(layout) do
        local bw = 2 * row.half / row.k
        local gap = max(1, row.bh * 0.1)
        for i = 0, row.k - 1 do
            idx = idx + 1
            if idx > n then break end
            local bx = cx - row.half + i * bw
            local on = idx <= lit
            c:rrect(floor(bx + gap / 2), floor(row.y + gap / 2), max(2, floor(bw - gap)), max(2, floor(row.bh - gap)),
                min(bw, row.bh) * 0.15, on and ICE or mix(SNOW_D, tone.bg, 0.45))
            if on and row.bh >= 8 then
                c:rect(floor(bx + gap), floor(row.y + gap), max(1, floor(bw * 0.4)), max(1, floor(row.bh * 0.14)), ICE_L)
            end
        end
    end
    -- the door
    local dw, dh = W * 0.2, H * 0.36
    fillRows(c, cx, base - dh, base, function(yy)
        local k = (yy - (base - dh)) / dh
        if k < 0.45 then local q = 1 - k / 0.45; return dw / 2 * sqrt(max(0, 1 - q * q)) end
        return dw / 2
    end, NIGHT)
    c:rect(floor(cx - W * 0.55), floor(base), floor(W * 1.1), max(2, floor(H * 0.05)), SNOW_D)
    if target and target > 0 and (done or 0) >= target then
        local fx, fy = cx + W * 0.04, base - H
        c:rect(floor(fx), floor(fy - H * 0.32), max(1, floor(H * 0.03)), floor(H * 0.34), WOOD)
        fillRows(c, fx + H * 0.1, fy - H * 0.32, fy - H * 0.18, function() return H * 0.09 end, RED)
    end
    return true
end

-- ─── progress bars: a penguin sliding on the ice ─────────────────────────────

local function penguin(c, x, y, s)
    -- on its belly, sliding right; s is its length
    local r = s * 0.28
    fillRows(c, x, y - r, y + r * 0.7, function(yy)
        local k = (yy - y) / r
        return s * 0.5 * sqrt(max(0, 1 - k * k * 0.8))
    end, COAL)
    fillRows(c, x + s * 0.05, y, y + r * 0.7, function(yy)
        local k = (yy - y) / r
        return s * 0.4 * sqrt(max(0, 1 - k * k * 1.6))
    end, WHITE)
    c:disc(x + s * 0.4, y - r * 0.25, r * 0.75, COAL)
    c:disc(x + s * 0.5, y - r * 0.4, max(1, r * 0.16), WHITE)
    c:disc(x + s * 0.52, y - r * 0.4, max(0.6, r * 0.08), COAL)
    fillRows(c, x + s * 0.68, y - r * 0.32, y - r * 0.08, function() return s * 0.08 end, CARROT)
    c:disc(x - s * 0.5, y + r * 0.1, max(1, r * 0.3), CARROT)
end

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local mid = y + h / 2
    local th = max(2, floor(h * 0.55))
    c:rrect(x, floor(mid - th / 2), w, th, th / 2, mix(SNOW, tone.bg, 0.3))
    if frac <= 0 then return end
    local e = x + w * frac
    c:rrect(x, floor(mid - th / 2), max(th, floor(e - x)), th, th / 2, fill or ICE, tone.track)
    c:rect(floor(x + th / 2), floor(mid - th / 2 + th * 0.18), max(1, floor(e - x - th)), max(1, floor(th * 0.2)), ICE_L)
    -- speed lines behind, the penguin at the end
    local s = max(10, h * 2.6)
    for k = 1, 2 do
        local lx = e - s * (0.7 + k * 0.35)
        if lx > x then c:rect(floor(lx), floor(mid - h * (0.5 + k * 0.25)), max(2, floor(s * 0.25)), max(1, floor(h * 0.12)), SNOW_E) end
    end
    penguin(c, min(e, x + w - s * 0.3), mid - h * 0.45, s)
end

-- ─── the challenge: a snowflake that fills out ──────────────────────────────
-- A faint snowflake waits on the card; its six arms grow out from the middle
-- as the month's goal fills, the side branches frosting in as each arm
-- reaches them. At the goal it sparkles.

local BRANCH_AT = { 0.38, 0.62, 0.84 }  -- along an arm, where its branches grow

local function flakeArms(c, cx, cy, R, frac, col, lw)
    local reach = R * frac
    for k = 0, 5 do
        local a = k * pi / 3 - pi / 2
        local ca, sa = cos(a), sin(a)
        if reach > 0 then c:polyline({ cx, cy, cx + reach * ca, cy + reach * sa }, lw, col) end
        for j, at in ipairs(BRANCH_AT) do
            local d = R * at
            if reach >= d then
                -- branches grow as the arm passes them, longest nearest the middle
                local full = R * (0.34 - 0.08 * j)
                local len = min(full, (reach - d) * 1.4)
                local mx, my = cx + d * ca, cy + d * sa
                for side = -1, 1, 2 do
                    local b = a + side * 0.75
                    c:polyline({ mx, my, mx + len * cos(b), my + len * sin(b) }, lw * 0.8, col)
                end
            end
        end
        if frac >= 1 then c:disc(cx + R * ca, cy + R * sa, lw * 1.1, col) end
    end
end

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local lw = max(2, R * 0.075)
    local r = R * 0.92
    flakeArms(c, cx, cy, r, 1, mix(SNOW_D, tone.bg, 0.45), lw)
    if frac > 0 then
        flakeArms(c, cx, cy, r, frac, ICE_D, lw)
        -- a lighter core along each arm
        flakeArms(c, cx, cy, r * 0.999, frac, ICE, max(1, lw * 0.35))
    end
    -- the hexagon in the middle
    c:disc(cx, cy, R * 0.16, frac > 0 and ICE_D or mix(SNOW_D, tone.bg, 0.3))
    c:disc(cx, cy, R * 0.08, frac >= 1 and WHITE or ICE_L)
    if frac >= 1 then
        for k = 0, 5 do
            local a = k * pi / 3
            local sx, sy = cx + R * 1.02 * cos(a), cy + R * 1.02 * sin(a)
            c:polyline({ sx - R * 0.06, sy, sx + R * 0.06, sy }, max(1, R * 0.02), ICE_D)
            c:polyline({ sx, sy - R * 0.06, sx, sy + R * 0.06 }, max(1, R * 0.02), ICE_D)
        end
    end
    return true
end

-- ─── Reading trends: frosty tiles ───────────────────────────────────────────

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, ICE_L, 0.35) or mix(tone.bg, SNOW, 0.5)
    c:rrect(x, y, w, h, min(h * 0.18, 14), base)
    local r = max(4, min(h * 0.14, w * 0.05))
    flake(c, x + w - r * 1.4, y + r * 1.4, r, mix(ICE, base, 0.35))
    flake(c, x + w - r * 3.3, y + r * 0.9, r * 0.55, mix(ICE, base, 0.5))
    return true
end

function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local col = (dir == "up") and ICE_D or ((dir == "down") and RED or SNOW_E)
    c:disc(cx, cy, r * 1.05, mix(col, COAL, 0.3))
    c:disc(cx, cy, r * 0.92, col)
    local a = r * 0.42
    local lw = max(2, r * 0.2)
    if dir == "up" then
        c:polyline({ cx - a, cy + a * 0.45, cx, cy - a * 0.5, cx + a, cy + a * 0.45 }, lw, WHITE)
    elseif dir == "down" then
        c:polyline({ cx - a, cy - a * 0.45, cx, cy + a * 0.5, cx + a, cy - a * 0.45 }, lw, WHITE)
    else
        c:rect(floor(cx - a), floor(cy - lw / 2), floor(2 * a), max(2, floor(lw)), WHITE)
    end
    return true
end

-- ─── the calendar: frosted panes, covers under snow ─────────────────────────

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local s = min(w, h) * 0.86
    if s < 12 then return false end
    local cx, cy = x + w / 2, y + h / 2
    local fade = o.future and 0.55 or 0
    local rad = s * 0.18
    c:rrect(floor(cx - s / 2), floor(cy - s / 2), floor(s), floor(s), rad, o.today and ICE_D or mix(SNOW_E, tone.bg, 0.4 + fade * 0.5))
    local e = max(2, s * 0.06)
    c:rrect(floor(cx - s / 2 + e), floor(cy - s / 2 + e), floor(s - 2 * e), floor(s - 2 * e), rad * 0.8, mix(mix(SNOW, WHITE, 0.4), tone.bg, fade))
    -- frost in the corner
    flake(c, cx + s * 0.28, cy - s * 0.28, s * 0.1, mix(ICE, tone.bg, 0.4 + fade * 0.4))
    local size = o.num_px or max(10, floor(s * 0.36))
    c:label(tostring(n), size, cx, cy, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

-- Snow on top of a cover, icicles hanging under it.
local function snowCap(c, x, y, w, h)
    local cap = max(3, h * 0.06)
    local n = max(4, floor(w / max(6, cap * 1.6)))
    -- icicles first, the snow over their roots
    for i = 0, n - 1 do
        local t = (i + 0.5) / n
        local ix = x + w * t
        local len = h * (0.06 + 0.07 * (((i * 5) % 4) / 3))
        local iw = max(2, w / n * 0.4)
        fillRows(c, ix, y + cap * 0.6, y + cap * 0.6 + len, function(yy)
            local k = (yy - (y + cap * 0.6)) / len
            return iw / 2 * (1 - k)
        end, ICE_L)
        c:rect(floor(ix - iw * 0.25), floor(y + cap * 0.6), max(1, floor(iw * 0.18)), floor(len * 0.6), WHITE)
    end
    local x0 = x - w * 0.03
    local ww = w * 1.06
    fillRows(c, x + w / 2, y - cap * 0.9, y + cap, function(yy)
        return ww / 2
    end, WHITE)
    for i = 0, n do
        local t = i / n
        c:disc(x0 + ww * t, y - cap * 0.6 + cap * 0.3 * sin(i * 1.7), cap * (0.75 + 0.25 * ((i * 3) % 2)), WHITE)
        c:disc(x0 + ww * t + cap * 0.3, y + cap * 0.9, cap * 0.35, WHITE)
    end
    -- a soft blue line under the snow
    c:rect(floor(x), floor(y + cap), floor(w), max(1, floor(cap * 0.12)), SNOW_D)
end

function D.calendarCover(c, x, y, w, h, tone, o)
    snowCap(c, x, y, w, h)
    if o.today then flake(c, x + w * 0.5, y - max(4, w * 0.12), max(4, w * 0.14), ICE_D) end
    return true
end

function D.bookCover(c, x, y, w, h, tone, o)
    snowCap(c, x, y, w, h)
    -- a few flakes drifting down the side
    flake(c, x + w * 1.08, y + h * 0.3, max(3, w * 0.05), ICE)
    flake(c, x - w * 0.07, y + h * 0.55, max(3, w * 0.04), ICE)
    flake(c, x + w * 1.04, y + h * 0.75, max(2, w * 0.03), ICE)
    return true
end

-- ─── the Dashboard's tab bar: snow and icicles ──────────────────────────────
-- A drift of snow along the top with icicles hanging from it; the open tab
-- is a frosted pane with a snowflake.
function D.tabBar(c, x, y, w, h, cells, tone)
    local snow = tone.dark and SNOW or SNOW_D
    local sh = max(3, floor(h * 0.1))
    local top = floor(y + h * 0.02)
    c:rrect(floor(x), top, floor(w), sh, sh / 2, snow)
    local n = max(6, floor(w / (h * 0.45)))
    for k = 1, n do
        local ix = x + w * (k - 0.5) / n
        local len = h * (0.1 + 0.1 * ((k * 7) % 3) / 2)
        local half = max(1, h * 0.03)
        fillRows(c, ix, top + sh - 1, top + sh + len, function(yy) return half * (1 - (yy - top - sh) / len) end,
            tone.dark and ICE_L or ICE)
    end
    for _, cell in ipairs(cells) do
        if cell.active then
            local cx = cell.x + cell.w / 2
            local fr = h * 0.11
            local pw = min(cell.w - 6, cell.label_w + h * 0.6 + fr * 2.4)
            local ph = h * 0.5
            local px, py = floor(cx - pw / 2), floor(y + h * 0.6 - ph / 2)
            c:frame(px, py, floor(pw), floor(ph), ph * 0.25, max(1, floor(h * 0.035)), ICE, ICE_L)
            flake(c, px + ph * 0.48, py + ph / 2, fr, ICE_D)
            cell.color = NIGHT
            cell.dx = fr * 1.1
            cell.dy = h * 0.1
        end
    end
    return true
end

return D
