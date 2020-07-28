package lime._internal.backend.native;

import lime.math.Vector4;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import lime.media.vorbis.VorbisFile;
import lime.media.AudioManager;
import lime.media.AudioSource;
import lime.utils.UInt8Array;
import haxe.Int64;

typedef FillBufferResult = {
	amount:Int,
	ended:Bool,
}

// Implementation based on https://github.com/snowkit/snow/blob/master/snow/modules/openal/ALStream.hx

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime.media.AudioBuffer)
class NativeAudioSource2 implements NativeAudioSourceImpl {

	static inline var BUFFER_LENGTH = 176000;
	static inline var BUFFER_NUMBER = 2;

	var buffers:Array<ALBuffer>;
	var audioSource:AudioSource;
	var handle:ALSource;
	var format:Int = 0;

	var loops:Int = 0;

	var playing:Bool = false;
	var dataLength:Int = 0;
	var samples:Int = 0;
	var bufferData:UInt8Array;

	var vorbisFile:VorbisFile;

	var timeBlock1:Float;
	var timeBlock2:Float;

	public function new(audioSource:AudioSource) {
		this.audioSource = audioSource;
	}

	public function init() {
		dataLength = 0;
		format = 0;
		playing = false;

		if(audioSource.buffer.channels == 1) {
			format = audioSource.buffer.bitsPerSample == 8 ? AL.FORMAT_MONO8 : AL.FORMAT_MONO16;
		} else if (audioSource.buffer.channels == 2) {
			format = audioSource.buffer.bitsPerSample == 8 ? AL.FORMAT_STEREO8 : AL.FORMAT_STEREO16;
		}

		if(audioSource.buffer.__srcVorbisFile != null) {
			buffers = [];
			for(i in 0...BUFFER_NUMBER) {
				buffers[i] = AL.createBuffer();
				error();
			}
			bufferData = new UInt8Array(BUFFER_LENGTH);

			vorbisFile = audioSource.buffer.__srcVorbisFile;
			dataLength = Std.int(Int64.toInt(vorbisFile.pcmTotal()) * audioSource.buffer.channels * (audioSource.buffer.bitsPerSample / 8));
			samples = Std.int ((dataLength * 8) / (audioSource.buffer.channels * audioSource.buffer.bitsPerSample));

			seek(0);
			initHandle();
		} else {
			throw "Non-streaming audio not implemented";
		}
	}

	public function dispose() {
		if (handle == null) {
			return;
		} 

		if(playing) {
			AL.sourceStop(handle);
			error();
		}
		flushBuffers();

		if(AL.getSourcei(handle, AL.BUFFER) != 0) {
			AL.sourcei(handle, AL.BUFFER, null);
			error();
		}
		
		AL.deleteSource(handle);
		error();

		while(buffers.length > 0) {
			AL.deleteBuffer(buffers.pop());
			error();
		}

		handle = null;
		buffers = null;
		bufferData = null;
	}

	public function update() {
		if (!playing) {
			return;
		}

		var stillStreaming = true;
		var processedBuffers:Int = AL.getSourcei(handle, AL.BUFFERS_PROCESSED);
		error();

		// Don't use more buffers than needed
		if(processedBuffers > BUFFER_NUMBER) processedBuffers = BUFFER_NUMBER;

		while(processedBuffers > 0) {
			var buffer = AL.sourceUnqueueBuffer(handle);
			error();

			var result = fillBuffer(buffer);

			// don't queue empty buffers
			var skipQueue = loops <= 0 && result.ended && result.amount <= 0;

			if(!skipQueue) {
				AL.sourceQueueBuffer(handle, buffer);
				error();
			}

			if(result.ended) {
				if(loops > 0) {
					seek(0);

					// refill buffer if it's empty
					if(result.amount <= 0) {
						fillBuffer(buffer);
					}

					loops--;
				} else {

					// wait until no more buffers are queued to stop and emit the onComplete signal
					var queued:Int = AL.getSourcei(handle, AL.BUFFERS_QUEUED);
					error();

					if(queued <= 0) {
						stillStreaming = false;
					}
				}
			}

			processedBuffers--;
		}

		if (!stillStreaming) {
			stop();
			audioSource.onComplete.dispatch();
		} else if(playing && AL.getSourcei(handle, AL.SOURCE_STATE) == AL.STOPPED) {
			// if we can't queue the buffers in time, the SOURCE_STATE will change to STOPPED
			AL.sourcePlay(handle);
		}
	}

	public function play() {
		if(playing || handle == null) {
			return;
		}

		playing = true;

		setCurrentTime(0);
	}

	public function pause() {
		playing = false;

		if(handle != null) {
			AL.sourcePause(handle);
			error();
		}
	}

