-- Christmas: cream cards in gold frames on a deep green page, holly red and
-- pine green, a wreath for the rings, candy canes for the bars, and a
-- snowflake that grows its arms for the Monthly challenge.
return {
    api = 1,
    id = "christmas",
    version = "1.1",
    name = "Christmas",
    names = { es = "Navidad", fr = "Noël", pt_br = "Natal", pt = "Natal", it = "Natale" },
    description = "A wreath and candy cane for the rings, baubles for the days, a tree for the year goal, presents for the bars, lights for the lines, an advent calendar and a present that opens to a book for the challenge.",
    descriptions = {
        es = "Una corona para los anillos, bastones de caramelo para las barras y un regalo que se abre en un libro para el reto, sobre una página verde oscuro.",
        fr = "Une couronne pour les anneaux, des sucres d’orge pour les barres et un cadeau qui s’ouvre sur un livre pour le défi, sur une page vert sapin.",
        pt_br = "Uma guirlanda para os anéis, bengalas de doce para as barras e um presente que se abre num livro para o desafio, sobre uma página verde-escura.",
        it = "Una ghirlanda per gli anelli, bastoncini di zucchero per le barre e un regalo che si apre su un libro per la sfida, su una pagina verde scuro.",
    },
    author = "Steven",
    theme = {
        surface = { 255, 250, 240 }, tint = { 243, 233, 214 }, fg = { 42, 20, 16 }, border = { 184, 134, 46 },
        page = { 15, 43, 29 }, page_fg = { 255, 250, 240 },
        accent = { label = "Holly red", deep = { 200, 16, 46 }, bright = { 255, 102, 102 } },
        accent2 = { label = "Pine green", deep = { 31, 122, 63 }, bright = { 102, 204, 119 } },
    },
    draw = "draw.lua",
}
