//
//  LocalizationManager.swift
//  WorkoutPulse
//
//  Created by Leon Grimmeisen on 29.08.24.
//

import Foundation

class LocalizationManager {
    private let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func getLanguage() -> Language {
        return dataManager.getLanguage()
    }
    
    func saveLanguage(language: Language) {
        dataManager.saveLanguage(language)
        // Consider adding a small delay or using async/await if needed
    }
}

enum Language: String, Identifiable, Codable, Equatable {
    case english = "EN"
    case german = "DE"
    
    var id: String { self.rawValue }
    
    var locale: Locale {
        switch self {
        case .english: return Locale(identifier: "en")
        case .german: return Locale(identifier: "de")
        }
    }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        }
    }
}
