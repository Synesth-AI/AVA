import Foundation
import SQLite3

// Simple SQLite-backed storage for EEG readings
// Table: eeg_samples(timestamp REAL, alpha REAL, beta REAL, gamma REAL, theta REAL, delta REAL)
final class EEGStorage {
    static let shared = EEGStorage()
    private init() { openDatabase(); createTableIfNeeded() }

    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "EEGStorageQueue")

    private func databaseURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("eeg.sqlite3")
    }

    private func openDatabase() {
        let url = databaseURL()
        if sqlite3_open(url.path, &db) != SQLITE_OK {
            print("[EEGStorage] Failed to open database at \(url.path)")
        }
    }

    private func createTableIfNeeded() {
        let sql = """
        CREATE TABLE IF NOT EXISTS eeg_samples (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp REAL NOT NULL,
            alpha REAL NOT NULL,
            beta REAL NOT NULL,
            gamma REAL NOT NULL,
            theta REAL NOT NULL,
            delta REAL NOT NULL
        );
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("[EEGStorage] Failed to create table")
            }
        } else {
            print("[EEGStorage] Failed to prepare create table")
        }
        sqlite3_finalize(stmt)
    }

    func insert(timestamp: TimeInterval, reading: EEGReading) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let sql = "INSERT INTO eeg_samples(timestamp, alpha, beta, gamma, theta, delta) VALUES(?,?,?,?,?,?)"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_double(stmt, 1, timestamp)
                sqlite3_bind_double(stmt, 2, reading.alpha)
                sqlite3_bind_double(stmt, 3, reading.beta)
                sqlite3_bind_double(stmt, 4, reading.gamma)
                sqlite3_bind_double(stmt, 5, reading.theta)
                sqlite3_bind_double(stmt, 6, reading.delta)
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("[EEGStorage] insert failed")
                }
            } else {
                print("[EEGStorage] prepare insert failed")
            }
            sqlite3_finalize(stmt)
        }
    }

    // Export all samples to CSV and return the file URL
    func exportCSV(completion: @escaping (URL?) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { DispatchQueue.main.async { completion(nil) }; return }
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = docs.appendingPathComponent("eeg_export_\(Int(Date().timeIntervalSince1970)).csv")
            let header = "timestamp,alpha,beta,gamma,theta,delta\n"
            var csv = header
            let sql = "SELECT timestamp, alpha, beta, gamma, theta, delta FROM eeg_samples ORDER BY timestamp ASC"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, sql, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    let ts = sqlite3_column_double(stmt, 0)
                    let alpha = sqlite3_column_double(stmt, 1)
                    let beta = sqlite3_column_double(stmt, 2)
                    let gamma = sqlite3_column_double(stmt, 3)
                    let theta = sqlite3_column_double(stmt, 4)
                    let delta = sqlite3_column_double(stmt, 5)
                    csv += "\(ts),\(alpha),\(beta),\(gamma),\(theta),\(delta)\n"
                }
                sqlite3_finalize(stmt)
            } else {
                // Even if select fails, still produce a header-only file so sharing works
                print("[EEGStorage] prepare select failed; exporting header-only CSV")
            }
            do {
                try csv.write(to: url, atomically: true, encoding: .utf8)
                DispatchQueue.main.async { completion(url) }
            } catch {
                print("[EEGStorage] failed writing CSV: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
