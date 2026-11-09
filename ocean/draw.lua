-- Ocean drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

local SEA, SEA_D, SEA_L = { 27, 138, 160 }, { 15, 99, 120 }, { 127, 208, 220 }
local CORAL, CORAL_D, CORAL_L = { 232, 111, 94 }, { 184, 74, 60 }, { 246, 190, 180 }
local SAND, SAND_D = { 232, 214, 168 }, { 201, 176, 122 }
local GOLD, GOLD_D = { 230, 180, 34 }, { 160, 122, 18 }
local PEARL, PEARL_E = { 246, 242, 234 }, { 201, 194, 176 }
local WOOD, WOOD_D = { 168, 112, 60 }, { 106, 68, 32 }
local PALM = { 74, 163, 106 }
local INK, WHITE = { 22, 56, 68 }, { 255, 255, 255 }

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

-- An ellipse (a across, b down from the middle), filled.
local function oval(c, cx, cy, a, b, col)
    fillRows(c, cx, cy - b, cy + b, function(yy)
        local k = (yy - cy) / b
        return a * sqrt(max(0, 1 - k * k))
    end, col)
end

-- A dome (the top half of an ellipse) standing on y = base.
local function dome(c, cx, base, a, b, col)
    fillRows(c, cx, base - b, base, function(yy)
        local k = (base - yy) / b
        return a * sqrt(max(0, 1 - k * k))
    end, col)
end

-- A five-armed star: a disc and five thick strokes.
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

local function bubble(c, x, y, r, col, bg)
    c:ring(x, y, r, max(1, r * 0.25), 1, col, col)
    c:disc(x - r * 0.3, y - r * 0.3, max(0.8, r * 0.22), WHITE)
end

-- A little fish facing right, l long.
local function fish(c, x, y, l, col, dark)
    local a, b = l * 0.42, l * 0.26
    local tx = x - a * 0.85
    local lw = max(1.5, b * 0.55)
    c:polyline({ tx, y, tx - a * 0.55, y - b * 0.85 }, lw, dark)
    c:polyline({ tx, y, tx - a * 0.55, y + b * 0.85 }, lw, dark)
    oval(c, x, y, a + 1, b + 1, dark)
    oval(c, x, y, a, b, col)
    c:disc(x + a * 0.5, y - b * 0.15, max(1, b * 0.22), INK)
    c:disc(x - a * 0.1, y - b * 0.35, max(0.8, b * 0.18), mix(col, WHITE, 0.5))
end

local function shell(c, x, y, s, col, dark)
    dome(c, x, y + s * 0.3, s * 0.55 + 1, s * 0.6 + 1, dark)
    dome(c, x, y + s * 0.3, s * 0.55, s * 0.6, col)
    for k = -2, 2 do
        local a = -pi / 2 + k * 0.42
        c:polyline({ x, y + s * 0.3, x + s * 0.5 * cos(a), y + s * 0.3 + s * 0.55 * sin(a) }, max(1, s * 0.06), dark)
    end
    c:rect(floor(x - s * 0.15), floor(y + s * 0.26), max(2, floor(s * 0.3)), max(1, floor(s * 0.12)), dark)
end

-- ─── rings: waves rolling round (sea for pages, coral for time) ──────────────

