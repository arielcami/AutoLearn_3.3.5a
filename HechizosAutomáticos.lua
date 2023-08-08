-- Ariel Camilo - Agosto 2023
-- Para que funcione, se necesita ejecutar los dos SQL en la base de datos World.

local scriptOn      = true  --> true/false para habilitar/deshabilitar el funcionamiento del script.
local scriptShow    = true  --> true/false para habilitar/deshabilitar el mensaje inicial.

local function al_subirNivel (e, P, old) ---------------------------------------------------------------------------------------

    local function learn (id_) if not P:HasSpell(id_) then P:LearnSpell(id_) end end

    if scriptOn then
        local C, L, A = P:GetClassMask(), P:GetLevel(), P:IsAlliance()

        if C==64 then   --> Tótems de Chamanes
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
        
        local function getSkills(class, level)

            local t_name = A and "aa_autolearn_a" or "aa_autolearn_h"   --> Hacemos un breve operador ternario.
            local query = string.format("SELECT `skill` FROM `"..t_name.."` WHERE `class` = %d AND `level` <= %d", class, level)
            local SQL = WorldDBQuery(query)
            local skills = {}   --> Declaramos nuestra tablita.

            while SQL and SQL:NextRow() do 
                table.insert(skills, SQL:GetInt32(0))   --> Llenamos momentáneamente nuestra tablita.
            end 
            return skills   --> Devuélveme eso perra!
        end
        
        for i = 1, L do                                 --> Iteramos con rango del 1 al nivel actual del jugador.
            local skills_found = getSkills(C, i)        --> Hacemos la recuperación de las habilidades en la DB.
            for _, skill in ipairs(skills_found) do     --> Iteramos sobre las skills encontradas.          
                learn(skill)                            --> Enseñar skills
            end
        end
    end
end ----------------------------------------------------------------------------------------------------------------------------

local function al_logear (e, P) --------------------------------------------------------------------------------------------------------------    
    if scriptOn and P:GetLevel()==1 then --> Como solo se enseñan las habilidades al nivel 1 aquí, con la consulta a la DB Alianza basta.
        local Query = WorldDBQuery("SELECT `skill` FROM `aa_autolearn_a` WHERE `class`= ".. P:GetClassMask().." AND `level` = "..P:GetLevel())
        if Query and not P:HasSpell( Query:GetInt32(0) ) then --> Solo enseñar si el jugador no tiene el hechizo.
            P:LearnSpell( Query:GetInt32(0) )  
        end
    end
    if scriptShow then P:SendBroadcastMessage("Módulo |cff00ff00HechizosAutomáticos|r en ejecución.") end
end ------------------------------------------------------------------------------------------------------------------------------------------

local function elunaLoad(ev) -----> Se ejecuta cuando se inicia el servidor, o se le hace reload al ElunaEngine. --------------------------------
    local db = { -- Preparamos la consulta para crear las bases de datos necesarias.
    a = "CREATE TABLE IF NOT EXISTS `aa_autolearn_a` (`level` TINYINT(3) UNSIGNED, `class` SMALLINT(4) UNSIGNED, `skill` MEDIUMINT(6) UNSIGNED)",
    h = "CREATE TABLE IF NOT EXISTS `aa_autolearn_h` (`level` TINYINT(3) UNSIGNED, `class` SMALLINT(4) UNSIGNED, `skill` MEDIUMINT(6) UNSIGNED)"}
    WorldDBExecute(db.a)    --> Creación base de datos de la Alianza.
    WorldDBExecute(db.h)    --> Creación base de datos de la Horda.
end ---------------------------------------------------------------------------------------------------------------------------------------------

local function al_aprender(ev, P, spell_id) --------------------------------------------------------------------
    P:SendUnitSay("|cff00ff00"..spell_id.."|r",0) -- Enviar al chat el ID de las Spells que se aprenden. (DEBUG)
end ------------------------------------------------------------------------------------------------------------

RegisterPlayerEvent(13, al_subirNivel)  
RegisterPlayerEvent(3,  al_logear)
RegisterServerEvent(33, elunaLoad) --> Solo se necesita ejecutar una vez, puedes desactivarlo si ya se ejecutó.
--RegisterPlayerEvent(44, al_aprender) --(ACTIVAR PARA DEBUG) 
