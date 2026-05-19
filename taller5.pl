% --- HECHOS (Base de Conocimiento) ---
personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragón', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

% --- REGLAS ARITMÉTICAS Y RECURSIVAS ---

% 1. Verificación de nivel (Operador relacional >=)
puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.

% 2. Cálculo recursivo de XP acumulada (Patrón factorial de 2.1)
xp_acumulada(0, 0).
xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,                
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).   

% 3. Verificación de inventario con member/2
tiene_requerido(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).      

% --- REGLAS DE UNIFICACIÓN Y COMPARACIÓN ---

% 1. Detectar personajes del mismo nivel exacto (vs unificación)
mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.              

% 2. Validar balance aritmético estricto
es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.           

% --- PROCESAMIENTO DE LISTAS Y NLP RECURSIVO ---

% 1. Fusionar inventarios de dos personajes usando append/3 (2.3)
fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

% 2. Base de conjugación
tiempo(presente). tiempo(pasado). tiempo(futuro).
persona(primera). persona(segunda). persona(tercera).
numero(singular). numero(plural).

ser(presente, primera, singular, "soy").
ser(presente, segunda, singular, "eres").
ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "será").

% Hechos extendidos para dar soporte a las tres personas del plural:
ser(presente, primera, plural, "somos").   
ser(presente, segunda, plural, "son").    
ser(presente, tercera, plural, "son").     

% 3. Regla de inferencia con estructura condicional (2.3)
conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo), persona(Persona), numero(Numero),
    (  Verbo = "ser" ->
       ser(Tiempo, Persona, Numero, R),
       Conjugacion = R
    ;  Conjugacion = Verbo ). 

% 4. Validación recursiva de nivel aplicable a listas de personajes
todos_pueden_aceptar([], _).
todos_pueden_aceptar([P|Ps], MisionID) :-
    puede_aceptar(P, MisionID),
    todos_pueden_aceptar(Ps, MisionID).

% 5. Formateador recursivo de nombres para listas 
formatear_nombres_rec([P], P).
formatear_nombres_rec([P1, P2], Resultado) :- 
    atomic_list_concat([P1, " y ", P2], Resultado).
formatear_nombres_rec([P|Ps], Resultado) :-
    Ps = [_, _|_], 
    formatear_nombres_rec(Ps, Resto),
    atomic_list_concat([P, ", ", Resto], Resultado).

% 6. Generación de reporte grupal  
generar_reporte_grupal(ListaPersonajes, MisionID, Persona, Mensaje) :-
    todos_pueden_aceptar(ListaPersonajes, MisionID),
    mision(MisionID, NombreMision, _, XP),
    length(ListaPersonajes, N),
    ( N == 1 -> (Num = singular, Adj = "capaz", P_Actual = tercera) ; (Num = plural, Adj = "capaces", P_Actual = Persona) ),
    conjugar_accion("ser", presente, P_Actual, Num, FormaVerbal),
    formatear_nombres_rec(ListaPersonajes, Sujetos),
    atomic_list_concat([Sujetos, ' ', FormaVerbal, ' ', Adj, " de completar ", NombreMision, " por ", XP, " XP"], Mensaje).