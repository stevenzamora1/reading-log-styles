-- Forest drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

-- wood: green sapwood (pages), honey oak (minutes), pale heartwood
local SAP, SAP_LINE = { 136, 187, 85 }, { 85, 136, 51 }
local OAK, OAK_LINE = { 204, 153, 102 }, { 153, 102, 51 }
local HEART, HEART_LINE = { 238, 221, 187 }, { 204, 170, 119 }
local BARK, BARK_DARK = { 119, 85, 51 }, { 85, 51, 34 }
local MOSS, MOSS_DARK, MOSS_LIGHT = { 102, 153, 68 }, { 68, 119, 51 }, { 170, 204, 119 }
local CAP, CAP_DARK, SPOT = { 204, 51, 34 }, { 153, 34, 17 }, { 255, 255, 238 }
local TAN, TAN_DARK = { 187, 136, 85 }, { 136, 85, 51 }
local STEM, GILL = { 238, 221, 187 }, { 221, 204, 170 }
local AUTUMN = { 221, 119, 51 }
local LADY, INK = { 221, 34, 34 }, { 34, 34, 34 }
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

-- A dome (the top half of an ellipse) standing on y = base.
local function dome(c, cx, base, a, b, col)
    fillRows(c, cx, base - b, base, function(yy)
        local k = (base - yy) / b
        return a * sqrt(max(0, 1 - k * k))
    end, col)
end

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

-- A mushroom standing on y = base, s tall: a red toadstool with white spots,
-- or a brown one.
local function mushroom(c, x, base, s, red)
    local capc, capd = red and CAP or TAN, red and CAP_DARK or TAN_DARK
    local sw, sh = max(2, s * 0.34), s * 0.6
    c:rrect(floor(x - sw / 2), floor(base - sh), max(2, floor(sw)), max(2, floor(sh)), sw * 0.4, STEM)
    local a, b = s * 0.56, s * 0.46
    local cy = base - sh + s * 0.1
    dome(c, x, cy + 0.6, a + 1, b + 1, capd)
    dome(c, x, cy, a, b, capc)
    c:rect(floor(x - a * 0.85), floor(cy - max(1, s * 0.03)), max(1, floor(a * 1.7)), max(1, floor(s * 0.07)), GILL)
    if red and s >= 9 then
        c:disc(x - a * 0.45, cy - b * 0.35, max(1, s * 0.08), SPOT)
        c:disc(x + a * 0.15, cy - b * 0.68, max(1, s * 0.07), SPOT)
        c:disc(x + a * 0.55, cy - b * 0.28, max(1, s * 0.06), SPOT)
    end
end

-- A ladybug seen from above, s across.
local function ladybug(c, x, y, s)
    c:disc(x, y - s * 0.42, s * 0.24, INK)
    c:disc(x, y, s * 0.52, INK)
    c:disc(x, y, s * 0.46, LADY)
    c:rect(floor(x - max(0.5, s * 0.03)), floor(y - s * 0.4), max(1, floor(s * 0.06)), floor(s * 0.86), INK)
    if s >= 8 then
        for _, d in ipairs({ { -0.22, -0.1 }, { 0.22, -0.1 }, { -0.2, 0.22 }, { 0.2, 0.22 } }) do
            c:disc(x + s * d[1], y + s * d[2], max(1, s * 0.08), INK)
        end
    end
end

-- An acorn, s tall, centred on (x, y).
local function acorn(c, x, y, s)
    c:disc(x, y + s * 0.12, s * 0.34, OAK_LINE)
    c:disc(x, y + s * 0.12, s * 0.3, OAK)
    c:disc(x, y + s * 0.32, s * 0.2, OAK)
    dome(c, x, y + s * 0.02, s * 0.4, s * 0.3, BARK)
    c:polyline({ x, y - s * 0.26, x + s * 0.06, y - s * 0.42 }, max(1, s * 0.08), BARK_DARK)
end

