package mobile.backend;

import flixel.FlxG;
import flixel.FlxBasic;

/**
 * ...
 * @author Idklool
 */
class TouchInput {
    public static inline final SWIPE_THRESHOLD:Float = 30.0;

    public static function BACK():Bool {
        return #if android FlxG.android.justReleased.BACK #else false #end;
    }

    public static function justTouched():Bool {
        #if mobile
        for (touch in FlxG.touches.list) {
            if (touch.justPressed) return true;
        }
        #end
        return false;
    }

    public static function justPressed(obj:FlxBasic):Bool {
        #if mobile
        for (touch in FlxG.touches.list) {
            if (touch.justPressed && touch.overlaps(obj)) return true;
        }
        #end
        return false;
    }

    public static function justReleased(obj:FlxBasic):Bool {
        #if mobile
        for (touch in FlxG.touches.list) {
            if (touch.justReleased && touch.overlaps(obj)) return true;
        }
        #end
        return false;
    }

    public static function pressed(obj:FlxBasic):Bool {
        #if mobile
        for (touch in FlxG.touches.list) {
            if (touch.pressed && touch.overlaps(obj)) return true;
        }
        #end
        return false;
    }

    public static function released(obj:FlxBasic):Bool {
        #if mobile
        for (touch in FlxG.touches.list) {
            if (touch.released && touch.overlaps(obj)) return true;
        }
        #end
        return false;
    }

    public static function isTouchInRegion(x:Float, y:Float, width:Float, height:Float):Bool {
        #if mobile
        for (touch in FlxG.touches.list) {
            if (touch.x >= x && touch.x <= x + width && touch.y >= y && touch.y <= y + height) {
                return true;
            }
        }
        #end
        return false;
    }
    
    public static function isSwipe(direction:String):Bool {
        #if mobile
        for (swipe in FlxG.swipes) {
            if (swipe != null && swipe.duration > 0) {
                var deltaX = swipe.endPosition.x - swipe.startPosition.x;
                var deltaY = swipe.endPosition.y - swipe.startPosition.y;

                switch (direction.toLowerCase()) {
                    case 'down':
                        if (deltaY > SWIPE_THRESHOLD && Math.abs(deltaY) > Math.abs(deltaX)) return true;
                    case 'up':
                        if (deltaY < -SWIPE_THRESHOLD && Math.abs(deltaY) > Math.abs(deltaX)) return true;
                    case 'right':
                        if (deltaX > SWIPE_THRESHOLD && Math.abs(deltaX) > Math.abs(deltaY)) return true;
                    case 'left':
                        if (deltaX < -SWIPE_THRESHOLD && Math.abs(deltaX) > Math.abs(deltaY)) return true;
                    default:
                        return false;
                }
            }
        }
        #end
        return false;
    }
}
