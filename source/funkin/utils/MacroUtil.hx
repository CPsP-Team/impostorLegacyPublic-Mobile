package funkin.utils;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.io.Path;

using haxe.macro.Tools;

using Lambda;
#end

class MacroUtil
{
	#if macro
	static function resolveCompileTimePath(path:String):Null<String>
	{
		if (sys.FileSystem.exists(path)) return path;

		var current = sys.FileSystem.fullPath(".");
		while (current != null && current.length > 0)
		{
			var candidate = current + "/" + path;
			if (sys.FileSystem.exists(candidate)) return candidate;

			var parent = Path.directory(current);
			if (parent == current || parent.length == 0) break;
			current = parent;
		}

		return null;
	}
	#end

	/**
	 * enforces the use of haxe 4.3.4
	 */
	public static macro function haxeVersionEnforcement()
	{
		#if (haxe_ver < "4.3.4")
		Context.fatalError('use haxe 4.3.4 or newer thx', (macro null).pos);
		#end
		
		return macro $v{0};
	}
	
	// might rewrite this one
	
	/**
	 * ONLY USE FOR ABSTRACTED CLASSES THAT ARE JUST VARS does nothing for anything else 
	 * Builds a anon strcture from static uppercase inline variables in an abstract type.
	 * ripped from FlxMacroUtil but modified to fit my needs
	 * https://code.haxe.org/category/macros/combine-objects.html
	 * https://github.com/HaxeFlixel/flixel/blob/master/flixel/system/macros/FlxMacroUtil.hx
	 */
	public static macro function buildAbstract(typePath:Expr, ?exclude:Array<String>)
	{
		var type = Context.getType(typePath.toString());
		var expressions:Array<ObjectField> = [];
		
		if (exclude == null) exclude = ["NONE"];
		
		switch (type.follow())
		{
			case TAbstract(_.get() => ab, _):
				for (f in ab.impl.get().statics.get())
				{
					switch (f.kind)
					{
						case FVar(AccInline, _):
							switch (f.expr().expr)
							{
								case TCast(Context.getTypedExpr(_) => expr, _):
									if (f.name.toUpperCase() == f.name && exclude.indexOf(f.name) == -1) // uppercase?
									{
										expressions.push({field: f.name, expr: expr});
									}
									
								default:
							}
							
						default:
					}
				}
			default:
		}
		
		var finalResult = {expr: EObjectDecl(expressions), pos: Context.currentPos()};
		return macro $b{[macro $finalResult]};
	}
	
	/**
	 * Gets the content from a file before compilation.
	 * 
	 * You must provide the full path to file
	 */
	public static macro function getPrecompliedContent(path:String)
	{
		#if !display
		final resolvedPath = resolveCompileTimePath(path);
		if (resolvedPath == null)
		{
			Context.fatalError('could not find content at $path', Context.currentPos());
		}
		
		final ret = sys.io.File.getContent(resolvedPath);
		
		return macro $v{ret};
		#end
	}
}
