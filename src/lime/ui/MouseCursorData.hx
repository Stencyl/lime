package lime.ui;

import lime.graphics.Image;
import lime.math.Vector2;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class MouseCursorData
{
	public var frameRate:Float;
	public var hotSpot:Vector2;
	public var images:Array<Image>;

	public function new()
	{
		images = [];
		hotSpot = new Vector2(0, 0);
		frameRate = 0;
	}
}
