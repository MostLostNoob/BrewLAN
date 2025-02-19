local AEnergyCreationUnit = import('/lua/aeonunits.lua').AEnergyCreationUnit

SAB1311 = Class(AEnergyCreationUnit) {
    AmbientEffects = 'AT3PowerAmbient',

    ShieldEffects = {
        '/effects/emitters/aeon_shield_generator_t2_01_emit.bp',
        '/effects/emitters/aeon_shield_generator_t3_03_emit.bp',
        '/effects/emitters/aeon_shield_generator_t3_04_emit.bp',
    },

    OnStopBeingBuilt = function(self, builder, layer)
        AEnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        self.Trash:Add(CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))
        self.ShieldEffectsBag = {}
    end,

    OnShieldEnabled = function(self)
        AEnergyCreationUnit.OnShieldEnabled(self)
        if not self.Spinner then
            self.Spinner = CreateRotator(self, 'Ring', 'y', nil, 0, 45, -45)
            self.Trash:Add(self.Spinner)
        end
        self.Spinner:SetSpinDown(false)
        self.Spinner:SetTargetSpeed(-45)
        for i, v in self.ShieldEffects do
            if self.ShieldEffectsBag[i] then
                self.ShieldEffectsBag[i]:Destroy()
            end
            self.ShieldEffectsBag[i] = CreateAttachedEmitter(self, 0, self:GetArmy(), v):ScaleEmitter(0.55)
        end
    end,

    OnShieldDisabled = function(self)
        AEnergyCreationUnit.OnShieldDisabled(self)
        if self.Spinner then
            self.Spinner:SetSpinDown(true)
            self.Spinner:SetTargetSpeed(0)
        end
        if self.ShieldEffectsBag then
            for i, v in self.ShieldEffectsBag do
                v:Destroy()
                self.ShieldEffectsBag[i] = nil
            end
        end
    end,
}

TypeClass = SAB1311
