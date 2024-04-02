//
//  WebsiteCover.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast
import PhotosUI

struct NewBannerView : View {
    @State private var text = ""
    @Binding var isPresenting:Bool
    var onAdded: ((String) -> ())
    
    var body: some View {
        VStack(alignment: .center) {
            FloatingTextField(title: "Banner Text", text: $text, caption: "This will be shown on the top of your site")
            
            
            ButtonLarge(label: "Add") {
                if text.isBlank {
                    return
                }
                
                
                onAdded(text)
                isPresenting.toggle()
            }
        }
        .padding()
    }
}

struct BannerTitles: View {
    @State private var titles = [String]()
    @ObservedObject private var user = UserInformation.shared
    @State private var msg:String?
    @State private var showAddDialog = false
    @State private var selectedItem:String?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            ForEach(titles, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.body)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.body)
                        .opacity(0.5)
                }
                .onTapGesture {
                    selectedItem = item
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    titles.remove(at: index)
                    update()
                }
            }
            .onMove { indexSet, index in
                titles.move(fromOffsets: indexSet, toOffset: index)
                update()
            }
        }
        .listStyle(.plain)
        .overlay(alignment: .center) {
            if titles.isEmpty {
                EmptyMessageViewWithButton(systemName: "list.dash.header.rectangle", msg: "No text banners are added to your website") {
                
                    Button("Add your first banner") {
                        showAddDialog.toggle()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    showAddDialog.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddDialog, content: {
            NewBannerView(isPresenting: $showAddDialog) { newItem in
                titles.append(newItem)
                msg = "New banner added"
                update()
            }
            .presentationDetents([.fraction(0.25)])
        })
        .task {
            getData()
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        }
        .navigationTitle("Banners")
    }
    
    func getData() {
        if let items = user.user?.store?.siteData?.listBanners {
            self.titles = items
        }
    }
    
    func update() {
        Task {
            if let id = UserInformation.shared.user?.storeId {
                let data = [
                    "siteData.listBanners" : titles,
                ]
                
                if let _ = try? await StoresDao().update(id: id, hashMap: data) {
                    DispatchQueue.main.async { [self] in
                        UserInformation.shared.user?.store?.siteData?.listBanners = titles
                        UserInformation.shared.updateUser()
                    }
                } else {
                    msg = "Error Happened"
                }
            }
        }
    }
}

#Preview {
    WebsiteCover()
}
