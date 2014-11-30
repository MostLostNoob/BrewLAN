--------------------------------------------------------------------------------
--  Summary:  The Gantry script
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------

local TLandFactoryUnit = SEB0401
local Utilities = import('/lua/utilities.lua')    
local Buff = import('/lua/sim/Buff.lua')   

SEB0401 = Class(TLandFactoryUnit) {    
--------------------------------------------------------------------------------
-- AI Cheats -- This script is triggered each time it starts building
--------------------------------------------------------------------------------   
    AIxCheats = function(self)
        TLandFactoryUnit.AIxCheats(self)       
        LOG('this module triggers, honest')
        local aiBrain = self:GetAIBrain()
        ------------------------------------------------------------------------
        -- AIX cheats
        ------------------------------------------------------------------------    
        if aiBrain.BrainType != 'Human' and aiBrain.CheatEnabled then       
            self:ForkThread(
                function()
                    self:SetBuildRate( self:GetBlueprint().Economy.BuildRate * (2.5+(GetGameTimeSeconds()/120-self.Time/120)) )
                    while aiBrain:GetEconomyIncome( 'MASS' ) > 0 and aiBrain:GetEconomyIncome( 'ENERGY' ) > 0 do
                        if aiBrain:GetEconomyIncome( 'MASS' ) < aiBrain:GetEconomyRequested('MASS') or aiBrain:GetEconomyIncome( 'ENERGY' ) < aiBrain:GetEconomyRequested('ENERGY') then
                            aiBrain:GiveResource('Mass',100)
                            aiBrain:GiveResource('Energy',1000)
                        end    
                        WaitSeconds(1)
                    end
                end
            )    
        ------------------------------------------------------------------------
        -- Regular minor-ai cheats
        ------------------------------------------------------------------------               
        elseif aiBrain.BrainType != 'Human' and not aiBrain.CheatEnabled then
            self:SetBuildRate( self:GetBlueprint().Economy.BuildRate * 2.5 )  
        end
    end,
}

TypeClass = SEB0401