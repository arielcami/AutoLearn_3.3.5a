--[[
    Ariel Camilo - Agosto 2023
    > Cómo Instalar: Ejecuta el siguiente comando por consola: .reload eluna, luego ejecuta los DOS archivos SQL en la base de datos world.
    > Para que se completen las misiones de clase, el jugador NO se debe saltar el nivel correspondiente.
        EJ: Las misiones del tótem de tierra son al nivel 4, 
        si el jugador pasa del nivel 3 al 5, no se completarán las misiones, esto no pasa con las spells.
    > Si se sube por ejemplo del nivel 1 al 80, se enseñan todas las habilidades de en medio.
]]

-- CONTROL
local scriptOn      = true  --> Habilita o desactiva este Script de manera total.
local scriptShow    = true  --> Muestra u oculta el anuncio del Script al logear.
local teachRiding   = false --> Decide si se enseñará o no la habilidad de equitación. Paladines y Bujos aprenden las dos primeras por la monturas de clase.
local doQuests      = true  --> Decide si completar misiones de clase como: Tótems, Redención, Domesticar Bestia y Forma de oso.
                    --> Nota: Aunque doQuests sea false, igual se enseñarán las spells, pero no por medio de misiones.

local quests = { --> ID de misiones. Quise ponerlas en la DB, pero luego recordé que tienen que ejecutarse en orden.
    [4]={ --> Nivel 4
        [64]={ --> Chamán: Tótem de tierra
            [2]={1516,1517,1518},
            [32]={1519,1520,1521},
            [128]={1516,1517,1518},
            [1024]={9449,9450,9451}}},
    [10]={ --> Nivel 10
        [1] = { --> Guerrero: Actitud defensiva
            [1]={1638,1639,1640,1665},      --> Humano
            [2]={1505,1498},                --> Orco
            [4]={1638,1639,1640,1665},      --> Enano
            [8]={1638,1639,1640,1665},      --> Elfo de la Noche
            [16]={1818,1819},               --> No-Muerto
            [32]={1505,1498},               --> Tauren
            [64]={1638,1639,1640,1665},     --> Gnomo
            [128]={1505,1498},              --> Troll
            [1024]={1638,1639,1640,1665}},  --> Draenei
        [4] = { --> Cazador: Domesticar bestia
            [2] = {6070,6062,6083,6082,6081},
            [4] = {6075,6064,6084,6085,6086},
            [8] = {6063,6101,6102,6103},
            [32] = {6061,6087,6088,6089},
            [128] = {6070,6062,6083,6082,6081},
            [512] = {9484,9486,9485,9673},  --> Elfo de Sangre
            [1024] = {9757,9591,9592,9593,9675}},
        [64] = { --> Chamán: Tótem de fuego
            [2] = {1524,1525,1526,1527},
            [32] = {2958,1524,1525,1526,1527},
            [128] = {1524,1525,1526,1527},
            [1024] = {9464,9465,9467,9468,9461,9555}},
        [256]= { --> Brujo: Abisario
            [1] = {1685,1688,1689},
            [2] = {1501,1504},
            [16] = {1473,1471},
            [64] = {1715,1688,1689},
            [512] = {9529,9619}},
        [1024]= { --> Druida: Forma de Oso 
            [8] = {5923,5921,5929,5931,6001},
            [32] = {5922,5930,5932,6002}}},
    [12]={ --> Nivel 12
        [2] = { --> Paladín: Redención
            [1]={1642,1643,1644,1780,1781,1786,1787,1788},
            [4]={3000,1646,1647,1648,1778,1779,1783,1784,1785},
            [512]={9677,9678,9681,9684,9685},
            [1024]={9598,9600}}},
    [14]={ --> Nivel 14
        [1024]={ --> Druida: Curar envenenamiento
            [8]={6121,6122,6123,6124,6125},
            [32]={6126,6127,6128,6129,6130}}},
    [20]={ --> Nivel 20
        [64]={ --> Chamán: Tótem de agua
            [2] = {1528,1530,1535,1536,1534,220,63,100,96},
            [32] = {1529,1530,1535,1536,1534,220,63,100,96},
            [128] = {1528,1530,1535,1536,1534,220,63,100,96},
            [1024] = {9501,9503,9504,9508,9509}},
        [256] = { --> Brujo: Súcubo
            [1] = {1717,1716,1738,1739},
            [2] = {1507,1508,1509,1510,1511,1515,1512,1513},
            [16] = {1472,1476,1474},
            [64] = {1717,1716,1738,1739},
            [512] = {10605,1472,1476,1474}}},
    [30]={ --> Nivel 30
        [1] = { --> Guerrero: Actitud rabiosa
            [1] = {1718,1719},
            [2] = {1718,1719},
            [4] = {1718,1719},
            [8] = {1718,1719},
            [16] = {1718,1719},
            [32] = {1718,1719},
            [64] = {1718,1719},
            [128] = {1718,1719},
            [1024] = {1718,1719}},
        [64] = { --> Chamán: Tótem de fuego
            [2] = {1531},
            [32] = {1532},
            [128] = {1531},
            [1024] = {9552,9553,9554}},
        [256] = { --> Brujo: Manáfago
            [1] = {1798,1758,1802,1804,1795},
            [2] = {2996,1801,1803,1805,1795},
            [16] = {3001,1801,1803,1805,1795},
            [64] = {1798,1758,1802,1804,1795},
            [512] = {3001,1801,1803,1805,1795}}}
}

