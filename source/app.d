import std.stdio;
import std.file;
import std.path;
import std.regex;
import std.array;
import std.getopt;
import std.algorithm;
import std.container;
import sdlang;

struct Rule {
    string type;
    string target;
    string replacement;
}

class MigrationEngine {
    Rule[] rules;

    void loadRules(string sdlPath) {
        if (!exists(sdlPath)) {
            writeln("Rules file not found: ", sdlPath);
            return;
        }

        try {
            Tag root = parseFile(sdlPath);
            foreach (tag; root.tags) {
                if (tag.name == "ruleset") {
                    foreach (ruleTag; tag.tags) {
                        Rule r;
                        r.type = ruleTag.name;
                        r.target = ruleTag.values[0].get!string;
                        r.replacement = ruleTag.values[1].get!string;
                        rules ~= r;
                    }
                }
            }
        } catch (Exception e) {
            writeln("Error parsing SDL rules: ", e.msg);
        }
    }

    string applyRules(string content) {
        foreach (rule; rules) {
            if (rule.type == "replace") {
                content = content.replace(rule.target, rule.replacement);
            } else if (rule.type == "regex") {
                auto re = regex(rule.target);
                content = replaceAll(content, re, rule.replacement);
            }
        }
        return content;
    }
}

string[] findMigrationPath(string rulesDir, string fromVer, string toVer) {
    struct Edge {
        string to;
        string file;
    }
    Edge[][string] graph;

    if (!exists(rulesDir)) return [];

    foreach (DirEntry entry; dirEntries(rulesDir, SpanMode.shallow)) {
        if (entry.isFile && entry.name.endsWith(".sdl")) {
            auto base = baseName(entry.name, ".sdl");
            auto parts = base.split("-");
            if (parts.length == 2) {
                graph[parts[0]] ~= Edge(parts[1], entry.name);
            }
        }
    }

    // BFS to find shortest path
    string[][string] parent;
    string[][string] parentFile;
    DList!string queue;
    queue.insertBack(fromVer);
    bool[string] visited;
    visited[fromVer] = true;

    while (!queue.empty) {
        auto current = queue.front;
        queue.removeFront();

        if (current == toVer) {
            // Reconstruct path
            string[] path;
            auto curr = toVer;
            while (curr != fromVer) {
                path ~= parentFile[curr][0];
                curr = parent[curr][0];
            }
            reverse(path);
            return path;
        }

        if (current in graph) {
            foreach (edge; graph[current]) {
                if (edge.to !in visited) {
                    visited[edge.to] = true;
                    parent[edge.to] ~= current;
                    parentFile[edge.to] ~= edge.file;
                    queue.insertBack(edge.to);
                }
            }
        }
    }

    return [];
}

int main(string[] args) {
    string path = ".";
    string rulesDir = "rules/qt";
    string fromVer = "";
    string toVer = "";
    string extensions = ".py,.cpp,.h";
    bool dryRun = false;

    auto helpInformation = getopt(
        args,
        "path|p", "Path to process", &path,
        "rules-dir|R", "Directory containing SDL rules", &rulesDir,
        "from|f", "Source version (e.g., 5.15)", &fromVer,
        "to|t", "Target version (e.g., 6.0)", &toVer,
        "extensions|e", "Comma-separated extensions", &extensions,
        "dry-run|d", "Dry run", &dryRun
    );

    if (helpInformation.helpWanted || (fromVer != "" && toVer == "")) {
        defaultGetoptPrinter("Qt Evolution Adapter", helpInformation.options);
        return 0;
    }

    auto engine = new MigrationEngine();
    
    if (fromVer != "" && toVer != "") {
        auto pathFiles = findMigrationPath(rulesDir, fromVer, toVer);
        if (pathFiles.empty) {
            writeln("No migration path found from ", fromVer, " to ", toVer);
            return 1;
        }
        writeln("Migration path: ", fromVer, " -> ", toVer, " using ", pathFiles);
        foreach (f; pathFiles) {
            engine.loadRules(f);
        }
    } else {
        // Fallback to default rule if no versions specified
        string defaultRule = buildPath(rulesDir, "5.15-6.0.sdl");
        if (exists(defaultRule)) {
            engine.loadRules(defaultRule);
        }
    }

    auto extList = extensions.split(",");

    if (!exists(path)) {
        writeln("Path does not exist: ", path);
        return 1;
    }

    if (isDir(path)) {
        foreach (DirEntry entry; dirEntries(path, SpanMode.depth)) {
            if (entry.isFile && extList.canFind(extension(entry.name))) {
                processFile(entry.name, engine, dryRun);
            }
        }
    } else {
        processFile(path, engine, dryRun);
    }

    return 0;
}

void processFile(string filename, MigrationEngine engine, bool dryRun) {
    string content = readText(filename);
    string newContent = engine.applyRules(content);

    if (content != newContent) {
        if (dryRun) {
            writeln("[DRY RUN] ", filename);
        } else {
            std.file.write(filename, newContent);
            writeln("Updated: ", filename);
        }
    }
}
