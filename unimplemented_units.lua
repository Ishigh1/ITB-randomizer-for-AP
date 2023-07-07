TinyheadMech = {
	Name = "Pitch Mech",
	Class = "Prime",
	Health = 3,
	Image = "MechTinyhead",
	ImageOffset = 9,
	MoveSpeed = 3,
	SkillList = { "Prime_TC_Punt" },
	SoundLocation = "/mech/flying/jet_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
	
AddPawn("TinyheadMech") 

RocketcrabMech = {
	Name = "Lightfoot Mech",
	Class = "Brute",
	Health = 3,
	MoveSpeed = 3,
	Image = "MechRocketcrab",
	ImageOffset = 9,
	SkillList = { "Brute_TC_GuidedMissile", },
	SoundLocation = "/mech/prime/rock_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}

AddPawn("RocketcrabMech")

TiltMech = 
{
	Name = "AOA Mech",
	Class = "Ranged",
	Health = 2,
	Image = "MechTilt",
	ImageOffset = 9,
	MoveSpeed = 3,
	SkillList = { "Ranged_TC_BounceShot" },
	SoundLocation = "/mech/science/pulse_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}

AddPawn("TiltMech")

NapalmMech2 = {
	Name = "Napalm Mech 2",
	Class = "Ranged",
	Health = 2,
	Image = "MechRedtube",
	ImageOffset = 13,
	MoveSpeed = 3,
	SkillList = { "Science_FireBeam", "Passive_FireBoost"  },
	SoundLocation = "/mech/prime/rock_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
	
AddPawn("NapalmMech") 

PlacerMech = 
{
	Name = "Placer Mech",
	Class = "Science",
	Health = 3,
	Image = "MechTritube",
	ImageOffset = 13,
	MoveSpeed = 3,
	SkillList = { "Support_KO_GridCharger" },
	SoundLocation = "/mech/science/pulse_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true,
}

AddPawn("PlacerMech")