local s = {} --> La variable "s" contendrá todo lo que es string, también registramos algunos links de objetos y spells.
	s.p0 		= '|cff00ff00Has completado la misión para: |r'
	s.p1 		= '|cff00ff00Has completado la cadena de misiones para: |r' 	
	s.tierra 	= GetItemLink(5175,7)
	s.fuego 	= GetItemLink(5176,7)
	s.agua 		= GetItemLink(5177,7)
	s.aire 		= GetItemLink(5178,7)
	s.actdef 	= '\124cff71d5ff\124Hspell:71\124h[Actitud defensiva]\124h\124r'
	s.actrab 	= '\124cff71d5ff\124Hspell:2458\124h[Actitud rabiosa]\124h\124r'
	s.reden 	= '\124cff71d5ff\124Hspell:7328\124h[Redención]\124h\124r'
	s.abis  	= '\124cff71d5ff\124Hspell:697\124h[Invocar abisario]\124h\124r'
	s.sucu  	= '\124cff71d5ff\124Hspell:712\124h[Invocar súcubo]\124h\124r'
	s.manaf  	= '\124cff71d5ff\124Hspell:691\124h[Invocar manáfago]\124h\124r'
	s.oso  		= '\124cff71d5ff\124Hspell:5487\124h[Forma de oso]\124h\124r'
	s.domes 	= '\124cff71d5ff\124Hspell:1515\124h[Domesticar bestia]\124h\124r'
	s.enven  	= '\124cff71d5ff\124Hspell:8946\124h[Curar envenenamiento]\124h\124r'

    local function do_quest(pl,qid)                 --> Función que llamaremos para completar misiones.
        if not pl:GetQuestRewardStatus(qid) then    --> Comprueba que el jugador no haya realizado la misión.
            pl:AddQuest(qid)                        --> Añadir misión.
            pl:CompleteQuest(qid)                   --> Completar misión.
            pl:RewardQuest(qid)                     --> Entregar misión y recibir recompesas; (xp, reputación, dinero, ítems y/o spells).
        end                                         
    end

