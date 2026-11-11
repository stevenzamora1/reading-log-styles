-- Ocean: seafoam cards in sea-glass frames on a deep teal page, sea blue and
-- coral; waves for the rings, bubbles for the days, a treasure chest of
-- pearls for the year goal and a sailboat crossing to an island for the
-- challenge.
return {
    api = 1,
    id = "ocean",
    version = "1.3",
    name = "Ocean",
    names = { es = "Océano", fr = "Océan", pt_br = "Oceano", pt = "Oceano", it = "Oceano", uk = "Океан" },
    description = "A lighthouse that fills up and shines once your pages and minutes are done for the rings, small lighthouses for the days, a fish swimming along the bars, a treasure chest of pearls for the year goal, portholes for the calendar and a sailboat crossing to an island for the challenge.",
    descriptions = {
        es = "Un faro que se llena y se enciende al cumplir páginas y minutos para los anillos, faros pequeños para los días, un pez que nada por las barras, un cofre de perlas para la meta del año y un velero que cruza hasta una isla para el reto.",
        fr = "Un phare qui se remplit et s’allume une fois tes pages et tes minutes faites pour les anneaux, de petits phares pour les jours, un poisson qui nage le long des barres, un coffre de perles pour l’objectif de l’année et un voilier qui rejoint une île pour le défi.",
        pt_br = "Um farol que se enche e acende quando as páginas e os minutos são cumpridos para os anéis, farolzinhos para os dias, um peixe nadando pelas barras, um baú de pérolas para a meta do ano e um veleiro que cruza até uma ilha para o desafio.",
        it = "Un faro che si riempie e si accende quando pagine e minuti sono fatti per gli anelli, piccoli fari per i giorni, un pesce che nuota lungo le barre, uno scrigno di perle per l’obiettivo dell’anno e una barca a vela che raggiunge un’isola per la sfida.",
    },
    author = "Steven",
    theme = {
        surface = { 238, 248, 246 }, tint = { 221, 240, 240 }, fg = { 22, 56, 68 }, border = { 90, 166, 180 },
        page = { 17, 59, 79 }, page_fg = { 238, 248, 246 },
        serif = true,
        accent = { label = "Sea", deep = { 17, 136, 153 }, bright = { 119, 204, 221 } },
        accent2 = { label = "Coral", deep = { 204, 85, 68 }, bright = { 238, 136, 119 } },
    },
    draw = "draw.lua",
}
