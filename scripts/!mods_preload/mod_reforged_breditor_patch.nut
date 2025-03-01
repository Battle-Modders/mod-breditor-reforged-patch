::ModBreditorReforgedPatch <- {
	Version = "1.0.0",
	ID = "mod_breditor_reforged_patch",
	Name = "Breditor Reforged Patch",
};

::ModBreditorReforgedPatch.MH <- ::Hooks.register(::ModBreditorReforgedPatch.ID, ::ModBreditorReforgedPatch.Version, ::ModBreditorReforgedPatch.Name);
::ModBreditorReforgedPatch.MH.require([
	"mod_msu",
	"mod_reforged",
	"mod_breditor"
]);

::ModBreditorReforgedPatch.MH.queue(">mod_breditor", ">mod_msu", function() {
	local mod = ::MSU.Class.Mod(::ModBreditorReforgedPatch.ID, ::ModBreditorReforgedPatch.Version, ::ModBreditorReforgedPatch.Name);
	mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Battle-Modders/mod-breditor-reforged-patch");
	mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/765");

	foreach (file in ::IO.enumerateFiles("mod_breditor_reforged_patch"))
	{
		::include(file);
	}

	foreach (file in ::IO.enumerateFiles("ui/mods/mod_breditor_reforged_patch/js_hooks"))
	{
		::Hooks.registerJS(file + ".js");
	}
});
