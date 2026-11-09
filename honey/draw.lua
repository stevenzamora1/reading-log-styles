-- Honey drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

local HONEY, HONEY_D, HONEY_L = { 232, 160, 32 }, { 176, 108, 12 }, { 250, 206, 96 }
local AMBER = { 214, 130, 20 }
local STRAW, STRAW_D, STRAW_L = { 222, 186, 112 }, { 166, 124, 52 }, { 240, 214, 160 }
local LAV, LAV_D = { 160, 128, 214 }, { 112, 84, 168 }
local WAX, WAX_E = { 255, 242, 206 }, { 214, 170, 90 }
local BLACK, WHITE, DOOR = { 40, 28, 12 }, { 255, 255, 255 }, { 90, 56, 20 }

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

-- A bee facing right, its body s long.
local function bee(c, x, y, s)
    local r = s * 0.32
    c:disc(x - r * 0.4, y - r * 1.05, r * 0.75, mix(WHITE, LAV, 0.15))
    c:disc(x + r * 0.35, y - r * 1.0, r * 0.65, mix(WHITE, LAV, 0.15))
    for i = -2, 2 do
        local px = x + i * r * 0.42
        local rr = r * (1 - abs(i) * 0.16)
        c:disc(px, y, rr, (i % 2 == 0) and HONEY_L or BLACK)
    end
    c:disc(x + r * 1.15, y - r * 0.1, r * 0.5, BLACK)
    c:polyline({ x - r * 1.2, y, x - r * 1.65, y + r * 0.15 }, max(1, r * 0.25), BLACK)
end

-- A pointy-topped hexagon of radius r round (cx, cy).
local function hex(c, cx, cy, r, col)
    local w = r * 0.866
    fillRows(c, cx, cy - r, cy + r, function(yy)
        local dy = abs(yy - cy)
        if dy <= r / 2 then return w end
        return w * (r - dy) / (r / 2)
    end, col)
end

local D = {}

-- ─── the rings: a straw beehive in three bands ──────────────────────────────
-- One skep instead of three rings: the bottom band fills with honey for the
-- day's pages, the middle band with lavender for the minutes, the top with
-- honey for the streak; a bee comes out once the streak band is full.
-- Reading Log draws a set of rings outer first at one centre, so the first
-- call draws the whole hive empty and fills the bottom band, and the next two
-- fill theirs. A ring on its own somewhere else is drawn the usual way.

-- the bands, as (top, bottom, half width at the top, at the bottom) in R from
-- the centre; the top band is a dome
local BANDS = {
    { 0.28, 0.84, 0.70, 0.80 },
    { -0.26, 0.28, 0.54, 0.70 },
    { -0.86, -0.26, 0.0, 0.54 },
}

local function bandHalf(cy, R, i)
    local b = BANDS[i]
    local y0, y1 = cy + b[1] * R, cy + b[2] * R
    return y0, y1, function(yy)
        local k = (yy - y0) / (y1 - y0)
        if k < 0 or k > 1 then return 0 end
        if i == 3 then return R * b[4] * sqrt(max(0, 1 - (1 - k) * (1 - k))) end
        return R * (b[3] + (b[4] - b[3]) * k)
    end
end

local function bandFill(c, cx, cy, R, i, frac, col)
    if frac <= 0 then return end
    local y0, y1, half = bandHalf(cy, R, i)
    fillRows(c, cx, y1 - (y1 - y0) * min(1, frac), y1, half, col)
end

-- the straw coils' lines and the door, over whatever fills the hive
local function coils(c, cx, cy, R)
    local lw = max(1, R * 0.03)
    for _, v in ipairs({ -0.62, -0.42, -0.26, -0.08, 0.10, 0.28, 0.46, 0.64 }) do
        local y = cy + v * R
        local hw
        if v <= -0.26 then
            local k = (v + 0.86) / 0.60
            hw = R * 0.54 * sqrt(max(0, 1 - (1 - k) * (1 - k)))
        elseif v <= 0.28 then hw = R * (0.54 + 0.16 * (v + 0.26) / 0.54)
        else hw = R * (0.70 + 0.10 * (v - 0.28) / 0.56) end
        c:rect(floor(cx - hw * 0.94), floor(y), max(1, floor(2 * hw * 0.94)), max(1, floor(lw)), STRAW_D)
    end
    -- the door
    local dr = R * 0.15
    fillRows(c, cx, cy + 0.84 * R - dr * 1.4, cy + 0.84 * R, function(yy)
        local k = (cy + 0.84 * R - yy) / (dr * 1.4)
        return dr * sqrt(max(0, 1 - k * k))
    end, DOOR)
end

local function hiveEmpty(c, cx, cy, R, tone, stand)
    local pale = mix(STRAW_L, tone.bg, 0.35)
    local e = max(1, R * 0.035)
    -- the stand
    if stand ~= false then
        c:rect(floor(cx - 0.9 * R), floor(cy + 0.84 * R), max(2, floor(1.8 * R)), max(2, floor(0.1 * R)), STRAW_D)
    end
    for i = 1, 3 do
        local y0, y1, half = bandHalf(cy, R, i)
        fillRows(c, cx, y0 - e, y1 + e, function(yy) return half(min(y1, max(y0, yy))) + e end, STRAW_D)
        fillRows(c, cx, y0, y1, half, pale)
    end
