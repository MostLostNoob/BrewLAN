--------------------------------------------------------------------------------
--  Summary  :  Cybran Stationary Explosive Script
--------------------------------------------------------------------------------
local MineStructureUnit = import('/lua/defaultunits.lua').BrewLANMineStructureUnit
local EffectTemplate = import('/lua/EffectTemplates.lua')

SRB2220 = Class(MineStructureUnit) {
    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) {
            FxDeathLand = EffectTemplate.CHvyProtonCannonHitUnit,
        },
    },
}
TypeClass = SRB2220
