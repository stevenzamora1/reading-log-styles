-- Dachshund: cream cards in warm brown frames on a toasty brown page,
-- ketchup red and mustard; a paw print on a bone for the rings, little dog
-- paw prints for the days, a bowl of kibble for the year goal, a sausage dog that
-- stretches along the bars and a hot dog for the challenge.
return {
    api = 1,
    id = "dachshund",
    version = "1.0",
    name = "Dachshund",
    names = { es = "Salchicha", fr = "Teckel", pt_br = "Salsicha", pt = "Teckel", it = "Bassotto", uk = "Такса" },
    description = "A big paw print on a bone for the rings (pages fill the pad, minutes fill a toe each quarter, the streak fills the bone), little dog paw prints for the days, a bowl of kibble for the year goal, a sausage dog that gets longer along the bars, a hot dog for the challenge, paw-print days on the calendar and a dog peeking over the covers.",
    descriptions = {
        es = "Una gran huella sobre un hueso para los anillos (las páginas llenan la almohadilla, los minutos un dedo por cada cuarto, la racha el hueso), huellitas para los días, un plato de croquetas para la meta del año, un perro salchicha que se alarga en las barras, un hot dog para el reto, huellas en el calendario y un perro asomándose sobre las portadas.",
        fr = "Une grande empreinte sur un os pour les anneaux (les pages remplissent le coussinet, les minutes un doigt par quart, la série l’os), de petites empreintes pour les jours, une gamelle de croquettes pour l’objectif de l’année, un teckel qui s’allonge le long des barres, un hot-dog pour le défi, des empreintes sur le calendrier et un chien qui dépasse des couvertures.",
        pt_br = "Uma patona sobre um osso para os anéis (as páginas enchem a almofada, os minutos um dedinho a cada quarto, a sequência o osso), patinhas para os dias, uma tigela de ração para a meta do ano, um salsicha que cresce nas barras, um cachorro-quente para o desafio, patinhas no calendário e um cachorro espiando por cima das capas.",
        it = "Una grande impronta su un osso per gli anelli (le pagine riempiono il cuscinetto, i minuti un dito per ogni quarto, la serie l’osso), piccole impronte per i giorni, una ciotola di crocchette per l’obiettivo dell’anno, un bassotto che si allunga lungo le barre, un hot dog per la sfida, impronte sul calendario e un cane che sbircia dalle copertine.",
    },
    author = "Steven",
    theme = {
        surface = { 255, 248, 238 }, tint = { 246, 232, 212 }, fg = { 62, 36, 20 }, border = { 200, 146, 96 },
        page = { 122, 74, 42 }, page_fg = { 255, 244, 228 },
        accent = { label = "Ketchup red", deep = { 196, 54, 44 }, bright = { 240, 112, 96 } },
        accent2 = { label = "Mustard", deep = { 176, 124, 14 }, bright = { 244, 200, 72 } },
    },
    draw = "draw.lua",
}
