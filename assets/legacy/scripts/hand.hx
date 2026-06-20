import flixel.FlxSprite;

var ext = 'ui/';
var hand:FlxSprite;
var handX = 850;
var handY = ClientPrefs.downScroll ? -120 : 440;
var isPressingHand:Bool = false;
var time = 0.6;

function onLoad()
{
    FlxG.mouse.visible = true;

    hand = new FlxSprite(handX, handY).loadGraphic(Paths.image(ext + 'taunthand'));
    hand.scale.set(0.3, 0.3);
    hand.alpha = 0.5;
    hand.cameras = [camHUD];
    game.add(hand);
}

function onUpdate(elapsed:Float)
{
    var mousePos = FlxG.mouse.getScreenPosition(camHUD);

    var wa = hand.frameWidth * 0.3;
    var wa2 = hand.frameHeight * 0.3;
 
    var handWa = hand.x + (hand.frameWidth - wa) / 2;
    var handWa2 = hand.y + (hand.frameHeight - wa2) / 2;

    var mouseOverlapsHand = (mousePos.x >= handWa && 
                             mousePos.x <= (handWa + wa) &&
                             mousePos.y >= handWa2 && 
                             mousePos.y <= (handWa2 + wa2));

    if (mouseOverlapsHand)
    {
        if (FlxG.mouse.justPressed && !isPressingHand)
        {
            isPressingHand = true;
            hand.alpha = 1.0;
            
            game.boyfriend.playAnim('hey', time);
            game.boyfriend.specialAnim = true;
        }
    }

    if (isPressingHand && (FlxG.mouse.justReleased || !mouseOverlapsHand))
    {
        isPressingHand = false;
        hand.alpha = 0.5;
    }

    if (controls.NOTE_TAUNT_P) 
    {
        hand.alpha = 1.0;
        game.boyfriend.playAnim('hey', time);
        game.boyfriend.specialAnim = true;
    }
    if (controls.NOTE_TAUNT_R && !isPressingHand) 
    {
        hand.alpha = 0.5;
    }
}

function onDestroy()
{
}
