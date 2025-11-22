//
//  VestigeEntity.swift
//  TileMosaic
//
//  Core data models for tile entities
//

import UIKit

// Tile categories
enum ObsoleteCategory: String, CaseIterable {
    case bdruu = "bdruu"
    case ueiuje = "ueiuje"
    case zmeoe = "zmeoe"
    case qiwiea = "qiwiea"
}

// Game difficulty mode
enum ChromaticDifficulty: String {
    case novice = "Novice Mode"
    case virtuoso = "Virtuoso Mode"

    var gridDimension: Int {
        switch self {
        case .novice: return 2
        case .virtuoso: return 3
        }
    }

    var memorizeInterval: Int {
        switch self {
        case .novice: return 5
        case .virtuoso: return 10
        }
    }

    var puzzleFragments: Int {
        switch self {
        case .novice: return 4 // 4x4 grid
        case .virtuoso: return 6 // 6x6 grid
        }
    }
}

// Tile data structure
struct VestigeTileEntity {
    let identifier: String
    let obsoleteCategory: ObsoleteCategory
    let numericValue: Int

    var imageDesignation: String {
        return identifier
    }

    static func generateArbitraryTile() -> VestigeTileEntity {
        let categoriesArray = ObsoleteCategory.allCases
        let selectedCategory = categoriesArray.randomElement()!

        let maxValue: Int
        switch selectedCategory {
        case .qiwiea:
            maxValue = 7
        default:
            maxValue = 8
        }

        let value = Int.random(in: 1...maxValue)
        return VestigeTileEntity(
            identifier: "\(selectedCategory.rawValue)\(value)",
            obsoleteCategory: selectedCategory,
            numericValue: value
        )
    }
}

// Leaderboard record
struct ChromaticRecord: Codable {
    let difficultyMode: String
    let accomplishedStrata: Int
    let chronologicalStamp: Date

    var formattedChronology: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: chronologicalStamp)
    }
}
