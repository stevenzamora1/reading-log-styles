-- Gothic: near-black cards in iron frames on a dark plum page, crimson and
-- lilac; a rose vine and an ivy vine for the rings, roses for the days, a
-- barbed wire for the bars, a vial in an arch for the year goal and a spider's web for the challenge.
return {
    api = 1,
    id = "gothic",
    version = "1.6",
    name = "Gothic",
    names = { es = "Gótico", fr = "Gothique", pt_br = "Gótico", pt = "Gótico", it = "Gotico", uk = "Готика" },
    description = "A rose that fills in with your pages inside a thorny vine that grows with your minutes for the rings, roses that gain a ring of thorns on days you meet both goals, barbed wire for the bars, a vial in an arch for the year goal, pointed arches for the charts and a spider spinning its web for the challenge.",
    descriptions = {
        es = "Una rosa que se llena con tus páginas dentro de una enredadera de espinas que crece con tus minutos para los anillos, rosas que ganan un anillo de espinas los días que cumples ambas metas, alambre de púas para las barras, un vial bajo un arco para la meta del año y una araña que teje su tela para el reto.",
        fr = "Une rose qui se remplit avec tes pages dans une ronce qui pousse avec tes minutes pour les anneaux, des roses qui gagnent une couronne d’épines les jours où tu atteins les deux objectifs, du fil barbelé pour les barres, une fiole sous une arche pour l’objectif de l’année et une araignée qui tisse sa toile pour le défi.",
        pt_br = "Uma rosa que se enche com suas páginas dentro de um ramo de espinhos que cresce com seus minutos para os anéis, rosas que ganham um anel de espinhos nos dias em que você cumpre as duas metas, arame farpado para as barras, um frasco num arco para a meta do ano e uma aranha tecendo sua teia para o desafio.",
        it = "Una rosa che si riempie con le tue pagine dentro un rovo di spine che cresce con i tuoi minuti per gli anelli, rose che ottengono un anello di spine nei giorni in cui raggiungi entrambi gli obiettivi, filo spinato per le barre, una fiala sotto un arco per l’obiettivo dell’anno e un ragno che tesse la tela per la sfida.",
    },
    author = "Steven",
    looks = {
        quote_look = "manuscript",
        streak_flame_look = "candle",
        device_look = "candle",
    },
    theme = {
        surface = { 17, 0, 17 }, tint = { 34, 17, 34 }, fg = { 238, 221, 238 }, border = { 136, 119, 153 },
        page = { 34, 17, 34 }, page_fg = { 238, 221, 238 },
        serif = true,
        accent = { label = "Crimson", deep = { 170, 17, 51 }, bright = { 255, 68, 102 } },
        accent2 = { label = "Lilac", deep = { 119, 85, 170 }, bright = { 187, 153, 238 } },
    },
    draw = "draw.lua",
}
