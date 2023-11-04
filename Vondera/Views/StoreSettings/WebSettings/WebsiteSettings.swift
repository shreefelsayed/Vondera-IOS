//
//  WebsiteSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI

struct WebsiteSettings: View {
    @ObservedObject var user = UserInformation.shared
    @State var active = true
    var body: some View {
        List {
            if let myUser = user.user, let store = myUser.store {
                
                VStack(alignment: .leading) {
                    Toggle(isOn: $active) {
                        Label("Live website", systemImage: "antenna.radiowaves.left.and.right.circle")
                    }
                    .disabled(!(store.subscribedPlan?.website ?? false))
                    
                    if !(store.subscribedPlan?.website ?? false) {
                        NavigationLink("Upgrade your plan to enable the website") {
                            AppPlans()
                        }
                        .font(.caption)
                        //Text("Upgrade your plan to enable the website")
                    }
                }
                
                
                NavigationLink {
                    ChangeUsername()
                } label: {
                    Label("Website Username", systemImage: "link.circle")
                }
                
                NavigationLink {
                    WebsiteTheme()
                } label: {
                    Label("Website theme", systemImage: "tshirt")
                }

                NavigationLink {
                    WebsiteCover()
                } label: {
                    Label("Cover photos", systemImage: "photo.on.rectangle.angled")
                }
                
                NavigationLink {
                    FeaturedProducts()
                } label: {
                    Label("Featured Products", systemImage: "star")
                }
                
                NavigationLink {
                    CustomPage()
                } label: {
                    Label("Custom Pages", systemImage: "book")
                }
                
                NavigationLink {
                    DiscountCodes()
                } label: {
                    Label("Discount Codes", systemImage: "coloncurrencysign")
                }
                
                NavigationLink {
                    PaymentSettings()
                } label: {
                    Label("Payment Options", systemImage: "creditcard.fill")
                }
                
                NavigationLink {
                    StoreSocial(store: store)
                } label: {
                    Label("Social Media Account", systemImage: "person.crop.circle.badge.checkmark")
                }
                
                NavigationLink {
                    SiteOptions()
                } label: {
                    Label("More options", systemImage: "option")
                }
            }
        }
        .onChange(of: active, perform: { newValue in
            if let id = UserInformation.shared.user?.storeId {
                UserInformation.shared.user?.store?.websiteEnabled = newValue
                Task {
                    try? await StoresDao().update(id:id, hashMap: ["websiteEnabled" : newValue])
                }
            }
            
        })
        .task {
            active = user.user?.store?.websiteEnabled ?? true
        }
    }
}

#Preview {
    WebsiteSettings()
}
