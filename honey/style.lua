-- Honey: warm cream cards in amber frames on a dark honey page, honey and
-- lavender; a beehive for the rings, little hives for the days, a honeycomb
-- for the year goal, a bee along the bars and a jar filling for the challenge.
return {
    api = 1,
    id = "honey",
    version = "1.2",
    name = "Honey",
    names = { es = "Miel", fr = "Miel", pt_br = "Mel", pt = "Mel", it = "Miele", uk = "Мед" },
    description = "A beehive that fills with honey for the rings, little hives for the days, a honeycomb for the year goal, a bee flying along the bars, honeycomb cells for the calendar and the trends, and a honey jar for the challenge.",
    descriptions = {
        es = "Una colmena que se llena de miel para los anillos, colmenitas para los días, un panal para la meta del año, una abeja volando por las barras, celdas de panal para el calendario y las tendencias, y un tarro de miel para el reto.",
        fr = "Une ruche qui se remplit de miel pour les anneaux, de petites ruches pour les jours, un rayon de miel pour l’objectif de l’année, une abeille le long des barres, des alvéoles pour le calendrier et les tendances, et un pot de miel pour le défi.",
        pt_br = "Uma colmeia que se enche de mel para os anéis, colmeias pequenas para os dias, um favo para a meta do ano, uma abelha voando pelas barras, alvéolos de favo para o calendário e as tendências, e um pote de mel para o desafio.",
        it = "Un alveare che si riempie di miele per gli anelli, piccoli alveari per i giorni, un favo per l’obiettivo dell’anno, un’ape che vola lungo le barre, celle di favo per il calendario e le tendenze, e un vasetto di miele per la sfida.",
    },
    author = "Steven",
    theme = {
        surface = { 255, 248, 230 }, tint = { 252, 236, 200 }, fg = { 64, 40, 12 }, border = { 214, 160, 60 },
        page = { 110, 70, 20 }, page_fg = { 255, 248, 230 },
        accent = { label = "Honey", deep = { 196, 128, 16 }, bright = { 245, 190, 60 } },
        accent2 = { label = "Lavender", deep = { 122, 92, 176 }, bright = { 184, 156, 232 } },
    },
    draw = "draw.lua",
}
