//
//  EncodableExtenstion.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation

extension Encodable {
    func asDicitionry() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}
