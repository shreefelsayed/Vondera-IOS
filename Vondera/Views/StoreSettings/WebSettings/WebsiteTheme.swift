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
    var storeId:String
    
    @State private var isSaving = false
    @State private var isLoading = false
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var themes = [ThemeModel]()
    @State private var fonts = [String]()
    
    @State private var selectedThemeId = 1
    @State private var selectedFont = 1
    
    @State private var primaryColor = Color.brown
    @State private var accentColor = Color.brown
    
    @State private var store:Store?
    @State private var showWarning:Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                Text("Font Theming")
                    .bold()
                
                HStack {
                    Text("Font Color")
                    Spacer()
                    ColorPicker(selection: $accentColor, supportsOpacity: false) {
                        Image(systemName: "eyedropper")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(6)
                            .clipShape(.circle)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Font Face")
                    
                    Spacer()
                    
                    Picker("Fonts", selection: $selectedFont) {
                        ForEach(fonts.indices, id: \.self) { index in
                            Text(fonts[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Spacer().frame(height: 24)
                
                Text("Website Theme")
                    .bold()
                
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
                
                Divider()
                
                
                ThemePicker(themes: themes, currentThemeId: selectedThemeId) { themeId in
                    selectedThemeId = themeId
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await validate() }
                }
            }
        }
        .confirmationDialog("Theme Changed", isPresented: $showWarning, actions: {
            Button("Switch Theme", role: .destructive) {
                Task { await update() }
            }
            Button("Cancel", role: .cancel) {
                showWarning = false // Dismiss the dialog
            }
        }, message: {
            Text("You have changed your website theme, this will lead to reset all of your colors, are you sure you want to switch the theme ?")
        })
        .willProgress(saving: isSaving)
        .willLoad(loading: isLoading)
        .task {
            await fetch()
        }
        .navigationTitle("Website theme")
    }
    
    func fetch() async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            let themes = try await ThemeDao().getThemes()
            let doc = try await Firestore.firestore().collection("main").document("ecommerce").getDocument()
            guard let store = store else { return }
            
            DispatchQueue.main.async {
                self.updateUI(store)
                self.themes = themes
                self.fonts = doc.data()?["fonts"] as! [String]
                self.isLoading = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUI(_ store:Store) {
        self.store = store
        selectedThemeId = store.siteData?.themeId ?? 1
        selectedFont = store.siteData?.fontId ?? 1
        primaryColor = Color(hex: store.siteData?.primaryColor ?? "")
        accentColor = Color(hex: store.siteData?.secondaryColor ?? "")
    }
    
    func hasUpdatedTheme() -> Bool {
        return store?.siteData?.themeId != selectedThemeId
    }
    
    func validate() async {
        guard !hasUpdatedTheme() else {
            showWarning.toggle()
            return
        }
        
        await update()
        
    }
    
    func update() async {
        DispatchQueue.main.async { self.isSaving = true }
        
        do {
            let data:[String:Any] = [
                "storeId": storeId,
                "primaryColor" : primaryColor.toHex(),
                "fontColor" : accentColor.toHex(),
                "themeId" : selectedThemeId,
                "fontId" : selectedFont,
            ]
            
            _ = try await FirebaseFunctionCaller().callFunction(functionName: "store-updateTheme", data: data)
            
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Theme Updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            DispatchQueue.main.async { self.isSaving = false }
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

struct ThemePicker: View {
    let themes: [ThemeModel]
    let currentThemeId: Int
    let onThemeSelected: (Int) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(themes, id: \.id) { theme in
                    VStack {
                        CachedImageView(imageUrl: theme.previewLink)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(currentThemeId == theme.id ? Color.accentColor : Color.clear, lineWidth: 3)
                            )
                        
                        
                        Text(theme.name)
                            .font(.body)
                            .foregroundColor(currentThemeId == theme.id ? Color.accentColor : Color.primary)
                    }
                    .onTapGesture {
                        onThemeSelected(theme.id)
                    }
                }
            }
        }
    }
}
