-- Christmas drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi

local GREEN, PINE, DARK = { 31, 122, 63 }, { 46, 140, 74 }, { 20, 90, 44 }
local RED, DEEPRED, WHITE = { 200, 16, 46 }, { 165, 13, 38 }, { 255, 255, 255 }
local GOLD, GOLDDARK, ICE, BLUE = { 232, 178, 58 }, { 168, 122, 30 }, { 42, 93, 176 }, { 42, 93, 176 }
local CREAM, BROWN = { 255, 250, 240 }, { 122, 74, 36 }
local BAUBLES = { RED, GREEN, GOLD, BLUE }

local function at(cx, cy, r, a) return cx + r * cos(a), cy + r * sin(a) end
local function mix(a, b, t) return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t } end

-- The part of a circle below a level, filled row by row: a bauble filling up.
local function fillCircle(c, cx, cy, r, frac, col)
    frac = max(0, min(1, frac))
    if frac <= 0 then return end
    if frac >= 1 then c:disc(cx, cy, r, col) return end
    local top = cy + r - 2 * r * frac
    local step = max(1, floor(r / 14))
    local yy = floor(top)
    while yy < cy + r do
        local dy = (yy + step / 2) - cy
        local half = sqrt(max(0, r * r - dy * dy))
        if half > 0.5 then c:rect(floor(cx - half + 0.5), yy, max(1, floor(2 * half + 0.5)), step, col) end
        yy = yy + step
    end
end

-- A filled triangle, point up, row by row.
local function triangle(c, cx, top, bottom, half, col)
    local step = max(1, floor((bottom - top) / 40))
    local yy = floor(top)
    while yy < bottom do
        local k = (yy + step / 2 - top) / (bottom - top)
        local hw = half * k
        if hw > 0.5 then c:rect(floor(cx - hw + 0.5), yy, max(1, floor(2 * hw + 0.5)), step, col) end
        yy = yy + step
    end
end

