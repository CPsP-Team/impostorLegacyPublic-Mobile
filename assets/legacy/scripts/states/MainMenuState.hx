import funkin.data.ClientPrefs;
import funkin.data.FinaleState;
import funkin.data.CosmicubeData;
import funkin.states.TitleState;
import funkin.states.editors.MasterEditorMenu;

import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.events.TextEvent;
import openfl.Lib;

import flixel.text.FlxText;
import flixel.FlxG;

using StringTools;

var debugText:FlxText;
var hiddenField:TextField;

var inputBuffer:String = "";

function onLoad()
{
	if (!ClientPrefs.inDevMode) return;
	
	debugText = new FlxText(0, 0, 1280, 'content/scripts/states/MainMenuState.hx\nPress 9 to go to credits roll sequence\nPress 7 to toggle Finale Endgame Sequence\nPress 6 to Force unlock Cosmicube requirements\nPress 5 to delete Cosmicube unlocks\nPress 4 to toggle Force Unlock for freeplay and story mode\nPress 3 to delete bought songs\nPress 2 to give a lot of moneys\nPress 1 to set money to 0\nPress E to open Editors Menu',
		12.5);
	debugText.alignment = 'right';
	add(debugText);

  #if mobile
	Lib.current.stage.addEventListener(TextEvent.TEXT_INPUT, onTextInput);

	#if ios
	hiddenField = new TextField();
	hiddenField.type = TextFieldType.INPUT;
	hiddenField.visible = false;
	Lib.current.stage.addChild(hiddenField);
	#end
	#end
}

function onUpdate()
{
	if (!ClientPrefs.inDevMode) return;

	#if mobile
	if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(debugText))
	{
		#if android
		if (Lib.current.stage.window != null) {
			Lib.current.stage.window.textInput = true;
		}
		#elseif ios
		if (hiddenField != null) {
			Lib.current.stage.focus = hiddenField;
		}
		#end
	}
	#end

	if (FlxG.keys.justPressed.ZERO)  triggerAction("0");
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

#if mobile
function onTextInput(e:TextEvent)
{
	if (!ClientPrefs.inDevMode) return;
	triggerAction(e.text.toUpperCase());

	#if android
	if (Lib.current.stage.window != null) Lib.current.stage.window.textInput = true;
	#end
}
#end

function triggerAction(char:String)
{
	inputBuffer += char;

	if (inputBuffer.length > 4) {
		inputBuffer = inputBuffer.substr(inputBuffer.length - 4);
	}

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