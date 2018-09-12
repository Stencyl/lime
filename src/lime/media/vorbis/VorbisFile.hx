package lime.media.vorbis; #if (!lime_doc_gen || lime_vorbis)


import haxe.Int64;
import haxe.io.Bytes;
import lime._internal.backend.native.NativeCFFI;

@:access(lime._internal.backend.native.NativeCFFI)


class VorbisFile {


	public var bitstream (default, null):Int;

	@:noCompletion private var handle:Dynamic;


	@:noCompletion private function new (handle:Dynamic) {

		trace("lime.media.vorbis.VorbisFile.new");
		this.handle = handle;

	}


	public function bitrate (bitstream:Int = -1):Int {

		trace("lime.media.vorbis.VorbisFile.bitrate");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_bitrate (handle, bitstream);
		#else
		return 0;
		#end

	}


	public function bitrateInstant ():Int {

		trace("lime.media.vorbis.VorbisFile.bitrateInstant");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_bitrate_instant (handle);
		#else
		return 0;
		#end

	}


	public function clear ():Void {

		trace("lime.media.vorbis.VorbisFile.clear");
		#if (lime_cffi && lime_vorbis && !macro)
		NativeCFFI.lime_vorbis_file_clear (handle);
		#end

	}


	public function comment (bitstream:Int = -1):VorbisComment {

		trace("lime.media.vorbis.VorbisFile.comment");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_comment (handle, bitstream);

		if (data != null) {

			var comment = new VorbisComment ();
			comment.userComments = data.userComments;
			comment.vendor = data.vendor;
			return comment;

		}
		#end

		return null;

	}


	public function crosslap (other:VorbisFile):Int {

		trace("lime.media.vorbis.VorbisFile.crosslap");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_crosslap (handle, other.handle);
		#else
		return 0;
		#end

	}


	public static function fromBytes (bytes:Bytes):VorbisFile {

		trace("lime.media.vorbis.VorbisFile.fromBytes");
		#if (lime_cffi && lime_vorbis && !macro)
		var handle = NativeCFFI.lime_vorbis_file_from_bytes (bytes);

		if (handle != null) {

			return new VorbisFile (handle);

		}
		#end

		return null;

	}


	public static function fromFile (path:String):VorbisFile {

		trace("lime.media.vorbis.VorbisFile.fromFile");
		#if (lime_cffi && lime_vorbis && !macro)
		var handle = NativeCFFI.lime_vorbis_file_from_file (path);

		if (handle != null) {

			return new VorbisFile (handle);

		}
		#end

		return null;

	}


	public function info (bitstream:Int = -1):VorbisInfo {

		trace("lime.media.vorbis.VorbisFile.info");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_info (handle, bitstream);

		if (data != null) {

			var info = new VorbisInfo ();
			info.bitrateLower = data.bitrateLower;
			info.bitrateNominal = data.bitrateNominal;
			info.bitrateUpper = data.bitrateUpper;
			info.channels = data.channels;
			info.rate = data.rate;
			info.version = data.version;
			return info;

		}
		#end

		return null;

	}


	public function pcmSeek (pos:Int64):Int {

		trace("lime.media.vorbis.VorbisFile.pcmSeek");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_pcm_seek (handle, pos.low, pos.high);
		#else
		return 0;
		#end

	}


	public function pcmSeekLap (pos:Int64):Int {

		trace("lime.media.vorbis.VorbisFile.pcmSeekLap");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_pcm_seek_lap (handle, pos.low, pos.high);
		#else
		return 0;
		#end

	}


	public function pcmSeekPage (pos:Int64):Int {

		trace("lime.media.vorbis.VorbisFile.pcmSeekPage");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_pcm_seek_page (handle, pos.low, pos.high);
		#else
		return 0;
		#end

	}


	public function pcmSeekPageLap (pos:Int64):Int {

		trace("lime.media.vorbis.VorbisFile.pcmSeekPageLap");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_pcm_seek_page_lap (handle, pos.low, pos.high);
		#else
		return 0;
		#end

	}


	public function pcmTell ():Int64 {

		trace("lime.media.vorbis.VorbisFile.pcmTell");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_pcm_tell (handle);

		if (data != null) {

			return Int64.make (data.high, data.low);

		}
		#end

		return Int64.ofInt (0);

	}