local function al_subirNivel (e, P, old) ---------------------------------------------------------------------------------------

    local function learn (id_) if not P:HasSpell(id_) then P:LearnSpell(id_) end end --> Llamaremos esta función más abajo.

    if scriptOn then
        local C, L, A, R = P:GetClassMask(), P:GetLevel(), P:IsAlliance(), P:GetRaceMask()

        if C==64 and not doQuests then   --> Tótems de Chamanes, se ejecuta solo si doQuests esta false.
            if L==4 or L==10 or L==20 or L==30 then
                local totems = {[4]=5175, [10]=5176, [20]=5177, [30]=5178}

                if P:AddItem(totems[L], 1) then
                else --> Si el jugador tiene el inventario lleno, enviar por correo.
                    local G = P:GetGUIDLow() 
                    local itemLink = GetItemLink(totems[L], 7)
                    P:SendBroadcastMessage("|cffff0000¡Inventario lleno! |rItem: "..itemLink.." enviado al correo.")
                    P:SendAreaTriggerMessage("|cffff0000¡Inventario lleno! |rItem: "..itemLink.." enviado al correo.")
                    SendMail("Inventario lleno", "No has podido recibir este objeto.", G, 0, 61, 0, 0, 0, totems[L], 1)
                end                
            end        
        end        
        
        local function getSkills(class, level) --> Función que llamaremos más adelante para retornar el id de una spell. -------

            local t_name = A and "aa_autolearn_a" or "aa_autolearn_h"   --> Hacemos un breve operador ternario.
            local query = string.format("SELECT `skill` FROM `"..t_name.."` WHERE `class` = %d AND `level` <= %d", class, level)
            local SQL = WorldDBQuery(query)
            local skills = {}   --> Declaramos nuestra tablita.

            while SQL and SQL:NextRow() do 
                table.insert(skills, SQL:GetInt32(0))   --> Llenamos momentáneamente nuestra tablita.
            end 
            return skills   --> Devuélveme eso perra!
        end --------------------------------------------------------------------------------------------------------------------
        
        for i = 1, L do                                 --> Iteramos con rango del 1 al nivel actual del jugador.
            local skills_found = getSkills(C, i)        --> Hacemos la recuperación de las habilidades en la DB.
            for _, skill in ipairs(skills_found) do     --> Iteramos sobre las skills encontradas.          
                learn(skill)                            --> Enseñar skills
            end
        end

        if (L==20 or L==40 or L==60 or L==70 or L==77) and (teachRiding) then 
            local riding = {33388, 33391, 34090, 34091, 54197}      --> 60%, 100%, 150%, 280% y vuelo en clima frío.
            local selection = {[20]=1,[40]=2,[60]=3,[70]=4,[77]=5}  --> Asociación de valores de L con índices de riding.
            learn(riding[ selection[L] ])                           --> Aprender el valor de montura correspondiente a L.
        end
        
        if doQuests then       
            local level = P:GetLevel() --> Por seguridad, almacenamos otra vez el nivel actual antes de que empieze a recibir XP de las misiones.
            local questList = quests[L] and quests[L][C] and quests[L][C][R] --> Hacemos un short-circuit evaluation.
            local function D(it) P:RemoveItem(it, 1) end

            if questList then --> Bucle para hacer misiones.
                for _, quest in ipairs(questList) do
                    do_quest(P, quest)
                end ----------------------------------------

                P:SetLevel(level) --> Llevamos al jugador al nivel que tenía antes de realizarles las misiones. (Línea 177)

                --> Borramos todos los objetos residuales de todas las misiones de todas las clases que quedan en inventario.            
                local deletes = {6866,24157,24184,24136,24138,6635,6636,24336,6637,7767,7768,7766,
                                 23749,23871,22243,6286,22244,15710,15208,15844,15826,15866,15842}
                for item = 1, #deletes do D( deletes[item] ) end ------------------------------------------------------------         
            end       
        end

        -- Enviar mensajes al chat. 
		local t = 1000 --> 1 segundo de espera. Esto es para que el mensaje siempre salga al final del chat.
        local function Msg(pl,te) pl:SendAreaTriggerMessage(te) pl:SendBroadcastMessage(te) end --> Para ahorrar espacio.

		if C==1 then        --> Guerrero
			if L==10 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.actdef) end P:RegisterEvent(timed,t) end 
			if L==30 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.actrab) end P:RegisterEvent(timed,t) end 
		elseif C==2 then    --> Paladín
			if L==12 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.reden) end P:RegisterEvent(timed,t) end 
		elseif C==4 then    --> Cazador
			if L==10 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.domes) end P:RegisterEvent(timed,t) end
		elseif C==64 then   --> Chamán
			if L== 4 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.tierra) end P:RegisterEvent(timed,t) end
			if L==10 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.fuego) end P:RegisterEvent(timed,t) end
			if L==20 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.agua) end P:RegisterEvent(timed,t) end
			if L==30 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.aire) end P:RegisterEvent(timed,t) end				
		elseif C==256 then  --> Brujo
			if L==10 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.abis) end P:RegisterEvent(timed,t) end
			if L==20 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.sucu) end P:RegisterEvent(timed,t) end
			if L==30 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.manaf) end P:RegisterEvent(timed,t) end
		elseif C==1024 then --> Druida
			if L==10 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.oso) end P:RegisterEvent(timed,t) end
			if L==14 then local function timed(Ev, del, rep, OB) Msg(OB, s.p1..s.enven) end P:RegisterEvent(timed,t) end
		end
    end