-- ─── rings: a leafy wreath (pages) and an acorn twig (time) ────────────────
-- A twig grows clockwise from the top as far as the day got: leaves along it
-- for pages, with red berries at the tip; acorns along an oak twig for time.

local BERRY = { 187, 34, 51 }

-- a wavy twig along the ring, as far as frac; returns the points' function
local function twig(c, cx, cy, rm, t, frac, col, lw)
    local a0 = -pi / 2
    local len = rm * 2 * pi * frac
    local period = max(10, t * 2.4)
    local amp = t * 0.1
    local function wave(sl) return rm + amp * sin(sl / period * 2 * pi) end
    local n = max(8, floor(len / (period / 6)))
    local pts = {}
    for i = 0, n do
        local sl = len * i / n
        local x, y = at(cx, cy, wave(sl), a0 + sl / rm)
        pts[#pts + 1] = x; pts[#pts + 1] = y
    end
    c:polyline(pts, lw, col)
    return len, wave
end

local function veinedLeaf(c, x, y, ang, len, wid, col)
    leaf(c, x, y, ang, len, wid, col)
    if len >= 12 then
        c:polyline({ x + len * 0.08 * cos(ang), y + len * 0.08 * sin(ang), x + len * 0.8 * cos(ang), y + len * 0.8 * sin(ang) },
            1, mix(col, { 0, 0, 0 }, 0.35))
    end
end

local function wreath(c, cx, cy, R, t, frac, track, tone)
    local rm = R - t / 2
    local pale = mix(track, tone.bg, 0.25)
    c:ring(cx, cy, rm + t * 0.2, t * 0.4, 0, pale, pale)
    if frac <= 0 then return end
    frac = min(frac, 1)
    if R < 22 then
        c:ring(cx, cy, R, t, frac, track, MOSS)
        local ex, ey = at(cx, cy, rm, -pi / 2 + 2 * pi * frac)
        c:disc(ex, ey, max(2, t * 0.5), BERRY)
        return
    end
    local len, wave = twig(c, cx, cy, rm, t, frac, BARK, max(1.5, t * 0.22))
    local gap = max(7, t * 0.95)
    local k, sl = 0, gap * 0.6
    while sl < len - t * 0.6 do
        local a = -pi / 2 + sl / rm
        local bx, by = at(cx, cy, wave(sl), a)
        local side = (k % 2 == 0) and 1 or -1
        -- each leaf leans forward along the twig, out and in in turn
        local d = a + pi / 2 - side * 0.75
        veinedLeaf(c, bx, by, d, t * 1.55, t * 0.62, (k % 3 == 2) and MOSS_DARK or MOSS)
        k = k + 1
        sl = sl + gap
    end
    -- berries at the tip
    local ex, ey = at(cx, cy, wave(len), -pi / 2 + len / rm)
    local br = max(2.5, t * 0.3)
    for _, o in ipairs({ { 0, 0 }, { 0.9, -0.7 }, { -0.8, -0.8 } }) do
        local bx, by = ex + o[1] * br * 1.1, ey + o[2] * br * 1.1
        c:disc(bx, by, br + 0.8, { 119, 17, 34 })
        c:disc(bx, by, br, BERRY)
        c:disc(bx - br * 0.3, by - br * 0.3, max(0.8, br * 0.25), { 238, 136, 153 })
    end
end

local function acornTwig(c, cx, cy, R, t, frac, track, tone)
    local rm = R - t / 2
    local pale = mix(track, tone.bg, 0.25)
    c:ring(cx, cy, rm + t * 0.2, t * 0.4, 0, pale, pale)
    if frac <= 0 then return end
    frac = min(frac, 1)
    if R < 22 then
        c:ring(cx, cy, R, t, frac, track, OAK)
        return
    end
    local len, wave = twig(c, cx, cy, rm, t, frac, OAK, max(1.5, t * 0.3))
    local gap = max(12, t * 2.2)
    local sl = gap * 0.7
    while sl < len - t * 0.3 do
        local ax, ay = at(cx, cy, wave(sl), -pi / 2 + sl / rm)
        acorn(c, ax, ay, max(8, t * 1.35))
        sl = sl + gap
    end
    if len - (sl - gap) > t * 0.9 then
        local ex, ey = at(cx, cy, wave(len), -pi / 2 + len / rm)
        veinedLeaf(c, ex, ey, -pi / 2 + len / rm + pi / 2 - 0.5, t * 1.2, t * 0.5, MOSS)
    end
end

-- the streak: a slim green stem with a leaf at its end
local function stem(c, cx, cy, R, t, frac, track, tone)
    local rm = R - t / 2
    local pale = mix(track, tone.bg, 0.25)
    c:ring(cx, cy, rm + t * 0.12, t * 0.24, 0, pale, pale)
    if frac <= 0 then return end
    frac = min(frac, 1)
    c:ring(cx, cy, rm + t * 0.1, t * 0.2, frac, pale, MOSS_DARK)
    if R >= 22 then
        local a = -pi / 2 + 2 * pi * frac
        local ex, ey = at(cx, cy, rm, a)
        veinedLeaf(c, ex, ey, a + pi / 2 - 0.6, t * 1.1, t * 0.45, MOSS)
    end
end

local D = {}

-- ─── the rings: a pine tree in three tiers ───────────────────────────────────
-- One tree instead of three rings: the bottom tier fills with the day's
-- pages, the middle one with the minutes, the top one with the streak; a
-- gold star on top once the streak tier is full. Reading Log draws a set of
-- rings outer first at one centre, so the first call draws the whole tree
-- empty and fills the bottom tier, and the next two fill theirs. A ring on
-- its own somewhere else is drawn the usual way.

local PINE = { { 68, 119, 51 }, { 102, 153, 68 }, { 153, 196, 102 } }
local PINE_EDGE = { 51, 85, 34 }
local STAR = { 238, 187, 51 }

-- the tiers, as (top, bottom, half width at top, at bottom) in R from the centre
local TIERS = {
    { 0.20, 0.70, 0.34, 0.84 },
    { -0.34, 0.20, 0.22, 0.62 },
    { -0.96, -0.34, 0.0, 0.40 },
}

local function tierHalf(cy, R, tr)
    local y0, y1 = cy + tr[1] * R, cy + tr[2] * R
    return y0, y1, function(yy)
        local k = (yy - y0) / (y1 - y0)
        if k < 0 or k > 1 then return 0 end
        return R * (tr[3] + (tr[4] - tr[3]) * k)
    end
end

local function tierFill(c, cx, cy, R, i, frac, col)
    if frac <= 0 then return end
    local y0, y1, half = tierHalf(cy, R, TIERS[i])
    fillRows(c, cx, y1 - (y1 - y0) * min(1, frac), y1, half, col)
end

local function pineEmpty(c, cx, cy, R, tone, trunk)
    local pale = mix(tone.bg, WHITE, 0.6)
    -- the trunk
    local tw = max(2, R * 0.2)
    c:rect(floor(cx - tw / 2), floor(cy + 0.66 * R), max(2, floor(tw)), max(2, floor(0.3 * R)), trunk or BARK)
    for i = 1, 3 do
        local y0, y1, half = tierHalf(cy, R, TIERS[i])
        local e = max(1, R * 0.035)
        fillRows(c, cx, y0 - e, y1 + e, function(yy)
            local h = half(min(y1, max(y0, yy)))
            return h + e
        end, PINE_EDGE)
        fillRows(c, cx, y0, y1, half, pale)
    end
end

local function starAt(c, x, y, r, col)
    for k = 0, 4 do
        local a = -pi / 2 + k * 2 * pi / 5
        c:polyline({ x, y, x + r * cos(a), y + r * sin(a) }, max(1, r * 0.45), col)
    end
    c:disc(x, y, r * 0.45, col)
end

local tri

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    frac = max(0, frac or 0)
    if which == 1 then
        tri = { c = c, cx = cx, cy = cy, R = R }
        pineEmpty(c, cx, cy, R, tone)
        tierFill(c, cx, cy, R, 1, frac, PINE[1])
        return true
    end
    if not (tri and tri.c == c and tri.cx == cx and tri.cy == cy) then return false end
    local i = which == 2 and 2 or 3
    tierFill(c, cx, cy, tri.R, i, frac, PINE[i])
    if i == 3 then
        if frac >= 1 then starAt(c, cx, cy - 0.98 * tri.R, max(3, tri.R * 0.13), STAR) end
        tri = nil
    end
    return true
end

-- ─── a day: a small pine ─────────────────────────────────────────────────────
-- It fills from the bottom with the day's pages; its trunk turns honey oak
-- once the day's minutes are read. Days to come are a pale outline.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    local R = d * 0.5
    if o.future then
        local pale = mix(MOSS_LIGHT, tone.bg, 0.75)
        for i = 1, 3 do
            local y0, y1, half = tierHalf(cy, R, TIERS[i])
            fillRows(c, cx, y0, y1, half, pale)
        end
        return true
    end
    pineEmpty(c, cx, cy, R, tone, (fm or 0) >= 1 and OAK or mix(BARK, tone.bg, 0.45))
    local f = min(1, fp or 0)
    if f > 0 then
        -- one fill across the whole tree, tier by tier
        local top, bottom = cy + TIERS[3][1] * R, cy + TIERS[1][2] * R
        local level = bottom - (bottom - top) * f
        for i = 1, 3 do
            local y0, y1, half = tierHalf(cy, R, TIERS[i])
            if level < y1 then fillRows(c, cx, max(y0, level), y1, half, PINE[i]) end
        end
    end
    return true
end

-- ─── the year goal: a woodpile ──────────────────────────────────────────────
-- A log for every book (as many as fit; past 30 each stands for several),
-- stacked like bricks. A log shows its cut end, rings and all, once the book
-- is read; the bottom rows fill first.

local function logEnd(c, x, y, r, lit, tone)
    if lit then
        c:disc(x, y, r, BARK_DARK)
        c:disc(x, y, r * 0.86, BARK)
        c:disc(x, y, r * 0.74, OAK)
        c:disc(x, y, r * 0.58, OAK_LINE)
        c:disc(x, y, r * 0.52, HEART)
        c:disc(x, y, r * 0.34, OAK_LINE)
        c:disc(x, y, r * 0.29, HEART)
        c:disc(x, y, max(1, r * 0.1), OAK_LINE)
    else
        local track = tone and tone.track or GILL
        c:disc(x, y, r, mix(track, BARK, 0.25))
        c:disc(x, y, r * 0.8, track)
    end
end

function D.goal(c, x, y, w, h, done, target, tone)
    local n = (target and target > 0) and min(target, 30) or 12
    local per = (target and target > 0) and target / n or 1
    local lit = (target and target > 0) and floor(min(done, target) / per + 1e-6) or 0
    -- choose the widest row that gives the biggest logs
    local best_r, best_k = 0, 1
    for k = 1, n do
        local rows = math.ceil(n / (k - 0.5 + (k == 1 and 0.5 or 0)))
        local r = min(w * 0.96 / (2 * k), h * 0.94 / (2 + (rows - 1) * 1.74))
        if r > best_r then best_r, best_k = r, k end
    end
    local r, k = best_r, best_k
    -- rows of k and k-1 in turn, from the bottom
    local slots, left, row = {}, n, 0
    while left > 0 do
        local m = (row % 2 == 0 or k == 1) and k or k - 1
        m = min(m, left)
        local full = (row % 2 == 0 or k == 1) and k or k - 1
        local yy = y + h - r * 1.03 - row * r * 1.74
        local x0 = x + w / 2 - (full - 1) * r
        for i = 1, m do slots[#slots + 1] = { x0 + (i - 1) * 2 * r, yy } end
        left = left - m
        row = row + 1
    end
    -- the ground under the pile
    local gw = k * 2 * r + r
    c:rect(floor(x + w / 2 - gw / 2), floor(y + h - max(2, r * 0.12)), floor(gw), max(2, floor(r * 0.12)), MOSS_DARK)
    for i, sl in ipairs(slots) do logEnd(c, sl[1], sl[2], r * 0.97, i <= lit, tone) end
    if target and target > 0 and done >= target then
        local topy = slots[#slots][2] - r * 0.9
        ladybug(c, slots[#slots][1], topy, max(6, r * 0.9))
    end
    return true
end

-- ─── bars: trees ─────────────────────────────────────────────────────────────
-- Each bar a tree, its crown at the top of the bar; the current one in autumn.

function D.chartBar(c, x, y, w, h, tone, fill, o)
    if w < 4 or h < 4 then return false end
    local cx = x + w / 2
    local col = o.current and AUTUMN or (((o.i or 1) % 2 == 0) and MOSS or MOSS_DARK)
    local dark = mix(col, { 0, 0, 0 }, 0.28)
    local r = w * 0.5
    if h < w * 1.3 then
        dome(c, cx, y + h, r + 1, h + 1, dark)
        dome(c, cx, y + h, r, h, col)
        return true
    end
    local tw = max(2, w * 0.24)
    c:rect(floor(cx - tw / 2), floor(y + r), floor(tw), floor(h - r), BARK)
    c:disc(cx, y + r, r + 1, dark)
    c:disc(cx, y + r, r, col)
    if h > w * 2.2 then
        c:disc(cx - r * 0.42, y + r * 1.7, r * 0.62 + 1, dark)
        c:disc(cx + r * 0.42, y + r * 1.7, r * 0.62 + 1, dark)
        c:disc(cx - r * 0.42, y + r * 1.7, r * 0.62, col)
        c:disc(cx + r * 0.42, y + r * 1.7, r * 0.62, col)
        c:disc(cx, y + r * 1.15, r * 0.7, col)
    end
    c:disc(cx - r * 0.35, y + r * 0.6, max(1, r * 0.2), mix(col, WHITE, 0.35))
    return true
end

-- ─── lines: a leafy vine (books), a line of acorns (pages) ──────────────────

function D.line(c, pts, xs, ys, n, lw, fill, tone, o)
    local s = max(4, lw * 2.2)
    if o.series == 2 then
        c:polyline(pts, max(1.5, lw * 0.7), mix(OAK_LINE, tone.bg, 0.15))
        for i = 1, n do acorn(c, xs[i], ys[i] - s * 0.5, s * 1.5) end
    else
        c:polyline(pts, max(1.5, lw * 0.8), MOSS_DARK)
        for i = 1, n do
            leaf(c, xs[i], ys[i], -pi / 2 - 0.65, s * 1.7, s * 0.85, MOSS)
            leaf(c, xs[i], ys[i], -pi / 2 + 0.65, s * 1.7, s * 0.85, MOSS)
        end
    end
    return true
end

-- ─── Today's timeline: a mossy strip, a mushroom over each sitting ───────────

function D.timeline(c, x, y, w, h, spans, now, tone)
    local top = floor(h * 0.55)
    local ty, th = y + top, max(4, h - top)
    c:rrect(x, ty, w, th, th / 2, tone.track)
    local ms = max(10, h * 0.9)
    local last = -1e9
    for k, sp in ipairs(spans) do
        local x1, x2 = x + w * sp[1], x + w * sp[2]
        local bw = max(th, x2 - x1)
        local bx = min(x1, x + w - bw)
        c:rrect(floor(bx), ty, floor(bw), th, th / 2, sp[3] or MOSS, tone.track)
        local mx = bx + bw / 2
        if mx - last >= ms * 0.9 then
            mushroom(c, mx, ty + 1, ms, k % 2 == 1)
            last = mx
        end
    end
    if now then
        local nx = x + w * now
        local s = max(6, h * 0.38)
        c:rect(floor(nx - max(1, th * 0.12)), floor(y + s * 0.6), max(2, floor(th * 0.24)), floor(ty + th + 3 - (y + s * 0.6)), BARK)
        ladybug(c, nx, y + s * 0.3, s)
    end
    return true
end

-- ─── Reading trends: wooden signs ────────────────────────────────────────────

local PLANK, PLANK2, PLANK_EDGE, GRAIN = { 226, 197, 149 }, { 216, 186, 138 }, { 160, 122, 72 }, { 204, 168, 116 }

function D.trendTile(c, x, y, w, h, tone, i)
    local plank = (i % 2 == 1) and PLANK or PLANK2
    c:frame(x, y, w, h, min(h * 0.08, 7), max(2, floor(min(w, h) * 0.025)), PLANK_EDGE, plank)
    -- the grain, faint, in waves across the board
    local lines = max(2, floor(h / 18))
    for k = 1, lines do
        local yy = y + h * k / (lines + 1)
        local pts = {}
        local ph = k * 1.7 + i
        for j = 0, 12 do
            local f = j / 12
            pts[#pts + 1] = x + w * (0.03 + 0.94 * f)
            pts[#pts + 1] = yy + sin(f * pi * 2.2 + ph) * h * 0.035
        end
        c:polyline(pts, max(1.6, h * 0.02), GRAIN)
    end
    -- a nail in each corner
    local nr = max(1.5, min(w, h) * 0.03)
    local m = nr * 3
    for _, p in ipairs({ { x + m, y + m }, { x + w - m, y + m }, { x + m, y + h - m }, { x + w - m, y + h - m } }) do
        c:disc(p[1], p[2], nr, { 136, 136, 119 })
        c:disc(p[1] - nr * 0.3, p[2] - nr * 0.3, max(0.6, nr * 0.35), { 204, 204, 187 })
    end
    return true
end

-- the mark: a signpost, its board pointing up or down, or a flat board
function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local hw = r * 0.82
    if dir ~= "up" and dir ~= "down" then
        c:rect(floor(cx - r * 0.1), floor(cy + r * 0.4), max(2, floor(r * 0.2)), floor(r * 0.7), BARK)
        c:rrect(floor(cx - hw - 1), floor(cy - r * 0.45 - 1), floor(2 * hw + 2), floor(r * 0.9 + 2), r * 0.1, OAK)
        c:rrect(floor(cx - hw), floor(cy - r * 0.45), floor(2 * hw), floor(r * 0.9), r * 0.1, OAK_LINE)
        c:rect(floor(cx - r * 0.42), floor(cy - r * 0.1), floor(r * 0.84), max(2, floor(r * 0.2)), WHITE)
        return true
    end
    local up = dir == "up"
    local s = up and 1 or -1
    local tip, base = cy - s * r * 1.0, cy + s * r * 0.5
    local shoulder = cy - s * r * 0.15
    local function half(yy)
        local d = (yy - tip) * s           -- distance from the tip, towards the base
        local tri = (shoulder - tip) * s
        if d < 0 or d > (base - tip) * s then return 0 end
        if d < tri then return hw * d / tri end
        return hw
    end
    -- the post
    c:rect(floor(cx - r * 0.11), floor(min(base, base + s * r * 0.55)), max(2, floor(r * 0.22)), floor(r * 0.55), BARK)
    local y0, y1 = min(tip, base), max(tip, base)
    fillRows(c, cx, y0 - 1.2, y1 + 1.2, function(yy) local hh = half(min(max(yy, y0), y1)); return hh > 0 and hh + 1.2 or 0 end, OAK)
    fillRows(c, cx, y0, y1, half, up and OAK_LINE or { 196, 122, 74 })
    -- a small white chevron, for greyscale screens
    local a, lw = r * 0.32, max(1.5, r * 0.14)
    local my = cy + s * r * 0.05
    c:polyline({ cx - a, my + s * a * 0.5, cx, my - s * a * 0.4, cx + a, my + s * a * 0.5 }, lw, WHITE)
    return true
end

-- ─── the calendar: wood slices ───────────────────────────────────────────────
-- A day without reading is a slice of log with its number; a day you read
-- gets a toadstool by its cover; today has a moss ring, or a ladybug on its
-- cover.

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local m = max(2, floor(min(w, h) * 0.06))
    local r = (min(w, h) - 2 * m) / 2
    if r < 6 then return false end
    local cx, cy = x + w / 2, y + h / 2
    local fade = o.future and 0.55 or 0
    local bark = mix(BARK, tone.bg, fade)
    local wood = mix(HEART, tone.bg, fade)
    local line = mix(HEART_LINE, tone.bg, fade)
    if o.today then c:ring(cx, cy, r + max(2, r * 0.12), max(2, r * 0.12), 1, MOSS, MOSS) end
    c:disc(cx, cy, r, bark)
    c:disc(cx, cy, r * 0.88, wood)
    local lw = max(1, r * 0.03)
    for _, f in ipairs({ 0.72, 0.52, 0.32 }) do
        c:ring(cx + r * 0.03, cy - r * 0.02, r * f, lw, 1, line, line)
    end
    local size = o.num_px or max(10, floor(r * 0.8))
    c:label(tostring(n), size, cx, cy, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

function D.calendarCover(c, x, y, w, h, tone, o)
    local s = max(8, min(w, h) * 0.3)
    mushroom(c, x + w - s * 0.2, y + h + s * 0.08, s, true)
    if o.today then ladybug(c, x + w * 0.5, y + max(3, s * 0.15), max(7, s * 0.6)) end
    return true
end

-- ─── the challenge: an acorn grows into an oak ───────────────────────────────
-- An acorn, a sprout, a sapling, then a young oak that fills out until the
-- month's goal is met, when acorns hang from it. The four stages along the
-- bottom, the one it's at underlined.

local function oak(c, cx, ground, R, g, tone)
    if g < 0.12 then
        acorn(c, cx, ground - R * 0.16, R * (0.24 + g))
        return
    end
    if g < 0.32 then
        -- a sprout: a stem and two leaves
        local hgt = R * (0.25 + 0.6 * (g - 0.12) / 0.2)
        c:polyline({ cx, ground, cx, ground - hgt }, max(1.5, R * 0.03), MOSS_DARK)
        local L = R * (0.18 + 0.12 * (g - 0.12) / 0.2)
        veinedLeaf(c, cx, ground - hgt, -pi / 2 - 0.9, L, L * 0.45, MOSS)
        veinedLeaf(c, cx, ground - hgt, -pi / 2 + 0.9, L, L * 0.45, MOSS)
        return
    end
    -- a tree: the trunk tapers up; the crown grows with g
    local k = (g - 0.32) / 0.68                       -- 0 (sapling) to 1 (full)
    local trunk_h = R * (0.45 + 0.4 * k)
    local tw = R * (0.04 + 0.08 * k)
    fillRows(c, cx, ground - trunk_h, ground, function(yy)
        local f = (ground - yy) / trunk_h
        return tw * (1 - 0.45 * f)
    end, BARK)
    local top = ground - trunk_h
    if k > 0.3 then
        c:polyline({ cx, top + trunk_h * 0.3, cx - R * 0.28 * k, top - R * 0.05 }, max(1.5, tw * 0.6), BARK)
        c:polyline({ cx, top + trunk_h * 0.2, cx + R * 0.26 * k, top - R * 0.1 }, max(1.5, tw * 0.6), BARK)
    end
    local cr = R * (0.18 + 0.2 * k)
    local blobs = { { 0, -0.75, 1.0, MOSS } }
    if k > 0.25 then
        blobs = { { -0.75, -0.25, 0.75, MOSS_DARK }, { 0.75, -0.3, 0.75, MOSS }, { 0, -0.75, 1.0, MOSS },
                  { -0.35, -1.2, 0.65, { 119, 170, 85 } }, { 0.4, -1.1, 0.7, MOSS_DARK } }
    end
    for _, b in ipairs(blobs) do
        c:disc(cx + b[1] * cr, top + b[2] * cr, b[3] * cr + 1, mix(b[4], { 0, 0, 0 }, 0.3))
    end
    for _, b in ipairs(blobs) do
        c:disc(cx + b[1] * cr, top + b[2] * cr, b[3] * cr, b[4])
    end
    if g >= 1 then
        for _, a in ipairs({ { -0.6, -0.35 }, { 0.55, -0.55 }, { -0.1, -0.2 } }) do
            acorn(c, cx + a[1] * cr, top + a[2] * cr, max(6, R * 0.12))
        end
    end
end

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local ground = cy + R * 0.5
    -- the mound
    local mw, mh = R * 0.95, R * 0.14
    fillRows(c, cx, ground - mh, ground + mh * 0.6, function(yy)
        local k = (yy - (ground - mh)) / (mh * 1.6)
        return mw * sqrt(max(0, 1 - (1 - k) * (1 - k))) * (k <= 1 and 1 or 0)
    end, MOSS_LIGHT)
    oak(c, cx, ground, R, frac, tone)
    -- the stages
    local s = R * 0.22
    local sy = cy + R * 0.98
    local stage = (frac < 0.12 and 1) or (frac < 0.32 and 2) or (frac < 1 and 3) or 4
    local gs = { 0.05, 0.22, 0.5, 1 }
    for i = 1, 4 do
        local sx = cx + (i - 2.5) * s * 1.6
        oak(c, sx, sy, s * 1.1, gs[i], tone)
        if i == stage then c:rrect(floor(sx - s * 0.5), floor(sy + s * 0.12), floor(s), max(2, floor(s * 0.1)), s * 0.05, OAK) end
    end
end

-- ─── progress bars: a snail on a mossy branch ────────────────────────────────

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local mid = y + h / 2
    local th = max(2, floor(h * 0.5))
    c:rrect(x, floor(mid - th / 2), w, th, th / 2, tone.track)
    if frac <= 0 then return end
    local e = x + w * frac
    local sh = max(3, floor(h * 0.75))
    c:rrect(x, floor(mid - sh / 2), max(sh, floor(e - x)), sh, sh / 2, BARK, tone.track)
    c:rrect(x, floor(mid - sh / 2), max(sh, floor(e - x)), max(1, floor(sh * 0.45)), sh / 4, MOSS, BARK)
    -- little leaves along the branch
    local gap = max(12, h * 3)
    local k = 0
    local lx = x + gap * 0.7
    while lx < e - h * 2.5 do
        local up = (k % 2 == 0)
        leaf(c, lx, up and (mid - sh * 0.4) or (mid + sh * 0.4), up and (-pi / 2 + 0.6) or (pi / 2 - 0.6), h * 1.2, h * 0.6, MOSS)
        k = k + 1
        lx = lx + gap
    end
    -- the snail, its shell on the branch, its head to the right
    local r = max(4, h * 1.05)
    local bx = min(e, x + w)
    c:rrect(floor(bx - r * 1.3), floor(mid - sh * 0.5 - r * 0.15), floor(r * 2.1), max(2, floor(r * 0.5)), r * 0.25, { 204, 187, 153 })
    c:polyline({ bx + r * 0.55, mid - sh * 0.5, bx + r * 0.75, mid - sh * 0.5 - r * 0.85 }, max(1, r * 0.12), { 153, 136, 102 })
    c:disc(bx + r * 0.75, mid - sh * 0.5 - r * 0.85, max(1, r * 0.13), INK)
    local scx, scy = bx - r * 0.45, mid - sh * 0.5 - r * 0.7
    c:disc(scx, scy, r + 1, OAK_LINE)
    c:disc(scx, scy, r, OAK)
    c:ring(scx + r * 0.1, scy + r * 0.05, r * 0.62, max(1, r * 0.14), 1, OAK_LINE, OAK_LINE)
    c:disc(scx + r * 0.18, scy + r * 0.1, max(1, r * 0.2), OAK_LINE)
end

return D