	public function pcmTotal (bitstream:Int = -1):Int64 {

		trace("lime.media.vorbis.VorbisFile.pcmTotal");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_pcm_total (handle, bitstream);

		if (data != null) {

			return Int64.make (data.high, data.low);

		}
		#end

		return Int64.ofInt (0);

	}


	public function rawSeek (pos:Int64):Int {

		trace("lime.media.vorbis.VorbisFile.rawSeek");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_raw_seek (handle, pos.low, pos.high);
		#else
		return 0;
		#end

	}


	public function rawSeekLap (pos:Int64):Int {

		trace("lime.media.vorbis.VorbisFile.rawSeekLap");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_raw_seek_lap (handle, pos.low, pos.high);
		#else
		return 0;
		#end

	}


	public function rawTell ():Int64 {


		trace("lime.media.vorbis.VorbisFile.rawTell");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_raw_tell (handle);

		if (data != null) {

			return Int64.make (data.high, data.low);

		}
		#end

		return Int64.ofInt (0);

	}


	public function rawTotal (bitstream:Int = -1):Int64 {

		trace("lime.media.vorbis.VorbisFile.rawTotal");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_raw_total (handle, bitstream);

		if (data != null) {

			return Int64.make (data.high, data.low);

		}
		#end

		return Int64.ofInt (0);

	}


	public function read (buffer:Bytes, position:Int, length:Int = 4096, bigEndianPacking:Bool = false, wordSize:Int = 2, signed:Bool = true):Int {

		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_read (handle, buffer, position, length, bigEndianPacking, wordSize, signed);
		if (data == null) return 0;
		bitstream = data.bitstream;
		return data.returnValue;
		#else
		return 0;
		#end

	}


	//public function readFilter (buffer:Bytes, length:Int = 4096, endianness:Endian = LITTLE_ENDIAN, wordSize:Int = 2, signed:Bool = true, bitstream:Int = 0, filter, filter_param


	public function readFloat (pcmChannels:Bytes, samples:Int):Int {

		trace("lime.media.vorbis.VorbisFile.readFloat");
		#if (lime_cffi && lime_vorbis && !macro)
		var data = NativeCFFI.lime_vorbis_file_read_float (handle, pcmChannels, samples);
		if (data == null) return 0;
		bitstream = data.bitstream;
		return data.returnValue;
		#else
		return 0;
		#end

	}


	public function seekable ():Bool {

		trace("lime.media.vorbis.VorbisFile.seekable");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_seekable (handle);
		#else
		return false;
		#end

	}


	public function serialNumber (bitstream:Int = -1):Int {

		trace("lime.media.vorbis.VorbisFile.serialNumber");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_serial_number (handle, bitstream);
		#else
		return 0;
		#end

	}


	public function streams ():Int {

		trace("lime.media.vorbis.VorbisFile.streams");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_streams (handle);
		#else
		return 0;
		#end

	}


	public function timeSeek (s:Float):Int {

		trace("lime.media.vorbis.VorbisFile.timeSeek");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_time_seek (handle, s);
		#else
		return 0;
		#end

	}


	public function timeSeekLap (s:Float):Int {

		trace("lime.media.vorbis.VorbisFile.timeSeekLap");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_time_seek_lap (handle, s);
		#else
		return 0;
		#end

	}


	public function timeSeekPage (s:Float):Int {

		trace("lime.media.vorbis.VorbisFile.timeSeekPage");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_time_seek_page (handle, s);
		#else
		return 0;
		#end

	}


	public function timeSeekPageLap (s:Float):Int {

		trace("lime.media.vorbis.VorbisFile.timeSeekPageLap");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_time_seek_page_lap (handle, s);
		#else
		return 0;
		#end

	}


	public function timeTell ():Float {

		trace("lime.media.vorbis.VorbisFile.timeTell");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_time_tell (handle);
		#else
		return 0;
		#end

	}


	public function timeTotal (bitstream:Int = -1):Float {

		trace("lime.media.vorbis.VorbisFile.timeTotal");
		#if (lime_cffi && lime_vorbis && !macro)
		return NativeCFFI.lime_vorbis_file_time_total (handle, bitstream);
		#else
		return 0;
		#end

	}


}


#end