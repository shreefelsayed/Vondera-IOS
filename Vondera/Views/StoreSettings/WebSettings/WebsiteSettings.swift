//
//  WebsiteSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI

struct WebsiteSettings: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var user = UserInformation.shared
    @State var active = true
    
    var body: some View {
        List {
            if let myUser = user.getUser(), let store = myUser.store {
                Section {
                    Toggle(isOn: $active) {
                        Label("Live website", systemImage: "antenna.radiowaves.left.and.right.circle")
                    }
                }
                
                Section("Theming") {
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
                        BannerTitles()
                    } label: {
                        Label("Banner titles", systemImage: "list.dash.header.rectangle")
                    }
                    
                }
                
                Section("Content") {
                    NavigationLink {
                        CustomPage()
                    } label: {
                        Label("Custom Pages", systemImage: "book")
                    }
                    
                    NavigationLink {
                        FeaturedProducts()
                    } label: {
                        Label("Featured Products", systemImage: "star")
                    }
                    
                    NavigationLink {
                        StoreSocial(store: store)
                    } label: {
                        Label("Social Media Accounts", systemImage: "person.crop.circle.badge.checkmark")
                    }
                    
                }
                
                Section("Payment") {
                    NavigationLink {
                        PaymentSettings()
                    } label: {
                        Label("Payment Options", systemImage: "creditcard.fill")
                    }
                    
                    NavigationLink {
                        DiscountCodes()
                    } label: {
                        Label("Discount Codes", systemImage: "coloncurrencysign")
                    }
                }
                
                Section("Domain Settings") {
                    NavigationLink {
                        ChangeUsername()
                    } label: {
                        Label("Website Username", systemImage: "link.circle")
                    }
                 
                    NavigationLink {
                        CustomDomain()
                    } label: {
                        Label("Custom Domain", systemImage: "w.circle")
                    }
                }
                
                Section("Pixels") {
                    NavigationLink {
                        GTMScreen()
                    } label: {
                        Label {
                            Text("Google Tag Manager")
                        } icon: {
                            Image(.google)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    NavigationLink {
                        FbPixelScreen()
                    } label: {
                        Label {
                            Text("Facebook Pixel")
                        } icon: {
                            Image(.facebook)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                
                Section("Other Settings") {
                    NavigationLink {
                        SiteOptions()
                    } label: {
                        Label("More options", systemImage: "option")
                    }
                    
                    NavigationLink {
                        EmailSettings()
                    } label: {
                        Label("Mailing Settings", systemImage: "envelope.circle")
                    }
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
        .navigationTitle("Website settings")
        .task {
            active = user.getUser()?.store?.websiteEnabled ?? true
        }
        .withAccessLevel(accessKey: .websiteCustomization, presentation: presentationMode)
    }
}

#Preview {
    NavigationStack {
        WebsiteSettings()
    }
}
