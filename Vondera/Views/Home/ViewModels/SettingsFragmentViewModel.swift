//
//  SettingsFragmentViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation

class SettingsFragmentViewModel: ObservableObject {
    lazy var user:UserData? = nil

    init() {
        user = UserInformation.shared.getUser()
    }
}
