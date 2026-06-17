package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;
	
	var warnText:FlxText;
	#if mobile
	var disableButton:FlxSprite;
	var keepButton:FlxSprite;
	var disableText:FlxText;
	var keepText:FlxText;
	#end
	
	override function create()
	{
		super.create();

		var inputText:String = "Press Confirm/A to keep these effects on.\nPress Back/B to disable these effects now.";
		#if mobile
		inputText = "Tap an option below to choose how flashing effects should work.";
		#end
		
		warnText = new FlxText(0, 0, FlxG.width, '
WARNING!\n
This mod contains effects that may trigger photosensitivity.\n
${inputText}\n
You may change this anytime in the Options menu.
		', 32);
		warnText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter();
		#if mobile
		warnText.y -= 60;
		#end
		add(warnText);

		#if mobile
		createMobileButtons();
		#end
	}
	
	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (controls.ACCEPT) choosePhotosensitive(false);
			if (controls.BACK) choosePhotosensitive(true);

			#if mobile
			if (touchReleasedObject(disableButton)) choosePhotosensitive(true);
			if (touchReleasedObject(keepButton)) choosePhotosensitive(false);
			#end
		}
		
		super.update(elapsed);
	}

	function choosePhotosensitive(disableEffects:Bool):Void
	{
		if (leftState) return;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		ClientPrefs.photosensitive = disableEffects;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		#if mobile
		FlxTween.tween(disableButton, {alpha: 0}, 0.25);
		FlxTween.tween(keepButton, {alpha: 0}, 0.25);
		FlxTween.tween(disableText, {alpha: 0}, 0.25);
		FlxTween.tween(keepText, {alpha: 0}, 0.25);
		#end

		if (disableEffects)
		{
			FlxTween.tween(warnText, {alpha: 0}, 1,
			{
				onComplete: function(twn:FlxTween) {
					FlxG.switchState(TitleState.new);
				}
			});
		}
		else
		{
			FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
				new FlxTimer().start(0.5, function(tmr:FlxTimer) {
					FlxG.switchState(TitleState.new);
				});
			});
		}

		leftState = true;
	}

	#if mobile
	function createMobileButtons():Void
	{
		var buttonWidth:Int = Std.int(Math.min(430, FlxG.width * 0.42));
		var buttonHeight:Int = 86;
		var gap:Float = 24;
		var startX:Float = (FlxG.width - buttonWidth * 2 - gap) * 0.5;
		var buttonY:Float = FlxG.height - buttonHeight - 42;

		disableButton = createActionButton(startX, buttonY, buttonWidth, buttonHeight, 0xffc83b4a);
		keepButton = createActionButton(startX + buttonWidth + gap, buttonY, buttonWidth, buttonHeight, 0xff2bbf72);
		disableText = createActionText(disableButton, 'DISABLE EFFECTS');
		keepText = createActionText(keepButton, 'KEEP EFFECTS ON');

		add(disableButton);
		add(keepButton);
		add(disableText);
		add(keepText);
	}

	function createActionButton(x:Float, y:Float, width:Int, height:Int, color:FlxColor):FlxSprite
	{
		var button:FlxSprite = new FlxSprite(x, y).makeGraphic(width, height, color);
		button.alpha = 0.9;
		button.scrollFactor.set();
		return button;
	}

	function createActionText(button:FlxSprite, label:String):FlxText
	{
		var text:FlxText = new FlxText(button.x, button.y + 23, button.width, label, 28);
		text.setFormat(Paths.DEFAULT_FONT, 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.borderSize = 2;
		text.scrollFactor.set();
		return text;
	}

	function touchReleasedObject(obj:FlxSprite):Bool
	{
		if (obj == null || !obj.alive || !obj.visible) return false;
		if (FlxG.mouse.justReleased && FlxG.mouse.overlaps(obj)) return true;

		for (touch in FlxG.touches.list)
		{
			if (touch.justReleased && touch.overlaps(obj)) return true;
		}

		return false;
	}
	#end
}
