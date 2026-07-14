package funkin.backend;

import flixel.FlxSubState;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxGroup.FlxTypedGroup;

import funkin.input.Controls;
import funkin.scripts.*;

#if mobile
import flixel.group.FlxGroup;
import mobile.controls.MobileHitbox;
import mobile.controls.MobileVirtualPad;
#end

class MusicBeatSubstate extends FlxSubState
{
    public static var instance:MusicBeatSubstate;
    
	public function new()
	{
	    instance = this;
		super();
	}
	
	public var curSection:Int = 0;
	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	
	public var curSectionStep:Int = 0;
	public var nextSectionStep:Int = 0;
	
	public var curDecSection:Float = 0;
	public var curDecStep:Float = 0;
	public var curDecBeat:Float = 0;
	
	private var controls(get, never):Controls;
	
	inline function get_controls():Controls return Controls.instance;
	
	#if mobile
	public var virtualPad:MobileVirtualPad;
	public var virtualPadCam:FlxCamera;
	
	public var hitbox:MobileHitbox;
	public var hitboxCam:FlxCamera;

    public function addVirtualPad(DPad:MobileDPadMode, Action:MobileActionMode)
	{
		virtualPad = new MobileVirtualPad(DPad, Action);
		add(virtualPad);
	}
	
	public function addMobileControls(DefaultDrawTarget:Bool = false)
	{
		hitbox = new MobileHitbox();

		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, DefaultDrawTarget);

		hitbox.cameras = [hitboxCam];
		hitbox.visible = false;
		add(hitbox);
	}
	
	public function addVirtualPadCamera(DefaultDrawTarget:Bool = false)
	{
		if (virtualPad != null)
		{
			virtualPadCam = new FlxCamera();
			virtualPadCam.bgColor.alpha = 0;
			FlxG.cameras.add(virtualPadCam, DefaultDrawTarget);
			
			virtualPad.cameras = [virtualPadCam];
		}
	}

	public function removeVirtualPad()
	{
		if (virtualPad != null)
		{
			remove(virtualPad);
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
		}

		if(virtualPadCam != null)
		{
			FlxG.cameras.remove(virtualPadCam);
			virtualPadCam = FlxDestroyUtil.destroy(virtualPadCam);
		}
	}
	
	public function removeMobileControls()
	{
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
		}

		if(hitboxCam != null)
		{
			FlxG.cameras.remove(hitboxCam);
			hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
		}
	}
	#end
	
	public var scripted:Bool = false;
	public var scriptName:String = '';
	public var scriptPrefix:String = 'substates';
	public var scriptGroup:ScriptGroup = new ScriptGroup();
	
	public function initStateScript(?scriptName:String, callOnLoad:Bool = true):Bool
	{
		if (scriptName == null)
		{
			final stateName = Type.getClassName(Type.getClass(this)).split('.').pop();
			scriptName = stateName ?? '???';
		}
		
		scriptGroup.scriptShareables.set('parent', this);
		
		this.scriptName = scriptName;
		
		final scriptFile = FunkinScript.getPath('scripts/$scriptPrefix/$scriptName');
		if (scriptGroup.exists(scriptFile)) return true;
		
		if (FunkinAssets.exists(scriptFile))
		{
			var _script = FunkinScript.fromFile(scriptFile, scriptName, scriptGroup.scriptShareables);
			if (_script.__garbage)
			{
				_script = FlxDestroyUtil.destroy(_script);
				return false;
			}
			
			scriptGroup.parent = this;
			
			Logger.log('script [$scriptName] initialized', NOTICE);
			
			scriptGroup.addScript(_script);
			scripted = true;
		}
		
		if (callOnLoad) scriptGroup.call('onLoad', []);
		
		return scripted;
	}
	
	inline function isHardcodedState() return (scriptGroup != null && !scriptGroup.call('customMenu') == true) || (scriptGroup == null);
	
	public function refreshZ(?group:FlxTypedGroup<FlxBasic>)
	{
		group ??= FlxG.state;
		group.sort(SortUtil.sortByZ, flixel.util.FlxSort.ASCENDING);
	}
	
	override function update(elapsed:Float)
	{
		final oldStep:Int = curStep;
		
		curDecSection = Conductor.getSection(Conductor.songPosition - ClientPrefs.noteOffset);
		updateCurStep();
		updateBeat();
		
		if (curStep > oldStep)
		{
			for (step in oldStep...curStep)
			{
				curStep = step + 1;
				
				updateBeat();
				
				if (curStep >= 0) stepHit();
				
				updateSection();
			}
		}
		else if (curStep < oldStep)
		{
			updateSection(true);
		}
		
		scriptGroup.call('onUpdate', [elapsed]);
		
		super.update(elapsed);
	}
	
	inline function updateSection(rollback:Bool = false):Void
	{
		final lastSection:Int = curSection;
		
		if (rollback)
		{
			curSection = Math.floor(curDecSection);
			updateSectionStep();
			
			if (curSection != lastSection && curSection >= 0) sectionHit();
		}
		else
		{
			while (curStep >= nextSectionStep)
			{
				curSection ++;
				curSectionStep = nextSectionStep;
				nextSectionStep += (getBeatsOnSection() * 4);
				
				if (curSection >= 0) sectionHit();
			}
		}
	}
	
	inline function updateSectionStep():Void
	{
		curSectionStep = Math.round(Conductor.getStep(Conductor.sectionToSeconds(curSection)));
		nextSectionStep = Math.round(Conductor.getStep(Conductor.sectionToSeconds(curSection + 1)));
	}
	
	inline function updateBeat():Void curBeat = Std.int((curDecBeat = curDecStep / 4) / 4);
	
	inline function updateCurStep():Void curStep = Std.int(curDecStep = Conductor.getStep(Conductor.songPosition - ClientPrefs.noteOffset));
	
	public inline function getBeatsOnSection():Int return (PlayState.SONG?.notes[curSection]?.sectionBeats ?? 4);
	
	public function stepHit():Void
	{
		scriptGroup.call('onStepHit', [curStep]);
		
		if (curStep % 4 == 0) beatHit();
	}
	
	public function beatHit():Void
	{
		scriptGroup.call('onBeatHit', [curBeat]);
	}
	
	public function sectionHit()
	{
		scriptGroup.call('onSectionHit', [curSection]);
	}
	
	override function destroy()
	{
		scriptGroup.call('onDestroy', []);
		
		scriptGroup = FlxDestroyUtil.destroy(scriptGroup);
		
		super.destroy();
		
		#if mobile
		removeVirtualPad();
		removeMobileControls();
		#end
	}
}
