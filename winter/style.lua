-- Winter: icy white cards in frost-blue frames on a deep night-blue page,
-- ice blue and mitten red; a snowman for the rings, little snowmen for the
-- days, an igloo for the year goal, a penguin sliding along the bars and a
-- snowflake that fills out for the challenge.
return {
    api = 1,
    id = "winter",
    version = "1.1",
    name = "Winter",
    names = { es = "Invierno", fr = "Hiver", pt_br = "Inverno", pt = "Inverno", it = "Inverno", uk = "Зима" },
    description = "A snowman you build for the rings, little snowmen for the days, an igloo that gains an ice block per book for the year goal, a penguin sliding along the bars, frosty tiles for the calendar and the trends, snow and icicles on the covers, and a snowflake that fills out for the challenge.",
    descriptions = {
        es = "Un muñeco de nieve que construyes para los anillos, muñequitos de nieve para los días, un iglú que gana un bloque de hielo por libro para la meta del año, un pingüino deslizándose por las barras, casillas escarchadas para el calendario y las tendencias, nieve y carámbanos en las portadas, y un copo de nieve que se completa para el reto.",
        fr = "Un bonhomme de neige à construire pour les anneaux, de petits bonshommes pour les jours, un igloo qui gagne un bloc de glace par livre pour l’objectif de l’année, un manchot qui glisse le long des barres, des cases givrées pour le calendrier et les tendances, de la neige et des glaçons sur les couvertures, et un flocon qui se dessine pour le défi.",
        pt_br = "Um boneco de neve que você monta para os anéis, bonequinhos de neve para os dias, um iglu que ganha um bloco de gelo por livro para a meta do ano, um pinguim deslizando pelas barras, quadros congelados para o calendário e as tendências, neve e pingentes de gelo nas capas, e um floco de neve que se completa para o desafio.",
        it = "Un pupazzo di neve da costruire per gli anelli, piccoli pupazzi per i giorni, un igloo che guadagna un blocco di ghiaccio per libro per l’obiettivo dell’anno, un pinguino che scivola lungo le barre, caselle ghiacciate per il calendario e le tendenze, neve e ghiaccioli sulle copertine, e un fiocco di neve che si completa per la sfida.",
    },
    author = "Steven",
    theme = {
        surface = { 246, 250, 254 }, tint = { 228, 239, 249 }, fg = { 26, 42, 66 }, border = { 140, 180, 220 },
        page = { 30, 48, 80 }, page_fg = { 236, 244, 252 },
        accent = { label = "Ice blue", deep = { 36, 108, 178 }, bright = { 110, 172, 232 } },
        accent2 = { label = "Mitten red", deep = { 190, 52, 64 }, bright = { 236, 110, 118 } },
    },
    draw = "draw.lua",
}
