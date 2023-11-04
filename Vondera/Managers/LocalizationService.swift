//
//  LocalizationService.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation

enum Language: String {
    case english_us = "en-US"
    case arabic = "ar"
}

class LocalizationService : ObservableObject {
    @Published var currentLanguage:Language = .english_us
    static let shared = LocalizationService()

    private init() {
        update()
    }
    
    func update() {
        currentLanguage = getLanguage()
    }
    
    func setLanguage(_ lang: Language) {
        currentLanguage = lang
        UserDefaults.standard.setValue(lang.rawValue, forKey: "language")
    }
    
    func getLanguage() -> Language {
        //MARK : Check for user pref
        if let languageString = UserDefaults.standard.string(forKey: "language") {
            return Language(rawValue: languageString) ?? .english_us
        }
        
        // MARK : Get Phone Language
        if let lang = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first {
            return Language(rawValue: lang) ?? .english_us
        }
        
        // MARK : return english
        return .english_us
    }
}
