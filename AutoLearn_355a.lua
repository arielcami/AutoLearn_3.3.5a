require("varsAutoLearn")

-- Configuración --------------------------------------------------------------------------------------------------------------
local Script_ON = true -- true/false : Enciende / Apaga el Script
local DK_HELP = true   -- true/false : Define si quieres que los DK sean sacados de su zona, tanto instantánea como legalmente.
-------------------------------------------------------------------------------------------------------------------------------

local function onLevelChange(E, P, oldLevel)
    if Script_ON then
        local C, R, L, F = P:GetClassMask(), P:GetRaceMask(), P:GetLevel(), P:IsAlliance() and 1 or 2

        for lev = 1, L do
            if spells[F][C] and spells[F][C][lev] then
                for _, id in ipairs(spells[F][C][lev]) do
                    learn(P, id)
                end
            end
        end

        local availableQuests = quests[L] and quests[L][C] and quests[L][C][R]
        local canDoQuests = availableQuests and true or false

        if canDoQuests then
            for i = 1, #quests[L][C][R] do
                doQuest(P, quests[L][C][R][i])
            end

            local function printDelayedMessages(eventid, delay, repeats, object)
                questMessages[C][L].printQuestMessage(object)
            end
            P:RegisterEvent(printDelayedMessages, 1000)
            canDoQuests = false
            deleteItems(P)
        end
    end
end

local function onLogin(E, P)
    if Script_ON then
        P:SendBroadcastMessage('|CFF00FF00[AutoSkills] funcionando, entrena solo tus talentos.')

        local C, L, R = P:GetClassMask(), P:GetLevel(), P:GetRaceMask()
        local class = getClassString(P:GetClassMask())

        -- Habilidades que están disponibles para aprender desde el nivel 1.
        if L == 1 then
            if class == 'WARRIOR' then
                learn(P, 6673) --> Grito de batalla
            elseif class == 'PALADIN' then
                learn(P, 465)  --> Aura de devoción
            elseif class == 'ROGUE' then
                learn(P, 1784) --> Sigilo
            elseif class == 'PRIEST' then
                learn(P, 1243) --> Palabra de poder: entereza
            elseif class == 'SHAMAN' then
                learn(P, 8017) --> Arma Muerdepiedras
            elseif class == 'MAGE' then
                learn(P, 1459) --> Intelecto Arcano
            elseif class == 'WARLOCK' then
                learn(P, 688)  --> Invocar diablillo
            elseif class == 'DRUID' then
                learn(P, 1126) --> Marca de lo Salvaje
            end
            --> El Cazador y el DK no tienen habilidades disponibles para el nivel 1.
        end

        -- Sacar DK de manera legal (Realizando misiones) instantáneamente. 
        -- Solo accede cuando DK_HELP es true, el jugador es DK y es nivel 55.
        if DK_HELP and C == 32 and L == 55 then
            if P:IsAlliance() then
                for i = 1, #alliance_01 do -- Misiones anteriores a la misión única de raza.
                    doQuest(P, alliance_01[i])
                end

                doQuest(P, dkRaces[R][1])  -- Misión única por raza.

                for i = 1, #alliance_02 do -- Continuar con las misiones restantes.
                    doQuest(P, alliance_02[i])
                end
                P:Teleport(0, -8843.5966, 642.2538, 95.8736, 5.4346) -- Teletransportar a Ventormenta
            else
                for i = 1, #horde_01 do
                    doQuest(P, horde_01[i])
                end

                doQuest(P, dkRaces[R][1])

                for i = 1, #horde_02 do
                    doQuest(P, horde_02[i])
                end
                P:Teleport(1, 1643.5269, -4411.58, 16.9977, 5.1409) -- Teletransportar a Orgrimmar
            end

            P:ModifyMoney(-2000000000)
            P:ModifyMoney(2000)
            P:SetLevel(58)
            P:AddItem(38632, 1)
            P:RemoveItem(41751, 10)
        end
    end
end

RegisterPlayerEvent(13, onLevelChange)
RegisterPlayerEvent(3, onLogin)
RegisterPlayerEvent(12, stopXP)