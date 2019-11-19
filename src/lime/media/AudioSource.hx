package lime.media;

import lime.app.Event;
import lime.media.openal.AL;
import lime.media.openal.ALSource;
import lime.math.Vector4;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class AudioSource
{
	static var ID = 0;

	public var onComplete = new Event<Void->Void> ();
	public var id:Int = ID++;
	public var buffer:AudioBuffer;
	public var currentTime(get, set):Int;
	public var gain(get, set):Float;
	public var length(get, set):Int;
	public var loops(get, set):Int;
	public var offset:Int;
	public var position(get, set):Vector4;

	@:noCompletion private var __backend:AudioSourceBackend;

	public function new(buffer:AudioBuffer = null, offset:Int = 0, length:Null<Int> = null, loops:Int = 0)
	{
		this.buffer = buffer;
		this.offset = offset;

		#if (flash || (js && html5))
		__backend = new AudioSourceBackend(this);
		#else
		@:privateAccess if (buffer.__srcVorbisFile == null)
			__backend = new lime._internal.backend.native.NativeAudioSource(this);
		else
			__backend = new lime._internal.backend.native.NativeAudioSource2(this);
		#end

		if (length != null && length != 0)
		{
			this.length = length;
		}

		this.loops = loops;

		if (buffer != null)
		{
			init();
		}
	}

	public function dispose():Void
	{
		__backend.dispose();
		AudioManager.removeAudioSource(this);
	}

	@:noCompletion private function init():Void
	{
		__backend.init();
		AudioManager.addAudioSource(this);
	}

	public function play():Void
	{
		__backend.play();
	}

	public function pause():Void
	{
		__backend.pause();
	}

	public function stop():Void
	{
		__backend.stop();
	}
	
	public function update()
	{
		__backend.update();
	}

	// Get & Set Methods
	@:noCompletion private function get_currentTime():Int
	{
		return __backend.getCurrentTime();
	}

	@:noCompletion private function set_currentTime(value:Int):Int
	{
		return __backend.setCurrentTime(value);
	}

	@:noCompletion private function get_gain():Float
	{
		return __backend.getGain();
	}

	@:noCompletion private function set_gain(value:Float):Float
	{
		return __backend.setGain(value);
	}

	@:noCompletion private function get_length():Int
	{
		return __backend.getLength();
	}

	@:noCompletion private function set_length(value:Int):Int
	{
		return __backend.setLength(value);
	}

	@:noCompletion private function get_loops():Int
	{
		return __backend.getLoops();
	}

	@:noCompletion private function set_loops(value:Int):Int
	{
		return __backend.setLoops(value);
	}

	@:noCompletion private function get_position():Vector4
	{
		return __backend.getPosition();
	}

	@:noCompletion private function set_position(value:Vector4):Vector4
	{
		return __backend.setPosition(value);
	}
}

#if flash
@:noCompletion private typedef AudioSourceBackend = lime._internal.backend.flash.FlashAudioSource;
#elseif (js && html5)
@:noCompletion private typedef AudioSourceBackend = lime._internal.backend.html5.HTML5AudioSource;
#else
@:noCompletion private typedef AudioSourceBackend = lime._internal.backend.native.NativeAudioSourceImpl;
#end
