//
//  RemoteConfigManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 12/11/2024.
//


import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager {
    
    // Shared instance for easy access
    static let shared = RemoteConfigManager()
    
    // Firebase Remote Config instance
    private let remoteConfig: RemoteConfig
    
    // Config keys
    private enum ConfigKeys: String {
        case awsAccessKey = "aws_access_key"
        case awsSecretKey = "aws_secret_key"
    }
    
    // Initialize and configure Remote Config
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        // Set default values (optional)
        let defaults: [String: NSObject] = [
            ConfigKeys.awsAccessKey.rawValue: "" as NSObject,
            ConfigKeys.awsSecretKey.rawValue: "" as NSObject
        ]
        remoteConfig.setDefaults(defaults)
        
        // Set minimum fetch interval (for development, set this lower; in production, use a higher interval)
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings
    }
    
    // Method to fetch values from Remote Config
    func fetchRemoteConfig(completion: @escaping (Bool) -> Void) {
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("Error fetching remote config: \(error)")
                completion(false)
                return
            }
            completion(status == .successFetchedFromRemote || status == .successUsingPreFetchedData)
        }
    }
    
    // Static computed properties to retrieve AWS keys
    static var awsAccessKey: String {
        return shared.remoteConfig[ConfigKeys.awsAccessKey.rawValue].stringValue ?? ""
    }
    
    static var awsSecretKey: String {
        return shared.remoteConfig[ConfigKeys.awsSecretKey.rawValue].stringValue ?? ""
    }
}
