if myHero.charName ~= "Amumu" then return end

local Qrange,Wrange,Erange,Rrange = 1000, 400, 350, 400
local Qwidth,Qdelay,Qspeed = 80, 0.25, 2000
require "VPrediction"

function OnLoad()
		VP = VPrediction()
		ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, Qrange, DAMAGE_MAGIC)
		ts.name = "Amumu Target"
		JMinions = minionManager(MINION_JUNGLE, Qrange, myHero)
		EnemyMinions = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_HEALTH_ASC)
		
        Cfg = scriptConfig("Amumu Options", "Amumu")
		
		Cfg:addSubMenu("Combo Settings", "Combo")
		Cfg.Combo:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Cfg.Combo:addParam("useQ", "Q Bandage Toss", SCRIPT_PARAM_ONOFF, true)
		Cfg.Combo:addParam("useE", "E Tantrum", SCRIPT_PARAM_ONOFF, true)
		Cfg.Combo:addParam("useW", "Auto Despair", SCRIPT_PARAM_ONOFF, true)
		Cfg.Combo:addParam("useR", "R Curse of the mummy", SCRIPT_PARAM_ONOFF, true)
		Cfg.Combo:addParam("Renemys", "Enemys for Ult", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
		
		Cfg:addSubMenu("Jungle Settings", "Jung")
		Cfg.Jung:addParam("JFarm", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("J"))
		Cfg.Jung:addParam("useQ", "Q Bandage Toss", SCRIPT_PARAM_ONOFF, true)
		Cfg.Jung:addParam("useE", "E Tantrum", SCRIPT_PARAM_ONOFF, true)
		Cfg.Jung:addParam("useW", "Auto Despair", SCRIPT_PARAM_ONOFF, true)
		
		Cfg:addSubMenu("Lane Farming", "Farm")
		Cfg.Farm:addParam("Farm", "Lane Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("L"))
		Cfg.Farm:addParam("useQ", "Q Bandage Toss", SCRIPT_PARAM_ONOFF, true)
		Cfg.Farm:addParam("useE", "E Tantrum", SCRIPT_PARAM_ONOFF, true)
		Cfg.Farm:addParam("useW", "Auto Despair", SCRIPT_PARAM_ONOFF, true)
		
		Cfg:addSubMenu("Draw Options", "Draw")
		Cfg.Draw:addParam("Q", "Q Range", SCRIPT_PARAM_ONOFF, true)
		Cfg.Draw:addParam("E", "E Range", SCRIPT_PARAM_ONOFF, true)

		Cfg:addParam("Dmana", "Despair Mana Manager%",SCRIPT_PARAM_SLICE, 40, 0, 100, 0)

		
        Cfg:addTS(ts)
		PrintChat(" >> <font color='#FF0000'>Amumu</font> by OuttaControlX _loaded...")
end

function OnTick()            
	ts:update()
	JMinions:update()
	EnemyMinions:update()
	Target = ts.target
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	Qready = (myHero:CanUseSpell(_Q) == READY)
	WcastControl()

	if Cfg.Combo.scriptActive and Target then
		if Qready and GetDistance(Target) <= Qrange and Cfg.Combo.useQ then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, Qdelay, Qwidth, Qrange, Qspeed, myHero, true)
			if HitChance >= 2 then CastSpell(_Q, CastPosition.x, CastPosition.z) end
		end
		if Eready and GetDistance(Target) <= Erange and Cfg.Combo.useE then CastSpell(_E) end
		if Rready and Cfg.Combo.useR and AreaEnemyCount(myHero, 550) >= Cfg.Combo.Renemys then CastSpell(_R) end
	end
	
	
	--Jungle Farm------------------------------------------
	if Cfg.Jung.JFarm then
	 	for i, minion in pairs(JMinions.objects) do
			if minion and minion.valid and not minion.dead and GetDistance(minion) <= 300 then
				--myHero:Attack(minion)
				if Eready and Cfg.Jung.useE and GetDistance(minion) <= Erange then CastSpell(_E) end
				if Qready and Cfg.Jung.useQ and GetDistance(minion) <= Qrange then CastSpell(_Q, minion.x, minion.z) end
			end
		end
	end
	--------------------------------------------------------
	
	if Cfg.Farm.Farm then
	 	for i, minion in pairs(EnemyMinions.objects) do
			if minion and minion.valid and not minion.dead and GetDistance(minion) <= 300 then
				--myHero:Attack(minion)
				if Eready and Cfg.Jung.useE and GetDistance(minion) <= Erange then CastSpell(_E) end
				if Qready and Cfg.Jung.useQ and GetDistance(minion) <= Qrange then CastSpell(_Q, minion.x, minion.z) end
			end
		end
	end
	
end

function WcastControl()
	if (GetTickCount() - (Tick or 0) < 1000) or not Wready or (myHero.mana / myHero.maxMana < Cfg.Dmana /100) and not inRecall then return end
	Tick = GetTickCount()
	EnemyWrange = false
	
		if Cfg.Combo.useW then
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if enemy and ValidTarget(enemy) and GetDistance(enemy) <= Wrange + 200 then
						if not Despair then CastSpell(_W) end
						EnemyWrange = true
						return
				end
			end
		end
		
		if Cfg.Jung.useW then
			for i, minion in pairs(JMinions.objects) do
				if minion and minion.valid and not minion.dead and GetDistance(minion) <= Wrange then
						if not Despair then CastSpell(_W) end
						EnemyWrange = true
						return
				end
			end
		end
		
		if Cfg.Farm.useW then
			for i, minion in pairs(EnemyMinions.objects) do
				if minion and minion.valid and not minion.dead and GetDistance(minion) <= Wrange then
						if not Despair then CastSpell(_W) end
						EnemyWrange = true
						return
				end
			end
		end

	if not EnemyWrange and Despair then
		CastSpell(_W)
		return
	end
end

function OnGainBuff(unit, buff)
	if unit.name == myHero.name and buff ~= nil then
		if buff.name == "AuraofDespair" then Despair = true end
	end
end

function OnLoseBuff(unit, buff)
	if unit.name == myHero.name and buff ~= nil then
		if buff.name == "AuraofDespair" then Despair = false end
	end
end


function AreaEnemyCount(Spot, Range, Killable)
	local count = 0
	if Killable == nil then Killable = false end
	if Killable == true then	
		for _, enemy in pairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead and enemy.visible and GetDistance(Spot, enemy) <= Range and getDmg("R", enemy, myHero) + Combo.UltS.Rhealth > enemy.health then
				count = count + 1
			end
		end          
	else
		for _, enemy in pairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead and enemy.visible and GetDistance(Spot, enemy) <= Range then
				count = count + 1
			end
		end            
	end
	return count
end

function OnDraw()
                if not myHero.dead then
                        if Cfg.Draw.Q then DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0x992D3D) end
						if Cfg.Draw.E then DrawCircle(myHero.x, myHero.y, myHero.z, Erange, 0x19A712) end
                        end
end            
