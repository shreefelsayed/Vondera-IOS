//
//  ImportShopify.swift
//  Vondera
//
//  Created by Shreif El Sayed on 30/11/2023.
//

import SwiftUI
import AlertToast

struct ImportShopify: View {
    @State private var shopId = ""
    @State private var adminAccessToken = ""
    @State private var showWarning = false
    
    @State private var msg:String?
    
    @State private var importing = false
    @State private var done = false
    @State private var data:[String: Any]?
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("import_shopify") var walkthrough = true

    var body: some View {
        ZStack {
            if walkthrough {
                ImportShopifyIntro(shouldShow: $walkthrough)
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        FloatingTextField(title: "Your shop id ex (f31a37.myshopify.com)", text: $shopId, caption: "This is the shop id found under your store name in shopify settings", required: true, keyboard: .webSearch)
                        
                        FloatingTextField(title: "Custom app admin api token ex (shpat_XXXX)", text: $adminAccessToken, caption: "This is the shop id found under your store name in shopify settings", required: true)
                        
                        
                        ButtonLarge(label: "Import Shopify Store", background: .accentColor, textColor: .white) {
                            showWarning.toggle()
                        }
                    }
                    
                }
                .padding()
                .confirmationDialog("Import shopify data", isPresented: $showWarning, titleVisibility: .visible, actions: {
                    Button("Start Importing", role: .none) {
                        Task {
                            await startImporting()
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {
                        
                    }
                }, message: {
                    Text("By importing your shopify data, we will import all of your orders, products, collections, if you already imported the data before, you don't need to import it again")
                })
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Walkthrough") {
                            walkthrough.toggle()
                        }
                    }
                }
                
                .sheet(isPresented: $done, onDismiss: {
                    Task {
                        await UserInformation.shared.refetchUser()
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }, content: {
                    NavigationStack {
                        VStack(alignment: .center, spacing: 24){
                            Image("shopify")
                                .resizable()
                                .aspectRatio(contentMode: .fit) // or .fill, depending on your preference
                                .frame(height: 240)
                            
                            Text("Your data from shopify has been imported 🎉")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .bold()
                                .padding(.bottom, 24)
                            
                            Group {
                                HStack {
                                    Text("\(data!["products"] as! Int) Products")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                
                                HStack {
                                    Text("\(data!["collections"] as! Int) Categories")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                
                                HStack {
                                    Text("\(data!["orders"] as! Int) Orders")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .font(.headline)
                            .bold()
                            
                            Spacer()
                        }
                        .padding()
                    }
                })
                .toast(isPresenting: Binding(value: $msg), alert: {
                    AlertToast(displayMode: .alert, type: .regular, title: msg)
                })
                .navigationTitle("Import from shopify")
                .willProgress(saving: importing)
            }
        }
        
        
        
    }
    
    func startImporting() async {
        guard !shopId.isBlank else {
            msg = "Please enter your shop id"
            return
        }
        
        guard !adminAccessToken.isBlank else {
            msg = "Please enter your admin access token"
            return
        }
        
        importing = true
        
        // --> Set the data
        if let storeId = UserInformation.shared.user?.storeId {
            let data = [
                "storeId": storeId,
                "accessToken" : adminAccessToken,
                "shopId" : shopId.replacingOccurrences(of: "https://", with: "")
            ]
            
            if let result = try? await FirebaseFunctionCaller().callFunction(functionName: "shopify-copyShopifyStore", data: data) {
                DispatchQueue.main.async {
                    if let resultData = result.data as? [String: Any], let _ = resultData["error"] as? String {
                        self.msg = "Make sure you entered a valid credintals"
                        self.importing = false
                    } else {
                        // -->
                        self.msg = "Data imported succefully"
                        self.importing = false
                        self.done = true
                        self.data = result.data as? [String: Any]
                    }
                }
                
            } else {
                msg = "Make sure you entered a valid credintals"
                importing = false
                return
            }
        } else {
            msg = "Something went wrong"
            importing = false
            return
        }
    }
}

#Preview {
    ImportShopify()
}
