import std.stdio;
import std.file;
import std.path;
import std.regex;
import std.array;
import std.getopt;
import std.algorithm;
import sdlang;

struct Rule {
    string type;
    string target;
    string replacement;
}

class MigrationEngine {
    Rule[] rules;

    this(string sdlPath) {
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
                        r.type = ruleTag.name; // "replace" or "regex"
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

int main(string[] args) {
    string path = ".";
    string rulesPath = "rules/qt5_to_qt6.sdl";
    string extensions = ".py,.cpp,.h";
    bool dryRun = false;

    auto helpInformation = getopt(
        args,
        "path|p", "Path to process (default: .)", &path,
        "rules|r", "Path to SDL rules file", &rulesPath,
        "extensions|e", "Comma-separated extensions (default: .py,.cpp,.h)", &extensions,
        "dry-run|d", "Dry run (no changes)", &dryRun
    );

    if (helpInformation.helpWanted) {
        defaultGetoptPrinter("Qt Upgrader (D version)", helpInformation.options);
        return 0;
    }

    auto engine = new MigrationEngine(rulesPath);
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
    writeln("Processing: ", filename);
    string content = readText(filename);
    string newContent = engine.applyRules(content);

    if (content != newContent) {
        if (dryRun) {
            writeln("  [DRY RUN] Would update ", filename);
        } else {
            std.file.write(filename, newContent);
            writeln("  Updated ", filename);
        }
    }
}