local function waves(c, cx, cy, R, t, frac, track, col, dark, tone)
    local rm = R - t / 2
    local pale = mix(track, tone.bg, 0.2)
    c:ring(cx, cy, rm + t * 0.3, t * 0.6, 0, pale, pale)
    if frac <= 0 then return end
    frac = min(frac, 1)
    if R < 22 then
        c:ring(cx, cy, R, t, frac, track, col)
        return
    end
    local len = rm * 2 * pi * frac
    local period = max(10, t * 2.4)
    local amp = t * 0.16
    local function curve(off, ph, am)
        local n = max(8, floor(len / (period / 8)))
        local pts = {}
        for i = 0, n do
            local sl = len * i / n
            local x, y = at(cx, cy, rm + off + am * sin(sl / period * 2 * pi + ph), -pi / 2 + sl / rm)
            pts[#pts + 1] = x; pts[#pts + 1] = y
        end
        return pts
    end
    c:polyline(curve(t * 0.08, 0, amp), max(2, t * 0.42), col)
    c:polyline(curve(-t * 0.24, 1.6, amp * 0.7), max(1.5, t * 0.12), mix(dark, tone.bg, 0.45))
    -- foam on each crest
    local k = 0
    while period * (k + 0.25) <= len do
        local sl = period * (k + 0.25)
        local x, y = at(cx, cy, rm + t * 0.08 + amp + t * 0.2, -pi / 2 + sl / rm)
        c:disc(x, y, max(1.5, t * 0.13), SEA_L)
        c:disc(x, y, max(1, t * 0.08), WHITE)
        k = k + 1
    end
end

local D = {}

-- ─── the rings: a lighthouse ─────────────────────────────────────────────────
-- One lighthouse instead of three rings: its base fills with the day's pages,
-- the striped tower with the minutes, the lamp room with the streak. Once the
-- pages and the minutes are both done, the lamp shines: a beam to each side.
-- Reading Log draws a set of rings outer first at one centre, so the first
-- call draws the whole lighthouse empty and fills the base, and the next two
-- fill theirs. A ring on its own somewhere else is drawn the usual way.

local LIGHT = { 255, 232, 140 }
-- the parts, as (top, bottom, half width at top, at bottom) in R from the centre
local PARTS = {
    { 0.40, 0.90, 0.30, 0.42 },     -- base: pages
    { -0.22, 0.40, 0.20, 0.30 },    -- tower: minutes
    { -0.56, -0.24, 0.17, 0.17 },   -- lamp room: streak
}
local FILLS = { SEA, CORAL, GOLD }

local function partHalf(cy, R, p)
    local y0, y1 = cy + p[1] * R, cy + p[2] * R
    return y0, y1, function(yy)
        local k = (yy - y0) / (y1 - y0)
        if k < 0 or k > 1 then return 0 end
        return R * (p[3] + (p[4] - p[3]) * k)
    end
end

local function partFill(c, cx, cy, R, i, frac, col)
    if frac <= 0 then return end
    local y0, y1, half = partHalf(cy, R, PARTS[i])
    fillRows(c, cx, y1 - (y1 - y0) * min(1, frac), y1, half, col)
end

local function lighthouseEmpty(c, cx, cy, R, tone)
    local pale = mix(tone.bg, WHITE, 0.6)
    local e = max(1, R * 0.035)
    -- the rock it stands on
    fillRows(c, cx, cy + 0.84 * R, cy + 0.98 * R, function(yy)
        local k = (yy - (cy + 0.84 * R)) / (0.14 * R)
        return R * (0.42 + 0.2 * k)
    end, SAND_D)
    for i = 1, 3 do
        local y0, y1, half = partHalf(cy, R, PARTS[i])
        fillRows(c, cx, y0 - e, y1 + e, function(yy) return half(min(y1, max(y0, yy))) + e end, INK)
        fillRows(c, cx, y0, y1, half, pale)
    end
    -- the gallery round the lamp room, and the roof
    c:rect(floor(cx - 0.30 * R), floor(cy - 0.25 * R), max(2, floor(0.6 * R)), max(2, floor(0.05 * R)), INK)
    fillRows(c, cx, cy - 0.86 * R, cy - 0.56 * R, function(yy)
        local k = (yy - (cy - 0.86 * R)) / (0.30 * R)
        return R * 0.27 * k
    end, CORAL_D)
end

-- white bands across the tower, over whatever is in it
local function stripes(c, cx, cy, R)
    for _, v in ipairs({ -0.04, 0.20 }) do
        local y = cy + v * R
        local hw = R * (0.20 + 0.10 * (v + 0.22) / 0.62)
        c:rect(floor(cx - hw + 0.5), floor(y), max(1, floor(2 * hw)), max(1, floor(0.06 * R)), WHITE)
    end
end

-- the lamp shining: a widening beam to each side
local function beam(c, cx, cy, R, reach)
    local ly = cy - 0.40 * R
    local n = max(4, floor(reach * R / 2))
    for i = 0, n do
        local k = i / n
        local x = 0.2 * R + k * (reach - 0.2) * R
        local hh = R * (0.04 + 0.16 * k)
        local col = LIGHT
        c:rect(floor(cx + x), floor(ly - hh), max(1, floor(R / n + 1)), max(1, floor(2 * hh)), col)
        c:rect(floor(cx - x - R / n), floor(ly - hh), max(1, floor(R / n + 1)), max(1, floor(2 * hh)), col)
    end
end

local tri

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    frac = max(0, frac or 0)
    if which == 1 then
        tri = { c = c, cx = cx, cy = cy, R = R, f1 = frac }
        lighthouseEmpty(c, cx, cy, R, tone)
        -- in the card's own colours, so they match its figures
        partFill(c, cx, cy, R, 1, frac, fill or FILLS[1])
        return true
    end
    if not (tri and tri.c == c and tri.cx == cx and tri.cy == cy) then return false end
    local i = which == 2 and 2 or 3
    partFill(c, cx, cy, tri.R, i, frac, i == 2 and fill or FILLS[i])
    if i == 2 then
        tri.f2 = frac
        stripes(c, cx, cy, tri.R)
    else
        if (tri.f1 or 0) >= 1 and (tri.f2 or 0) >= 1 then beam(c, cx, cy, tri.R, 0.98) end
        tri = nil
    end
    return true
end

-- ─── a day: a small lighthouse ───────────────────────────────────────────────
-- It fills from the bottom with the day's pages, and its lamp shines once
-- the day's pages and minutes are both done. Days to come are an outline.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    local R = d * 0.5
    if o.future then
        local pale = mix(SEA_L, tone.bg, 0.7)
        for i = 1, 3 do
            local y0, y1, half = partHalf(cy, R, PARTS[i])
            fillRows(c, cx, y0, y1, half, pale)
        end
        return true
    end
    lighthouseEmpty(c, cx, cy, R, tone)
    local f = min(1, fp or 0)
    if f > 0 then
        local top, bottom = cy + PARTS[3][1] * R, cy + PARTS[1][2] * R
        local level = bottom - (bottom - top) * f
        for i = 1, 3 do
            local y0, y1, half = partHalf(cy, R, PARTS[i])
            if level < y1 then fillRows(c, cx, max(y0, level), y1, half, FILLS[i]) end
        end
    end
    stripes(c, cx, cy, R)
    if (fp or 0) >= 1 and (fm or 0) >= 1 then beam(c, cx, cy, R, 0.7) end
    return true
end

-- ─── the year goal: a treasure chest of pearls ───────────────────────────────
-- A pearl for every book (as many as fit; past 30 each stands for several),
-- heaped in the open chest; the ones still to read are outlines.

function D.goal(c, x, y, w, h, done, target, tone)
    local cx = x + w / 2
    local cw = w * 0.92
    local chh = h * 0.3
    local base = y + h * 0.98
    local ctop = base - chh
    local n = (target and target > 0) and min(target, 30) or 12
    local per = (target and target > 0) and target / n or 1
    local lit = (target and target > 0) and floor(min(done, target) / per + 1e-6) or 0
    -- pearls in rows, each row one fewer, as big as fits
    local pr, rows, left
    for try = 1, 30 do
        pr = (cw / 2) / (3 + try * 0.5)
        local per_row = floor(cw * 0.9 / (pr * 2.05))
        rows, left = {}, n
        while left > 0 and per_row > 0 do
            local k = min(per_row, left)
            rows[#rows + 1] = k
            left = left - k
            per_row = per_row - 1
        end
        if left == 0 and (#rows * pr * 1.8 + pr) <= (ctop - y) * 0.95 + pr then break end
    end
    -- the lid, open behind
    dome(c, cx, ctop + 1, cw * 0.5 + 1.5, min(chh * 0.9, (ctop - y) * 0.9) + 1.5, WOOD_D)
    dome(c, cx, ctop, cw * 0.5, min(chh * 0.9, (ctop - y) * 0.9), WOOD)
    local i = 0
    for r = 1, #rows do
        local k = rows[r]
        local py = ctop + pr * 0.35 - (r - 1) * pr * 1.75
        for j = 1, k do
            i = i + 1
            local px = cx + (j - (k + 1) / 2) * pr * 2.05
            if i <= lit then
                c:disc(px, py, pr + 0.8, PEARL_E)
                c:disc(px, py, pr, PEARL)
                c:disc(px - pr * 0.32, py - pr * 0.32, max(0.8, pr * 0.25), WHITE)
            else
                c:ring(px, py, pr * 0.85, max(1, pr * 0.14), 1, mix(PEARL_E, tone.bg, 0.3), mix(PEARL_E, tone.bg, 0.3))
            end
        end
    end
    -- the chest, in front of the bottom row
    c:rrect(floor(cx - cw / 2 - 1), floor(ctop + pr * 0.6 - 1), floor(cw + 2), floor(base - ctop - pr * 0.6 + 2), max(1, cw * 0.04), WOOD_D)
    c:rrect(floor(cx - cw / 2), floor(ctop + pr * 0.6), floor(cw), floor(base - ctop - pr * 0.6), max(1, cw * 0.035), WOOD)
    local bh = base - ctop - pr * 0.6
    for _, f in ipairs({ 0.36, 0.68 }) do
        c:rect(floor(cx - cw / 2), floor(ctop + pr * 0.6 + bh * f), floor(cw), max(1, floor(bh * 0.04)), WOOD_D)
    end
    local band = max(2, floor(cw * 0.08))
    c:rect(floor(cx - cw / 2), floor(ctop + pr * 0.6), band, floor(bh), GOLD)
    c:rect(floor(cx + cw / 2 - band), floor(ctop + pr * 0.6), band, floor(bh), GOLD)
    c:rrect(floor(cx - band), floor(ctop + pr * 0.6 + bh * 0.12), floor(band * 2), floor(bh * 0.3), max(1, band * 0.3), GOLD)
    c:disc(cx, ctop + pr * 0.6 + bh * 0.25, max(1, band * 0.3), GOLD_D)
    if target and target > 0 and done >= target then
        star(c, cx + cw * 0.3, y + max(6, h * 0.06), max(4, w * 0.07), GOLD)
    end
    return true
end

-- ─── bars: columns of sea, a curl of foam on top ─────────────────────────────

function D.chartBar(c, x, y, w, h, tone, fill, o)
    if w < 3 or h < 3 then return false end
    local col = o.current and CORAL or SEA
    local light = o.current and CORAL_L or SEA_L
    c:rrect(x, y, w, h, min(w / 2, h / 2), col)
    if w >= 8 and h >= w then
        -- the curl of the wave at the top
        local pts = {}
        for i = 0, 8 do
            local a = pi + pi * 1.3 * i / 8
            pts[#pts + 1] = x + w * 0.5 + w * 0.28 * cos(a)
            pts[#pts + 1] = y + w * 0.5 + w * 0.28 * sin(a)
        end
        c:polyline(pts, max(1.5, w * 0.1), light)
        if h > w * 2.5 then
            c:ring(x + w * 0.38, y + h * 0.62, max(1.5, w * 0.12), max(1, w * 0.05), 1, light, light)
            c:ring(x + w * 0.62, y + h * 0.78, max(1.5, w * 0.08), max(1, w * 0.04), 1, light, light)
        end
    end
    return true
end

-- ─── lines: shells (books), a dashed line with bubbles (pages) ───────────────

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
    local s = max(5, lw * 2.6)
    if o.series == 2 then
        dashed(c, pts, max(1.5, lw * 0.8), fill, max(4, lw * 3.5), max(3, lw * 2.5))
        for i = 1, n do
            c:disc(xs[i], ys[i], s * 0.62, tone.bg)
            bubble(c, xs[i], ys[i], s * 0.55, fill, tone.bg)
        end
    else
        c:polyline(pts, max(1.5, lw * 0.75), fill)
        for i = 1, n do shell(c, xs[i], ys[i] - s * 0.35, s * 1.25, CORAL_L, CORAL_D) end
    end
    return true
end

-- ─── Today's timeline: a strip of sea, a fish over each sitting ──────────────

function D.timeline(c, x, y, w, h, spans, now, tone)
    local top = floor(h * 0.55)
    local ty, th = y + top, max(4, h - top)
    c:rrect(x, ty, w, th, th / 2, tone.track)
    local fl = max(12, h * 1.1)
    local last = -1e9
    for k, sp in ipairs(spans) do
        local x1, x2 = x + w * sp[1], x + w * sp[2]
        local bw = max(th, x2 - x1)
        local bx = min(x1, x + w - bw)
        c:rrect(floor(bx), ty, floor(bw), th, th / 2, sp[3] or SEA, tone.track)
        local mx = bx + bw / 2
        if mx - last >= fl then
            fish(c, mx, ty - fl * 0.3, fl, (k % 2 == 1) and CORAL or GOLD, (k % 2 == 1) and CORAL_D or GOLD_D)
            last = mx
        end
    end
    if now then
        local nx = x + w * now
        local r = max(4, h * 0.26)
        c:rect(floor(nx - max(1, th * 0.12)), floor(y + r * 1.6), max(2, floor(th * 0.24)), floor(ty + th + 3 - (y + r * 1.6)), INK)
        -- a buoy
        c:disc(nx, y + r, r + 1, CORAL_D)
        c:disc(nx, y + r, r, CORAL)
        c:rect(floor(nx - r), floor(y + r - r * 0.25), floor(2 * r), max(1, floor(r * 0.5)), WHITE)
    end
    return true
end

-- ─── Reading trends: tiles with a wave along the bottom, bubbles for marks ───

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, SEA_L, 0.18) or mix(tone.bg, CORAL_L, 0.2)
    c:rrect(x, y, w, h, min(h * 0.18, 14), base)
    local wave = (i % 2 == 1) and mix(base, SEA, 0.3) or mix(base, CORAL, 0.3)
    for k = 0, 1 do
        local yy = y + h * (0.84 + k * 0.08)
        local pts = {}
        for j = 0, 24 do
            local f = j / 24
            pts[#pts + 1] = x + w * (0.04 + 0.92 * f)
            pts[#pts + 1] = yy + h * 0.03 * sin(f * pi * 8 + k * 1.5)
        end
        c:polyline(pts, max(1.5, h * 0.025), wave)
    end
    local s = max(8, min(w, h) * 0.2)
    shell(c, x + w - s * 0.9, y + s * 0.75, s, mix(CORAL_L, base, 0.2), mix(CORAL_D, base, 0.3))
    return true
end

function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local col = (dir == "up") and SEA or ((dir == "down") and CORAL or SAND_D)
    c:disc(cx, cy, r, col)
    c:ring(cx, cy, r, max(1.5, r * 0.1), 1, mix(col, { 0, 0, 0 }, 0.25), mix(col, { 0, 0, 0 }, 0.25))
    c:disc(cx - r * 0.42, cy - r * 0.42, max(1, r * 0.17), WHITE)
    local a = r * 0.42
    local lw = max(2, r * 0.2)
    if dir == "up" then
        c:polyline({ cx - a, cy + a * 0.45, cx, cy - a * 0.5, cx + a, cy + a * 0.45 }, lw, WHITE)
    elseif dir == "down" then
        c:polyline({ cx - a, cy - a * 0.45, cx, cy + a * 0.5, cx + a, cy - a * 0.45 }, lw, WHITE)
    else
        c:rect(floor(cx - a), floor(cy - lw / 2), floor(2 * a), max(2, floor(lw)), WHITE)
    end
    -- two little bubbles rising off it
    bubble(c, cx + r * 0.85, cy - r * 0.95, max(1.5, r * 0.18), col, tone.bg)
    bubble(c, cx + r * 1.15, cy - r * 1.35, max(1.2, r * 0.12), col, tone.bg)
    return true
end

-- ─── the calendar: portholes ─────────────────────────────────────────────────
-- A day without reading is a porthole with its number; a day you read has a
-- starfish on its cover; today has a coral rim, or bubbles over its cover.

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local m = max(2, floor(min(w, h) * 0.06))
    local r = (min(w, h) - 2 * m) / 2
    if r < 6 then return false end
    local cx, cy = x + w / 2, y + h / 2
    local fade = o.future and 0.55 or 0
    local rim = o.today and CORAL or mix(GOLD, tone.bg, fade)
    local rimd = o.today and CORAL_D or mix(GOLD_D, tone.bg, fade)
    c:disc(cx, cy, r, rimd)
    c:disc(cx, cy, r * 0.94, rim)
    c:disc(cx, cy, r * 0.74, rimd)
    c:disc(cx, cy, r * 0.7, mix(mix(SEA_L, tone.bg, 0.45), tone.bg, fade))
    if r >= 12 then
        for k = 0, 5 do
            local bx, by = at(cx, cy, r * 0.84, -pi / 2 + k * pi / 3)
            c:disc(bx, by, max(1, r * 0.06), rimd)
        end
        c:polyline({ cx - r * 0.42, cy - r * 0.18, cx - r * 0.22, cy - r * 0.42 }, max(1, r * 0.06), mix(WHITE, tone.bg, fade))
    end
    local size = o.num_px or max(10, floor(r * 0.75))
    c:label(tostring(n), size, cx, cy, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

-- Two rows of waves along the bottom of a cover, foam on the front one.
local function waves(c, x, y, w, h)
    local wh = max(6, h * 0.2)
    local base = floor(y + h)
    local x0, x1 = floor(x), floor(x + w)
    for layer = 1, 2 do
        local top0 = base - wh * (layer == 1 and 1 or 0.6)
        local amp = wh * (layer == 1 and 0.16 or 0.2)
        local col = layer == 1 and SEA_L or SEA
        local ph = layer == 1 and 1.3 or 0
        for xi = x0, x1 - 1 do
            local t = (xi - x) / w
            local top = floor(top0 + amp * sin(t * 2 * pi * 2.2 + ph))
            if top < base then c:rect(xi, top, 1, base - top, col) end
        end
    end
    -- foam on the crests of the front row
    local top0, amp = base - wh * 0.6, wh * 0.2
    local fr = max(1, wh * 0.09)
    for k = 0, 4 do
        local t = (k + 0.75) / 2.2
        if t > 1 then break end
        local fx = x + w * t
        local fy = top0 - amp
        c:disc(fx, fy + fr * 0.4, fr * 1.2, WHITE)
        c:disc(fx - fr * 1.5, fy + fr * 0.9, fr, WHITE)
        c:disc(fx + fr * 1.4, fy + fr * 1.0, fr * 0.8, WHITE)
    end
    c:rect(x0, base - max(1, floor(wh * 0.12)), x1 - x0, max(1, floor(wh * 0.12)), SEA_D)
end

function D.bookCover(c, x, y, w, h, tone, o)
    waves(c, x, y, w, h)
    return true
end

function D.calendarCover(c, x, y, w, h, tone, o)
    local s = max(5, min(w, h) * 0.16)
    waves(c, x, y, w, h)
    if o.today then
        bubble(c, x + w * 0.5, y - s * 0.4, max(2, s * 0.45), SEA, tone.bg)
        bubble(c, x + w * 0.5 + s * 0.6, y - s * 1.2, max(1.5, s * 0.3), SEA, tone.bg)
    end
    return true
end

-- ─── the challenge: a sailboat crossing to an island ─────────────────────────
-- The boat sails along a dotted course from the left as the month's goal
-- fills; at the end it's moored by the island's palm, a flag up.

local function boat(c, x, wl, s, flag)
    -- the hull: wider at the top
    fillRows(c, x, wl - s * 0.18, wl + s * 0.12, function(yy)
        local k = (yy - (wl - s * 0.18)) / (s * 0.3)
        return s * (0.55 - 0.2 * k)
    end, WOOD)
    c:rect(floor(x - s * 0.55), floor(wl - s * 0.2), floor(s * 1.1), max(1, floor(s * 0.05)), WOOD_D)
    -- the mast and the sail
    c:rect(floor(x - max(0.5, s * 0.025)), floor(wl - s * 0.95), max(1, floor(s * 0.05)), floor(s * 0.78), WOOD_D)
    fillRows(c, x + s * 0.03, wl - s * 0.92, wl - s * 0.24, function(yy)
        local k = (yy - (wl - s * 0.92)) / (s * 0.68)
        return s * 0.42 * k
    end, WHITE)
    c:polyline({ x + s * 0.03, wl - s * 0.92, x + s * 0.45, wl - s * 0.26, x + s * 0.03, wl - s * 0.26 }, max(1, s * 0.03), SEA_D)
    if flag then
        fillRows(c, x - s * 0.1, wl - s * 1.05, wl - s * 0.9, function() return s * 0.1 end, CORAL)
    end
end

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local wl = cy + R * 0.38                -- the waterline
    -- the sun
    local sx, sy = cx - R * 0.55, cy - R * 0.55
    for k = 0, 7 do
        local a = k * pi / 4
        c:polyline({ sx + R * 0.17 * cos(a), sy + R * 0.17 * sin(a), sx + R * 0.24 * cos(a), sy + R * 0.24 * sin(a) }, max(1.5, R * 0.025), GOLD)
    end
    c:disc(sx, sy, R * 0.13, GOLD)
    -- the island and its palm
    local ix = cx + R * 0.68
    dome(c, ix, wl + R * 0.04, R * 0.34, R * 0.16, SAND)
    local tx, ty = ix + R * 0.05, wl - R * 0.1
    local top_x, top_y = ix - R * 0.06, wl - R * 0.62
    c:polyline({ tx, ty, ix + R * 0.04, wl - R * 0.35, top_x, top_y }, max(2, R * 0.05), WOOD)
    for _, a in ipairs({ -2.6, -1.9, -1.2, -0.5, 0.2 }) do
        local ex, ey = top_x + R * 0.24 * cos(a), top_y + R * 0.24 * sin(a) + R * 0.06
        c:polyline({ top_x, top_y, (top_x + ex) / 2, (top_y + ey) / 2 - R * 0.05, ex, ey }, max(2, R * 0.045), PALM)
    end
    -- the sea
    local left, right = cx - R * 0.98, cx + R * 0.98
    c:rect(floor(left), floor(wl), floor(right - left), floor(R * 0.42), mix(SEA_L, tone.bg, 0.35))
    for k = 0, 2 do
        local yy = wl + R * (0.02 + k * 0.13)
        local pts = {}
        for j = 0, 30 do
            local f = j / 30
            pts[#pts + 1] = left + (right - left) * f
            pts[#pts + 1] = yy + R * 0.025 * sin(f * pi * 10 + k)
        end
        c:polyline(pts, max(1.5, R * 0.022), (k == 0) and SEA or mix(SEA, tone.bg, 0.35))
    end
    -- the course, dotted, and the boat on it
    local x0, x1 = cx - R * 0.8, ix - R * 0.42
    local n = 14
    for k = 0, n do
        local f = k / n
        if f > frac then c:disc(x0 + (x1 - x0) * f, wl + R * 0.09, max(1, R * 0.018), SEA_D) end
    end
    local bx = x0 + (x1 - x0) * frac
    boat(c, bx, wl + R * 0.03 + R * 0.02 * sin(frac * 20), R * 0.42, frac >= 1)
end

-- ─── progress bars: a fish swimming along the water ──────────────────────────

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local mid = y + h / 2
    local th = max(2, floor(h * 0.5))
    c:rrect(x, floor(mid - th / 2), w, th, th / 2, tone.track)
    if frac <= 0 then return end
    local e = x + w * frac
    local sh = max(3, floor(h * 0.7))
    c:rrect(x, floor(mid - sh / 2), max(sh, floor(e - x)), sh, sh / 2, SEA, tone.track)
    if e - x > h * 3 then
        local pts = {}
        local n = floor((e - x) / max(4, h * 0.6))
        for j = 0, n do
            local f = j / n
            pts[#pts + 1] = x + sh * 0.5 + (e - x - sh * 1.5) * f
            pts[#pts + 1] = mid - sh * 0.12 + sh * 0.12 * sin(f * n * 1.6)
        end
        c:polyline(pts, max(1, sh * 0.16), SEA_L)
    end
    -- bubbles trailing off behind the fish
    local fl = max(10, h * 2.2)
    local fx = min(e, x + w) - fl * 0.25
    if e - x > fl then
        bubble(c, fx - fl * 0.65, mid - h * 0.9, max(1.5, h * 0.22), SEA, tone.bg)
        bubble(c, fx - fl * 0.95, mid - h * 1.4, max(1.2, h * 0.16), SEA, tone.bg)
    end
    fish(c, fx, mid - h * 0.1, fl, CORAL, CORAL_D)
end

return D
