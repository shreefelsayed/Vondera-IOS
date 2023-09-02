//
//  AppStoreHelper.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/08/2023.
//

import Foundation
import StoreKit

class AppStoreHelper {
    func showRating() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
