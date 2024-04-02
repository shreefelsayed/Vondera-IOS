//
//  HomeFragmentViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import UIKit

class HomeFragmentViewModel : ObservableObject {
    var myUser = UserInformation.shared.user
        
    var usersDao = UsersDao()
    var storesDao = StoresDao()
    var tipDao = TipDao()
    
    @Published var isLoading = true
    
    @Published var tip:Tip? = nil
    @Published var topAreas = [GovStatics]()
    @Published var storeStatics = [StoreStatics]()
    @Published var staticsDays = 7 {
        didSet {
            Task {
                await getStatics()
            }
        }
    }
    
    
    init() {
        initalize()
    }
    
    
    func refreshData() async {
        await updateUser()
                
        await getTipOfDay()
                
        await getTopCities()
                
        await getStatics()
    }
    
    func initalize()  {
        self.isLoading = true
        Task {
            do {
                guard myUser != nil else {
                    print("user wasn't saved")
                    await AuthManger().logOut()
                    return
                }
                
                await refreshData()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func getStatics() async {
        guard (myUser?.store?.ordersCount ?? 0) > 10 else {
            return
        }
        
        do {
            if let storeId = myUser?.storeId {
                let items = try await StaticsDao(storeId: storeId).getLastDays(days: staticsDays)
                DispatchQueue.main.async {
                    self.storeStatics = items
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUser() async {
        do {
            if let myUser = myUser {
                if let userDoc = try await usersDao.getUserWithStore(userId: myUser.id) {
                    DispatchQueue.main.async { [userDoc] in
                        UserInformation.shared.updateUser(userDoc)
                        self.myUser = userDoc
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTopCities() async {
        do {
            if let id = myUser?.storeId {
                let items = try await GovStaticsDao(storeId: id).getStatics()
                DispatchQueue.main.async {
                    self.topAreas = items
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTipOfDay() async {
        do {
            if let items = try await tipDao.getTipOfTheDay() {
                DispatchQueue.main.async {
                    self.tip = items
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func openLink(url:String?) {
        if let url = url {
            if let Url = URL(string: url) {
                UIApplication.shared.open(Url)
            }
        }
    }
}
