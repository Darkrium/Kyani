
function init()
    self.tickTime = 1.0
    self.tickTimer = self.tickTime
    self.damage = 1
    script.setUpdateDelta(25)
end

function update(dt)
 if status.stat("kyani_wet") == 1 then
   status.setPersistentEffects("kyaniweaken", {
           {stat = "maxEnergy", effectiveMultiplier = 0.1},
           {stat = "protection", effectiveMultiplier = 0.3}
            })
     self.tickTimer = self.tickTimer - dt
     if self.tickTimer <= 0 then
      self.tickTimer = self.tickTime
       self.damage = self.damage * 2
        status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        damageSourceKind = "poison",
        sourceEntityId = entity.id()
      })
	  end
  else
   self.damage = 1
   status.clearPersistentEffects("kyaniweaken")
end
end

