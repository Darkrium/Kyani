function init(args)
  object.setInteractive(true)
  if storage.droptable == nil then
	storage.droptable = root.assetJson("/objects/crafting/resourceextractor/kyani_resource_extractor_droptable.config")
  end
  animator.setAnimationState("extractorState", "active")
  animator.setParticleEmitterBurstCount("inputerror", 1)
  animator.setParticleEmitterBurstCount("spaceerror", 1)
  message.setHandler("kyani_extract_stack", kyani_extract_stack)
end

function update(dt)
end

function checkforvalidinput(itemname)
	if root.itemType(itemname) ~= "material" then return false end
	for i, name in ipairs(storage.droptable.compatible_types) do
		if name == itemname then return true
    end
	end	
end

function kyani_extract_stack()
	animator.setSoundVolume("extract", 0.6, 0)
	animator.playSound("extract")
	local contents = world.containerItems(entity.id())
	if world.containerItemAt(entity.id(), 0) == nil then
		animator.burstParticleEmitter("inputerror")
		animator.playSound("error")
		return
	end
	if checkforvalidinput(contents[1].name) == true then
		local matname = contents[1].name
		local material_to_use = storage.droptable.drop_tables[matname]
		local spaces_required = #material_to_use.drop_comm + #material_to_use.drop_rare
		--sb.logInfo("spaces required calc: " .. tostring(spaces_required))
		if spaces_required > kyani_extractor_get_amt_of_free_spaces() then
			animator.burstParticleEmitter("spaceerror")
			animator.playSound("error")
			return
		end
		while world.containerAvailable(entity.id(), matname) > 0 do
			if math.random(1,100) > material_to_use.chance_none then
				local rarityroll = math.random(1,100)
				local itemlist = {}
				if rarityroll >= 98 then
					itemlist = material_to_use.drop_rare
				else
					itemlist = material_to_use.drop_comm
				end
				if #itemlist ~= 0 and #itemlist ~= nil then
					local item_to_pick = math.random(1,#itemlist)
					if world.containerItemsCanFit(entity.id(), {name=itemlist[item_to_pick],count=1,data={}}) < 1 then
						-- no room for output error
						animator.burstParticleEmitter("spaceerror")
						animator.playSound("error")
						return
					end
					world.containerAddItems(entity.id(), {name = itemlist[item_to_pick], count = 1, data={}})
				end
			end
			world.containerConsume(entity.id(), {name = matname, count = 1, data={}})
		end
	else
		-- invalid input error
		animator.burstParticleEmitter("inputerror")
		animator.playSound("error")
		return
	end
end

function kyani_extractor_get_amt_of_free_spaces()
	local spacestotal = world.containerSize(entity.id())
	local spacestaken = world.containerItems(entity.id())
	--sb.logInfo("free spaces calc: " .. tostring(spacestotal - #spacestaken))
	return spacestotal - #spacestaken
end
