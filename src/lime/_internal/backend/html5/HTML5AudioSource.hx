package lime._internal.backend.html5;

import lime.math.Vector4;
import lime.media.AudioSource;

@:access(lime.media.AudioBuffer)
class HTML5AudioSource
{
	private var completed:Bool;
	private var gain:Float;
	private var id:Int;
	private var length:Int;
	private var loops:Int;
	private var parent:AudioSource;
	private var playing:Bool;

	public function new(parent:AudioSource)
	{
		this.parent = parent;

		id = -1;
		gain = 1;
	}

	public function dispose():Void {}

	public function init():Void {}

	public function play():Void
	{
		#if lime_howlerjs
		if (playing || parent.buffer == null || parent.buffer.__srcHowl == null)
		{
			return;
		}

		playing = true;

		var time = getCurrentTime();

		completed = false;

		var cacheVolume = untyped parent.buffer.__srcHowl._volume;
		untyped parent.buffer.__srcHowl._volume = parent.gain;

		id = parent.buffer.__srcHowl.play();

		untyped parent.buffer.__srcHowl._volume = cacheVolume;
		// setGain (parent.gain);

		if(parent.pan != null) setPan(parent.pan);
		if(parent.position != null) setPosition(parent.position);
		
		parent.buffer.__srcHowl.on("end", howl_onEnd, id);

		setCurrentTime(time);
		#end
	}

	public function pause():Void
	{
		#if lime_howlerjs
		playing = false;

		if (parent.buffer != null && parent.buffer.__srcHowl != null)
		{
			parent.buffer.__srcHowl.pause(id);
		}
		#end
	}

	public function stop():Void
	{
		#if lime_howlerjs
		playing = false;

		if (parent.buffer != null && parent.buffer.__srcHowl != null)
		{
			parent.buffer.__srcHowl.stop(id);
			parent.buffer.__srcHowl.off ("end", howl_onEnd, id);
		}
		#end
	}
	
	public function update():Void {}

	// Event Handlers
	private function howl_onEnd()
	{
		#if lime_howlerjs
		playing = false;

		if (loops > 0)
		{
			loops--;
			stop();
			// currentTime = 0;
			play();
			return;
		}
		else if (parent.buffer != null && parent.buffer.__srcHowl != null)
		{
			parent.buffer.__srcHowl.stop(id);
			parent.buffer.__srcHowl.off ("end", howl_onEnd, id);
		}

		completed = true;
		parent.onComplete.dispatch();
		#end
	}

	// Get & Set Methods
	public function getCurrentTime():Int
	{
		if (id == -1)
		{
			return 0;
		}

		#if lime_howlerjs
		if (completed)
		{
			return getLength();
		}
		else if (parent.buffer != null && parent.buffer.__srcHowl != null)
		{
			var time = Std.int(parent.buffer.__srcHowl.seek(id) * 1000) - parent.offset;
			if (time < 0) return 0;
			return time;
		}
		#end

		return 0;
	}

	public function setCurrentTime(value:Int):Int
	{
		#if lime_howlerjs
		if (parent.buffer != null && parent.buffer.__srcHowl != null)
		{
			// if (playing) buffer.__srcHowl.play (id);
			var pos = (value + parent.offset) / 1000;
			if (pos < 0) pos = 0;
			parent.buffer.__srcHowl.seek(pos, id);
		}
		#end

		return value;
	}

	public function getGain():Float
	{
		return gain;
	}

	public function setGain(value:Float):Float
	{
		#if lime_howlerjs
		// set howler volume only if we have an active id.
		// Passing -1 might create issues in future play()'s.

		if (parent.buffer != null && parent.buffer.__srcHowl != null && id != -1)
		{
			parent.buffer.__srcHowl.volume(value, id);
		}
		#end

		return gain = value;
	}

	public function getLength():Int
	{
		if (length != 0)
		{
			return length;
		}

		#if lime_howlerjs
		if (parent.buffer != null && parent.buffer.__srcHowl != null)
		{
			return Std.int(parent.buffer.__srcHowl.duration() * 1000);
		}
		#end

		return 0;
	}

	public function setLength(value:Int):Int
	{
		return length = value;
	}

	public function getLoops():Int
	{
		return loops;
	}

	public function setLoops(value:Int):Int
	{
		return loops = value;
	}

	public function setPan(value:Float):Float
	{
		#if lime_howlerjs
		if (parent.buffer.__srcHowl != null && parent.buffer.__srcHowl.stereo != null) parent.buffer.__srcHowl.stereo(value, id);
		#end

		return value;
	}

	public function setPosition(value:Vector4):Vector4
	{
		#if lime_howlerjs
		if (parent.buffer.__srcHowl != null && parent.buffer.__srcHowl.pos != null) parent.buffer.__srcHowl.pos(value.x, value.y, value.z, id);
		// There are more settings to the position of the sound on the "pannerAttr()" function of howler. Maybe somebody who understands sound should look into it?
		#end

		return value;
	}
}
