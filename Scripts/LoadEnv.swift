import Foundation

/// Simple .env loader for local development.
/// Supports KEY=VALUE lines, ignores comments (#) and blank lines.
struct EnvLoader {
    static func load(from filename: String = ".env.local") {
        guard let root = ProcessInfo.processInfo.environment["PROJECT_ROOT"] ?? FileManager.default.currentDirectoryPath as String? else { return }
        let path = (root as NSString).appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: path),
              let data = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }
        data.split(separator: "\n").forEach { lineSub in
            let line = lineSub.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#"),
                  let eq = line.firstIndex(of: "=") else { return }
            let key = String(line[..<eq]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
            setenv(key, value, 1)
        }
    }
}
