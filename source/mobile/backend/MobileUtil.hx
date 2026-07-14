package mobile.backend;

#if android
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.widget.Toast as AndroidToast;
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.Tools as AndroidTools;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;

import lime.system.JNI;
#end

import lime.system.System as LimeSystem;
import lime.app.Application;

import openfl.Assets;

import haxe.io.Path;
import haxe.io.Bytes;
import haxe.Json;
import haxe.Exception;

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

/** 
 * @Authors MaysLastPlay, ArkoseLabs, MarioMaster (MasterX-39), Dechis (dx7405), JustX
 * @version 0.4.1
 **/
typedef CustomStorageModeData = { final modes:Array<ModeData>; }
typedef ModeData = { final Name:String; final Folder:String; }

class MobileUtil
{
	#if sys
	public static inline function getAssetDirectory():String
		return #if android Path.addTrailingSlash("/sdcard/Android/data/com.motorfrog.impostor/files") #elseif ios LimeSystem.documentsDirectory #else Sys.getCwd() #end;

	#if android
	public static inline function getCustomStoragePath():String
		return AndroidContext.getExternalFilesDir() + '/storageModes.json';
		
	public static inline function getStorageTypePath():String
		return AndroidContext.getExternalFilesDir() + '/storagetype.txt';

	private static var _getFreeSpaceMB:Dynamic = null;

	public static function getCustomStorageDirectories(?doNotSeperate:Bool = false):Array<String>
	{
		final curJsonFile:String = getCustomStoragePath();
		final arrayReturn:Array<String> = [];

		if (FileSystem.exists(curJsonFile))
		{
			try {
				final rawJson:String = File.getContent(curJsonFile);
				final parsedData:CustomStorageModeData = Json.parse(rawJson);

				if (parsedData?.modes != null) {
					for (mode in parsedData.modes) {
						if (mode?.Name == null || mode?.Folder == null) continue;

						if (doNotSeperate)
							arrayReturn.push('${mode.Name}|${mode.Folder}');
						else
							arrayReturn.push(mode.Name);
					}
				}
			} catch (e:Exception) {
				trace('Error parsing storage JSON: ${e.message}');
			}
		}
		return arrayReturn;
	}

	public static var currentDirectory:String = null;
	
	public static function initDirectory():String {
		var daPath:String = '';

		try {
			if (!FileSystem.exists(getStorageTypePath()))
				File.saveContent(getStorageTypePath(), ClientPrefs.storageType);
		} catch (e:Exception) {
			trace('Error saving storage type: ${e.message}');
		}

		var curStorageType:String = "EXTERNAL_DATA"; 
		try {
			if (FileSystem.exists(getStorageTypePath())) {
				curStorageType = File.getContent(getStorageTypePath());
			}
		} catch (e:Exception) {
			trace('Error reading storage type: ${e.message}');
		}

		for (line in getCustomStorageDirectories(true))
		{
			if (line.startsWith(curStorageType) && line.trim() != '') {
				final dat = line.split("|");
				if (dat != null && dat.length > 1) {
					daPath = dat[1];
				}
			}
		}

		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = "/sdcard/.ImpostorLegacy";
			case 'EXTERNAL_MEDIA':
				daPath = "/sdcard/Android/media/com.motorfrog.impostor";
			case 'EXTERNAL_DATA':
				daPath = "/sdcard/Android/data/com.motorfrog.impostor";
			default:
				if (daPath == null || daPath.trim() == '') daPath = "/sdcard/Android/data/com.motorfrog.impostor/files";
		}
		
		daPath = Path.addTrailingSlash(daPath);
		currentDirectory = daPath;

		final safeAlert = function(msg:String, title:String) {
			if (Application.current?.window != null) {
				Application.current.window.alert(msg, title);
			} else {
				trace('$title: $msg');
			}
		};

		try {
			if (!FileSystem.exists(getAssetDirectory()))
				FileSystem.createDirectory(getAssetDirectory());
		} catch (e:Dynamic) {
			safeAlert('Looks like you don\'t have directory named\n${getAssetDirectory()}\n\nCurrent Error:\n$e', "Warning!");
		}

		try {
			final contentDir = '${daPath}content/';
			if (!FileSystem.exists(contentDir))
				FileSystem.createDirectory(contentDir);
		} catch (e:Dynamic) {
			safeAlert('Looks like you don\'t have directory named\n${daPath}content/\n\nCurrent Error:\n$e', "Warning!");
		}

