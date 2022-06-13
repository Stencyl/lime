package;

import sys.FileSystem;
import fsindexer.tree.IndexedFileTree;
import fsindexer.filter.PathFilter;
import fsindexer.filter.PathVisitResult;

using StringTools;

class ProjectFolderHash
{
	static function main():Void
	{
		var projectFolderPath = "..";
		var indexFile = "project.index";
		if(FileSystem.exists(indexFile))
			FileSystem.deleteFile(indexFile);

		var sourceTree = IndexedFileTree.loadWithFilter(projectFolderPath, indexFile, new ProjectFolderPathFilter());
		
		trace(sourceTree.getRoot().getHash());
	}
}

class ProjectFolderPathFilter implements PathFilter
{
	public function new() {}

	public function requiresTraversal():Bool
		return false;
	
	public function preVisitDirectory(path:String):PathVisitResult
	{
		if(path == "obj" || path == "tools")
			return EXCLUDE;
		if(path.startsWith("lib/") && !path.startsWith("lib/custom"))
			return EXCLUDE;
		return INCLUDE;
	}

	public function visitFile(path:String):PathVisitResult
	{
		if(path.endsWith("project.index") || path.endsWith("README.md") || path.endsWith(".DS_Store"))
			return EXCLUDE;
		return INCLUDE;
	}

	public function postVisitDirectory(path:String):Void {}
}