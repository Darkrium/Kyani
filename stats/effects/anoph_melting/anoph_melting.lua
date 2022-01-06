function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)

  script.setUpdateDelta(5)

  self.tickTime = 1.0
  self.tickTimer = self.tickTime
  self.damage = 3

  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = 3,
      damageSourceKind = "kyani_anophium",
      sourceEntityId = entity.id()
    })
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    self.damage = self.damage * 2
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        damageSourceKind = "kyani_anophium",
        sourceEntityId = entity.id()
      })
  end
end

function onExpire()

end
