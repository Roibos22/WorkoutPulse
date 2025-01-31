//
//  Language.swift
//  WorkoutPulse
//
//  Created by Leon Grimmeisen on 30.08.24.
//
import Foundation

enum Language: String, Identifiable, Codable, Equatable {
    case englishUK = "EN_UK"
    case englishUS = "EN_US"
    case german = "DE"
    case italian = "IT"
    case french = "FR"
    case spanish = "ES"
    case portuguesePT = "PT_PT"
    case portugueseBR = "PT_BR"
    
    var id: String { self.rawValue }
    
    var locale: Locale {
        switch self {
        case .englishUK: return Locale(identifier: "en_GB")
        case .englishUS: return Locale(identifier: "en_US")
        case .german: return Locale(identifier: "de_DE")
        case .italian: return Locale(identifier: "it_IT")
        case .french: return Locale(identifier: "fr_FR")
        case .spanish: return Locale(identifier: "es_ES")
        case .portuguesePT: return Locale(identifier: "pt_PT")
        case .portugueseBR: return Locale(identifier: "pt_BR")
        }
    }
    
    // ... other properties ...

    static func from(locale: Locale) -> Language {
        let languageCode = locale.language.languageCode?.identifier.lowercased()
        let regionCode = locale.region?.identifier.uppercased()
        
        switch (languageCode, regionCode) {
        case ("en", "GB"): return .englishUK
        case ("en", "US"): return .englishUS
        case ("de", _): return .german
        case ("it", _): return .italian
        case ("fr", _): return .french
        case ("es", _): return .spanish
        case ("pt", "PT"): return .portuguesePT
        case ("pt", "BR"): return .portugueseBR
        default: return .englishUS // Default to US English if no match
        }
    }
    
    var displayName: String {
        switch self {
        case .englishUK: return "🇬🇧 English"
        case .englishUS: return "🇺🇸 English"
        case .german: return "🇩🇪 Deutsch"
        case .italian: return "🇮🇹 Italiano"
        case .french: return "🇫🇷 Français"
        case .spanish: return "🇪🇸 Español"
        case .portuguesePT: return "🇵🇹 Português"
        case .portugueseBR: return "🇧🇷 Português"
        }
    }
    
    var defaultWorkoutTitle: String {
        switch self {
        case .englishUK, .englishUS: return "New Workout"
        case .german: return "Neues Workout"
        case .italian: return "Nuovo Allenamento"
        case .french: return "Nouvel Entraînement"
        case .spanish: return "Nuevo Entrenamiento"
        case .portuguesePT, .portugueseBR: return "Novo Treino"
        }
    }
    
    var defaultExerciseTitle: String {
        switch self {
        case .englishUK, .englishUS: return "Exercise"
        case .german: return "Übung"
        case .italian: return "Esercizio"
        case .french: return "Exercice"
        case .spanish: return "Ejercicio"
        case .portuguesePT, .portugueseBR: return "Exercício"
        }
    }
    
    var defaultNewExerciseTitle: String {
        switch self {
        case .englishUK, .englishUS: return "New Exercise"
        case .german: return "Neue Übung"
        case .italian: return "Nuovo Esercizio"
        case .french: return "Nouvel Exercice"
        case .spanish: return "Nuevo Ejercicio"
        case .portuguesePT, .portugueseBR: return "Novo Exercício"
        }
    }
}

