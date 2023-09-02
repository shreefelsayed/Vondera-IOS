//
//  HomeFragmentViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import UIKit

class HomeFragmentViewModel : ObservableObject {
    @Published var user:UserData?
    
    var productsDao:ProductsDao?
    var govStaticsDao:GovStaticsDao?
    
    var usersDao = UsersDao()
    var storesDao = StoresDao()
    var tipDao = TipDao()
    
    @Published var isLoading = true
    
    @Published var tip:Tip? = nil
    @Published var topSelling = [Product]()
    @Published var topAreas = [GovStatics]()
    @Published var onlineUser = [UserData]()

    init() {
        initalize()
    }
    
    func initalize()  {
        print("View model inited")
        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                
                user = await getUser()
                
                guard user != nil else {
                    print("user wasn't saved")
                    await AuthManger().logOut()
                    return
                }
                
                productsDao = ProductsDao(storeId: user!.storeId)
                govStaticsDao = GovStaticsDao(storeId: user!.storeId)

                await updateUser()
                
                await getTipOfDay()
                
                await getTopProducts()
                
                await getTopCities()
                
                await getOnlineUsers()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
            }
        }
    }
    
    func updateUser() async {
        
        do {
            var userDoc = try await usersDao.getUser(uId: user!.id)
            let store = try await storesDao.getStore(uId: user!.storeId)
            
            userDoc?.store = store
            _ = await LocalInfo().saveUser(user: userDoc!)
            
            self.user = userDoc
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    func getOnlineUsers() async {
        do {
            onlineUser =  try await usersDao.getOnlineUser(expectId: user?.id ?? "", storeId: user?.storeId ?? "")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUser() async -> UserData? {
        let user = await LocalInfo().getLocalUser()
        DispatchQueue.main.async {
            self.user = user
        }
        return user
    }
    
    func getTopProducts() async {
        do {
            topSelling = try await productsDao!.getTopSelling()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTopCities() async {
        do {
            topAreas = try await govStaticsDao!.getStatics()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTipOfDay() async {
        do {
            tip = try await tipDao.getTipOfTheDay()
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