		return daPath;
	}

	public static function getPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions([
				'READ_MEDIA_IMAGES',
				'READ_MEDIA_VIDEO',
				'READ_MEDIA_AUDIO',
				'READ_MEDIA_VISUAL_USER_SELECTED'
			]);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
	}

	public static var lastGettedPermission:Int;
	
	public static function chmodPermission(fullPath:String):Void {
		try {
			final process = new Process('stat -c %a ${fullPath}');
			final stringOutput:String = process.stdout.readAll().toString();
			process.close();
			lastGettedPermission = Std.parseInt(stringOutput);
		} catch (e:Dynamic) {
			trace('Error getting permissions for $fullPath: $e');
		}
	}

	public static function chmod(permissions:Int, fullPath:String):Void {
		try {
			final process = new Process('chmod -R ${permissions} ${fullPath}');
			final exitCode = process.exitCode();
			if (exitCode == 0) 
				trace('Success: Permissions for $fullPath set to ($permissions)');
			else {
				final errorOutput = process.stderr.readAll().toString();
				trace('ERROR: chmod failed for $fullPath. Exit: $exitCode, Error: $errorOutput');
			}
			process.close();
		} catch (e:Dynamic) {
			trace('Failed to execute chmod on $fullPath: $e');
		}
	}
	#end

	public static function getDirectory():String
	{
		#if android	
		if (currentDirectory == null || currentDirectory == "") {
    	    trace("currentDirectory is null, initializing again...");
			currentDirectory = initDirectory(); 
    	}
		return currentDirectory;
		#elseif ios
		return LimeSystem.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	public static function getFreeSpace(targetPath:String):Float
    {
        #if android
        if (_getFreeSpaceMB == null) {
            try {
                _getFreeSpaceMB = JNI.createStaticMethod("mobile/backend/java/FileUtils", "getFreeSpaceMB", "(Ljava/lang/String;)D");
            } catch (e:Dynamic) {
                trace('JNI Error: Could not bind FileUtils.getFreeSpaceMB - $e');
                return -1.0;
            }
        }
        
        if (_getFreeSpaceMB != null)
            return cast _getFreeSpaceMB(targetPath);
		
        return -1.0;
        #else
        return 9999.0; 
        #end
    }

	/**
	 * Saves a file to the external storage using atomic save (.tmp) to prevent corruption on out-of-memory.
	 */
	public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!', ?alert:Bool = true):Void
	{
		final folder:String = #if android getDirectory() + #else Sys.getCwd() + #end 'saves/';

		final freeSpaceMB = getFreeSpace(folder);
			if (freeSpaceMB != -1.0 && freeSpaceMB < 5.0) {
				final errorMsg:String = 'Failed to save "$fileName".\n' + 
						'Your device has only ${Std.int(freeSpaceMB)} MB of storage space left.';
				
				if (alert && Application.current?.window != null)
					Application.current.window.alert(errorMsg, 'Storage Full!');
				else
					trace('ABORTED SAVE: $errorTitle ($freeSpaceMB MB left).');
					
				return; 
			}

		try {
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			final targetPath = '$folder$fileName';
			final tempPath = '$folder$fileName.tmp';

			File.saveContent(tempPath, fileData);

			if (FileSystem.exists(targetPath))
				FileSystem.deleteFile(targetPath);

			FileSystem.rename(tempPath, targetPath);

			if (alert && Application.current?.window != null)
				Application.current.window.alert('$fileName has been saved.', "Success!");
			else if (alert)
				trace('$fileName has been saved.');
		} catch (e:Dynamic) {
			try { if (FileSystem.exists('$folder$fileName.tmp')) FileSystem.deleteFile('$folder$fileName.tmp'); } catch(e2:Dynamic) {}

			final errorMsg = 'Couldn\'t save $fileName.\nCheck if your device has enough free storage space!\n\nError: $e';
			
			if (alert && Application.current?.window != null)
				Application.current.window.alert(errorMsg, "Storage Error!");
			else
				trace('Save failed (storage full?): $e');
		}
	}
	#end

	/**
	 * @param folders Optional list of specific folders (e.g. ["assets/data/"]). If null, copies all assets.
	 */
	public static function copyAssets(?folders:Array<String> = null, ?onProgress:String->Int->Int->Void = null, ?onComplete:Void->Void = null):Void {
		#if mobile
		final rootTarget = getAssetDirectory();

		try {
			final assetList:Array<String> = Assets.list();
			
			if (assetList == null) {
				trace("Error: Assets.list() returned null.");
				if (onComplete != null) onComplete();
				return;
			}

			final toCopy = assetList.filter(assetKey -> {
				var cleanPath = assetKey;
				final colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) {
					cleanPath = cleanPath.substring(colonIndex + 1);
				}

				if (!cleanPath.startsWith("assets/")) return false;
				if (folders == null) return true;

				for (f in folders) {
					if (cleanPath.startsWith(f)) return true;
				}
				return false;
			});

			final total = toCopy.length;
			if (total == 0) {
				if (onComplete != null) onComplete();
				return;
			}

			for (i in 0...total) {
				final assetKey = toCopy[i];
				var cleanPath = assetKey;
				final colonIndex = cleanPath.indexOf(":");

				if (colonIndex != -1) {
					cleanPath = cleanPath.substring(colonIndex + 1);
				}

				final fullPath = Path.join([rootTarget, cleanPath]);
				final directory = Path.directory(fullPath);

				if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);

				if (!FileSystem.exists(fullPath)) {
					var bytes:Bytes = null;

					try {
						bytes = Assets.getBytes(assetKey);
					} catch (e:Dynamic) {
						try {
							final text:String = Assets.getText(assetKey);
							if (text != null) bytes = Bytes.ofString(text);
						} catch (e2:Dynamic) {
							trace('Failed to read text fallback for $assetKey: $e2');
						}
					}

					if (bytes != null) {
						try {
							File.saveBytes(fullPath, bytes);
						} catch (saveErr:Dynamic) {
							trace('CRITICAL: Failed to write $fullPath. Storage full? Error: $saveErr');
							
							if (Application.current?.window != null) {
								Application.current.window.alert(
									"Failed to copy game data.\nYour phone's storage might be full.\nPlease free up some space and try again.", 
									"Out of Storage!"
								);
							}
							
							if (onComplete != null) onComplete();
							return; 
						}
					} else {
						trace('Could not extract data for asset: $assetKey');
					}
				}

				if (onProgress != null) onProgress(cleanPath, i + 1, total);
			}

			if (onComplete != null) onComplete();
		} catch (e:Dynamic) {
			trace('Asset Copy Error: $e');
			if (onComplete != null) onComplete();
		}
		#end
	}
}
