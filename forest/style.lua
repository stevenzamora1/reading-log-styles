-- Forest: soft cream cards in moss frames on a mossy green page, moss and
-- oak; a leafy wreath and an acorn twig for the rings, leaves for the days,
-- a woodpile that gains a log per book for the year goal and an oak growing for the challenge.
return {
    api = 1,
    id = "forest",
    version = "1.1",
    name = "Forest",
    names = { es = "Bosque", fr = "Forêt", pt_br = "Floresta", pt = "Floresta", it = "Bosco", uk = "Ліс" },
    description = "A pine tree whose tiers fill for the rings, small pines for the days, a snail on a mossy branch for the bars, a woodpile that gains a log per book for the year goal, trees for the charts, wooden signs for the trends and an acorn that grows into an oak for the challenge.",
    descriptions = {
        es = "Un pino cuyos pisos se llenan para los anillos, pinos pequeños para los días, un caracol sobre una rama para las barras, una pila de leña con un tronco por libro para la meta del año y una bellota que se convierte en roble para el reto.",
        fr = "Un sapin dont les étages se remplissent pour les anneaux, de petits sapins pour les jours, un escargot sur une branche pour les barres, une pile de bûches qui gagne une bûche par livre pour l’objectif de l’année et un gland qui devient chêne pour le défi.",
        pt_br = "Um pinheiro cujos andares se enchem para os anéis, pinheirinhos para os dias, um caracol num galho para as barras, uma pilha de lenha com um tronco por livro para a meta do ano e uma bolota que vira carvalho para o desafio.",
        it = "Un pino i cui piani si riempiono per gli anelli, piccoli pini per i giorni, una lumaca su un ramo per le barre, una catasta di legna con un ceppo per libro per l’obiettivo dell’anno e una ghianda che diventa quercia per la sfida.",
    },
    author = "Steven",
    looks = {
        quote_look = "paper",
    },
    theme = {
        surface = { 238, 238, 221 }, tint = { 221, 238, 204 }, fg = { 51, 51, 34 }, border = { 119, 136, 85 },
        page = { 68, 85, 51 }, page_fg = { 238, 238, 221 },
        serif = true,
        accent = { label = "Moss", deep = { 68, 119, 51 }, bright = { 153, 204, 119 } },
        accent2 = { label = "Oak", deep = { 136, 85, 34 }, bright = { 221, 170, 119 } },
    },
    draw = "draw.lua",
}
