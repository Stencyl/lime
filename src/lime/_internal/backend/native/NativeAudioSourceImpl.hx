package lime._internal.backend.native;

import lime.math.Vector4;

interface NativeAudioSourceImpl {

	public function dispose ():Void;
	public function init ():Void;
	public function update():Void;
	public function play ():Void;
	public function pause ():Void;
	public function stop ():Void;
	public function getCurrentTime():Int;
	public function setCurrentTime (value:Int):Int;
	public function getGain ():Float;
	public function setGain (value:Float):Float;
	public function getLength ():Int;
	public function setLength (value:Int):Int;
	public function getLoops ():Int;
	public function setLoops (value:Int):Int;
	public function setPan (value:Float):Float;
	public function setPosition (value:Vector4):Vector4;
	
}