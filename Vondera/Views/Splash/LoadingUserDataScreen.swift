//
//  LoadingUserDataScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/03/2024.
//

import SwiftUI

struct LoadingUserDataScreen: View {
    @ObservedObject var user = UserInformation.shared
    
    var body: some View {
        if let _ = user.user {
            AccountHomeScreen()
        } else {
            SplashScreen()
                .task {
                    do {
                        let loggedUser = try await AuthManger().getData()
                        if loggedUser == nil {
                            await AuthManger().logOut()
                        }
                    } catch {
                        await AuthManger().logOut()
                    }
                }
        }
    
    }
}

#Preview {
    LoadingUserDataScreen()
}