end

local FILLS = { HONEY, LAV, AMBER }

local tri

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    frac = max(0, frac or 0)
    if which == 1 then
        tri = { c = c, cx = cx, cy = cy, R = R }
        hiveEmpty(c, cx, cy, R, tone)
        bandFill(c, cx, cy, R, 1, frac, fill or FILLS[1])
        return true
    end
    if not (tri and tri.c == c and tri.cx == cx and tri.cy == cy) then return false end
    local r = tri.R
    if which == 2 then
        bandFill(c, cx, cy, r, 2, frac, fill or FILLS[2])
    else
        bandFill(c, cx, cy, r, 3, frac, FILLS[3])
        coils(c, cx, cy, r)
        if frac >= 1 then bee(c, cx + 0.62 * r, cy - 0.70 * r, max(6, r * 0.42)) end
        tri = nil
    end
    return true
end

-- ─── a day: a little hive ────────────────────────────────────────────────────
-- It fills with honey from the bottom as the day's pages add up; a bee
-- visits once the day's pages and minutes are both done. Days to come are a
-- pale outline.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    local R = d * 0.5
    if o.future then
        local pale = mix(STRAW_L, tone.bg, 0.6)
        for i = 1, 3 do
            local y0, y1, half = bandHalf(cy, R, i)
            fillRows(c, cx, y0, y1, half, pale)
        end
        return true
    end
    hiveEmpty(c, cx, cy, R, tone, false)
    local f = min(1, fp or 0)
    if f > 0 then
        local top, bottom = cy + BANDS[3][1] * R, cy + BANDS[1][2] * R
        local level = bottom - (bottom - top) * f
        for i = 1, 3 do
            local y0, y1, half = bandHalf(cy, R, i)
            if level < y1 then fillRows(c, cx, max(y0, level), y1, half, HONEY) end
        end
    end
    coils(c, cx, cy, R)
    if (fp or 0) >= 1 and (fm or 0) >= 1 then bee(c, cx + 0.6 * R, cy - 0.66 * R, max(5, R * 0.5)) end
    if o.today then
        c:rect(floor(cx - 0.6 * R), floor(cy + 0.92 * R), max(2, floor(1.2 * R)), max(2, floor(0.08 * R)), LAV_D)
    end
    return true
end

-- ─── the year goal: a honeycomb ──────────────────────────────────────────────
-- A cell for every book (as many as fit; past 40 each stands for several),
-- filled with honey once the book is read, from the bottom row up. A bee
-- sits on the comb once the goal is reached.

function D.goal(c, x, y, w, h, done, target, tone)
    local n = (target and target > 0) and min(target, 40) or 12
    local per = (target and target > 0) and target / n or 1
    local lit = (target and target > 0) and floor(min(done or 0, target) / per + 1e-6) or 0
    -- the cell size: the largest that fits n cells in rows of offset hexagons
    local best
    for cols = 1, n do
        local rows = math.ceil(n / cols)
        local r = min(w / ((cols + 0.5) * 1.732), h / (rows * 1.5 + 0.5))
        if not best or r > best.r then best = { r = r, cols = cols, rows = rows } end
    end
    local r, cols, rows = best.r * 0.98, best.cols, best.rows
    local gw, gh = (cols + 0.5) * 1.732 * r, rows * 1.5 * r + 0.5 * r
    local ox, oy = x + (w - gw) / 2, y + (h - gh) / 2
    local k = 0
    for row = rows - 1, 0, -1 do
        for col = 0, cols - 1 do
            k = k + 1
            if k > n then break end
            local cx = ox + 0.866 * r + col * 1.732 * r + ((row % 2 == 1) and 0.866 * r or 0)
            local cy = oy + r + row * 1.5 * r
            hex(c, cx, cy, r, WAX_E)
            hex(c, cx, cy, r * 0.86, k <= lit and HONEY or mix(WAX, tone.bg, 0.3))
            if k <= lit and r >= 8 then c:disc(cx - r * 0.25, cy - r * 0.25, max(1, r * 0.12), HONEY_L) end
        end
    end
    if target and target > 0 and (done or 0) >= target then bee(c, x + w * 0.82, y + h * 0.12, max(8, min(w, h) * 0.14)) end
    return true
end

