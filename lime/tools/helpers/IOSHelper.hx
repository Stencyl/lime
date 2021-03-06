package lime.tools.helpers;


import haxe.io.Path;
import lime.project.Platform;
import lime.tools.helpers.PathHelper;
import lime.tools.helpers.ProcessHelper;
import lime.project.Haxelib;
import lime.project.HXProject;
import sys.io.Process;
import sys.FileSystem;


class IOSHelper {
	
	
	private static var initialized = false;
	
	
	public static function build (project:HXProject, workingDirectory:String, additionalArguments:Array<String> = null):Void {
		
		initialize (project);
		
		var platformName = "iphoneos";
		
		if (project.targetFlags.exists ("simulator")) {
			
			platformName = "iphonesimulator";
			
		}
		
		var configuration = "Release";
		
		if (project.debug) {
			
			configuration = "Debug";
			
		}
		
		var iphoneVersion = project.environment.get ("IPHONE_VER");
		var commands = [ "-configuration", configuration, "PLATFORM_NAME=" + platformName, "SDKROOT=" + platformName + iphoneVersion, "PATH=$PATH" ];
		
		if (project.targetFlags.exists ("simulator")) {
			
			if (project.targetFlags.exists ("i386")) {
				
				commands.push ("-arch");
				commands.push ("i386");
				
			} else {
				
				commands.push ("-arch");
				commands.push ("x86_64");
			
			}
			
		} else {

			var deployment = project.config.getFloat ("ios.deployment", 8);

			if (project.targetFlags.exists ("armv7") && deployment < 11) {
				
				commands.push ("-arch");
				commands.push ("armv7");
				
			} else if (project.targetFlags.exists ("armv7s") && deployment < 11) {
				
				commands.push ("-arch");
				commands.push ("armv7s");
				
			} else if (project.targetFlags.exists ("arm64")) {
				
				commands.push ("-arch");
				commands.push ("arm64");
				
			}

		}
		
		commands.push ("-project");
		commands.push (project.app.file + ".xcodeproj");
		
		var xcodeVersions = getXcodeVersion()
			.split(".")
			.map(function (i:String) {
				var ver = Std.parseInt(i);
				return ver != null ? ver : 0;
			});

		if (xcodeVersions[0] >= 9) {
			if (project.config.getBool('ios.allow-provisioning-updates', true)) {
				commands.push("-allowProvisioningUpdates");
			}
			if (project.config.getBool('ios.allow-provisioning-device-registration', true)) {
				commands.push("-allowProvisioningDeviceRegistration");
			}
		}

		if (additionalArguments != null) {
			
			commands = commands.concat (additionalArguments);
			
		}

		//XXX: this needs to be formatted so that $PATH is treated as a variable.
		commands = commands.map(function(s) return s == "PATH=$PATH" ? "PATH=\"$PATH\"" : StringTools.quoteUnixArg(s));
		var cmd = ["xcodebuild"].concat(commands).join(" ");

		ProcessHelper.runCommand (workingDirectory, cmd, null);
		
	}
	
	
	public static function getSDKDirectory (project:HXProject):String {
		
		initialize (project);
		
		var platformName = "iPhoneOS";
		
		if (project.targetFlags.exists ("simulator")) {
			
			platformName = "iPhoneSimulator";
			
		}
		
		var process = new Process ("xcode-select", [ "--print-path" ]);
		var directory = process.stdout.readLine ();
		process.close ();
		
		if (directory == "" || directory.indexOf ("Run xcode-select") > -1) {
			
			directory = "/Applications/Xcode.app/Contents/Developer";
			
		}
		
		directory += "/Platforms/" + platformName + ".platform/Developer/SDKs/" + platformName + project.environment.get ("IPHONE_VER") + ".sdk";
		return directory;
		
	}
	
	
	public static function getIOSVersion (project:HXProject):Void {
		
		if (!project.environment.exists ("IPHONE_VER") || project.environment.get ("IPHONE_VER") == "4.2") {
			
			if (!project.environment.exists ("DEVELOPER_DIR") && PlatformHelper.hostPlatform == MAC) {
				
				var process = new Process ("xcode-select", [ "--print-path" ]);
				var developerDir = process.stdout.readLine ();
				process.close ();
				
				project.environment.set ("DEVELOPER_DIR", developerDir);
				
			}
			
			var devPath = project.environment.get ("DEVELOPER_DIR") + "/Platforms/iPhoneOS.platform/Developer/SDKs";
			
			if (FileSystem.exists (devPath)) {
				
				var files = FileSystem.readDirectory (devPath);
				var extractVersion = ~/^iPhoneOS(.*).sdk$/;
				var best = "0", version;
				
				for (file in files) {
					
					if (extractVersion.match (file)) {
						
						version = extractVersion.matched (1);
						
						if (Std.parseFloat (version) > Std.parseFloat (best)) {
							
							best = version;
							
						}
						
					}
					
				}
				
				if (best != "") {
					
					project.environment.set ("IPHONE_VER", best);
					
				}
				
			}
			
		}
		
	}
	
	
	private static function getOSXVersion ():String {
		
		var output = ProcessHelper.runProcess ("", "sw_vers", [ "-productVersion" ]);
		
		return StringTools.trim (output);
		
	}
	
	
	public static function getProvisioningFile (project:HXProject = null):String {
		
		if (project != null && project.config.exists ("ios.provisioning-profile")) {
			
			return PathHelper.tryFullPath (project.config.getString ("ios.provisioning-profile"));
			
		} else if (PlatformHelper.hostPlatform == Platform.MAC) {
			
			var path = PathHelper.expand ("~/Library/MobileDevice/Provisioning Profiles");
			var files = FileSystem.readDirectory (path);
			
			for (file in files) {
				
				if (Path.extension (file) == "mobileprovision") {
					
					return path + "/" + file;
					
				}
				
			}
			
		}
		
		return "";
		
	}
	
	
	private static function getXcodeVersion ():String {
		
		var output = ProcessHelper.runProcess ("", "xcodebuild", [ "-version" ]);
		var firstLine = output.split ("\n").shift ();
		
		return StringTools.trim (firstLine.substring ("Xcode".length, firstLine.length));
		
	}
	
	
	private static function initialize (project:HXProject):Void {
		
		if (!initialized) {
			
			getIOSVersion (project);
			
			initialized = true;
			
		}
		
	}
	
	
	public static function launch (project:HXProject, workingDirectory:String):Void {
		
		initialize (project);
		
		var configuration = "Release";
			
		if (project.debug) {
			
			configuration = "Debug";
			
		}
		
		if (project.targetFlags.exists ("simulator")) {
			
			var applicationPath = "";
			
			if (Path.extension (workingDirectory) == "app" || Path.extension (workingDirectory) == "ipa") {
				
				applicationPath = workingDirectory;
				
			} else {
				
				applicationPath = workingDirectory + "/build/" + configuration + "-iphonesimulator/" + project.app.file + ".app";
				
			}

			var appPath = FileSystem.fullPath (applicationPath);
			var sdk = project.environment.get("IPHONE_VER");
			var output = project.environment.get ("IPHONE_STDOUT");
			var dtid = project.defines.get("devicetypeid");
			dtid = StringTools.replace(dtid, ",", ", ");
				
			var templatePaths = [ PathHelper.combine (PathHelper.getHaxelib (new Haxelib ("lime")), "templates") ].concat (project.templatePaths);
			var launcher = PathHelper.findTemplate (templatePaths, "bin/ios-sim");
			Sys.command ("chmod", [ "+x", launcher ]);
			
			ProcessHelper.runCommand ("", launcher, [ "launch", appPath, "--devicetypeid", dtid, "--log", output] );
			
		} else {
			
			var applicationPath = "";
			
			if (Path.extension (workingDirectory) == "app" || Path.extension (workingDirectory) == "ipa") {
				
				applicationPath = workingDirectory;
				
			} else {
				
				applicationPath = workingDirectory + "/build/" + configuration + "-iphoneos/" + project.app.file + ".app";
				
			}
			
			var templatePaths = [ PathHelper.combine (PathHelper.getHaxelib (new Haxelib ("lime")), "templates") ].concat (project.templatePaths);
			var launcher = PathHelper.findTemplate (templatePaths, "bin/ios-deploy");
			Sys.command ("chmod", [ "+x", launcher ]);
			
			var xcodeVersion = getXcodeVersion ();
			
			ProcessHelper.runCommand ("", launcher, [ "install", "--noninteractive", "--debug", "--bundle", FileSystem.fullPath (applicationPath) ]);
			
		}
		
	}
	
	
	public static function sign (project:HXProject, workingDirectory:String, entitlementsPath:String):Void {
		
		initialize (project);
		
		var configuration = "Release";
		
		if (project.debug) {
			
			configuration = "Debug";
			
		}
		
		var identity = project.config.getString ("ios.identity", "iPhone Developer");
		
		var commands = [ "--no-strict", "-f", "-s", identity, "CODE_SIGN_IDENTITY=" + identity ];
		
		if (entitlementsPath != null) {
			
			commands.push ("--entitlements");
			commands.push (entitlementsPath);
			
		}
		
		if (project.config.exists ("ios.provisioning-profile")) {
			
			commands.push ("PROVISIONING_PROFILE=" + project.config.getString ("ios.provisioning-profile"));
			
		}
		
		var applicationPath = "build/" + configuration + "-iphoneos/" + project.app.file + ".app";
		commands.push (applicationPath);
		
		ProcessHelper.runCommand (workingDirectory, "codesign", commands, true, true);
		
	}
	
	
	private static function waitForDeviceState (command:String, args:Array<String>):Void {
		
		var output;
		
		while (true) {
			
			output = ProcessHelper.runProcess ("", command, args, true, true, true);
			
			if (output != null && output.toLowerCase ().indexOf ("invalid device state") > -1) {
				
				Sys.sleep (3);
				
			} else {
				
				break;
				
			}
			
		}
		
	}
	
	
}