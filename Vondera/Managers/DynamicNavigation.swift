//
//  DynamicNavigation.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/03/2024.
//

import Foundation
import SwiftUI

struct Destination: Identifiable, Hashable, Equatable {
    static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
        }
    
    var id = UUID().uuidString
    var dest:AnyView
}


class DynamicNavigation : ObservableObject {
    @Published var destination: Destination?
    @Published var isPreseneted:Bool = false
    static let shared = DynamicNavigation()

    func navigate(to view:AnyView?) {
        guard let view = view else {return}
        destination = Destination(dest: view)
        isPreseneted = true
    }
}
