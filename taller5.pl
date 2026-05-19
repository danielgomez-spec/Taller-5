
% Personajes 
personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).
personaje('Hercules', 6, 110).
personaje('Sonya', 4, 90).
personaje('jax', 2, 75).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragón', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

% Inventarios Corregidos 
inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).
inventario('Hercules', [hacha, escudo]).
inventario('Sonya', [daga, pocion]).
inventario('jax', [garrote]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

% Tres Enemigos 
enemigo(caballero_oscuro, 40).
enemigo(mago, 90).
enemigo(rey_esqueleto, 250).

% Fuerza de Ataque de las Armas 
fuerza_arma(espada, 30).
fuerza_arma(arco, 25).
fuerza_arma(varita, 35).
fuerza_arma(hacha, 45).
fuerza_arma(daga, 15).
fuerza_arma(garrote, 10).
fuerza_arma(escudo, 0).  
fuerza_arma(pocion, 0).

% REGLAS DE COMBATE 

%  Validar si un jugador tiene un arma y obtiene su daño
obtener_danio_personaje(Personaje, Arma, Danio) :-
    inventario(Personaje, Inventario),
    member(Arma, Inventario),
    fuerza_arma(Arma, Danio).

% Ataque de 1 jugador
ejecutar_ataque_individual(Personaje, Arma, Enemigo, Mensaje) :-
    enemigo(Enemigo, VidaEnemigo),
    obtener_danio_personaje(Personaje, Arma, Danio),
    ( Danio >= VidaEnemigo ->
        Resultado = " y logra derrotarlo solo."
    ; 
        Resultado = " pero NO es suficiente para derrotarlo solo."
    ),
    atomic_list_concat([Personaje, " ataca al ", Enemigo, " (Vida: ", VidaEnemigo, ") con ", Arma, " haciendo ", Danio, " de danio", Resultado], Mensaje).

% Ataque de varios jugadores
procesar_ataque_grupo([], 0, []).
procesar_ataque_grupo([P|Ps], DanioTotal, [DetalleP|DetallesResto]) :-
    obtener_danio_personaje(P, Arma, DanioP),
    atomic_list_concat([P, " con ", Arma, " (", DanioP, ")"], DetalleP),
    procesar_ataque_grupo(Ps, DanioResto, DetallesResto),
    DanioTotal is DanioP + DanioResto.

ejecutar_ataque_grupal(ListaPersonajes, Enemigo, Mensaje) :-
    enemigo(Enemigo, VidaEnemigo),
    procesar_ataque_grupo(ListaPersonajes, DanioTotal, ListaDetalles),
    formatear_nombres_rec(ListaDetalles, DetalleGrupoFormateado),
    ( DanioTotal >= VidaEnemigo ->
        Resultado = " y ¡LOGRAN derrotarlo en equipo!"
    ; 
        Resultado = " y NO logran derrotarlo."
    ),
    atomic_list_concat(['El grupo compuesto por [', DetalleGrupoFormateado, '] atacan al ', Enemigo, ' (Vida: ', VidaEnemigo, ') sumando un danio total de ', DanioTotal, Resultado], Mensaje).


% REGLAS ARITMÉTICAS Y RECURSIVAS 

puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.

xp_acumulada(0, 0).
xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,                
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).   

tiene_requerido(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).      

mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.              

es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.           

fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

tiempo(presente). tiempo(pasado). tiempo(futuro).
persona(primera). persona(segunda). persona(tercera).
numero(singular). numero(plural).

ser(presente, primera, singular, "soy").
ser(presente, segunda, singular, "eres").
ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "será").
ser(presente, primera, plural, "somos").   
ser(presente, segunda, plural, "son").    
ser(presente, tercera, plural, "son").     

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo), persona(Persona), numero(Numero),
    (  Verbo = "ser" ->
       ser(Tiempo, Persona, Numero, R),
       Conjugacion = R
    ;  Conjugacion = Verbo ). 

todos_pueden_aceptar([], _).
todos_pueden_aceptar([P|Ps], MisionID) :-
    puede_aceptar(P, MisionID),
    todos_pueden_aceptar(Ps, MisionID).

formatear_nombres_rec([P], P).
formatear_nombres_rec([P1, P2], Resultado) :- 
    atomic_list_concat([P1, " y ", P2], Resultado).
formatear_nombres_rec([P|Ps], Resultado) :-
    Ps = [_, _|_], 
    formatear_nombres_rec(Ps, Resto),
    atomic_list_concat([P, ", ", Resto], Resultado).

generar_reporte_grupal(ListaPersonajes, MisionID, Persona, Mensaje) :-
    todos_pueden_aceptar(ListaPersonajes, MisionID),
    mision(MisionID, NombreMision, _, XP),
    length(ListaPersonajes, N),
    ( N == 1 -> (Num = singular, Adj = "capaz", P_Actual = tercera) ; (Num = plural, Adj = "capaces", P_Actual = Persona) ),
    conjugar_accion("ser", presente, P_Actual, Num, FormaVerbal),
    formatear_nombres_rec(ListaPersonajes, Sujetos),
    atomic_list_concat([Sujetos, ' ', FormaVerbal, ' ', Adj, " de completar ", NombreMision, " por ", XP, " XP"], Mensaje).