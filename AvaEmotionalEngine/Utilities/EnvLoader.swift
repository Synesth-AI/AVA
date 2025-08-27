import Foundation

/// Simple .env loader for local development.
/// Reads KEY=VALUE pairs (ignores lines starting with # and blank lines)
struct EnvLoader {
    /// Loads environment variables from a file sitting at project root (default .env.local)
    /// Any loaded value overrides existing process env values.
    static func load(from filename: String = ".env.local") {
        // Determine project root: use PROJECT_ROOT env or current directory
        let root = ProcessInfo.processInfo.environment["PROJECT_ROOT"] ?? FileManager.default.currentDirectoryPath
        let path = (root as NSString).appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: path),
              let data = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }
        data.split(separator: "\n").forEach { rawLine in
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#"),
                  let eq = line.firstIndex(of: "=") else { return }
            let key = String(line[..<eq]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
            setenv(key, value, 1) // override existing var if present
        }
    }
}
