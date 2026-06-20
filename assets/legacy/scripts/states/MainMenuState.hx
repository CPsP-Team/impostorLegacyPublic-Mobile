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
	
	updateDebugText();
}

function updateDebugText()
{
	if (debugText == null) {
		debugText = new FlxText(0, 0, 1280, '', 14);
		debugText.alignment = 'right';
		add(debugText);
	}

	debugText.text = 'content/scripts/states/MainMenuState.hx\n\nTap this text to change action:\nCURRENT: ' + texts[idklmaowhattsis] + '\n\nTap the LEFT side of the screen to trigger it.';
}

function onUpdate()
{
	if (!ClientPrefs.inDevMode) return;

	if (FlxG.mouse.justPressed)
	{
		if (FlxG.mouse.overlaps(debugText))
		{
			idklmaowhattsis++;
			if (idklmaowhattsis >= acts.length) idklmaowhattsis = 0;
			updateDebugText();
		}
		else if (FlxG.mouse.x <= FlxG.width / 2)
		{
			triggerAction(acts[idklmaowhattsis]);
		}
	}

	if (FlxG.keys.justPressed.ONE)   triggerAction("1");
	if (FlxG.keys.justPressed.TWO)   triggerAction("2");
	if (FlxG.keys.justPressed.THREE) triggerAction("3");
	if (FlxG.keys.justPressed.FOUR)  triggerAction("4");
	if (FlxG.keys.justPressed.FIVE)  triggerAction("5");
	if (FlxG.keys.justPressed.SIX)   triggerAction("6");
	if (FlxG.keys.justPressed.SEVEN) triggerAction("7");
	if (FlxG.keys.justPressed.NINE)  triggerAction("9");
	if (FlxG.keys.justPressed.E)     triggerAction("E");
}

function triggerAction(char:String)
{
	switch (char)
	{
		case "7":
			ClientPrefs.finaleState = (ClientPrefs.finaleState == FinaleState.ACTIVE ? FinaleState.INACTIVE : FinaleState.ACTIVE);
			ClientPrefs.flush();
			TitleState.initialized = false;
			FlxG.resetGame();

		case "9":
			persistentUpdate = persistentDraw = false;
			openSubState(new funkin.states.substates.CreditsRollSubState(true, function() persistentUpdate = persistentDraw = true, function() persistentUpdate = persistentDraw = true));

		case "6":
			ClientPrefs.forceUnlockReq = !ClientPrefs.forceUnlockReq;
			ClientPrefs.flush();
			trace(ClientPrefs.forceUnlockReq ? 'FORCE UNLOCK REQ ON' : 'FORCE UNLOCK REQ OFF');

		case "5":
			ClientPrefs.cosmicubeUnlocks.resize(0);
			ClientPrefs.flush();
			trace('Cosmicube progress reset');

		case "4":
			ClientPrefs.forceUnlock = !ClientPrefs.forceUnlock;
			ClientPrefs.doubletrouble = ClientPrefs.forceUnlock;
			ClientPrefs.flush();
			trace(ClientPrefs.forceUnlock ? 'FORCE UNLOCK ON' : 'FORCE UNLOCK OFF');

		case "3":
			ClientPrefs.unlockedSongs = [];
			ClientPrefs.flush();
			trace('WIPED SONG DATA');

		case "2":
			CosmicubeData.currentMoney = 2_147_483_647;
			ClientPrefs.flush();
			trace('FREE MONEY');

		case "1":
			CosmicubeData.currentMoney = 0;
			ClientPrefs.flush();
			trace('no money :(');
			
		case "E":
			FlxG.switchState(new editors.MasterEditorMenu());
	}
}