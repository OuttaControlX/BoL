--[[
 Fiddlesticks by OuttaControlX
 v1.0
                       
]]

if myHero.charName ~= "FiddleSticks" then return end

local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTarget = nil
local wisincast = false

local ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 750, DAMAGE_MAGIC)
local ToInterrupt = {}
local InterruptList = {
    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    { charName = "FiddleSticks", spellName = "Crowstorm"},
    { charName = "FiddleSticks", spellName = "DrainChannel"},
    { charName = "Galio", spellName = "GalioIdolOfDurand"},
    { charName = "Karthus", spellName = "FallenOne"},
    { charName = "Katarina", spellName = "KatarinaR"},
    { charName = "Lucian", spellName = "LucianR"},
    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", spellName = "AbsoluteZero"},                            
    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    { charName = "Shen", spellName = "ShenStandUnited"},
    { charName = "Urgot", spellName = "UrgotSwap2"},
    { charName = "Varus", spellName = "VarusQ"},
	{ charName = "Warwick", spellName = "InfiniteDuress"},
	{ charName = "Velkoz", spellName = "VelkozR"}
}

function OnLoad()
	Myspace = GetDistance(myHero.minBBox)
	Qrange,Wrange,Erange,Rrange = 575 + Myspace,475 + Myspace,750 + Myspace,750 + Myspace
	myTrueRange = 475 + Myspace
	Cfg = scriptConfig("FiddleSticks Options", "FiddleSticks")
	
	Cfg:addSubMenu("Combo Settings", "C")
	Cfg.C:addParam("AA", "Orbwalk", SCRIPT_PARAM_ONOFF, true) 
	Cfg.C:addParam("Q", "Terrify", SCRIPT_PARAM_ONOFF, true) 
	Cfg.C:addParam("W", "Drain", SCRIPT_PARAM_ONOFF, true)
	Cfg.C:addParam("E", "Dark Wind", SCRIPT_PARAM_ONOFF, true)
	Cfg.C:addParam("R", "Crowstorm", SCRIPT_PARAM_ONOFF, false)
	
	Cfg:addParam("SBTW", "Combo On", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Cfg:addParam("WFix", "W stuck Fix", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M")) 
	Cfg:addParam("Interrupt", "Interrupt Spells", SCRIPT_PARAM_ONOFF, true)
	Cfg:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Cfg:addTS(ts)
	PrintChat(" >> <font color='#339933'>Fiddlesticks</font> by OuttaControlX _loaded...")
end

function OnTick()            
	ts:update()
	Target = ts.target
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	if Cfg.SBTW and not wisincast then OrbWalk() end
	if Cfg.WFix then wisincast = false end
	if Target then
		wactive = myHero.casting == 1
		if Cfg.SBTW and not wisincast and not wactive then
			if Rready and Cfg.C.R and GetDistance(Target) <= Rrange then CastSpell(_R, Target.x, Target.z) end
			if Eready and Cfg.C.E and GetDistance(Target) <= Erange then CastSpell(_E, Target) end
			if Qready and Cfg.C.Q and GetDistance(Target) <= Qrange then CastSpell(_Q, Target) end
			if Wready and Cfg.C.W and not Qready and GetDistance(Target) <= Wrange then CastSpell(_W, Target) end
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.name == myHero.name and buff ~= nil then
		if buff.name == "fearmonger_marker" then
			wisincast = true
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit.name == myHero.name and buff ~= nil then
		if buff.name == "fearmonger_marker" then
			wisincast = false
		end
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

-----------------------------------------
function OrbWalk()
	if Cfg.C.AA then
	myTarget = ts.target
	if myTarget ~= nil and GetDistance(myTarget) <= myTrueRange then		
		if timeToShoot() then
			myHero:Attack(myTarget)
		elseif heroCanMove() then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
	end
end

function heroCanMove()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20 )
end 
 
function timeToShoot()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 100 and GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 250
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end
---------------------------------------------------

function OnProcessSpell(unit, spell)
	if Cfg.Interrupt and Qready and #ToInterrupt > 0 then
		for _, ability in pairs(ToInterrupt) do
			if spell.name == ability and unit.team ~= myHero.team then
				if GetDistance(unit) <= Qrange then CastSpell(_Q, Target) end
			end
		end
	end
	if unit == myHero then
		--print(""..spell.name.."")
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000
		end 
		if spell.name == "Drain" then
		wisincast = true
		end
	end
end

function OnDraw()
    if Cfg.drawcircles and not myHero.dead then
		if Wready then DrawCircle(myHero.x, myHero.y, myHero.z, Wrange, 0xFF0000) end
		if Eready then DrawCircle(myHero.x, myHero.y, myHero.z, Erange, 0xFF0000) end
		if Qready then DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0xFF4629) end
		if not Wready then DrawCircle(myHero.x, myHero.y, myHero.z, Wrange, 0xFFFFFF) end
		if not Qready then DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0xFFFFFF) end
		if Target ~= nil then DrawCircle(Target.x, Target.y, Target.z, 150, 0x00FF00) end 
    end
end            