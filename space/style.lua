-- Space: midnight-blue cards on a near-black page, nebula violet and comet
-- cyan; comets for the rings, the moon waxing for the days, a constellation
-- for the year goal and a spiral galaxy whose stars light up for the challenge.
return {
    api = 1,
    id = "space",
    version = "1.0",
    name = "Space",
    names = { es = "Espacio", fr = "Espace", pt_br = "Espaço", pt = "Espaço", it = "Spazio", uk = "Космос" },
    description = "The moon waxing in the middle with a comet flying round it for the rings, the moon waxing to full for the days, a rocket along the bars, a constellation that gains a star per book for the year goal, little planets for the calendar and a spiral galaxy whose stars light up for the challenge.",
    descriptions = {
        es = "La luna creciendo en el centro con un cometa girando a su alrededor para los anillos, la luna que crece hasta llena para los días, un cohete por las barras, una constelación con una estrella por libro para la meta del año y una galaxia espiral cuyas estrellas se encienden para el reto.",
        fr = "La lune qui croît au centre avec une comète qui tourne autour pour les anneaux, la lune qui croît jusqu’à la pleine lune pour les jours, une fusée le long des barres, une constellation qui gagne une étoile par livre pour l’objectif de l’année et une galaxie spirale dont les étoiles s’allument pour le défi.",
        pt_br = "A lua crescendo no centro com um cometa girando ao redor para os anéis, a lua crescendo até cheia para os dias, um foguete pelas barras, uma constelação que ganha uma estrela por livro para a meta do ano e uma galáxia espiral cujas estrelas se acendem para o desafio.",
        it = "La luna che cresce al centro con una cometa che le gira intorno per gli anelli, la luna che cresce fino a piena per i giorni, un razzo lungo le barre, una costellazione che guadagna una stella per libro per l’obiettivo dell’anno e una galassia a spirale le cui stelle si accendono per la sfida.",
    },
    author = "Steven",
    theme = {
        surface = { 20, 26, 61 }, tint = { 34, 40, 85 }, fg = { 232, 236, 255 }, border = { 90, 99, 160 },
        page = { 11, 16, 38 }, page_fg = { 232, 236, 255 },
        serif = true,
        accent = { label = "Nebula", deep = { 119, 85, 204 }, bright = { 170, 136, 255 } },
        accent2 = { label = "Comet", deep = { 34, 153, 187 }, bright = { 102, 212, 238 } },
    },
    draw = "draw.lua",
}
