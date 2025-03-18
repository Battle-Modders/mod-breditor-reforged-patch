// Overwrite relevant functions to make it compatible with Reforged
// Generally the original function is copy pasted and some stuff is modified to adapt to Reforged

::ModBreditorReforgedPatch.MH.hook("scripts/ui/screens/world/world_breditor_screen", function(q) {
	q.cantyouhaveonewaytocloseit = @() function()
	{
 		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if(b.getTitle() == "ImmaBreditorBug")
			{
				this.World.getPlayerRoster().remove(b);
			}
			else
			{
				b.getSkills().update();
			}
		};
	}

	q.queryRosterInformation = @() function( _id = null )
	{
		local fakebro = this.World.getPlayerRoster().create("scripts/entity/tactical/player");
		fakebro.setStartValuesEx(["cripple_background"]);
		fakebro.setTitle("ImmaBreditorBug");
		fakebro.setName("SendLog");

		local brothers = this.World.getPlayerRoster().getAll();
		local roster = [];
		//this.logDebug("1");
		local basestats = {
			Hitpoints = [50,60],
			Bravery = [30,40],
			Stamina = [90,100],
			MeleeSkill = [47,57],
			RangedSkill = [32,42],
			MeleeDefense = [0,5],
			RangedDefense = [0,5],
			Initiative = [100,110]
		};
		local traitstemp = clone this.Const.CharacterTraits;
		local extratraits = prepareyourtraits();
 		local injuries = clone this.Const.Injury.Permanent;
		local traits = [];
		foreach( trtmp in traitstemp )
		{
			traits.push(trtmp);
		}
		foreach( trtxtr in extratraits )
		{
			traits.push(trtxtr);
		}
		foreach( inj in injuries )
		{
			if (inj.ID != "injury.missing_hand") //bugged
			{
				local injfixed = [inj.ID, "scripts/skills/"+inj.Script];
				traits.push(injfixed);
			}
		}

		local thirdvalue = null;
		local traitstemp = null;
		foreach( tr in traits )
		{
			traitstemp = this.new(tr[1]);
			if (tr[0] == "racial.skeleton")
			{
				thirdvalue = "ui/icons/unknown_traits.png";
			}
			else
			{
				thirdvalue = traitstemp.getIconColored();
			}
			tr.push(thirdvalue);
			if (!fakebro.getSkills().hasSkill(tr[0]))
			{
				fakebro.getSkills().add(this.new(tr[1]));
			}
		}

		local perkttreeeeee = gimmeperks();

		foreach( perkgroupCategory in perkttreeeeee )
		{
			foreach( perkGroup in perkgroupCategory )
			{
				fakebro.getPerkTree().addPerkGroup(perkGroup.ID);
			}
		}

		foreach( b in brothers )
		{
			if (_id != null && _id != b.getID())
			{continue;}
			local background = b.getBackground();
			local additionalstats = background.onChangeAttributes();
			//local properties = b.getCurrentProperties();

			local broskills = b.getSkills(); //b.getSkills().query(this.Const.SkillType.Trait),
			local brotraits = [];
			foreach( tr in traits )
			{
				if (broskills.hasSkill(tr[0]))
				{
					brotraits.push(tr);
				}
			}

			local e = {
				ID = b.getID(),
				Name = b.getName(),
				ImagePath = b.getImagePath(),
				ImageOffsetX = b.getImageOffsetX(),
				ImageOffsetY = b.getImageOffsetY(),
				Background = background.getID(),
				BackgroundImagePath = background.getIconColored(),
				BackgroundText = background.getDescription(),
				XpValue = b.getXP(),
				Level = b.getLevel(),
				LevelUps = b.m.LevelUps,
				PerkPoints = b.getPerkPoints(),
				Hitpoints = {
					Max = b.getBaseProperties().Hitpoints,
					MaxPlus = b.getHitpointsMax(),
					Talent = b.getTalents()[this.Const.Attributes.Hitpoints],
					BLimit = basestats.Hitpoints[1] + additionalstats.Hitpoints[1],
				},
				Stamina = {
					Max = b.getBaseProperties().Stamina,
					MaxPlus = b.getFatigueMax(),
					Talent = b.getTalents()[this.Const.Attributes.Fatigue],
					BLimit = basestats.Stamina[1] + additionalstats.Stamina[1],
				},
				Initiative = {
					Max = b.getBaseProperties().Initiative,
					MaxPlus = b.getInitiative(),
					Talent = b.getTalents()[this.Const.Attributes.Initiative],
					BLimit = basestats.Initiative[1] + additionalstats.Initiative[1],
				},
				Bravery = {
					Max = b.getBaseProperties().Bravery,
					MaxPlus = b.getBravery(),
					Talent = b.getTalents()[this.Const.Attributes.Bravery],
					BLimit = basestats.Bravery[1] + additionalstats.Bravery[1],
				},
				MeleeSkill = {
					Max = b.getBaseProperties().MeleeSkill,
					MaxPlus = b.m.CurrentProperties.getMeleeSkill(),
					Talent = b.getTalents()[this.Const.Attributes.MeleeSkill],
					BLimit = basestats.MeleeSkill[1] + additionalstats.MeleeSkill[1],
				},
				RangedSkill = {
					Max = b.getBaseProperties().RangedSkill,
					MaxPlus = b.m.CurrentProperties.getRangedSkill(),
					Talent = b.getTalents()[this.Const.Attributes.RangedSkill],
					BLimit = basestats.RangedSkill[1] + additionalstats.RangedSkill[1],
				},
				MeleeDefense = {
					Max = b.getBaseProperties().MeleeDefense,
					MaxPlus = b.m.CurrentProperties.getMeleeDefense(),
					Talent = b.getTalents()[this.Const.Attributes.MeleeDefense],
					BLimit = basestats.MeleeDefense[1] + additionalstats.MeleeDefense[1],
				},
				RangedDefense = {
					Max = b.getBaseProperties().RangedDefense,
					MaxPlus = b.m.CurrentProperties.getRangedDefense(),
					Talent = b.getTalents()[this.Const.Attributes.RangedDefense],
					BLimit = basestats.RangedDefense[1] + additionalstats.RangedDefense[1],
				},
				ActionPoints = b.getActionPointsMax(),
				DailyWage = b.getDailyCost(),
				DailyFood = b.getDailyFood(),
				Traits = brotraits,
			};
			if (_id != null && _id == b.getID())
			{return e;}
			roster.push(e);
		}

		local categories = ::DynamicPerks.PerkGroupCategories.getOrdered().map(@(_c) _c.getName());
		categories.push("Special");

		return {
			Title = "Breditor",
			//SubTitle = "Edit characteristics of your soldiers",
			Roster = roster,
			Traits = traits,
			Backgrounds = prepareyourbgs(),
			NamedItems = prepareNI(),
			PTree = perkttreeeeee,
			ModBreditorReforgedPatchCategories = categories
			//Assets = this.m.Parent.queryAssetsInformation()
		};
	}

	q.onChooseBG = @() function( _result )
	{
		local result = null;
		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				local XPbackup = b.m.XP;
				local Levelbackup = b.m.Level;
				local LevelUpsbackup = b.m.LevelUps;
				local PerkPointsBackup = b.m.PerkPoints;
				local TitleBackup = b.m.Title;
				local bg = this.new(_result.TraitLink);
				local BackgroundText = b.getBackground().getDescription();

				bg.m.IsNew = false;
				b.getSkills().removeByID(b.getBackground().getID());
				b.getSkills().add(bg);
				b.getBackground().m.Description = BackgroundText;
				b.getBackground().m.RawDescription = BackgroundText;

				local additionalstats = b.getBackground().onChangeAttributes();
				b.m.XP = XPbackup;
				b.m.Level = Levelbackup;
				b.m.LevelUps = LevelUpsbackup;
				b.m.PerkPoints = PerkPointsBackup;
				b.m.Title = TitleBackup;
				result =
				{
					BackgroundImagePath = bg.getIconColored(),
				};
				//background.buildDescription();
				//background.onSetAppearance();
				break;
			}
		};
		return result;
	}

	q.ExportBro = @() function( _result )
	{
		local result = "";
		local splitchar = "%!";
		local sprites = ["body",
			"head",
			"beard",
			"hair",
			"tattoo_body",
			"tattoo_head",
			"beard_top"
		];
		if (_result.MainS){result = result + "mainstatsbredata";}
		if (_result.LifeStats){result = result + "lifestatsbredata";}
		if (_result.Gear){result = result + "gearbredata";}
		result = result + splitchar;

		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				if (_result.MainS)
				{
					//player.nut - skipped lifetime statistics, not sure if it's needed
					result = result + b.m.Level + splitchar;
					result = result + b.m.PerkPoints + splitchar;
					result = result + b.m.PerkPointsSpent + splitchar;
					result = result + b.m.LevelUps + splitchar;
					for( local i = 0; i != this.Const.Attributes.COUNT; i = ++i )
					{
						result = result + b.m.Talents[i] + splitchar;
					}
					for( local i = 0; i != this.Const.Attributes.COUNT; i = ++i )
					{
						result = result + b.m.Attributes[i].len() + splitchar;
						foreach( a in b.m.Attributes[i] )
						{
							result = result + a + splitchar;
						}
					}
					//LEGENDS - ignoring m.Formations
					//------------------------------------------------------------------------------------------------
					//human.nut
					result = result + b.m.Body + splitchar;
					result = result + b.m.Ethnicity + splitchar;
					result = result + b.m.Gender + splitchar;
					result = result + b.m.VoiceSet + splitchar;
					//extra
					for( local i = 0; i < sprites.len(); i = ++i )
					{
						if (b.getSprite(sprites[i]).HasBrush)
						{
							result = result + "true" + splitchar;
							result = result + b.getSprite(sprites[i]).getBrush().Name + splitchar;
						}
						else
						{
							result = result + "false" + splitchar;
						}
					}
					//------------------------------------------------------------------------------------------------
					//actor.nut
					result = result + b.m.BaseProperties.ActionPoints + splitchar;
					result = result + b.m.BaseProperties.Hitpoints + splitchar;
					result = result + b.m.BaseProperties.Bravery + splitchar;
					result = result + b.m.BaseProperties.Stamina + splitchar;
					result = result + b.m.BaseProperties.MeleeSkill + splitchar;
					result = result + b.m.BaseProperties.RangedSkill + splitchar;
					result = result + b.m.BaseProperties.MeleeDefense + splitchar;
					result = result + b.m.BaseProperties.RangedDefense + splitchar;
					result = result + b.m.BaseProperties.Initiative + splitchar;
					result = result + b.m.BaseProperties.DailyWage + splitchar;
					result = result + b.m.BaseProperties.DailyFood + splitchar;
					result = result + b.m.Name + splitchar;
					result = result + b.m.Title + splitchar;
					result = result + b.getHitpointsPct() + splitchar;
					result = result + b.m.XP + splitchar;
					//------------------------------------------------------------------------------------------------
					//entity.nut - flags - fuck them
					//skill container
					local skillz = b.getSkills();
					local numSkills = 0;
					foreach( skill in skillz.m.Skills )
					{
						if (skill.isSerialized() && (!skill.isType(this.Const.SkillType.Injury) || skill.isType(this.Const.SkillType.PermanentInjury)) && !skill.isType(this.Const.SkillType.DrugEffect)){numSkills = ++numSkills;}
					}
					result = result + numSkills + splitchar;
					foreach( skill in skillz.m.Skills )
					{
						if (skill.isSerialized() && (!skill.isType(this.Const.SkillType.Injury) || skill.isType(this.Const.SkillType.PermanentInjury)) && !skill.isType(this.Const.SkillType.DrugEffect))
						{
							result = result + this.IO.scriptFilenameByHash(skill.ClassNameHash) + splitchar;
							//skill.nut
							result = result + skill.m.IsNew + splitchar;
							if (skill.isType(this.Const.SkillType.Background) && skill.m.ID != "trait.intensive_training_trait") //who thought it was a good idea?
							{
								result = result + skill.m.Description + splitchar;
								result = result + skill.m.RawDescription + splitchar;
								result = result + skill.m.Level + splitchar;
								result = result + skill.m.DailyCostMult + splitchar;
								//LEGENDS
								result = result + skill.isBackgroundType(this.Const.BackgroundType.Female) + splitchar;
								result = result + skill.isBackgroundType(this.Const.BackgroundType.ConvertedCultist) + splitchar;
								if (skill.m.CustomPerkTree == null)
								{	result = result + 0 + splitchar;	}
								else
								{	result = result + skill.m.CustomPerkTree.len() + splitchar;
									for( local i = 0; i < skill.m.CustomPerkTree.len(); i = i )
									{	result = result + skill.m.CustomPerkTree[i].len() + splitchar;
										for( local j = 0; j < skill.m.CustomPerkTree[i].len(); j = j )
										{	result = result + skill.m.CustomPerkTree[i][j] + splitchar;
											j = ++j;}
										i = ++i;}
								}
							}
							//LEGENDS
							if (skill.m.ID == "trait.intensive_training_trait")
							{	result = result + skill.m.HitpointsAdded + splitchar;
								result = result + skill.m.StaminaAdded + splitchar;
								result = result + skill.m.BraveAdded + splitchar;
								result = result + skill.m.IniAdded + splitchar;
								result = result + skill.m.MatkAdded + splitchar;
								result = result + skill.m.RatkAdded + splitchar;
								result = result + skill.m.MdefAdded + splitchar;
								result = result + skill.m.RdefAdded + splitchar;
								result = result + skill.m.BonusXP + splitchar;
								result = result + skill.m.TraitGained + splitchar;}
							if (skill.m.ID == "trait.pit_fighter" || skill.m.ID == "trait.arena_fighter" || skill.m.ID == "trait.arena_veteran")
							{	result = result + b.getFlags().getAsInt("ArenaFights") + splitchar;
								result = result + b.getFlags().getAsInt("ArenaFightsWon") + splitchar;}
						}
					}
					result = result + "Finish" + splitchar;
				}

				if (_result.LifeStats)
				{
					result = result + "LSBBegin" + splitchar;
					result = result + b.m.LifetimeStats.Kills + splitchar;
					result = result + b.m.LifetimeStats.Battles + splitchar;
					result = result + b.m.LifetimeStats.BattlesWithoutMe + splitchar;
					result = result + b.m.LifetimeStats.MostPowerfulVanquishedType + splitchar;
					result = result + b.m.LifetimeStats.MostPowerfulVanquished + splitchar;
					result = result + b.m.LifetimeStats.MostPowerfulVanquishedXP + splitchar;
					result = result + b.m.LifetimeStats.FavoriteWeapon + splitchar;
					result = result + b.m.LifetimeStats.FavoriteWeaponUses + splitchar;
					result = result + b.m.LifetimeStats.CurrentWeaponUses + splitchar;
					//LEGENDS
					local lstags = b.m.LifetimeStats.Tags;
					result = result + lstags.m.len() + splitchar;
					foreach( v in lstags.m )
					{	result = result + v.Key + splitchar;
						result = result + v.Value + splitchar;}
					result = result + "Finish" + splitchar;
				}

				if (_result.Gear)
				{
					result = result + "EqBBegin" + splitchar;
					local itemz = b.m.Items;
					//item container
					//result = result + itemz.m.UnlockedBagSlots + splitchar;
					local numItems = 0;
					for( local i = 0; i < this.Const.ItemSlot.COUNT; i = ++i )
					{
						for( local j = 0; j < this.Const.ItemSlotSpaces[i]; j = ++j )
						{
							if (itemz.m.Items[i][j] != null && itemz.m.Items[i][j] != -1){numItems = ++numItems;}
						}
					}
					result = result + numItems + splitchar;
					for( local i = 0; i < this.Const.ItemSlot.COUNT; i = ++i )
					{
						for( local j = 0; j < this.Const.ItemSlotSpaces[i]; j = ++j )
						{
							local curitem = itemz.m.Items[i][j];
							if (curitem != null && curitem != -1)
							{
								result = result + curitem.getCurrentSlotType() + splitchar;
								result = result + this.IO.scriptFilenameByHash(curitem.ClassNameHash) + splitchar;
								local HS = false;
								if ("HiddenString" in curitem.m){HS = true;
								result = result + curitem.m.HiddenString + splitchar;}
								//item.nut
								result = result + curitem.m.IsToBeRepaired + splitchar;
								result = result + curitem.m.Variant + splitchar;
								result = result + curitem.m.Condition + splitchar;
								result = result + curitem.m.PriceMult + splitchar;
								result = result + curitem.m.MagicNumber + splitchar;
								result = result + curitem.m.Name + splitchar; //not from item.nut, not always serialized but pretty much every item should have it
								//LEGENDS - so much redundancy...
								//result = result + curitem.getInstanceID + splitchar; //let's see if this works without it
								result = result + curitem.m.RuneVariant + splitchar;
								result = result + curitem.m.IsToBeSalvaged + splitchar;
								result = result + curitem.m.IsToBeRepairedQueue + splitchar;
								result = result + curitem.m.IsToBeSalvagedQueue + splitchar;
								result = result + curitem.m.RuneBonus1 + splitchar;
								result = result + curitem.m.RuneBonus2 + splitchar;
								//------------------------------------------------------------------------------------------------
								if(curitem.isItemType(this.Const.Items.ItemType.Ammo) && !curitem.isItemType(this.Const.Items.ItemType.Weapon)) //throwing weapons age gonna be serialized with other weapons
								{result = result + curitem.m.Ammo + splitchar;}
								if(curitem.isItemType(this.Const.Items.ItemType.Weapon))
								{	result = result + curitem.m.Ammo + splitchar;
									if(curitem.isItemType(this.Const.Items.ItemType.Named) || HS == true)
									{
										result = result + curitem.m.ConditionMax + splitchar;
										result = result + curitem.m.StaminaModifier + splitchar;
										result = result + curitem.m.RegularDamage + splitchar;
										result = result + curitem.m.RegularDamageMax + splitchar;
										result = result + curitem.m.ArmorDamageMult + splitchar;
										result = result + curitem.m.ChanceToHitHead + splitchar;
										result = result + curitem.m.ShieldDamage + splitchar;
										result = result + curitem.m.AdditionalAccuracy + splitchar;
										result = result + curitem.m.DirectDamageAdd + splitchar;
										result = result + curitem.m.FatigueOnSkillUse + splitchar;
										result = result + curitem.m.AmmoMax + splitchar;}
								}
								if(curitem.isItemType(this.Const.Items.ItemType.Shield))
								{
									if(curitem.isItemType(this.Const.Items.ItemType.Named) || HS == true)
									{	result = result + curitem.m.ConditionMax + splitchar;
										result = result + curitem.m.StaminaModifier + splitchar;
										result = result + curitem.m.MeleeDefense + splitchar;
										result = result + curitem.m.RangedDefense + splitchar;
										result = result + curitem.m.FatigueOnSkillUse + splitchar;}
									if(curitem.m.ID == "shield.faction_kite_shield" || curitem.m.ID == "shield.faction_heater_shield")
									{	result = result + curitem.m.Faction + splitchar;}
								}
							}
						}
					}
					result = result + "Finish" + splitchar;
				} //gear end
				break;
			}
		};
		//result = result + "ImportFinished";
		this.logDebug(""+result);
		return result;
	}

	q.ImportBro = @() function( _result )
	{
		local result = "Error01";
		local stringarray = this.ImportBroFixString(_result.IString);
		if (stringarray.len() < 5)
		{
			return result;
		}
		local hasMS = false;
		local hasLS = false;
		local hasGS = false;
		if (this.String.contains(stringarray[0], "mainstatsbredata")){hasMS = true && _result.MainS;}
		if (this.String.contains(stringarray[0], "lifestatsbredata")){hasLS = true && _result.LifeStats;}
		if (this.String.contains(stringarray[0], "gearbredata")){hasGS = true && _result.Gear;}
		local iesettings = {hasMS = hasMS,
			hasLS = hasLS,
			hasGS = hasGS,
		};
		if (!hasMS && !hasLS && !hasGS)
		{
			return "Cannot do that!";
		}
/* 		this.logDebug("hasMS "+hasMS+", _result.MainS "+_result.MainS+", string "+this.String.contains(stringarray[0], "mainstatsbredata"));
		this.logDebug("hasLS "+hasLS+", _result.LifeStats "+_result.LifeStats+", string "+this.String.contains(stringarray[0], "lifestatsbredata"));
		this.logDebug("hasGS "+hasGS+", _result.Gear "+_result.Gear+", string "+this.String.contains(stringarray[0], "gearbredata")); */

		local temprosterbro = this.World.getTemporaryRoster().create("scripts/entity/tactical/player");
		local testresult = null;
		try {testresult = this.ImportBroProcessBro(temprosterbro, stringarray, iesettings);}
		catch (err) {result = "Error02";};
		if (testresult != "Finish")
		{
			return result;
		}
		this.World.getTemporaryRoster().clear();
		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				testresult = this.ImportBroProcessBro(b, stringarray, iesettings);
				this.logDebug(""+testresult);

				local skillz = b.getSkills();
				this.World.State.m.AppropriateTimeToRecalc = 0;
				skillz.update();
 				this.World.State.m.AppropriateTimeToRecalc = 1;
				result = iesettings;
				result.Room <- this.World.Assets.getStash().getNumberOfEmptySlots() - 3; //because fakebro cripple's 3
				if(hasGS){result.ImagePath <- b.getImagePath();}
				break;
			}
		};
		return result;
	}

	q.ImportBroProcessBro = @() function(b, stringarray, _iesettings)
	{
		local result = null;
		local sprites = ["body",
			"head",
			"beard",
			"hair",
			"tattoo_body",
			"tattoo_head",
			"beard_top"
		];
		local LSBBegin = 0;
		local EqBBegin = 0;
		foreach(_key, _value in stringarray)
		{
			if (_value == "LSBBegin" && _iesettings.hasLS)
			{LSBBegin = _key+1}
			if (_value == "EqBBegin" && _iesettings.hasGS)
			{EqBBegin = _key+1}
		}
		local leo = 1;
		if (_iesettings.hasMS)
		{
			//player.nut
			b.m.Level = stringarray[leo]; leo = ++leo;
			b.m.PerkPoints = stringarray[leo]; leo = ++leo;
			b.m.PerkPointsSpent = stringarray[leo]; leo = ++leo;
			b.m.LevelUps = stringarray[leo]; leo = ++leo;
			b.m.Talents.resize(this.Const.Attributes.COUNT, 0);
			for( local i = 0; i != this.Const.Attributes.COUNT; i = ++i )
			{
				b.m.Talents[i] = stringarray[leo]; leo = ++leo;
			}
			b.m.Attributes.resize(this.Const.Attributes.COUNT);
			for( local i = 0; i != this.Const.Attributes.COUNT; i = ++i )
			{
				b.m.Attributes[i] = [];
				local curattr = stringarray[leo]; leo = ++leo;
				b.m.Attributes[i].resize(curattr);
				for( local j = 0; j != curattr; j = ++j )
				{
					b.m.Attributes[i][j] = stringarray[leo]; leo = ++leo;
				}
			}
			//LEGENDS - ignoring m.Formations
			b.m.VeteranPerks = stringarray[leo]; leo = ++leo;
			//skipping some funny female bg stuff and other irrelevant info
			//------------------------------------------------------------------------------------------------
			//human.nut
			b.m.Body = stringarray[leo]; leo = ++leo;
			b.m.Ethnicity = stringarray[leo]; leo = ++leo;
			b.m.Gender = stringarray[leo]; leo = ++leo;
			b.m.VoiceSet = stringarray[leo]; leo = ++leo;
			b.m.Sound[this.Const.Sound.ActorEvent.NoDamageReceived] = this.Const.HumanSounds[b.m.VoiceSet].NoDamageReceived;
			b.m.Sound[this.Const.Sound.ActorEvent.DamageReceived] = this.Const.HumanSounds[b.m.VoiceSet].DamageReceived;
			b.m.Sound[this.Const.Sound.ActorEvent.Death] = this.Const.HumanSounds[b.m.VoiceSet].Death;
			b.m.Sound[this.Const.Sound.ActorEvent.Fatigue] = this.Const.HumanSounds[b.m.VoiceSet].Fatigue;
			b.m.Sound[this.Const.Sound.ActorEvent.Flee] = this.Const.HumanSounds[b.m.VoiceSet].Fatigue;
			//LEGENDS
			b.setGender(b.m.Gender, false);
			//extra
			local cursprite = null;
			for( local i = 0; i < sprites.len(); i = ++i )
			{
				cursprite = stringarray[leo]; leo = ++leo;
				if (cursprite)
				{
					b.getSprite(sprites[i]).setBrush(stringarray[leo]); leo = ++leo;
				}
				else
				{
					b.getSprite(sprites[i]).resetBrush();
					continue;
				}
			}
			//------------------------------------------------------------------------------------------------
			//actor.nut
			b.m.BaseProperties.ActionPoints = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.Hitpoints = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.Bravery = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.Stamina = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.MeleeSkill = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.RangedSkill = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.MeleeDefense = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.RangedDefense = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.Initiative = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.DailyWage = stringarray[leo]; leo = ++leo;
			b.m.BaseProperties.DailyFood = stringarray[leo]; leo = ++leo;
			b.m.Name = stringarray[leo]; leo = ++leo;
			b.m.Title = stringarray[leo]; leo = ++leo;
			b.setHitpointsPct(this.Math.maxf(0.0, stringarray[leo])); leo = ++leo;
			b.m.XP = stringarray[leo]; leo = ++leo;
			//------------------------------------------------------------------------------------------------
			//entity.nut - flags - fuck them
			//skill container
			local skillz = b.getSkills();
			skillz.m.IsUpdating = true;
			local numSkills = stringarray[leo]; leo = ++leo;
			foreach( skill in skillz.m.Skills )
			{
				if (skill.isType(this.Const.SkillType.Background) || skill.isType(this.Const.SkillType.Trait) || skill.isType(this.Const.SkillType.Perk) || skill.isType(this.Const.SkillType.PermanentInjury) || skill.isType(this.Const.SkillType.TemporaryInjury))
				{
					if (!skill.isType(this.Const.SkillType.Special) && !skill.isType(this.Const.SkillType.Active) && (!skill.isType(this.Const.SkillType.StatusEffect) || (skill.isType(this.Const.SkillType.StatusEffect) && skill.isType(this.Const.SkillType.Perk)) || (skill.isType(this.Const.SkillType.StatusEffect) && skill.isType(this.Const.SkillType.Trait))) &&
					!skill.isType(this.Const.SkillType.Item)) //!skill.isType(this.Const.SkillType.Racial) &&
					{
						skill.removeSelf();
					}
				}
			}
			b.getFlags().set("ArenaFights", 0);
			b.getFlags().set("ArenaFightsWon", 0);
			for( local i = 0; i < numSkills; i = ++i )
			{
				//this.logDebug("leo "+stringarray[leo]);
				local skill = this.new(stringarray[leo]); leo = ++leo;
				//skill.nut
				skill.m.IsNew = stringarray[leo]; leo = ++leo;
				if (skill.isType(this.Const.SkillType.Background) && skill.m.ID != "trait.intensive_training_trait") //who thought it was a good idea?
				{
					skill.m.Description = stringarray[leo]; leo = ++leo;
					skill.m.RawDescription = stringarray[leo]; leo = ++leo;
					skill.m.Level = stringarray[leo]; leo = ++leo;
					skill.m.DailyCostMult = stringarray[leo]; leo = ++leo;
					//LEGENDS
					local isfemale = stringarray[leo]; leo = ++leo;
					if (isfemale){skill.addBackgroundType(this.Const.BackgroundType.Female); skill.setGender(1);}
					else{skill.setGender(0);}
					local isconverted = stringarray[leo]; leo = ++leo;
					if (isconverted){skill.addBackgroundType(this.Const.BackgroundType.ConvertedCultist);}
					skill.m.CustomPerkTree = [];
					local numRows = stringarray[leo]; leo = ++leo;
					for( local rr = 0; rr < numRows; rr = rr )
					{	local numPerks = stringarray[leo]; leo = ++leo;
						local perks = [];
						for( local j = 0; j < numPerks; j = j )
						{	perks.push(stringarray[leo]); leo = ++leo;
							j = ++j;}
						skill.m.CustomPerkTree.push(perks);
						rr = ++rr;
					}
					if (skill.m.CustomPerkTree != []){skill.buildPerkTree();} //if (skill.m.CustomPerkTree != null)
				}
				if (skill.m.ID == "perk.gifted") {skill.m.IsApplied = true;}
				//LEGENDS
				if (skill.m.ID == "trait.intensive_training_trait")
				{	skill.m.HitpointsAdded = stringarray[leo]; leo = ++leo;
					skill.m.StaminaAdded = stringarray[leo]; leo = ++leo;
					skill.m.BraveAdded = stringarray[leo]; leo = ++leo;
					skill.m.IniAdded = stringarray[leo]; leo = ++leo;
					skill.m.MatkAdded = stringarray[leo]; leo = ++leo;
					skill.m.RatkAdded = stringarray[leo]; leo = ++leo;
					skill.m.MdefAdded = stringarray[leo]; leo = ++leo;
					skill.m.RdefAdded = stringarray[leo]; leo = ++leo;
					skill.m.BonusXP = stringarray[leo]; leo = ++leo;
					skill.m.TraitGained = stringarray[leo]; leo = ++leo;}
				if (skill.m.ID == "trait.pit_fighter" || skill.m.ID == "trait.arena_fighter" || skill.m.ID == "trait.arena_veteran")
				{	b.getFlags().set("ArenaFights", stringarray[leo]); leo = ++leo;
					b.getFlags().set("ArenaFightsWon", stringarray[leo]); leo = ++leo;}
				skillz.add(skill);
			}
			skillz.m.IsUpdating = false;
			if (stringarray[leo] != "Finish"){return null}
		}

		if (_iesettings.hasLS && LSBBegin != 0)
		{
			if (stringarray[leo] == "Finish" || leo == 1){leo = LSBBegin}
			b.m.LifetimeStats.Kills = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.Battles = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.BattlesWithoutMe = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.MostPowerfulVanquishedType = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.MostPowerfulVanquished = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.MostPowerfulVanquishedXP = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.FavoriteWeapon = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.FavoriteWeaponUses = stringarray[leo]; leo = ++leo;
			b.m.LifetimeStats.CurrentWeaponUses = stringarray[leo]; leo = ++leo;
			//LEGENDS
			local lstags = b.m.LifetimeStats.Tags;
			local tagsquantity = stringarray[leo]; leo = ++leo;
			lstags.m = {};
			for( local ctag = 0; ctag < tagsquantity; ctag = ++ctag )
			{	local key = stringarray[leo]; leo = ++leo;
				local value = stringarray[leo]; leo = ++leo;
				lstags.set(key, value);}
			if (stringarray[leo] != "Finish"){return null}
		}

		if (_iesettings.hasGS && EqBBegin != 0)
		{
			if (stringarray[leo] == "Finish" || leo == 1){leo = EqBBegin}
			local itemz = b.m.Items;
			itemz.clear();
			//item container

			itemz.m.UnlockedBagSlots = b.getSkills().hasSkill("perk.bags_and_belts") ? 4 : 2;
			//itemz.m.UnlockedBagSlots = stringarray[leo]; leo = ++leo;
			local numItems = stringarray[leo]; leo = ++leo;
			for( local i = 0; i < numItems; i = ++i )
			{
				local slotType = stringarray[leo]; leo = ++leo;
				//this.logDebug("leo "+leo+" value "+stringarray[leo]+" id "+curitem.m.ID);
				local curitem = this.new(stringarray[leo]); leo = ++leo;
				local HS = false;
				if ("HiddenString" in curitem.m){HS = true;
				curitem.m.HiddenString = stringarray[leo]; leo = ++leo;}
				//item.nut
				curitem.m.IsToBeRepaired = stringarray[leo]; leo = ++leo;
				curitem.m.Variant = stringarray[leo]; leo = ++leo;
				curitem.m.Condition = stringarray[leo]; leo = ++leo;
				curitem.m.PriceMult = stringarray[leo]; leo = ++leo;
				curitem.m.MagicNumber = stringarray[leo]; leo = ++leo;
				curitem.m.Name = stringarray[leo]; leo = ++leo;
				//LEGENDS
				//curitem.m.OldID = stringarray[leo]; leo = ++leo; //let's see if this works without it
				curitem.m.OldID = curitem.getInstanceID();
				curitem.m.RuneVariant = stringarray[leo]; leo = ++leo;
				curitem.m.IsToBeSalvaged = stringarray[leo]; leo = ++leo;
				curitem.m.IsToBeRepairedQueue = stringarray[leo]; leo = ++leo;
				curitem.m.IsToBeSalvagedQueue = stringarray[leo]; leo = ++leo;
				curitem.m.RuneBonus1 = stringarray[leo]; leo = ++leo;
				curitem.m.RuneBonus2 = stringarray[leo]; leo = ++leo;
				//------------------------------------------------------------------------------------------------
				if(curitem.isItemType(this.Const.Items.ItemType.Ammo) && !curitem.isItemType(this.Const.Items.ItemType.Weapon)) //throwing weapons age gonna be serialized with other weapons
				{curitem.m.Ammo = stringarray[leo]; leo = ++leo;}
				if(curitem.isItemType(this.Const.Items.ItemType.Weapon))
				{	curitem.m.Ammo = stringarray[leo]; leo = ++leo;
					if(curitem.isItemType(this.Const.Items.ItemType.Named) || HS == true)
					{
						curitem.m.ConditionMax = stringarray[leo]; leo = ++leo;
						curitem.m.StaminaModifier = stringarray[leo]; leo = ++leo;
						curitem.m.RegularDamage = stringarray[leo]; leo = ++leo;
						curitem.m.RegularDamageMax = stringarray[leo]; leo = ++leo;
						curitem.m.ArmorDamageMult = stringarray[leo]; leo = ++leo;
						curitem.m.ChanceToHitHead = stringarray[leo]; leo = ++leo;
						curitem.m.ShieldDamage = stringarray[leo]; leo = ++leo;
						curitem.m.AdditionalAccuracy = stringarray[leo]; leo = ++leo;
						curitem.m.DirectDamageAdd = stringarray[leo]; leo = ++leo;
						curitem.m.FatigueOnSkillUse = stringarray[leo]; leo = ++leo;
						curitem.m.AmmoMax = stringarray[leo]; leo = ++leo;}
					curitem.m.Condition = this.Math.minf(curitem.m.ConditionMax, curitem.m.Condition);
					if(curitem.m.Ammo != 0 && curitem.m.AmmoMax == 0)
					{	curitem.m.AmmoMax = curitem.m.Ammo;	}
					if(curitem.isRuned()){curitem.updateRuneSigil();}
				}
				if(curitem.isItemType(this.Const.Items.ItemType.Shield))
				{
					if(curitem.isItemType(this.Const.Items.ItemType.Named) || HS == true)
					{	curitem.m.ConditionMax = stringarray[leo]; leo = ++leo;
						curitem.m.StaminaModifier = stringarray[leo]; leo = ++leo;
						curitem.m.MeleeDefense = stringarray[leo]; leo = ++leo;
						curitem.m.RangedDefense = stringarray[leo]; leo = ++leo;
						curitem.m.FatigueOnSkillUse = stringarray[leo]; leo = ++leo;}
					if(curitem.m.ID == "shield.faction_kite_shield" || curitem.m.ID == "shield.faction_heater_shield")
					{	curitem.m.Faction = stringarray[leo]; leo = ++leo;}
					curitem.m.Condition = this.Math.minf(curitem.m.ConditionMax, curitem.m.Condition);
					if(curitem.isRuned()){curitem.updateRuneSigil();}
				}

				curitem.updateVariant();
				local win = false;
				if (slotType == this.Const.ItemSlot.Bag)
				{win = itemz.addToBag(curitem);}
				else
				{win = itemz.equip(curitem);} //to hell with overflown items
			}
			if (stringarray[leo] != "Finish"){return null}
		} //gear end

		result = stringarray[leo];
		return result;
	}

	q.RequestingPerkData = @() function( _result )
	{
		local result = [];
		local r = 0;
		local perkttreeeeee = gimmeperks();

		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				local id = perkttreeeeee[_result.ButOne][_result.ButTwo].ID;
				local pt = ::DynamicPerks.PerkGroups.findById(id);
				foreach( index, arrAdd in pt.getTree() )
				{
					foreach( perkID in arrAdd )
					{
						local perk = ::Const.Perks.findById(perkID);
						if (b.getPerkTree().hasPerk(perk.ID))
						{
							 r = {
								ID = perk.ID,
								Icon = perk.Icon,
							};
						}
						else
						{
							r = {
								ID = perk.ID,
								Icon = perk.IconDisabled,
							};
						}
						result.push(r);
					}
				}
				break;
			}
		};
		return result;
	}

	q.AddPG = @() function( _result )
	{
		local perkttreeeeee = gimmeperks();

		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				local id = perkttreeeeee[_result.ButOne][_result.ButTwo].ID;
				b.getPerkTree().addPerkGroup(id);
				break;
			}
		};
	}

	q.AddPerk = @() function( _result )
	{
		local result = null;
		local perkttreeeeee = gimmeperks();
		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				local bg = b.getBackground();
				local id = perkttreeeeee[_result.ButOne][_result.ButTwo].ID;
				local pt = ::DynamicPerks.PerkGroups.findById(id);
				local counter = 0;
				foreach( index, row in pt.getTree() )
				{
					foreach( perkID in row )
					{
						if (counter == _result.PerkId)
						{
							//this.logDebug("countr "+counter+" perkid"+_result.PerkId+" row "+index+" column"+perkAdd);
							local perk = ::Const.Perks.findById(perkID)
							if (b.getSkills().hasSkill(perk.ID))
							{
								b.getSkills().removeAllByID(perk.ID);
								b.getSkills().collectGarbage(true);
								b.m.PerkPoints +=1;
								b.m.PerkPointsSpent = b.m.PerkPointsSpent - 1;
							}
							if (b.getPerkTree().hasPerk(perkID))
							{
								b.getPerkTree().removePerk(perkID);
							}
							else
							{
								b.getPerkTree().addPerk(perkID, index + 1);
							}
						}
						counter +=1;
					}
				}
				result =
				{
					PerkPoints = b.getPerkPoints(),
				};
				break;
			}
		};
		return result;
	}

	q.RemovePG = @() function( _result )
	{
		local result = null;
		local perkttreeeeee = gimmeperks();
		local brothers = this.World.getPlayerRoster().getAll();
		foreach( b in brothers )
		{
			if (b.getID() == _result.BroId)
			{
				local bg = b.getBackground();
				local pt = perkttreeeeee[_result.ButOne];
				foreach( tr in pt )
				{
					local perkgroup = tr.Tree;
					foreach( index, arrAdd in perkgroup )
					{
						foreach( perkAdd in arrAdd )
						{
							//this.logDebug("countr "+counter+" perkid"+_result.PerkId+" row "+index+" column"+perkAdd);
							local perk = clone ::Const.Perks.findById(perkAdd);
							if (b.getSkills().hasSkill(perk.ID))
							{
								b.getSkills().removeAllByID(perk.ID);
								b.getSkills().collectGarbage(true);
								b.m.PerkPoints +=1;
								b.m.PerkPointsSpent = b.m.PerkPointsSpent - 1;
							}
							b.getPerkTree().removePerk(perk.ID);
						}
					}
				}
				result =
				{
					PerkPoints = b.getPerkPoints(),
				};
				break;
			}
		};
		return result;
	}

	q.gimmeperks = @() function()
	{
		local function toUIData( _collectionID )
		{
			local ret = [];
			foreach (groupID in ::DynamicPerks.PerkGroupCategories.findById(_collectionID).getGroups())
			{
				local group = ::DynamicPerks.PerkGroups.findById(groupID);
				ret.push({
					ID = groupID,
					Name = group.getName()
					Tree = group.getTree()
				});
			}
			return ret;
		}

		local perkttreeeeee = {
			Special = []
		};

		foreach (category in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			perkttreeeeee[category.getName()] <- toUIData(category.getID());
		}

		foreach (perkGroup in ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup))
		{
			perkttreeeeee.Special.push({
				ID = perkGroup.getID(),
				Name = perkGroup.getName(),
				Tree = perkGroup.getTree()
			})
		}

		return perkttreeeeee;
	}

	q.prepareyourtraits = @() function()
	{
		local traits = [
			[
				"trait.addict",
				"scripts/skills/traits/addict_trait"
			],
			[
				"trait.cultist_fanatic",
				"scripts/skills/traits/cultist_fanatic_trait"
			],
			[
				"trait.cultist_zealot",
				"scripts/skills/traits/cultist_zealot_trait"
			],
			[
				"trait.cultist_acolyte",
				"scripts/skills/traits/cultist_acolyte_trait"
			],
			[
				"trait.cultist_disciple",
				"scripts/skills/traits/cultist_disciple_trait"
			],
			[
				"trait.cultist_chosen",
				"scripts/skills/traits/cultist_chosen_trait"
			],
			[
				"trait.cultist_prophet",
				"scripts/skills/traits/cultist_prophet_trait"
			],
	 		[
				"trait.glorious",
				"scripts/skills/traits/glorious_endurance_trait"
			],
			[
				"trait.glorious",
				"scripts/skills/traits/glorious_quickness_trait"
			],
			[
				"trait.glorious",
				"scripts/skills/traits/glorious_resolve_trait"
			],
	 		[
				"trait.pit_fighter",
				"scripts/skills/traits/arena_pit_fighter_trait"
			],
			[
				"trait.arena_fighter",
				"scripts/skills/traits/arena_fighter_trait"
			],
			[
				"trait.arena_veteran",
				"scripts/skills/traits/arena_veteran_trait"
			],
			[
				"trait.mad",
				"scripts/skills/traits/mad_trait"
			],
			[
				"trait.old",
				"scripts/skills/traits/old_trait"
			],
			[
				"trait.player",
				"scripts/skills/traits/player_character_trait"
			],
			[
				"trait.oath_of_camaraderie",
				"scripts/skills/traits/oath_of_camaraderie_trait"
			],
			[
				"trait.oath_of_distinction",
				"scripts/skills/traits/oath_of_distinction_trait"
			],
			[
				"trait.oath_of_dominion",
				"scripts/skills/traits/oath_of_dominion_trait"
			],
			[
				"trait.oath_of_endurance",
				"scripts/skills/traits/oath_of_endurance_trait"
			],
			[
				"trait.oath_of_fortification",
				"scripts/skills/traits/oath_of_fortification_trait"
			],
			[
				"trait.oath_of_honor",
				"scripts/skills/traits/oath_of_honor_trait"
			],
			[
				"trait.oath_of_humility",
				"scripts/skills/traits/oath_of_humility_trait"
			],
			[
				"trait.oath_of_righteousness",
				"scripts/skills/traits/oath_of_righteousness_trait"
			],
			[
				"trait.oath_of_sacrifice",
				"scripts/skills/traits/oath_of_sacrifice_trait"
			],
			[
				"trait.oath_of_valor",
				"scripts/skills/traits/oath_of_valor_trait"
			],
			[
				"trait.oath_of_vengeance",
				"scripts/skills/traits/oath_of_vengeance_trait"
			],
			[
				"trait.oath_of_wrath",
				"scripts/skills/traits/oath_of_wrath_trait"
			]
		];
		return traits;
	}

	q.prepareyourbgs = @() function()
	{
		local ret = [];
		local ids = [];
		foreach (script in ::IO.enumerateFiles("scripts/skills/backgrounds"))
		{
			if (script == "scripts/skills/backgrounds/character_background")
				continue;

			local bg = ::new(script);
			if (ids.find(bg.getID()) != null)
				continue;

			ids.push(bg.getID());
			ret.push([bg.getID(), script, bg.getIcon()]);
		}

		return ret;
	}

	q.prepareNI = @() function()
	{
		//this.World.Assets.getStash().getFirstEmptySlot()
		local namedstuff =
		{
			CurrentItem = {
				ConditionMax = null,
				StaminaModifier = null,
				MeleeDefense = null,
				RangedDefense = null,
				FatigueOnSkillUse = null,
				RegularDamage = null,
				RegularDamageMax = null,
				ArmorDamageMult = null,
				DirectDamageAdd = null,
				ChanceToHitHead = null,
				ShieldDamage = null,
				AdditionalAccuracy = null,
				AmmoMax = null,
			},
			Items =
			{
				Weapons =
				{
					Stats = ["ConditionMax", "StaminaModifier", "RegularDamage", "RegularDamageMax", "ArmorDamageMult", "DirectDamageAdd", "FatigueOnSkillUse", "ChanceToHitHead", "ShieldDamage", "AdditionalAccuracy", "AmmoMax"],
					Ref = "scripts/items/weapons/named/",
					Unwanted = "named_weapon",
					List = [],
				},
				Shields =
				{
					Stats = ["ConditionMax", "StaminaModifier", "MeleeDefense", "RangedDefense", "FatigueOnSkillUse"],
					Ref = "scripts/items/shields/named/",
					Unwanted = "named_shield",
					List = [],
				},
				Armor =
				{
					Stats = ["ConditionMax", "StaminaModifier"],
					Ref = "scripts/items/armor/named/",
					Unwanted = "named_armor",
					List = [],
				},
				Helmets =
				{
					Stats = ["ConditionMax", "StaminaModifier"],
					Ref = "scripts/items/helmets/named/",
					Unwanted = "named_helmet",
					List = [],
				},
				Legendary =
				{
					//Stats = [],
					List = [
/* 					"scripts/items/armor/legendary/armor_of_davkul",
					"scripts/items/armor/legendary/emperors_armor",
					"scripts/items/armor/legendary/ijirok_armor", */
					"scripts/items/helmets/legendary/emperors_countenance",
					"scripts/items/helmets/legendary/ijirok_helmet",
					"scripts/items/helmets/legendary/mask_of_davkul",
					"scripts/items/helmets/physician_mask",
					"scripts/items/shields/legendary/gilders_embrace_shield",
					"scripts/items/shields/special/craftable_kraken_shield",
					"scripts/items/weapons/legendary/lightbringer_sword",
					"scripts/items/weapons/legendary/obsidian_dagger",
					"scripts/items/shields/special/craftable_schrat_shield",
					"scripts/items/accessory/legendary/cursed_crystal_skull",
					"scripts/items/accessory/undead_trophy_item",
					"scripts/items/accessory/orc_trophy_item",
					"scripts/items/accessory/goblin_trophy_item",
					"scripts/items/accessory/sergeant_badge_item",
					"scripts/items/accessory/hexen_trophy_item",
					"scripts/items/accessory/heavily_armored_wardog_item",
					"scripts/items/accessory/heavily_armored_warhound_item",
					"scripts/items/accessory/wolf_item",
					"scripts/items/accessory/falcon_item",
					"scripts/items/special/golden_goose_item",
					"scripts/items/accessory/oathtaker_skull_01_item",
					"scripts/items/accessory/oathtaker_skull_02_item",
					],
				},
				Alchemy =
				{
					List = ["scripts/items/accessory/antidote_item",
					"scripts/items/accessory/berserker_mushrooms_item",
					"scripts/items/accessory/cat_potion_item",
					"scripts/items/accessory/iron_will_potion_item",
					"scripts/items/accessory/lionheart_potion_item",
					"scripts/items/accessory/night_vision_elixir_item",
					"scripts/items/accessory/poison_item",
					"scripts/items/accessory/spider_poison_item",
					"scripts/items/accessory/recovery_potion_item",
					"scripts/items/misc/miracle_drug_item",
					"scripts/items/misc/anatomist/alp_potion_item",
					"scripts/items/misc/anatomist/ancient_priest_potion_item",
					"scripts/items/misc/anatomist/apotheosis_potion_item",
					"scripts/items/misc/anatomist/direwolf_potion_item",
					"scripts/items/misc/anatomist/fallen_hero_potion_item",
					"scripts/items/misc/anatomist/geist_potion_item",
					"scripts/items/misc/anatomist/goblin_grunt_potion_item",
					"scripts/items/misc/anatomist/goblin_overseer_potion_item",
					"scripts/items/misc/anatomist/goblin_shaman_potion_item",
					"scripts/items/misc/anatomist/hexe_potion_item",
					"scripts/items/misc/anatomist/honor_guard_potion_item",
					"scripts/items/misc/anatomist/hyena_potion_item",
					"scripts/items/misc/anatomist/ifrit_potion_item",
					"scripts/items/misc/anatomist/ijirok_potion_item",
					"scripts/items/misc/anatomist/kraken_potion_item",
					"scripts/items/misc/anatomist/lindwurm_potion_item",
					"scripts/items/misc/anatomist/lorekeeper_potion_item",
					"scripts/items/misc/anatomist/nachzehrer_potion_item",
					"scripts/items/misc/anatomist/necromancer_potion_item",
					"scripts/items/misc/anatomist/necrosavant_potion_item",
					"scripts/items/misc/anatomist/orc_berserker_potion_item",
					"scripts/items/misc/anatomist/orc_warlord_potion_item",
					"scripts/items/misc/anatomist/orc_warrior_potion_item",
					"scripts/items/misc/anatomist/orc_young_potion_item",
					"scripts/items/misc/anatomist/rachegeist_potion_item",
					"scripts/items/misc/anatomist/schrat_potion_item",
					"scripts/items/misc/anatomist/serpent_potion_item",
					"scripts/items/misc/anatomist/skeleton_warrior_potion_item",
					"scripts/items/misc/anatomist/unhold_potion_item",
					"scripts/items/misc/anatomist/webknecht_potion_item",
					"scripts/items/misc/anatomist/wiederganger_potion_item",
					"scripts/items/misc/anatomist/research_notes_beasts_item",
					"scripts/items/misc/anatomist/research_notes_greenskins_item",
					"scripts/items/misc/anatomist/research_notes_legendary_item",
					"scripts/items/misc/anatomist/research_notes_undead_item",
					],
				},
				Misc =
				{
					List = [],
				},
			},
		};


		namedstuff.Items.Armor.Ref = "scripts/items/armor/named/";
		namedstuff.Items.Misc.List = ["scripts/items/armor_upgrades/additional_padding_upgrade",
		"scripts/items/armor_upgrades/barbarian_horn_upgrade",
		"scripts/items/armor_upgrades/bone_platings_upgrade",
		"scripts/items/armor_upgrades/direwolf_pelt_upgrade",
		"scripts/items/armor_upgrades/heavy_gladiator_upgrade",
		"scripts/items/armor_upgrades/horn_plate_upgrade",
		"scripts/items/armor_upgrades/hyena_fur_upgrade",
		"scripts/items/armor_upgrades/light_gladiator_upgrade",
		"scripts/items/armor_upgrades/light_padding_replacement_upgrade",
		"scripts/items/armor_upgrades/lindwurm_scales_upgrade",
		"scripts/items/armor_upgrades/protective_runes_upgrade",
		"scripts/items/armor_upgrades/serpent_skin_upgrade",
		"scripts/items/armor_upgrades/unhold_fur_upgrade",
		];


		foreach(type, value in namedstuff.Items)
		{
			if (type != "Legendary" && type != "Alchemy" && type != "Misc")
			{
				value.List = this.IO.enumerateFiles(value.Ref); //array
				local unwantedind = value.List.find(value.Ref+value.Unwanted);
				if (unwantedind != null)
				{
					value.List.remove(unwantedind)
				}
			}
		}
		local misctherest = [
			"scripts/items/misc/unhold_hide_item",
			"scripts/items/misc/vampire_dust_item",
			"scripts/items/tools/smoke_bomb_item",
			"scripts/items/tools/fire_bomb_item",
			"scripts/items/tools/daze_bomb_item",
			"scripts/items/tools/holy_water_item",
			"scripts/items/tools/reinforced_throwing_net",
			"scripts/items/tools/acid_flask_item",
			"scripts/items/accessory/bandage_item",
			"scripts/items/supplies/cured_rations_item",
		];
		namedstuff.Items.Misc.List.extend(misctherest);

		return namedstuff;
	}
});
