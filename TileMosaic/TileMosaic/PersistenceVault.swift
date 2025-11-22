//
//  PersistenceVault.swift
//  TileMosaic
//
//  Manages leaderboard data persistence
//

import Foundation

class PersistenceVault {
    static let sharedArchive = PersistenceVault()

    private let noviceRecordsKey = "com.tilemosaic.novice.chronicles"
    private let virtuosoRecordsKey = "com.tilemosaic.virtuoso.chronicles"

    private init() {}

    func archiveAccomplishment(mode: ChromaticDifficulty, strata: Int) {
        let record = ChromaticRecord(
            difficultyMode: mode.rawValue,
            accomplishedStrata: strata,
            chronologicalStamp: Date()
        )

        var existingRecords = retrieveChronicles(for: mode)
        existingRecords.append(record)

        // Sort by level descending
        existingRecords.sort { $0.accomplishedStrata > $1.accomplishedStrata }

        // Keep top 10
        if existingRecords.count > 10 {
            existingRecords = Array(existingRecords.prefix(10))
        }

        let key = mode == .novice ? noviceRecordsKey : virtuosoRecordsKey
        if let encoded = try? JSONEncoder().encode(existingRecords) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func retrieveChronicles(for mode: ChromaticDifficulty) -> [ChromaticRecord] {
        let key = mode == .novice ? noviceRecordsKey : virtuosoRecordsKey
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([ChromaticRecord].self, from: data) else {
            return []
        }
        return records
    }

    func obliterateAllChronicles() {
        UserDefaults.standard.removeObject(forKey: noviceRecordsKey)
        UserDefaults.standard.removeObject(forKey: virtuosoRecordsKey)
    }
}
