--------------------------------------------------------------------------------
--  Summary:  Arthrolab script
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local BrewLANExperimentalFactoryUnit = import('/lua/defaultunits.lua').BrewLANExperimentalFactoryUnit
--------------------------------------------------------------------------------
local CreateCybranFactoryBuildEffects = import('/lua/EffectUtilities.lua').CreateCybranFactoryBuildEffects
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
--------------------------------------------------------------------------------
SRB0401 = Class(BrewLANExperimentalFactoryUnit) {
--------------------------------------------------------------------------------
-- Function triggers
--------------------------------------------------------------------------------
    OnCreate = function(self)
        BrewLANExperimentalFactoryUnit.OnCreate(self)
        self.AnimationInitialisation(self)
    end,

--------------------------------------------------------------------------------
-- Animations
--------------------------------------------------------------------------------
    AnimationInitialisation = function(self)
        --CreateSlider(unit, bone, [goal_x, goal_y, goal_z, [speed, worldspace
        --CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
        self.Sliders = {
            CreateSlider(self, 'Arm1', 0, 0, 0, 3.5, true),
            CreateSlider(self, 'Arm2', 0, 0, 0, 10.5, true),
            CreateSlider(self, 'Arm3', 0, 0, 0, 3.5, true),
            CreateSlider(self, 'Platform',0,0,0,7, true),
            CreateRotator(self, 'Platform', 'y', 0, 0, 4, 0),
            CreateSlider(self, 'Arm1B', 0, 0, 0, 3.5, true),
            CreateSlider(self, 'Arm2B', 0, 0, 0, 3.5, true),
            CreateSlider(self, 'Arm3B', 0, 0, 0, 3.5, true),
        }
        self.ArmRotators1 = {
            'Arm1_CraneB021',
            'Arm1_CraneB024',
            'Arm1_CraneB026',
            'Arm1_CraneB028',
            'Arm1_CraneB030',
            --
            'Arm1_CraneB032',
            'Arm1_CraneB034',
            'Arm1_CraneB031',
            'Arm1_CraneB038',
            'Arm1_CraneB040',
            --
            'Arm1_CraneB047',
            'Arm1_CraneB043',
            'Arm1_CraneB045',
            'Arm1_CraneB049',
            'Arm1_CraneB042',
        }
        self.Platforms = {
            {--1
                'Platform'
            },
            {--2
                'Platform_B'
            },
            {--3
            },
            {--4
                'Platform_C',
                'Platform_D',
            },
            {--5
            },
            {--6
                'Platform_E',
                'Platform_DE',
            },
            {--7
                'Platform_EF',
            },
            {--8
                'Platform_F',
            },
        }
        for arrayi, array in self.Platforms do
            for i, bone in array do
                if arrayi <= 1 then
                    self:ShowBone(bone, true)
                else
                    self:HideBone(bone, true)
                end
            end
        end
    end,

    CreateBuildEffects = function(self, unitBeingBuilt, order)
        if self.ShowThread then
            self.ShowThread:Destroy()
        end
        local bp = unitBeingBuilt:GetBlueprint()
        --local ScaleMult = 1/self:GetBlueprint().Display.UniformScale
        local UnitSize = {
            bp.Physics.SkirtSizeX or bp.SizeX, --Width
            bp.SizeY, --Height
            bp.Physics.SkirtSizeZ or bp.SizeZ, --Length
        }
        self.RotateBase = false
        if math.max(UnitSize[1],UnitSize[3]) > 3 and math.max(UnitSize[1],UnitSize[3]) <= 10 and math.abs(UnitSize[1]-UnitSize[3]) <= 2 then
            self.RotateBase = true
        end
        --I want to add something so that when it is a short wide unit, the min pos for length pos is 0, but no units are this shape that I know of.
        local MovementSizes = {
            math.min(math.max(UnitSize[1]-1,0),6)*0.5, --Width
            math.min(math.max(UnitSize[2]-2,0),4.25), --Height
            math.min(math.max(UnitSize[3]-1,0),10)*0.5, --Platform
            math.min(math.max(UnitSize[3]-1,1),10), --Rear arm
        }
        unitBeingBuilt:HideBone(0, true)
        --ArmN
        self.Sliders[1]:SetGoal(MovementSizes[1],0,0)
        self.Sliders[2]:SetGoal(0,0,-MovementSizes[4])
        self.Sliders[3]:SetGoal(-MovementSizes[1],0,0)
        --Platform
        self.Sliders[4]:SetGoal(0,0,-MovementSizes[3])
        --ArmNB
        self.Sliders[6]:SetGoal(0,MovementSizes[2],0)
        self.Sliders[7]:SetGoal(0,MovementSizes[2],0)
        self.Sliders[8]:SetGoal(0,MovementSizes[2],0)

        self.ShowThread = self:ForkThread(function()
            WaitFor(self.Sliders[1])
            unitBeingBuilt:ShowBone(0,true)
        end)
        --1,   2,     6,          10.5
        --all, slink, monkeylord, megalith
        for arrayi, array in self.Platforms do
            for i, bone in array do
                if arrayi <= math.ceil(math.max(UnitSize[1],UnitSize[3])) then
                    self:ShowBone(bone, true)
                else
                    self:HideBone(bone, true)
                end
            end
        end
        if self.RotateBase then
            self.Sliders[5]:ClearGoal()
            self.Sliders[5]:SetTargetSpeed(10)
        else
            self.Sliders[5]:SetGoal(0)
        end
        self.AnimateArms = true
        if not self.CraneArmAnimationThread then
            self.CraneArmAnimationThread = self:ForkThread(self.CraneArmAnimation)
        end

        if not unitBeingBuilt then return end
        coroutine.yield(1)
        CreateCybranFactoryBuildEffects( self, unitBeingBuilt, __blueprints.srb0401.General.BuildBones, self.BuildEffectsBag )
        BrewLANExperimentalFactoryUnit.CreateBuildEffects(self, unitBeingBuilt, order)
    end,

    StopBuildingEffects = function(self, unitBeingBuilt)
        BrewLANExperimentalFactoryUnit.StopBuildingEffects(self, unitBeingBuilt)
        self.Sliders[5]:SetGoal(0)
        self.AnimateArms = false
    end,

    CraneArmAnimation = function(self)
        for i, v in self.ArmRotators1 do
            self.ArmRotators1[i] = CreateRotator(self, v, 'z', 60, 50, 4, 50)
        end
        local unitBeingBuilt
        while true do
            if self.AnimateArms then
                for i, v in self.ArmRotators1 do
                    if math.random(1,3) ~= 3 then
                        v:SetGoal(55 + math.random(0,10))
                    end
                end
            end
            coroutine.yield(2)
            --Rotation return watch thread, so we don't have two different loops running
            unitBeingBuilt = self:GetFocusUnit()
            if unitBeingBuilt and self.RotateBase and unitBeingBuilt:GetFractionComplete() > 0.8 then
                self.Sliders[5]:SetGoal(0)
            end
        end
    end,

    StartBuildFx = function(self, unitBeingBuilt)
    end,
}

TypeClass = SRB0401