	public function stop() {
		if (playing && handle != null) {
			AL.sourceStop(handle);
			error();
		}

		playing = false;
	}

	inline function initHandle() {
		handle = AL.createSource();
		error();
		AL.sourcef(handle, AL.GAIN, 1.0);
		error();
		AL.sourcei(handle, AL.LOOPING, AL.FALSE);
		error();
		AL.sourcef(handle, AL.PITCH, 1.0);
		error();
		AL.distanceModel(AL.NONE);
		error();
		AL.source3f(handle, AL.POSITION, 0, 0, 0);
		error();
		AL.source3f(handle, AL.VELOCITY, 0, 0, 0);
		error();
	}

	function initBuffers() {
		for(i in 0...BUFFER_NUMBER) {
			var result = fillBuffer(buffers[i]);
			if(result.amount > 0) {
				AL.sourceQueueBuffer(handle, buffers[i]);
				error();
			}
		}
	}

	function fillBuffer(buffer:ALBuffer, ?pos:haxe.PosInfos):FillBufferResult {
		
		var position = Std.int(Int64.toInt(vorbisFile.pcmTell()) * audioSource.buffer.channels * (audioSource.buffer.bitsPerSample / 8));

		var result = readVorbisFile();

		if(result.amount > 0) {
			AL.bufferData(buffer, format, bufferData, result.amount, audioSource.buffer.sampleRate);
			error();
		}

		return result;
	}

	function flushBuffers(?pos:haxe.PosInfos) {
		if(handle == null) {
			return;
		}
		var queued = AL.getSourcei(handle, AL.BUFFERS_QUEUED);
		error();
		AL.sourceUnqueueBuffers(handle, queued);
		error();
	}

	inline function error(?pos:haxe.PosInfos) {
		#if debug
		var e = AL.getErrorString();
		if(e != null && e.length > 0) trace('${pos.methodName}:${pos.lineNumber} -> ${e}');
		#end
	}

	inline function seek(value:Float) {
		vorbisFile.timeSeek (value);
	}

	inline function bytesToSeconds(bytes:Int) {
		return bytes / (audioSource.buffer.sampleRate * audioSource.buffer.channels * (audioSource.buffer.bitsPerSample == 16 ? 2 : 1));
	}

	inline function secondsToBytes(seconds:Float) {
		return Std.int(seconds * (audioSource.buffer.sampleRate * audioSource.buffer.channels * (audioSource.buffer.bitsPerSample == 16 ? 2 : 1)));
	}

	function readVorbisFile(length:Int = BUFFER_LENGTH):FillBufferResult {
		var read = 0, total = 0, readMax = 0;
		timeBlock1 = timeBlock2;
		timeBlock2 = vorbisFile.timeTell();
		while(total < length) {
			readMax = 4096;
			if(readMax > length - total) {
				readMax = length - total;
			}

			read = vorbisFile.read(bufferData.buffer, total, readMax);

			if(read > 0) {
				total += read;
			} else {
				break;
			}
		}

		return {amount: total, ended: total < length};
	}

	// GETTERS AND SETTERS

	public function getCurrentTime() {
		var time = timeBlock1 * 1000 + AL.getSourcef(handle, AL.SEC_OFFSET) * 1000 - audioSource.offset;
		return time > 0 ? Std.int(time) : 0;
	}

	public function setCurrentTime(value:Int) {
		if(handle != null) {
			AL.sourceStop(handle);
			error();
			flushBuffers();

			seek((value + audioSource.offset) / 1000);

			initBuffers();

			if(playing) {
				AL.sourcePlay(handle);
				error();
			}
		}

		return value;
	}

	public function getGain() {
		if(handle == null) {
			return 1.0;
		} 

		return AL.getSourcef(handle, AL.GAIN);
	}

	public function setGain(value:Float):Float {
		if(handle != null) {
			AL.sourcef(handle, AL.GAIN, value);
		}

		return value;
	}

	public function getLength() {
		return Std.int(bytesToSeconds(dataLength) * 1000 - audioSource.offset);
	}

	public function setLength(value:Int) {
		return getLength();
	}

	public function getLoops() {
		return loops;
	}

	public function setLoops(value:Int) {
		return loops = value;
	}

	public function setPan(value:Float):Float
	{
		if (handle != null)
		{
			AL.distanceModel(AL.NONE);
			error();
			AL.source3f(handle, AL.POSITION, value, 0, -1 * Math.sqrt(1 - Math.pow(value, 2)));
			error();
		}

		return value;
	}

	public function setPosition(value:Vector4):Vector4
	{
		if (handle != null)
		{
			AL.distanceModel(AL.INVERSE_DISTANCE_CLAMPED);
			error();
			AL.source3f(handle, AL.POSITION, value.x, value.y, value.z);
			error();
		}

		return value;
	}

}