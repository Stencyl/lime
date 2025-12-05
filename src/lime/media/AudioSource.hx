package lime.media;

import lime.app.Event;
import lime.media.openal.AL;
import lime.media.openal.ALSource;
import lime.math.Vector4;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
/**
	The `AudioSource` class provides a way to control audio playback in a Lime application. 
	It allows for playing, pausing, and stopping audio, as well as controlling various 
	audio properties such as gain, pitch, and looping.

	Depending on the platform, the audio backend may vary, but the API remains consistent.

	@see lime.media.AudioBuffer
**/
class AudioSource
{
	/**
		An event that is dispatched when the audio playback is complete.
	**/
	public var onComplete = new Event<Void->Void>();
	
	/**
		The `AudioBuffer` associated with this `AudioSource`.
	**/
	public var buffer:AudioBuffer;

	/**
		The current playback position of the audio, in milliseconds.
	**/
	public var currentTime(get, set):Int;

	/**
		The gain (volume) of the audio. A value of `1.0` represents the default volume.
	**/
	public var gain(get, set):Float;

	/**
		The length of the audio, in milliseconds.
	**/
	public var length(get, set):Int;

	/**
		The number of times the audio will loop. A value of `0` means the audio will not loop.
	**/
	public var loops(get, set):Int;

	/**
		The pitch of the audio. A value of `1.0` represents the default pitch.
	**/
	public var pitch(get, set):Float;

	/**
		The offset within the audio buffer to start playback, in samples.
	**/
	public var offset:Int;

	/**
		The left-right pan of the audio source, from -1 (left) to 1 (right) or null (unset).
	**/
	public var pan(get, set):Null<Float>;
	
	/**
		The 3D position of the audio source, represented as a `Vector4`, or null (unset).
	**/
	public var position(get, set):Null<Vector4>;


	public var _pan:Null<Float>;
	public var _position:Null<Vector4>;
	
	@:noCompletion private var __backend:AudioSourceBackend;

	/**
		Creates a new `AudioSource` instance.
		@param buffer The `AudioBuffer` to associate with this `AudioSource`.
		@param offset The starting offset within the audio buffer, in samples.
		@param length The length of the audio to play, in milliseconds. If `null`, the full buffer is used.
		@param loops The number of times to loop the audio. `0` means no looping.
	**/
	public function new(buffer:AudioBuffer = null, offset:Int = 0, length:Null<Int> = null, loops:Int = 0)
	{
		this.buffer = buffer;
		this.offset = offset;

		__backend = new AudioSourceBackend(this);
		
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

	/**
		Releases any resources used by this `AudioSource`.
	**/
	public function dispose():Void
	{
		__backend.dispose();
	}

	@:noCompletion private function init():Void
	{
		__backend.init();
	}

	/**
		Starts or resumes audio playback.
	**/
	public function play():Void
	{
		__backend.play();
	}

	/**
		Pauses audio playback.
	**/
	public function pause():Void
	{
		__backend.pause();
	}

	/**
		Stops audio playback and resets the playback position to the beginning.
	**/
	public function stop():Void
	{
		__backend.stop();
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

	@:noCompletion private function get_pan():Null<Float>
	{
		return _pan;
	}

	@:noCompletion private function set_pan(value:Null<Float>):Null<Float>
	{
		if(_position != null)
		{
			trace("Can't set pan on a spatial sound.");
			return _pan;
		}

		if(value == null)
		{
			_pan = __backend.setPan(0);
		}

		_pan = __backend.setPan(value);

		return _pan;
	}

	@:noCompletion private function get_pitch():Float
	{
		return __backend.getPitch();
	}

	@:noCompletion private function set_pitch(value:Float):Float
	{
		return __backend.setPitch(value);
	}

	@:noCompletion private function get_position():Null<Vector4>
	{
		return _position;
	}

	@:noCompletion private function set_position(value:Null<Vector4>):Null<Vector4>
	{
		if(_pan != null)
		{
			trace("Can't set position on a panned sound.");
			return _position;
		}

		if(value == null)
		{
			_position = __backend.setPosition(new Vector4(0, 0, 0, 0));
		}

		_position = __backend.setPosition(value);

		return _position;
	}
}

#if flash
@:noCompletion private typedef AudioSourceBackend = lime._internal.backend.flash.FlashAudioSource;
#elseif (js && html5)
@:noCompletion private typedef AudioSourceBackend = lime._internal.backend.html5.HTML5AudioSource;
#else
@:noCompletion private typedef AudioSourceBackend = lime._internal.backend.native.NativeAudioSource;
#end
