do
    local OldBrewLANExperimentalFactoryUnit = ExperimentalFactoryUnit

    ExperimentalFactoryUnit = Class(OldBrewLANExperimentalFactoryUnit) {
        AICheats = function(self)
            ------------------------------------------------------------------------
            -- Default hax, from BrewLAN actual
            ------------------------------------------------------------------------
            if OldBrewLANExperimentalFactoryUnit.AICheats then
                OldBrewLANExperimentalFactoryUnit.AICheats(self)
            end
            ------------------------------------------------------------------------
            -- AIX cheats
            ------------------------------------------------------------------------
            local aiBrain = self:GetAIBrain()
            if aiBrain.BrainType ~= 'Human' and aiBrain.CheatEnabled then
                self:SetBuildRate( self:GetBlueprint().Economy.BuildRate * (math.min(2.5+(GetGameTimeSeconds()/120-self.Time/120), 25)) )
                if not self.Multiplier then
                    self.Multiplier = 1
                    self:ForkThread(
                        function()
                            while aiBrain:GetEconomyIncome( 'MASS' ) > 0 and aiBrain:GetEconomyIncome( 'ENERGY' ) > 0 do
                                if aiBrain:GetEconomyIncome( 'MASS' ) < aiBrain:GetEconomyRequested('MASS') or aiBrain:GetEconomyIncome( 'ENERGY' ) < aiBrain:GetEconomyRequested('ENERGY') then
                                    aiBrain:GiveResource('Mass',50 * self.Multiplier)
                                    aiBrain:GiveResource('Energy',500 * self.Multiplier)
                                end
                                coroutine.yield(10)
                            end
                        end
                    )
                else
                    self.Multiplier = self.Multiplier + 1
                end
            end
        end
    }
end
