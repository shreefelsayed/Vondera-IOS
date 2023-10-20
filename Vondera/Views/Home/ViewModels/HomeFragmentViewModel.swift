//
//  HomeFragmentViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import UIKit

class HomeFragmentViewModel : ObservableObject {
    @Published var myUser:UserData?
    
    var productsDao:ProductsDao?
    var govStaticsDao:GovStaticsDao?
    
    var usersDao = UsersDao()
    var storesDao = StoresDao()
    var tipDao = TipDao()
    
    @Published var isLoading = true
    
    @Published var tip:Tip? = nil
    @Published var topSelling = [StoreProduct]()
    @Published var topAreas = [GovStatics]()
    @Published var onlineUser = [UserData]()
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
        
        productsDao = ProductsDao(storeId: myUser!.storeId)
        govStaticsDao = GovStaticsDao(storeId: myUser!.storeId)
        
        await getTipOfDay()
        
        await getTopProducts()
        
        await getTopCities()
        
        await getOnlineUsers()
        
        await getStatics()
    }
    
    func initalize()  {
        self.isLoading = true
        self.myUser = UserInformation.shared.getUser()
        
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
            let items = try await StaticsDao(storeId: myUser!.storeId).getLastDays(days: staticsDays)
            DispatchQueue.main.async {
                self.storeStatics = items
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUser() async {
        do {
            if let myUser = myUser {
                if let userDoc = try await usersDao.getUserWithStore(userId: myUser.id) {
                    UserInformation.shared.updateUser(userDoc)
                    DispatchQueue.main.async { [userDoc] in
                        self.myUser = userDoc
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func getOnlineUsers() async {
        do {
            if let myUser = myUser {
                let items = try await usersDao.getOnlineUser(expectId: myUser.id, storeId: myUser.storeId)
                DispatchQueue.main.async {
                    self.onlineUser = items
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUser() async {
        if let user = UserInformation.shared.getUser() {
            DispatchQueue.main.async {
                self.myUser = user
            }
        }
    }
    
    func getTopProducts() async {
        do {
            if let items = try await productsDao?.getTopSelling() {
                DispatchQueue.main.async {
                    self.topSelling = items
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTopCities() async {
        do {
            if let items = try await govStaticsDao?.getStatics() {
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