-- A five-pointed star, as five thick strokes.
local function star(c, cx, cy, r, col)
    local pts = {}
    for i = 0, 10 do
        local rr = (i % 2 == 0) and r or r * 0.42
        local a = -pi / 2 + pi * i / 5
        pts[#pts + 1] = cx + rr * cos(a)
        pts[#pts + 1] = cy + rr * sin(a)
    end
    c:disc(cx, cy, r * 0.45, col)
    c:polyline(pts, max(1.5, r * 0.32), col)
end

local function bow(c, x, y, s, col)
    c:disc(x - s, y - s * 0.4, s * 0.72, col)
    c:disc(x + s, y - s * 0.4, s * 0.72, col)
    c:polyline({ x, y, x - s * 0.7, y + s * 1.4 }, max(1.5, s * 0.4), col)
    c:polyline({ x, y, x + s * 0.7, y + s * 1.4 }, max(1.5, s * 0.4), col)
    c:disc(x, y, s * 0.45, DEEPRED)
end

-- ─── rings: the wreath (pages) and the candy cane (time) ─────────────────────

local function wreath(c, cx, cy, R, t, frac, track)
    c:ring(cx, cy, R, t, 0, track, track)
    if frac <= 0 then return end
    frac = min(frac, 1)
    local a0 = -pi / 2
    local a1 = a0 + 2 * pi * frac
    if R < 22 then
        c:ring(cx, cy, R, t, frac, track, GREEN)
        if frac >= 1 then c:disc(cx, cy - R, max(2, t * 0.45), RED) end
        return
    end
    c:ring(cx, cy, R, t * 0.55, frac, track, DARK)
    local step = max(3, t * 0.42)
    local n = max(2, floor(2 * pi * R * frac / step))
    local len = t * 0.38
    local lw = max(1.5, t * 0.14)
    local cols = { GREEN, PINE, DARK }
    for k = 0, n do
        local a = a0 + (a1 - a0) * k / n
        for side = -1, 1, 2 do
            local x, y = at(cx, cy, R + side * t * 0.12, a)
            local d = a + pi / 2 + side * 0.75
            c:polyline({ x, y, x + len * cos(d), y + len * sin(d) }, lw, cols[(k % 3) + 1])
        end
    end
    local berries = max(1, floor(n / 7))
    for k = 1, berries do
        local a = a0 + (a1 - a0) * (k - 0.5) / berries
        local x, y = at(cx, cy, R + t * 0.05, a + 0.04)
        c:disc(x, y, max(2, t * 0.2), RED)
    end
    local bx, by = at(cx, cy, R, a1)
    bow(c, bx, by, max(3, t * 0.42), RED)
end

local function cane(c, cx, cy, R, t, frac, track)
    c:ring(cx, cy, R, t, frac, track, WHITE)
    if frac <= 0 then return end
    frac = min(frac, 1)
    local a0 = -pi / 2
    local span = 2 * pi * frac
    local step = max(0.12, (t * 1.3) / R)
    local lw = max(1.5, t * 0.32)
    local k = 0
    while (k + 0.5) * step < span do
        local a = a0 + (k + 0.25) * step
        local x1, y1 = at(cx, cy, R - t * 0.38, a)
        local x2, y2 = at(cx, cy, R + t * 0.38, a + step * 0.45)
        c:polyline({ x1, y1, x2, y2 }, lw, RED)
        k = k + 1
    end
end

local D = {}

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    if which == 2 then cane(c, cx, cy, R, t, frac, track) else wreath(c, cx, cy, R, t, frac, track) end
end

-- ─── a day: a bauble ─────────────────────────────────────────────────────────
-- It fills with colour from the bottom as the day's pages add up, gets a gold
-- band when the minutes goal is met, and a shine when both are. Today has a
-- red ring round it; days still to come are pale outlines.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    local r = d * 0.36
    local by = cy + d * 0.07
    local col = BAUBLES[(floor(cx / max(1, d)) % #BAUBLES) + 1]
    local cap_w, cap_h = max(3, r * 0.55), max(2, r * 0.3)
    -- the hook and cap
    c:polyline({ cx, by - r - cap_h - max(2, r * 0.35), cx, by - r - cap_h }, max(1, r * 0.08), GOLDDARK)
    c:rrect(floor(cx - cap_w / 2), floor(by - r - cap_h + 1), floor(cap_w), floor(cap_h), max(1, cap_h * 0.3), GOLD)
    if o.future then
        c:ring(cx, by, r, max(1, r * 0.12), 1, tone.track, tone.track)
        return true
    end
    c:disc(cx, by, r, mix(tone.bg, tone.track, 0.7))
    fillCircle(c, cx, by, r, fp, col)
    if fm > 0 then
        -- the minutes: a gold band across the middle, as far as they got
        local bh = max(2, r * 0.26)
        local half = r * 0.96
        local bw = 2 * half * min(1, fm)
        c:rect(floor(cx - half), floor(by - bh / 2), max(1, floor(bw)), floor(bh), fm >= 1 and GOLD or mix(GOLD, tone.bg, 0.45))
    end
    if fp >= 1 and fm >= 1 and not o.small then
        c:disc(cx - r * 0.38, by - r * 0.38, max(1.5, r * 0.18), WHITE)
    end
    if o.today then
        c:ring(cx, by, r + max(1, r * 0.1), max(1.5, r * 0.14), 1, RED, RED)
    else
        c:ring(cx, by, r, max(1, r * 0.08), 1, GOLDDARK, GOLDDARK)
    end
    return true
end

-- ─── the year goal: a tree, an ornament for every book ──────────────────────

function D.goal(c, x, y, w, h, done, target, tone)
    local cx = x + w / 2
    local trunk_h = h * 0.1
    local base = y + h - trunk_h
    local top = y + h * 0.12
    local half = min(w * 0.5, (base - top) * 0.62)
    c:rect(floor(cx - w * 0.08), floor(base), floor(w * 0.16), floor(trunk_h), BROWN)
    -- three tiers, the lower ones wider
    local tiers = { { 0.0, 0.48, 0.55 }, { 0.26, 0.76, 0.8 }, { 0.5, 1.0, 1.0 } }
    local H = base - top
    for i, tr in ipairs(tiers) do
        triangle(c, cx, top + H * tr[1], top + H * tr[2], half * tr[3], i % 2 == 1 and GREEN or PINE)
    end
    -- a gold garland across each tier
    for _, f in ipairs({ 0.36, 0.64, 0.9 }) do
        local yy = top + H * f
        local hw = half * (0.35 + f * 0.6)
        c:polyline({ cx - hw * 0.85, yy - H * 0.03, cx, yy + H * 0.03, cx + hw * 0.85, yy - H * 0.04 }, max(1.5, w * 0.012), GOLD)
    end
    -- the ornaments: one place per book (as many as fit), lit as books are read
    local slots = {}
    local rows = { { 0.3, 2 }, { 0.46, 3 }, { 0.62, 4 }, { 0.78, 5 }, { 0.94, 6 } }
    for _, rw in ipairs(rows) do
        local yy = top + H * rw[1]
        local hw = half * rw[1] * 0.78
        for k = 1, rw[2] do
            local fx = (rw[2] == 1) and 0 or ((k - 1) / (rw[2] - 1) * 2 - 1)
            slots[#slots + 1] = { cx + fx * hw, yy }
        end
    end
    local n = #slots
    if target and target > 0 and target < n then n = target end
    local lit = target and target > 0 and floor(n * min(1, done / target) + 0.5) or 0
    local r = max(2.5, min(w, h) * 0.035)
    for i = 1, n do
        local sx, sy = slots[i][1], slots[i][2]
        if i <= lit then
            c:disc(sx, sy, r, BAUBLES[((i - 1) % #BAUBLES) + 1])
            c:disc(sx - r * 0.35, sy - r * 0.35, max(1, r * 0.3), WHITE)
        else
            c:ring(sx, sy, r * 0.8, max(1, r * 0.25), 1, mix(GREEN, WHITE, 0.45), mix(GREEN, WHITE, 0.45))
        end
    end
    star(c, cx, top, max(4, w * 0.075), GOLD)
    return true
end

-- ─── bars: stacked presents ──────────────────────────────────────────────────

local WRAP = { RED, GREEN, GOLD, BLUE }

function D.chartBar(c, x, y, w, h, tone, fill, o)
    if h < 3 or w < 3 then return false end
    -- a few presents, each a little narrower than the one under it
    local count = max(1, min(5, floor(h / max(6, w * 1.1))))
    local yy = y + h
    local box = h / count
    for k = 0, count - 1 do
        local shrink = min(0.3, k * 0.08)
        local bw = w * (1 - shrink)
        local bx = x + (w - bw) / 2
        local by = yy - box
        local col = o.current and ((k % 2 == 0) and RED or GREEN) or WRAP[((o.i or 1) + k - 1) % #WRAP + 1]
        c:rrect(floor(bx), floor(by + 1), max(2, floor(bw)), max(1, floor(box - 1)), max(0, min(2, box * 0.08)), col)
        local rw = max(1, floor(bw * 0.18))
        local ribbon = (col == GOLD) and RED or (o.current and GOLD or CREAM)
        c:rect(floor(bx + bw / 2 - rw / 2), floor(by + 1), rw, max(1, floor(box - 1)), ribbon)
        if box >= 10 then c:rect(floor(bx), floor(by + box * 0.45 - rw / 2), max(2, floor(bw)), rw, ribbon) end
        yy = by
    end
    -- a bow on the top one
    if w >= 6 then bow(c, x + w / 2, yy - max(1, w * 0.06), max(2, w * 0.2), o.current and GOLD or RED) end
    return true
end

-- ─── lines: a string of lights ───────────────────────────────────────────────

function D.line(c, pts, xs, ys, n, lw, fill, tone, o)
    c:polyline(pts, max(1.5, lw * 0.6), DARK)
    local r = max(5, lw * 2.2)
    for i = 1, n do
        -- the bulbs stand up off the wire, clear of the month names below
        local x, y = xs[i], ys[i]
        c:rect(floor(x - r * 0.4), floor(y - r * 0.6), max(2, floor(r * 0.8)), max(2, floor(r * 0.6)), GOLDDARK)
        local cy = y - r * 0.6 - r * 1.2
        c:disc(x, cy + r * 0.3, r * 0.9, mix(fill, tone.bg, 0.65))
        c:disc(x, cy, r * 0.75, fill)
        c:disc(x, cy + r * 0.45, r * 0.75, fill)
        c:disc(x - r * 0.25, cy - r * 0.1, max(1, r * 0.22), WHITE)
    end
    return true
end

-- ─── Today's timeline: lights along the day, lit where you read ─────────────

function D.timeline(c, x, y, w, h, spans, now, tone)
    local wy = y + h * 0.28
    local pts = {}
    local waves = 6
    for i = 0, 48 do
        local f = i / 48
        pts[#pts + 1] = x + w * f
        pts[#pts + 1] = wy + h * 0.14 * sin(f * pi * 2 * waves)
    end
    c:polyline(pts, max(1.5, h * 0.06), DARK)
    local n = max(8, floor(w / max(10, h * 0.7)))
    local r = max(2.5, h * 0.2)
    for i = 0, n - 1 do
        local f = (i + 0.5) / n
        local bx = x + w * f
        local wyy = wy + h * 0.14 * sin(f * pi * 2 * waves)
        local col
        for _, sp in ipairs(spans) do
            if f >= sp[1] - 0.5 / n and f <= sp[2] + 0.5 / n then col = BAUBLES[(i % #BAUBLES) + 1] end
        end
        c:rect(floor(bx - r * 0.35), floor(wyy), max(2, floor(r * 0.7)), max(2, floor(r * 0.5)), GOLDDARK)
        local cy = wyy + r * 0.5 + r
        if col then
            c:disc(bx, cy + r * 0.3, r * 1.5, mix(col, tone.bg, 0.7))
            c:disc(bx, cy, r * 0.8, col)
            c:disc(bx, cy + r * 0.5, r * 0.8, col)
        else
            c:disc(bx, cy, r * 0.8, mix(tone.track, tone.bg, 0.2))
            c:disc(bx, cy + r * 0.5, r * 0.8, mix(tone.track, tone.bg, 0.2))
        end
    end
    if now then star(c, x + w * now, y + h * 0.02, max(4, h * 0.22), GOLD) end
    return true
end

-- ─── Reading trends: wrapped presents and baubles ────────────────────────────

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, RED, 0.07) or mix(tone.bg, GREEN, 0.08)
    c:rrect(x, y, w, h, min(h * 0.18, 14), base)
    -- ribbon round the top-right corner, tied in a bow there (clear of the text)
    local rw = max(3, floor(min(w, h) * 0.06))
    local col = (i % 2 == 1) and RED or GREEN
    local bx, by = x + w - max(8, w * 0.07), y + max(6, h * 0.14)
    c:rect(floor(bx - w * 0.16), floor(by - rw / 2), floor(w * 0.16 + (x + w - bx)), rw, col)
    c:rect(floor(bx - rw / 2), floor(y), rw, floor(h * 0.32), col)
    bow(c, bx, by, max(3, min(w, h) * 0.08), col)
    return true
end

function D.trendBadge(c, cx, cy, r, dir, tone, fill)
    local col = (dir == "up") and GREEN or ((dir == "down") and RED or GOLD)
    c:rect(floor(cx - r * 0.25), floor(cy - r * 1.18), max(2, floor(r * 0.5)), max(2, floor(r * 0.28)), GOLD)
    c:disc(cx, cy, r, col)
    c:disc(cx - r * 0.42, cy - r * 0.42, max(1, r * 0.16), WHITE)
    local a = r * 0.42
    local lw = max(2, r * 0.2)
    if dir == "up" then
        c:polyline({ cx - a, cy + a * 0.45, cx, cy - a * 0.5, cx + a, cy + a * 0.45 }, lw, WHITE)
    elseif dir == "down" then
        c:polyline({ cx - a, cy - a * 0.45, cx, cy + a * 0.5, cx + a, cy - a * 0.45 }, lw, WHITE)
    else
        c:rrect(floor(cx - a), floor(cy - lw / 2), floor(2 * a), max(2, floor(lw)), lw / 2, WHITE)
    end
    return true
end

-- ─── the calendar: an advent calendar ────────────────────────────────────────
-- A day without reading is a closed door with its number; a day you read
-- is the door swung open, showing the book; today has a gold star.

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local m = max(2, floor(min(w, h) * 0.08))
    local dw, dh = w - 2 * m, h - 2 * m
    if dw < 6 or dh < 6 then return false end
    local col = (n % 2 == 1) and RED or GREEN
    if o.future then col = mix(col, tone.bg, 0.55) end
    c:frame(x + m, y + m, dw, dh, max(1, floor(min(dw, dh) * 0.08)), max(1, floor(min(dw, dh) * 0.05)), GOLD, col)
    local size = o.num_px or max(10, floor(dh * 0.4))
    c:label(tostring(n), size, x + w / 2, y + h / 2, { bold = true, anchor = "c", valign = "mid", color = CREAM })
    if o.today then star(c, x + w - m - dw * 0.18, y + m + dh * 0.18, max(3, dw * 0.13), GOLD) end
    -- a small brass knob
    c:disc(x + m + dw * 0.86, y + m + dh * 0.55, max(1, dw * 0.04), GOLD)
    return true
end

function D.calendarCover(c, x, y, w, h, tone, o)
    -- the door, swung open on the left
    local fw = max(3, floor(w * 0.16))
    c:rrect(x - fw - 1, y + floor(h * 0.04), fw, floor(h * 0.92), max(1, floor(fw * 0.2)), RED)
    c:rect(x - fw - 1, y + floor(h * 0.04), max(1, floor(fw * 0.2)), floor(h * 0.92), GOLD)
    -- a bow on the corner
    bow(c, x + w - max(3, w * 0.12), y + max(3, w * 0.1), max(2, w * 0.1), RED)
    if o.today then star(c, x + w * 0.5, y - max(3, w * 0.08), max(3, w * 0.14), GOLD) end
    return true
end

-- ─── the challenge: a snowflake that grows its arms ──────────────────────────

local function arms(c, cx, cy, R, frac, col, lw)
    for i = 0, 5 do
        local a = -pi / 2 + pi * i / 3
        local L = R * frac
        if L > 0 then
            local ex, ey = at(cx, cy, L, a)
            c:polyline({ cx, cy, ex, ey }, lw, col)
        end
        for _, f in ipairs({ 0.45, 0.75 }) do
            if f * R <= L then
                local bx, by = at(cx, cy, f * R, a)
                for side = -1, 1, 2 do
                    local b = a + side * 0.7
                    c:polyline({ bx, by, bx + R * 0.24 * cos(b), by + R * 0.24 * sin(b) }, lw * 0.8, col)
                end
            end
        end
    end
end

function D.challenge(c, cx, cy, R, frac, tone)
    local lw = max(2, R * 0.075)
    arms(c, cx, cy, R * 0.92, 1, tone.track, lw)
    arms(c, cx, cy, R * 0.92, max(0, min(1, frac)), ICE, lw)
    c:disc(cx, cy, R * 0.2, tone.bg)
    c:ring(cx, cy, R * 0.2, max(2, R * 0.05), 1, ICE, ICE)
    if frac >= 1 then c:disc(cx, cy, R * 0.09, GOLD) end
end

-- ─── progress bars: a candy cane with a bell ─────────────────────────────────

function D.bar(c, x, y, w, h, frac, tone)
    frac = max(0, min(1, frac or 0))
    c:rrect(x, y, w, h, h / 2, tone.track)
    if frac <= 0 then return end
    local e = max(h, floor(w * frac + 0.5))
    c:rrect(x, y, e, h, h / 2, WHITE, tone.track)
    local sx = x + h * 0.4
    local lw = max(1.5, h * 0.42)
    while sx + h * 0.9 <= x + e - h * 0.3 do
        c:polyline({ sx, y + h - 1, sx + h * 0.8, y + 1 }, lw, RED)
        sx = sx + h * 1.4
    end
    if h >= 5 and frac < 1 then
        local r = max(3, h * 0.85)
        c:disc(x + e, y + h / 2, r, GOLD)
        c:disc(x + e, y + h / 2 + r * 0.55, max(1.5, r * 0.3), GOLDDARK)
    end
end

return D