end ----------------------------------------------------------------------------------------------------------------------------

local function al_logear (e, P) --------------------------------------------------------------------------------------------------------------
    
    local L, C, R = P:GetLevel(), P:GetClassMask(), P:GetRaceMask()
  
    if scriptOn and P:GetLevel()==1 then --> Como solo se enseñan las habilidades al nivel 1 aquí, con la consulta a la DB Alianza basta.
        local Query = WorldDBQuery("SELECT `skill` FROM `aa_autolearn_a` WHERE `class`= ".. P:GetClassMask().." AND `level` = "..P:GetLevel())
        if Query and not P:HasSpell( Query:GetInt32(0) ) then --> Solo enseñar si el jugador no tiene el hechizo.
            P:LearnSpell( Query:GetInt32(0) )  
        end
    end
    if scriptShow then P:SendBroadcastMessage("Módulo |cff00ff00HechizosAutomáticos|r en ejecución.") end
end ------------------------------------------------------------------------------------------------------------------------------------------

local function elunaLoad(ev) -----> Se ejecuta cuando se inicia el servidor, o se le hace reload al ElunaEngine. --------------------------------
    local cr, u = "CREATE TABLE IF NOT EXISTS "," UNSIGNED"
    local db = { -->Preparamos la consulta para crear las bases de datos necesarias.
    a = cr.."`aa_autolearn_a` (`level` TINYINT(3)"..u..",`class` SMALLINT(4)"..u..",`skill` MEDIUMINT(6)"..u..")",
    h = cr.."`aa_autolearn_h` (`level` TINYINT(3)"..u..",`class` SMALLINT(4)"..u..",`skill` MEDIUMINT(6)"..u..")"}
    WorldDBExecute(db.a)    --> Creación base de datos de las habilidades Alianza.
    WorldDBExecute(db.h)    --> Creación base de datos de las habilidades Horda.
end ---------------------------------------------------------------------------------------------------------------------------------------------

local function al_aprender(ev, P, spell_id) --------------------------------------------------------------------
    P:SendUnitSay("|cff00ff00"..spell_id.."|r",0) -->Enviar al chat el ID de las Spells que se aprenden. (DEBUG)
end ------------------------------------------------------------------------------------------------------------

RegisterPlayerEvent(13, al_subirNivel)  
RegisterPlayerEvent(3,  al_logear)
RegisterServerEvent(33, elunaLoad) --> Solo se necesita ejecutar una vez, puedes desactivarlo si ya se ejecutó.
--RegisterPlayerEvent(44, al_aprender) --(ACTIVAR PARA DEBUG) 
