--[[
 Simple Teemo by OuttaControlX
 v1.0
                       
]]
if myHero.charName ~= "Teemo" then return end
 
local Qrange,Rrange = 680, 230
local ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 680, DAMAGE_MAGIC)
 
require "SOW"
require "VPrediction"
 
function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
        Cfg = scriptConfig("Simple Teemo", "Teemo")
		Cfg:addParam("SBTW", "Combo On", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Cfg:addParam("AA", "Auto Attack", SCRIPT_PARAM_ONOFF, true)
		Cfg:addParam("useR", "Shroom Defense", SCRIPT_PARAM_ONOFF, true,   string.byte("K"))
        Cfg:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
		Cfg:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(Cfg.Orbwalking)
		Cfg:permaShow("AA")   
		Cfg:permaShow("useR")   
        Cfg:addTS(ts)
		PrintChat(" >> <font color='#FF0000'>Simple Teemo</font> by OuttaControlX _loaded...")
end
 
function OnTick()            
	ts:update()
	Target = ts.target
	Rready = (myHero:CanUseSpell(_R) == READY)
	Qready = (myHero:CanUseSpell(_Q) == READY)
	SOWi:EnableAttacks()
	if Target then
		if Rready and Cfg.useR then RCheck(230) end
		if Cfg.SBTW then
			SOWi:DisableAttacks()
			if Qready and GetDistance(Target) <= Qrange then CastSpell(_Q, Target) end
			SOWi:EnableAttacks()
		end
	end
end

function RCheck(range)
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and ValidTarget(enemy) and GetDistance(enemy) <= range then CastSpell(_R, enemy) end
	end
end
 
function OnDraw()
    if Cfg.drawcircles and not myHero.dead then
		if Rready then DrawCircle(myHero.x, myHero.y, myHero.z, Rrange, 0xFF0000) end
		if Qready then DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0xFF4629) end
		if not Qready then DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0xFFFFFF) end
		if Target ~= nil then DrawCircle(Target.x, Target.y, Target.z, 150, 0x00FF00) end 
    end
end            