package;

import sys.FileSystem;
import fsindexer.tree.IndexedFileTree;
import fsindexer.filter.PathFilter;

class ProjectFolderHash
{
	static function main():Void
	{
		var projectFolderPath = "..";
		var indexFile = "project.index";
		if(FileSystem.exists(indexFile))
			FileSystem.deleteFile(indexFile);

		var pathsToExclude = ["lib" => "", "obj" => "", "tools" => ""];
		var excludeFilter = PathFilters.fromExcludePredicate(path -> pathsToExclude.exists(path));
		
		var sourceTree = IndexedFileTree.loadWithFilter(projectFolderPath, indexFile, excludeFilter);
		
		trace(sourceTree.getRoot().getHash());
	}
}
