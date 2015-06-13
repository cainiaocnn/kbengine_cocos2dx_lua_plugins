require "gameFight/ArmatureSprite.lua"
require "gameFight/ArmatureSpriteShap.lua"
require "gameFight/ArmatureEffect.lua"

require "gameFight/GameFightMusic.lua"
my_require "gameFight/GameSceneEffect.lua"
my_require "gameFight/GameFightContract.lua"
my_require "gameFight/GameFightHeroTalk.lua"
require "gameFight/GameFightInfoBase.lua"
my_require "gameFight/GameFightTextBattle.lua"

-- 联网
--
if true then	--异步加载资源(Sync)
	my_require "gameFight/SkillResourcesLoad.lua"
	--先异步加载骨骼后,进入战斗,技能使用时候异步加载
	my_require "gameFight/GameFightCenter_Sync.lua"
else			--直接加载资源(Dirc)
	my_require "gameFight/GameFightCenter_Real.lua"
end
--]]
-- 单机
-- require "gameFight/GameFightCenter_Simp.lua"

require "gameFight/SpriteStateCenter.lua"
require "gameFight/SpriteSkillRelease.lua"
require "gameFight/SpriteStateMachine.lua"
require "gameFight/SkillReleaseCenter.lua"

--
my_require "gameFight/SpriteActionPool.lua"
my_require "gameFight/SpriteDamagePool.lua"
my_require "gameFight/SpriteArmaturePool.lua"
my_require "gameFight/SkillActionPerform.lua"
require "gameFight/SpriteDoBeHitDelay.lua"
my_require "gameFight/SceneSkillEffectPool.lua"
my_require "gameFight/SkillDoReleaseBefore.lua"
my_require "gameFight/SpriteSkillBufferPool.lua"

