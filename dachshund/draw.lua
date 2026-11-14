-- Dachshund drawings for Reading Log (the format: Reading Log's stylepacks.lua,
-- or this repository's README).
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs

local FUR, FUR_D, FUR_L = { 160, 90, 44 }, { 104, 56, 26 }, { 206, 140, 84 }
local INK = { 40, 24, 14 }
local RED, RED_D = { 206, 62, 56 }, { 150, 36, 32 }
local MUSTARD, MUSTARD_D = { 240, 190, 40 }, { 190, 140, 20 }
local BUN, BUN_D = { 228, 170, 98 }, { 186, 126, 62 }
local SAUSAGE, SAUSAGE_D = { 196, 90, 62 }, { 150, 62, 40 }
local BONE, BONE_D = { 248, 240, 224 }, { 214, 200, 176 }
local PINK = { 236, 128, 140 }
local WHITE = { 255, 255, 255 }

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

-- The part of a disc below a level: frac of it, from the bottom.
local function discFill(c, cx, cy, r, frac, col)
    frac = max(0, min(1, frac or 0))
    if frac <= 0 then return end
    if frac >= 1 then c:disc(cx, cy, r, col) return end
    fillRows(c, cx, cy + r - 2 * r * frac, cy + r, function(yy)
        local dy = yy - cy
        return sqrt(max(0, r * r - dy * dy))
    end, col)
end

-- A dog's head looking along (tx, ty) (a unit vector): round head, snout,
-- nose, eye and a floppy ear. ox, oy: the "up" side of the head.
local function head(c, hx, hy, hr, tx, ty, ox, oy)
    c:disc(hx, hy, hr, FUR)
    local sx, sy = hx + tx * hr * 0.95, hy + ty * hr * 0.95
    c:disc(sx, sy, hr * 0.58, FUR)
    c:disc(sx + tx * hr * 0.42, sy + ty * hr * 0.42, max(1, hr * 0.24), INK)
    c:disc(hx + tx * hr * 0.25 + ox * hr * 0.35, hy + ty * hr * 0.25 + oy * hr * 0.35, max(1, hr * 0.14), INK)
    -- the ear hangs down the side of the head
    local ex, ey = hx - tx * hr * 0.25 - ox * hr * 0.05, hy - ty * hr * 0.25 - oy * hr * 0.05
    c:disc(ex, ey, hr * 0.5, FUR_D)
    c:disc(ex - ox * hr * 0.35, ey - oy * hr * 0.35, hr * 0.38, FUR_D)
end

-- A bone, w long, lying flat, centred on cx, cy.
local function bone(c, cx, cy, w, col)
    local r = w * 0.16
    c:rect(floor(cx - w / 2 + r), floor(cy - r * 0.8), max(1, floor(w - 2 * r)), max(1, floor(r * 1.6)), col)
    for _, sx in ipairs({ -1, 1 }) do
        c:disc(cx + sx * (w / 2 - r), cy - r * 0.75, r, col)
        c:disc(cx + sx * (w / 2 - r), cy + r * 0.75, r, col)
    end
end

-- A paw print.
local function paw(c, cx, cy, r, col)
    c:disc(cx, cy + r * 0.25, r * 0.55, col)
    for k = -1, 1 do c:disc(cx + k * r * 0.48, cy - r * 0.45 + abs(k) * r * 0.15, r * 0.24, col) end
end

local D = {}

-- ─── the rings: a big paw print on a bone ───────────────────────────────────
-- One paw print instead of three rings: its big pad fills from the bottom
-- with the day's pages, a toe fills for every quarter of the minutes, and
-- the bone it stands on fills from left to right with the streak.
-- Reading Log draws a set of rings outer first at one centre: the first call
-- draws the pad (and works out where everything goes), the next two the toes
-- and the bone. A ring on its own elsewhere is drawn the usual way.

-- An ellipse (half widths rx, ry) filled from the bottom up to frac.
local function ellipseFill(c, cx, cy, rx, ry, frac, col)
    frac = max(0, min(1, frac or 0))
    if frac <= 0 or rx < 0.5 or ry < 0.5 then return end
    fillRows(c, cx, cy + ry - 2 * ry * frac, cy + ry, function(yy)
        local dy = (yy - cy) / ry
        return rx * sqrt(max(0, 1 - dy * dy))
    end, col)
end

-- A bone lying flat, w long and h tall, centred on cx, cy, filled from the
-- left up to frac, column by column (its bar, and a knob top and bottom at
-- each end).
local function boneFill(c, cx, cy, w, h, frac, col)
    frac = max(0, min(1, frac or 0))
    if frac <= 0 then return end
    local kr = h * 0.26                 -- each knob (two at each end, just touching)
    local r = kr                        -- (the bar runs between the knobs' middles)
    local bar = h * 0.17
    local x0 = cx - w / 2
    local ky = h * 0.5 - kr
    local knobs = { { x0 + kr, cy - ky }, { x0 + kr, cy + ky }, { x0 + w - kr, cy - ky }, { x0 + w - kr, cy + ky } }
    local step = max(1, floor(w / 140))
    local xx = floor(x0)
    local x_end = x0 + w * frac
    while xx < x_end do
        local mx = xx + step / 2
        local top, bot
        if mx > x0 + r and mx < x0 + w - r then top, bot = cy - bar, cy + bar end
        for _, k in ipairs(knobs) do
            local dx = mx - k[1]
            if abs(dx) < kr then
                local hh = sqrt(kr * kr - dx * dx)
                top = top and min(top, k[2] - hh) or (k[2] - hh)
                bot = bot and max(bot, k[2] + hh) or (k[2] + hh)
            end
        end
        if top then c:rect(xx, floor(top), step, max(1, floor(bot - top + 0.5)), col) end
        xx = xx + step
    end
end

local paws

function D.ring(c, cx, cy, R, t, frac, track, fill, tone, which)
    frac = max(0, frac or 0)
    local faint = mix(FUR_L, tone.bg, tone.dark and 0.55 or 0.7)
    local edge = tone.dark and mix(FUR_L, tone.bg, 0.25) or FUR_D
    local lw = max(1.5, R * 0.03)
    if which == 1 then
        -- where everything goes, inside the ring's circle
        local k = { c = c, cx = cx, cy = cy, R = R }
        k.px, k.py = cx, cy + R * 0.08                 -- the big pad
        k.prx, k.pry = R * 0.42, R * 0.32
        k.toe_r = R * 0.15
        k.toes = {}
        for i, a in ipairs({ -2.35, -1.85, -1.29, -0.79 }) do
            local d = R * 0.6
            k.toes[i] = { k.px + d * cos(a), k.py - R * 0.05 + d * sin(a) * 0.95 }
        end
        k.bx, k.by, k.bw, k.bh = cx, cy + R * 0.7, R * 1.45, R * 0.36
        paws = k
        -- the pad: an edge, the faint pad, the pages so far
        ellipseFill(c, k.px, k.py, k.prx + lw, k.pry + lw, 1, edge)
        ellipseFill(c, k.px, k.py, k.prx, k.pry, 1, faint)
        ellipseFill(c, k.px, k.py, k.prx, k.pry, min(1, frac), FUR)
        -- the toes, faint until the minutes come in (the second ring)
        for _, toe in ipairs(k.toes) do
            ellipseFill(c, toe[1], toe[2], k.toe_r * 0.82 + lw, k.toe_r + lw, 1, edge)
            ellipseFill(c, toe[1], toe[2], k.toe_r * 0.82, k.toe_r, 1, faint)
        end
        -- the bone, faint until the streak comes in (the third)
        boneFill(c, k.bx, k.by, k.bw + 2 * lw, k.bh + 2 * lw, 1, edge)
        boneFill(c, k.bx, k.by, k.bw, k.bh, 1, mix(BUN, tone.bg, 0.72))
        return true
    end
    if not (paws and paws.c == c and paws.cx == cx and paws.cy == cy) then return false end
    local k = paws
    local f = min(1, frac)
    if which == 2 then
        -- minutes: a toe for every quarter, the next one filling
        for i, toe in ipairs(k.toes) do
            local part = max(0, min(1, f * 4 - (i - 1)))
            ellipseFill(c, toe[1], toe[2], k.toe_r * 0.82, k.toe_r, part, FUR)
        end
    else
        -- the streak: the bone (a biscuit-coloured chew) fills from the left
        boneFill(c, k.bx, k.by, k.bw, k.bh, f, BUN)
        paws = nil
    end
    return true
end

-- ─── a day: a little paw print ──────────────────────────────────────────────
-- Like the rings' big paw: its pad fills from the bottom with the day's
-- pages and a toe fills for every quarter of the day's minutes. Days to
-- come are faint.

function D.day(c, cx, cy, d, fp, fm, tone, o)
    local u = d * 0.36                                  -- the paw's size
    local px, py = cx, cy + u * 0.32                    -- its pad
    local prx, pry = u * 0.62, u * 0.48
    local tr = u * 0.23
    local toes = {}
    for i, a in ipairs({ -2.4, -1.88, -1.26, -0.74 }) do
        toes[i] = { px + u * 0.86 * cos(a), py - u * 0.08 + u * 0.86 * sin(a) }
    end
    local faint = mix(FUR_L, tone.bg, o.future and 0.8 or 0.62)
    local edge = (not o.small and d >= 28) and max(1, d * 0.025) or 0
    if edge > 0 and not o.future then
        local ec = tone.dark and mix(FUR_L, tone.bg, 0.3) or FUR_D
        ellipseFill(c, px, py, prx + edge, pry + edge, 1, ec)
        for _, t in ipairs(toes) do ellipseFill(c, t[1], t[2], tr * 0.85 + edge, tr + edge, 1, ec) end
    end
    ellipseFill(c, px, py, prx, pry, 1, faint)
    for _, t in ipairs(toes) do ellipseFill(c, t[1], t[2], tr * 0.85, tr, 1, faint) end
    if not o.future then
        ellipseFill(c, px, py, prx, pry, min(1, fp or 0), FUR)
        local f = min(1, fm or 0)
        for i, t in ipairs(toes) do
            ellipseFill(c, t[1], t[2], tr * 0.85, tr, max(0, min(1, f * 4 - (i - 1))), FUR)
        end
    end
    if o.today then
        c:rect(floor(cx - u * 0.8), floor(cy + d * 0.46), max(2, floor(1.6 * u)), max(2, floor(d * 0.05)), RED_D)
    end
    return true
end

-- ─── the year goal: a bowl of kibble ────────────────────────────────────────
-- A piece of kibble for every book (as many as fit; past 40 each stands for
-- several), heaped in a dog bowl. A read book's piece is brown; the rest are
-- faint. A bone goes on top once the goal is met.

function D.goal(c, x, y, w, h, done, target, tone)
    local n = (target and target > 0) and min(target, 40) or 12
    local per = (target and target > 0) and target / n or 1
    local lit = (target and target > 0) and floor(min(done or 0, target) / per + 1e-6) or 0
    local W = min(w * 0.94, h * 1.4)
    local Hb = W * 0.28
    local cx, base = x + w / 2, y + h * 0.94
    local rim = base - Hb
    -- the heap: rows of kibble in a dome over the rim
    local Hh = W * 0.36
    local kr
    local rows
    for try = 1, 30 do
        kr = W * (0.075 - try * 0.0018)
        rows = {}
        local total, j = 0, 0
        while true do
            local yy = rim - kr * (0.9 + j * 1.75)
            local k = (rim - yy) / Hh
            if k > 1 then break end
            local half = W * 0.44 * sqrt(max(0, 1 - k * k))
            local m = max(0, floor(2 * half / (kr * 2.1)))
            if m == 0 then break end
            rows[#rows + 1] = { y = yy, m = m, half = half }
            total = total + m
            j = j + 1
        end
        if total >= n then break end
    end
    local idx = 0
    for _, row in ipairs(rows) do
        local stepx = 2 * row.half / row.m
        for i = 0, row.m - 1 do
            idx = idx + 1
            if idx > n then break end
            local kx = cx - row.half + stepx * (i + 0.5)
            local on = idx <= lit
            c:disc(kx, row.y, kr, on and FUR or mix(FUR_L, tone.bg, 0.65))
            if on and kr >= 3 then c:disc(kx - kr * 0.3, row.y - kr * 0.3, kr * 0.28, FUR_L) end
        end
        if idx >= n then break end
    end
    -- the bowl, over the heap's foot
    fillRows(c, cx, rim, base, function(yy)
        local k = (yy - rim) / Hb
        return W / 2 * (1 - 0.18 * k)
    end, RED)
    c:rrect(floor(cx - W / 2 - W * 0.02), floor(rim - Hb * 0.12), floor(W * 1.04), max(2, floor(Hb * 0.24)), Hb * 0.12, RED_D)
    bone(c, cx, rim + Hb * 0.55, W * 0.26, BONE)
    if target and target > 0 and (done or 0) >= target then
        bone(c, cx, rim - Hh - kr, W * 0.36, BONE)
    end
    return true
end

-- ─── progress bars: a sausage dog that stretches ─────────────────────────────
-- The further through the book, the longer the dog.

function D.bar(c, x, y, w, h, frac, tone, fill)
    frac = max(0, min(1, frac or 0))
    local bt = max(5, h * 1.15)
    local ground = y + h / 2 + bt * 0.55
    local gh = max(2, floor(h * 0.3))
    c:rrect(x, floor(ground - gh / 2), w, gh, gh / 2, mix(FUR_L, tone.bg, 0.6))
    local hr = bt * 0.72
    local x1 = x + max(bt * 1.6, (w - hr * 1.6) * frac)
    local x0 = x + bt * 0.3
    if frac > 0 then
        c:rrect(x, floor(ground - gh / 2), max(gh, floor(x1 - x)), gh, gh / 2, fill or RED, tone.track)
    end
    local top = ground - bt * 0.35 - bt
    -- legs, then the long body over them, the tail, the head
    local leg_h = bt * 0.4
    for _, lx in ipairs({ x0 + bt * 0.35, x0 + bt * 0.8, x1 - bt * 0.9, x1 - bt * 0.45 }) do
        c:rect(floor(lx), floor(top + bt * 0.8), max(2, floor(bt * 0.24)), floor(leg_h), FUR_D)
    end
    c:rrect(floor(x0), floor(top), max(floor(bt), floor(x1 - x0)), floor(bt), bt / 2, FUR)
    c:rect(floor(x0 + bt * 0.5), floor(top + bt * 0.62), max(1, floor(x1 - x0 - bt)), max(1, floor(bt * 0.2)), FUR_L)
    c:polyline({ x0 + bt * 0.15, top + bt * 0.35, x0 - bt * 0.35, top - bt * 0.15 }, max(2, bt * 0.22), FUR)
    head(c, x1, top - bt * 0.05, hr, 1, 0, 0, -1)
    return true
end

-- ─── the challenge: a hot dog ───────────────────────────────────────────────
-- A bun with a sausage that cooks from end to end over the first half of
-- the month's goal, then a line of ketchup and a line of mustard.

local function zig(c, x0, x1, y, amp, frac, lw, col, phase)
    if frac <= 0 then return end
    local n = 14
    local pts = {}
    local last = floor(n * frac + 0.5)
    for i = 0, last do
        pts[#pts + 1] = x0 + (x1 - x0) * i / n
        pts[#pts + 1] = y + amp * (((i + phase) % 2 == 0) and -1 or 1)
    end
    if #pts >= 4 then c:polyline(pts, lw, col) end
end

function D.challenge(c, cx, cy, R, frac, tone)
    frac = max(0, min(1, frac or 0))
    local W = R * 1.9
    local bh = R * 0.55
    local by = cy + R * 0.05
    -- the bun
    c:rrect(floor(cx - W / 2), floor(by), floor(W), floor(bh), bh / 2, BUN)
    c:rrect(floor(cx - W / 2 + bh * 0.2), floor(by + bh * 0.62), floor(W - bh * 0.4), max(2, floor(bh * 0.18)), bh * 0.09, BUN_D)
    -- the sausage: raw, then cooked from the left
    local sh = R * 0.36
    local sx, sw, sy = cx - W * 0.56, W * 1.12, by - sh * 0.55
    c:rrect(floor(sx), floor(sy), floor(sw), floor(sh), sh / 2, mix(PINK, tone.bg, 0.35))
    local cooked = min(1, frac / 0.5)
    if cooked > 0 then
        c:rrect(floor(sx), floor(sy), max(floor(sh), floor(sw * cooked)), floor(sh), sh / 2, SAUSAGE)
        c:rect(floor(sx + sh * 0.4), floor(sy + sh * 0.2), max(1, floor(sw * cooked - sh * 0.8)), max(1, floor(sh * 0.14)), mix(SAUSAGE, WHITE, 0.3))
    end
    local lw = max(2, R * 0.06)
    zig(c, sx + sh * 0.4, sx + sw - sh * 0.4, sy + sh * 0.35, sh * 0.16, min(1, max(0, (frac - 0.5) / 0.25)), lw, RED, 0)
    zig(c, sx + sh * 0.4, sx + sw - sh * 0.4, sy + sh * 0.6, sh * 0.16, min(1, max(0, (frac - 0.75) / 0.25)), lw, MUSTARD, 1)
    -- the bun's top half sits behind; a sesame of little steam lines when done
    if frac >= 1 then
        for k = -1, 1 do
            local x1 = cx + k * R * 0.4
            c:polyline({ x1, sy - R * 0.12, x1 - R * 0.05, sy - R * 0.25, x1, sy - R * 0.38 }, max(1, R * 0.03), mix(tone.fg, tone.bg, 0.5))
        end
    end
    return true
end

-- ─── Reading trends: tiles with a paw print ─────────────────────────────────

function D.trendTile(c, x, y, w, h, tone, i)
    local base = (i % 2 == 1) and mix(tone.bg, FUR_L, 0.22) or mix(tone.bg, BONE_D, 0.35)
    c:rrect(x, y, w, h, min(h * 0.18, 14), base)
    local r = max(4, min(h * 0.16, w * 0.06))
    paw(c, x + w - r * 1.5, y + r * 1.5, r, mix(FUR, base, 0.55))
    return true
end

-- ─── the calendar: paw-print days, dogs peeking over the covers ─────────────

function D.calendarEmpty(c, x, y, w, h, n, tone, o)
    local s = min(w, h) * 0.86
    if s < 12 then return false end
    local cx, cy = x + w / 2, y + h / 2
    local fade = o.future and 0.6 or 0
    c:rrect(floor(cx - s / 2), floor(cy - s / 2), floor(s), floor(s), s * 0.2,
        o.today and RED or mix(mix(FUR_L, tone.bg, 0.5), tone.bg, fade))
    local e = max(2, s * 0.06)
    c:rrect(floor(cx - s / 2 + e), floor(cy - s / 2 + e), floor(s - 2 * e), floor(s - 2 * e), s * 0.16, mix(BONE, tone.bg, 0.3 + fade * 0.5))
    paw(c, cx + s * 0.27, cy - s * 0.27, s * 0.1, mix(FUR_L, tone.bg, 0.3 + fade * 0.5))
    local size = o.num_px or max(10, floor(s * 0.36))
    c:label(tostring(n), size, cx, cy, { bold = true, anchor = "c", valign = "mid",
        color = o.future and mix(tone.fg, tone.bg, 0.5) or tone.fg })
    return true
end

-- Two front paws over the top of a cover.
local function paws(c, x, y, w)
    local r = max(2, w * 0.09)
    for _, t in ipairs({ 0.3, 0.7 }) do
        local px = x + w * t
        fillRows(c, px, y - r * 0.9, y + r * 0.8, function(yy)
            if yy < y - r * 0.2 then return r * 0.9 * sqrt(max(0, 1 - ((yy - (y - r * 0.2)) / (r * 0.7)) ^ 2)) end
            return r * 0.9
        end, FUR)
        for k = -1, 1 do c:rect(floor(px + k * r * 0.45), floor(y + r * 0.35), 1, max(1, floor(r * 0.45)), FUR_D) end
    end
end

function D.calendarCover(c, x, y, w, h, tone, o)
    paws(c, x, y, w)
    return true
end

function D.bookCover(c, x, y, w, h, tone, o)
    -- a dog peeking over the top, its paws on the book
    local hr = w * 0.17
    local hx, hy = x + w * 0.5, y - hr * 0.35
    c:disc(hx - hr * 0.95, hy + hr * 0.1, hr * 0.5, FUR_D)
    c:disc(hx + hr * 0.95, hy + hr * 0.1, hr * 0.5, FUR_D)
    c:disc(hx, hy, hr, FUR)
    c:disc(hx, hy + hr * 0.45, hr * 0.5, FUR_L)
    c:disc(hx, hy + hr * 0.25, max(1, hr * 0.18), INK)
    c:disc(hx - hr * 0.38, hy - hr * 0.2, max(1, hr * 0.12), INK)
    c:disc(hx + hr * 0.38, hy - hr * 0.2, max(1, hr * 0.12), INK)
    paws(c, x, y, w)
    return true
end

-- ─── the Dashboard's tab bar: a very long dachshund ─────────────────────────
-- A dachshund lies along the bottom of the tabs, nose at the right; the open
-- tab hangs on a bone-shaped tag.
function D.tabBar(c, x, y, w, h, cells, tone)
    local bt = max(5, h * 0.22)
    local top = y + h - bt * 1.5
    local x0, x1 = x + bt * 1.2, x + w - bt * 1.6
    for k = 0, 5 do
        local lx = x0 + bt * 0.6 + (x1 - x0 - bt * 1.6) * k / 5
        c:rect(floor(lx), floor(top + bt * 0.7), max(2, floor(bt * 0.28)), floor(bt * 0.45), FUR_D)
    end
    c:rrect(floor(x0), floor(top), floor(x1 - x0), floor(bt), bt / 2, FUR)
    c:polyline({ x0 + bt * 0.2, top + bt * 0.3, x0 - bt * 0.6, top - bt * 0.3 }, max(2, bt * 0.25), FUR)
    head(c, x1, top - bt * 0.05, bt * 0.75, 1, 0, 0, -1)
    for _, cell in ipairs(cells) do
        if cell.active then
            local cx = cell.x + cell.w / 2
            local ph = h * 0.46
            local pw = min(cell.w - ph * 0.6, cell.label_w + h * 0.5)
            local py = y + h * 0.42 - ph / 2
            local r = ph * 0.3
            c:rect(floor(cx - pw / 2), floor(py), floor(pw), floor(ph), BONE)
            for _, sx in ipairs({ -1, 1 }) do
                c:disc(cx + sx * pw / 2, py + r * 0.9, r, BONE)
                c:disc(cx + sx * pw / 2, py + ph - r * 0.9, r, BONE)
            end
            cell.color = FUR_D
            cell.dy = -h * 0.08
        end
    end
    return true
end

return D
