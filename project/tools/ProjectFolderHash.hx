package;

import sys.FileSystem;
import fsindexer.tree.IndexedFileTree;
import fsindexer.filter.PathFilter;

using StringTools;

class ProjectFolderHash
{
	static function main():Void
	{
		var projectFolderPath = "..";
		var indexFile = "project.index";
		if(FileSystem.exists(indexFile))
			FileSystem.deleteFile(indexFile);

		var excludeFilter = PathFilters.fromExcludePredicate(path -> {
			if(path == "obj" || path == "tools" || path == indexFile || path == "BuildHashlink.xml" || path == "README.md") return true;
			if(path.endsWith(".DS_Store")) return true;
			//for direct descendants of lib/
			if(path.startsWith("lib/") && path.indexOf("/", 4) == -1)
			{
				//don't ignore custom or *.xml, ignore everything else (lib folders)
				return !path.endsWith("/custom") && !path.endsWith(".xml");
			}
			return false;
		});
		
		var sourceTree = IndexedFileTree.loadWithFilter(projectFolderPath, indexFile, excludeFilter);
		
		trace(sourceTree.getRoot().getHash());
	}
}
