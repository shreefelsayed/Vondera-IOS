//
//  WebsiteTheme.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast
import FirebaseFirestore

struct WebsiteTheme: View {
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:String?
    @Environment(\.presentationMode) private var presentationMode
    
    @State var theme = [String]()
    @State var selectedTheme = 1
    @State var primaryColor = Color.brown
    @State var accentColor = Color.brown

    var body: some View {
        List {
            if !theme.isEmpty {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(theme.indices, id: \.self) { index in
                        Text(theme[index])
                            .tag(index)
                    }
                }
                .pickerStyle(.menu)
            }
            
            HStack {
                Text("Primary Color")
                Spacer()
                ColorPicker(selection: $primaryColor, supportsOpacity: false) {
                    Image(systemName: "eyedropper")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(6)
                        .clipShape(.circle)
                }
            }
            
            HStack {
                Text("Secondary Color")
                Spacer()
                ColorPicker(selection: $accentColor, supportsOpacity: false) {
                    Image(systemName: "eyedropper")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(6)
                        .clipShape(.circle)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(saving)
            }
        }
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .task {
            if let siteData = user.user?.store?.siteData {
                selectedTheme = siteData.themeId ?? 1
                primaryColor = Color(hex: siteData.primaryColor ?? "")
                accentColor = Color(hex: siteData.secondaryColor ?? "")
                getTheme()
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        }
        .navigationTitle("Website theme")
    }
    
    func getTheme() {
        Task {
            if let doc = try? await Firestore.firestore().collection("main").document("ecommerce").getDocument() {
                let items:[String] = doc.data()?["themes"] as! [String]
                DispatchQueue.main.async {
                    self.theme = items
                }
            }
        }
    }
    
    func update() {
        Task {
            if let id = UserInformation.shared.user?.storeId {
                saving = true
                
                let data = [
                    "siteData.primaryColor" : primaryColor.toHex(),
                    "siteData.secondaryColor" : accentColor.toHex(),
                    "siteData.themeId" : selectedTheme,
                ]
                
                if let _ = try? await StoresDao().update(id: id, hashMap: data) {
                    DispatchQueue.main.async { [self] in
                        UserInformation.shared.user?.store?.siteData?.primaryColor = primaryColor.toHex()
                        UserInformation.shared.user?.store?.siteData?.secondaryColor = accentColor.toHex()
                        UserInformation.shared.user?.store?.siteData?.themeId = selectedTheme
                        UserInformation.shared.updateUser()
                        presentationMode.wrappedValue.dismiss()
                        msg = "Updated"
                    }
                } else {
                    msg = "Error Happened"
                }
                
                saving = false
            }
            
        }
    }
}

#Preview {
    WebsiteTheme()
}
