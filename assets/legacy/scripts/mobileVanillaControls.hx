// Made by Dechis (dx7405), MaysLastPlay, inspired from FNF Official mobile controls by FunkinCrew

var mobileNoteX:Array<Float> = [249, 415, 738, 904];
var desktopNoteX:Array<Float> = [898, 985, 1075, 1163];
var laneHeld:Array<Bool> = [false, false, false, false];
var laneSprites:Array<FlxSprite> = [];
var laneY:Float = 40;
var ratingY:Float = 160;
var noteScale:Float = 1.0;
var mobileLayout:Bool = true;
var playerStrumYDelta:Array<Float> = [0, 0, 0, 0];

function onCreatePost():Void
{
	noteFix();
	createTouchLanes();
	syncTouchLanesToPlayerStrums();
}

function onSongStart():Void
{
	noteFix();
	syncTouchLanesToPlayerStrums();
}

function postReceptorGeneration():Void
{
	noteFix();
	createTouchLanes();
	syncTouchLanesToPlayerStrums();
}

function onUpdatePost(elapsed:Float):Void
{
	noteFix();
	syncTouchLanesToPlayerStrums();
	syncSplashesToPlayerStrums();
	updateTouchLanes();
}

function noteFix():Void
{
	if (!usingVanillaMobileControls()) return;
	
	var noteX:Array<Float> = isMobileTouch() ? mobileNoteX : desktopNoteX;
	var downscroll:Bool = checkArrowDownscroll();
	
	if (downscroll)
	{
		laneY = isMobileTouch() ? 520 : 606;
		ratingY = isMobileTouch() ? 450 : 546;
	}
	else
	{
		laneY = isMobileTouch() ? 100 : 40;
		ratingY = isMobileTouch() ? 260 : 160;
	}
	
	var isPixel:Bool = (PlayState.isPixelStage != null && PlayState.isPixelStage);
	
	if (isPixel) 
	{
		noteScale = 6.0;
	} 
	else 
	{
		noteScale = isMobileTouch() ? 0.70 : 0.82;
	}
	
	for (playField in playFields)
	{
		var isPlayerField:Bool = playField.ID == 0;
		playField.visible = isPlayerField;
		playField.alpha = isPlayerField ? 1 : 0;
		
		for (i in 0...Std.int(Math.min(4, playField.members.length)))
		{
			var strum = playField.members[i];
			if (strum == null) continue;
			
			if (isPlayerField) playerStrumYDelta[i] = laneY - strum.y;
			
			strum.x = noteX[i];
			strum.y = laneY;
			strum.downScroll = downscroll;
			
			if (isPixel)
			{
				strum.scale.set(noteScale, noteScale);
				strum.updateHitbox();
			}
			
			if (isPlayerField)
			{
				strum.alpha = 1;
				strum.alphaMult = 1;
				strum.visible = true;
			}
			else
			{
				strum.alpha = 0;
				strum.alphaMult = 0;
				strum.visible = false;
			}
		}
	}
	
	var playerField = getPlayerField();
	
	for (note in notes)
	{
		if (note == null) continue;
		
		var isPlayerNote:Bool = note.lane == 0;
		note.visible = isPlayerNote;
		note.alpha = isPlayerNote ? 1 : 0;
		if (!isPlayerNote) continue;
		
		if (note.isSustainNote)
		{
			note.scale.x = note.baseScale.x;
		}
		else
		{
			note.scale.x = noteScale;
			note.scale.y = noteScale;
			note.updateHitbox();
		}
		
		if (playerField != null && note.noteData >= 0 && note.noteData < playerField.members.length)
		{
			var strum = playerField.members[note.noteData];
			if (strum != null)
			{
				if (note.noteData < playerStrumYDelta.length) note.y += playerStrumYDelta[note.noteData];
				note.x = strum.x + ((strum.width - note.width) * 0.5);
				if (note.isSustainNote) note.clip(strum);
			}
		}
	}
}

function createTouchLanes():Void
{
	if (!usingVanillaMobileControls()) return;
	if (laneSprites.length > 0) return;
	
	for (i in 0...4)
	{
		var lane = new FlxSprite(mobileNoteX[i], 0).makeGraphic(1, 1, FlxColor.WHITE);
		lane.setSize(120, FlxG.height);
		lane.alpha = 0.001;
		lane.scrollFactor.set();
		lane.camera = camHUD;
		add(lane);
		laneSprites.push(lane);
	}
}

function syncTouchLanesToPlayerStrums():Void
{
	if (!usingVanillaMobileControls()) return;
	if (laneSprites.length < 4) return;
	
	var field = getPlayerField();
	if (field == null) return;
	
	for (i in 0...Std.int(Math.min(4, field.members.length)))
	{
		var strum = field.members[i];
		var lane = laneSprites[i];
		if (strum == null || lane == null) continue;
		
		var pad:Float = 24;
		lane.x = strum.x - pad;
		lane.y = 0;
		lane.setSize(strum.width + (pad * 2), FlxG.height);
	}
}

