//
//  UserHome.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import NetworkImage

struct UserHome: View {
    @StateObject var viewModel = UserHomeViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            HomeFragment()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }.padding()
            OrdersFragment()
                .tabItem {
                    Image(systemName: "backpack.fill")
                    Text("Orders")
                }
            
            StoreFragment()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if viewModel.myUser != nil {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    NavigationLink(destination: Dashboard(store: viewModel.myUser!.store!)) {
                        NetworkImage(url: URL(string: viewModel.myUser?.store!.logo ?? "" )) { image in
                            image.centerCropped()
                        } placeholder: {
                            ProgressView()
                        } fallback: {
                            Image("defaultPhoto")
                                .resizable()
                                .centerCropped()
                        }
                        .background(Color.white)
                        .frame(width: 30, height: 30, alignment: .bottomTrailing)
                        .clipShape(Circle())
                    }
                })
                
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Text(viewModel.myUser?.store?.name ?? "")
                        .font(.title)
                        .bold()
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationLink(destination: OrderSearchView(storeId: viewModel.myUser!.storeId)) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .resizable()
                    }
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationLink(destination: QrCodeScanner(storeId: viewModel.myUser?.storeId ?? "")) {
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                    }
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationLink(destination: AddToCart(storeId: viewModel.myUser!.storeId)) {
                        Image(systemName: "cart")
                            .resizable()
                    }
                })
            }
        }
        .onAppear {
            Task {
                await viewModel.getUser()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                online()
            } else if newPhase == .background {
                offline()
            }
        }
    }
    
    func online() {
        Task { await viewModel.userOnline() }
    }
    
    func offline() {
        Task { await viewModel.userOffline() }
    }
}

struct UserHome_Previews: PreviewProvider {
    static var previews: some View {
        UserHome()
    }
}
