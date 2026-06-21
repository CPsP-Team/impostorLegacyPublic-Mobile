import funkin.data.ClientPrefs;
import funkin.data.FinaleState;
import funkin.data.CosmicubeData;
import funkin.states.TitleState;
import funkin.states.editors.MasterEditorMenu;

import flixel.text.FlxText;
import flixel.FlxG;

using StringTools;

var debugText:FlxText;
var idklmaowhattsis:Int = 0;

var acts:Array<String> = ["9", "7", "6", "5", "4", "3", "2", "1", "E"]; 
var texts:Array<String> = [
	"Go to Credits Roll Sequence (9)", 
	"Toggle Finale Endgame Sequence (7)", 
	"Force unlock Cosmicube requirements (6)", 
	"Delete Cosmicube Unlocks (5)", 
	"Toggle Freeplay/Story Unlock (4)", 
	"Delete Bought Songs (3)", 
	"Give a lot of money!!! (2)", 
	"Set Money to 0 (1)", 
	"Open Editors Menu (E)"
];

function onLoad()
{
	if (!ClientPrefs.inDevMode) return;
	var debugText = new FlxText(0, 0, 1280,
		'content/scripts/states/MainMenuState.hx\nPress 9 to go to credits roll sequence\nPress Shift 7 to toggle Finale Endgame Sequence\nPress 6 to Force unlock Cosmicube requirements\nPress 5 to delete Cosmicube unlocks\nPress 4 to toggle Force Unlock for freeplay and story mode\nPress 3 to delete bought songs\nPress 2 to give a lot of moneys\nPress 1 to set money to 0',
		12.5);
	debugText.alignment = 'right';
	add(debugText);
}

function onUpdate()
{
	if (!ClientPrefs.inDevMode) return;
	
	if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.SEVEN)
	{
		ClientPrefs.finaleState = (ClientPrefs.finaleState == FinaleState.ACTIVE ? FinaleState.INACTIVE : FinaleState.ACTIVE);
		ClientPrefs.flush();
		TitleState.initialized = false;
		FlxG.resetGame();
	}
	if (FlxG.keys.justPressed.NINE)
	{
		persistentUpdate = persistentDraw = false;
		openSubState(new funkin.states.substates.CreditsRollSubState(true, function() persistentUpdate = persistentDraw = true, function() persistentUpdate = persistentDraw = true));
	}
	if (FlxG.keys.justPressed.SIX)
	{
		ClientPrefs.forceUnlockReq = !ClientPrefs.forceUnlockReq;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlockReq ? 'FORCE UNLOCK REQ ON' : 'FORCE UNLOCK REQ OFF');
	}
	if (FlxG.keys.justPressed.FIVE)
	{
		ClientPrefs.cosmicubeUnlocks.resize(0);
		ClientPrefs.flush();
		trace('Cosmicube progress reset');
	}
	if (FlxG.keys.justPressed.FOUR)
	{
		ClientPrefs.forceUnlock = !ClientPrefs.forceUnlock;
		ClientPrefs.doubletrouble = ClientPrefs.forceUnlock;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlock ? 'FORCE UNLOCK ON' : 'FORCE UNLOCK OFF');
	}
	if (FlxG.keys.justPressed.THREE)
	{
		ClientPrefs.unlockedSongs = [];
		ClientPrefs.flush();
		trace('WIPED SONG DATA');
	}
	if (FlxG.keys.justPressed.TWO)
	{
		CosmicubeData.currentMoney = 2_147_483_647;
		ClientPrefs.flush();
		trace('FREE MONEY');
	}
	if (FlxG.keys.justPressed.ONE)
	{
		CosmicubeData.currentMoney = 0;
		ClientPrefs.flush();
		trace('no money :(');
	}
}