function syncSplashesToPlayerStrums():Void
{
	if (!usingVanillaMobileControls()) return;
	
	var field = getPlayerField();
	if (field == null) return;
	
	for (splash in field.grpNoteSplashes)
	{
		syncSplashToStrum(splash, field);
	}
	
	for (splash in field.grpSusSplashes)
	{
		syncSplashToStrum(splash, field);
	}
}

function syncSplashToStrum(splash, field):Void
{
	if (splash == null || !splash.alive || splash.noteData < 0 || splash.noteData >= field.members.length) return;
	
	var strum = field.members[splash.noteData];
	if (strum == null) return;
	
	splash.x = strum.x + ((strum.width - splash.width) * 0.5);
	splash.y = strum.y + ((strum.height - splash.height) * 0.5);
	splash.spriteOffset.set(0, 0);
}

function updateTouchLanes():Void
{
	if (!usingVanillaMobileControls()) return;
	
	for (i in 0...laneSprites.length)
	{
		var pressed:Bool = touchOverlaps(laneSprites[i]);
		
		if (pressed && !laneHeld[i])
		{
			laneHeld[i] = true;
			pressLane(i);
		}
		else if (pressed)
		{
			holdLane(i);
		}
		else if (!pressed && laneHeld[i])
		{
			laneHeld[i] = false;
			releaseLane(i);
		}
	}
}

function pressLane(dir:Int):Void
{
	var anyInput:Bool = false;
	var ghostTapped:Bool = true;
	
	for (field in playFields)
	{
		if (field.ID != 0 || !field.canInput()) continue;
		
		anyInput = true;
		
		var topNote = null;
		for (note in field.getNotes(dir))
		{
			if (note.isSustainNote)
			{
				ghostTapped = false;
				continue;
			}
			
			if (topNote == null || note.hitPriority > topNote.hitPriority || (note.hitPriority == topNote.hitPriority && note.strumTime < topNote.strumTime))
			{
				topNote = note;
			}
		}
		
		if (topNote != null)
		{
			field.onNoteHit.dispatch(topNote, field);
			ghostTapped = false;
		}
		else if (field.playAnims)
		{
			var strum = field.members[dir];
			if (strum != null)
			{
				strum.playAnim('pressed');
				strum.resetAnim = 0;
			}
		}
	}
	
	if (ghostTapped && anyInput)
	{
		PlayState.instance.scripts.call('onGhostTap', [dir]);
		
		if (!ClientPrefs.ghostTapping)
		{
			for (field in playFields)
			{
				if (field.ID == 0 && field.canInput()) field.onMissPress.dispatch(dir, field);
			}
		}
	}
}

function holdLane(dir:Int):Void
{
	for (field in playFields)
	{
		if (field.ID != 0 || !field.canInput()) continue;
		
		for (note in field.notes)
		{
			if (note.alive && note.noteData == dir && note.isSustainNote && !note.wasGoodHit && !note.tooLate && Conductor.songPosition >= note.strumTime)
			{
				field.onNoteHit.dispatch(note, field);
			}
		}
	}
}

function isVanillaLaneHeld(dir:Int):Bool
{
	return usingVanillaMobileControls() && dir >= 0 && dir < laneHeld.length && laneHeld[dir];
}

function releaseLane(dir:Int):Void
{
	for (field in playFields)
	{
		if (field.ID != 0 || !field.inControl || field.autoPlayed || !field.playerControls) continue;
		
		var strum = field.members[dir];
		if (strum != null)
		{
			strum.playAnim('static');
			strum.resetAnim = 0;
		}
		
		for (splash in field.grpSusSplashes)
		{
			if (splash.alive && splash.noteData == dir && !splash.completed) splash.kill();
		}
	}
}

function getPlayerField()
{
	for (field in playFields)
	{
		if (field != null && field.ID == 0) return field;
	}
	
	return null;
}

function touchOverlaps(obj:FlxSprite):Bool
{
	if (FlxG.mouse.pressed && FlxG.mouse.overlaps(obj, camHUD)) return true;
	
	for (touch in FlxG.touches.list)
	{
		if (touch.pressed && touch.overlaps(obj, camHUD)) return true;
	}
	
	return false;
}

function isMobileTouch():Bool
{
	return mobileLayout && usingVanillaMobileControls();
}

function checkArrowDownscroll():Bool {
    if (ClientPrefs.mobileControlMode == 'Vanilla') {
        return true;
    }
    
    if (ClientPrefs.downScroll == true) {
        return true;
    }
    
    return false;
}

function usingVanillaMobileControls():Bool
{
	return ClientPrefs.mobileControlMode == 'Vanilla';
}