-- ─── a bar: a honey drip with a bee at its end ───────────────────────────────

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local mid = y + h / 2
    local th = max(2, floor(h * 0.5))
    c:rrect(x, floor(mid - th / 2), w, th, th / 2, tone.track)
    if frac <= 0 then return end
    local e = x + w * frac
    local sh = max(3, floor(h * 0.7))
    c:rrect(x, floor(mid - sh / 2), max(sh, floor(e - x)), sh, sh / 2, HONEY, tone.track)
    c:rrect(x + sh / 3, floor(mid - sh / 2 + sh * 0.15), max(1, floor(e - x - sh * 0.7)), max(1, floor(sh * 0.22)), sh / 6, HONEY_L, HONEY)
    -- drips hanging from the honey
    local gap = max(14, h * 4)
    local dx = x + gap * 0.6
    local i = 0
    while dx < e - sh do
        local len = sh * (0.5 + 0.35 * ((i * 7) % 3) / 2)
        c:rect(floor(dx), floor(mid + sh / 2 - 1), max(1, floor(sh * 0.3)), floor(len), HONEY)
        c:disc(dx + sh * 0.15, mid + sh / 2 + len, max(1, sh * 0.22), HONEY)
        dx = dx + gap
        i = i + 1
    end
    bee(c, min(e, x + w) + h * 0.2, mid - h * 0.3, max(6, h * 1.5))
end

-- ─── the challenge: a honey jar filling ─────────────────────────────────────

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local top, bottom = cy - 0.62 * R, cy + 0.86 * R
    local function body(yy)
        local k = (yy - top) / (bottom - top)
        if k < 0 or k > 1 then return 0 end
        local base = 0.62 * R
        if k < 0.08 then return base * (0.78 + k * 2.5) end
        if k > 0.9 then return base * (1 - (k - 0.9) * 1.5) end
        return base
    end
    local e = max(2, R * 0.04)
    fillRows(c, cx, top - e, bottom + e, function(yy) return body(min(bottom, max(top, yy))) + e end, WAX_E)
    fillRows(c, cx, top, bottom, body, mix(WAX, tone.bg, 0.2))
    if frac > 0 then fillRows(c, cx, bottom - (bottom - top) * 0.92 * frac, bottom, body, HONEY) end
    -- the lid and its cloth
    c:rrect(floor(cx - 0.56 * R), floor(top - 0.18 * R), floor(1.12 * R), floor(0.16 * R), R * 0.04, LAV_D)
    c:rrect(floor(cx - 0.66 * R), floor(top - 0.30 * R), floor(1.32 * R), floor(0.14 * R), R * 0.06, LAV)
    -- a label
    c:rrect(floor(cx - 0.36 * R), floor(cy + 0.05 * R), floor(0.72 * R), floor(0.36 * R), R * 0.06, WAX)
    hex(c, cx, cy + 0.23 * R, R * 0.12, HONEY_D)
    if frac >= 1 then bee(c, cx + 0.72 * R, top - 0.42 * R, max(8, R * 0.32)) end
end

-- ─── Reading trends: honeycomb tiles ─────────────────────────────────────────
-- A warm tile with a corner of honeycomb (its cells filled in turn) and honey
-- dripping from the top edge.

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, HONEY_L, 0.22) or mix(tone.bg, LAV, 0.14)
    c:rrect(x, y, w, h, min(h * 0.18, 14), base)
    -- three cells of honeycomb in the top right corner, clear of the text
    local r = max(4, min(h * 0.15, w * 0.05))
    local cx0, cy0 = x + w - r * 1.1, y + r * 1.15
    for k, cpos in ipairs({ { 0, 0 }, { -1.732, 0 }, { -0.866, 1.5 } }) do
        local hx, hy = cx0 + cpos[1] * r, cy0 + cpos[2] * r
        hex(c, hx, hy, r, mix(WAX_E, base, 0.4))
        hex(c, hx, hy, r * 0.8, (k + i) % 3 == 0 and mix(WAX, base, 0.4) or mix(HONEY, base, 0.35))
    end
    return true
end

function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local col = (dir == "up") and HONEY or ((dir == "down") and LAV or STRAW)
    hex(c, cx, cy, r * 1.08, mix(col, BLACK, 0.3))
    hex(c, cx, cy, r * 0.94, col)
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

-- ─── the calendar: a comb of cells ───────────────────────────────────────────
-- A day with no book is a wax cell with its number; today's has a lavender
-- rim; days to come are paler. A day with a book keeps its cover, with honey
-- dripping over its top edge (and a bee on today's).

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local r = min(w / 1.8, h / 2.05)
    if r < 7 then return false end
    local cx, cy = x + w / 2, y + h / 2
    local fade = o.future and 0.55 or 0
    hex(c, cx, cy, r, o.today and LAV_D or mix(WAX_E, tone.bg, fade))
    hex(c, cx, cy, r * 0.86, mix(mix(WAX, HONEY_L, 0.25), tone.bg, fade))
    local size = o.num_px or max(10, floor(r * 0.7))
    c:label(tostring(n), size, cx, cy, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

function D.calendarCover(c, x, y, w, h, tone, o)
    local t = max(2, floor(h * 0.05))
    c:rect(floor(x), floor(y), floor(w), t, HONEY)
    for k = 0, 2 do
        local dx = x + w * (0.18 + 0.3 * k)
        local len = h * (0.1 + 0.06 * ((k * 2) % 3))
        c:rect(floor(dx), floor(y), max(2, floor(w * 0.07)), floor(len), HONEY)
        c:disc(dx + w * 0.035, y + len, max(1.5, w * 0.055), HONEY)
    end
    if o.today then bee(c, x + w * 0.78, y - h * 0.06, max(6, w * 0.32)) end
    return true
end

return D
