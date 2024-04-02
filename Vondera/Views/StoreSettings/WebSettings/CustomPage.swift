//
//  CustomPage.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast
import RichTextKit

struct CustomPage: View {
    
    @State var addItem = false
    @State var items = [WebsiteSection]()
    @State var isLoading = false
    
    
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:String?
    @Environment(\.presentationMode) private var presentationMode
    @State var editedItem:WebsiteSection?
    
    var body: some View {
        List {
            ForEach(items) { page in
                CustomPageItem(page: page).swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        editedItem = page
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if isLoading {
                ProgressView()
            } else if !isLoading && items.isEmpty {
                EmptyMessageViewWithButton(systemName: "book", msg: "No custom pages were added to your website") {
                    Button("Add your first page") {
                        addItem.toggle()
                    }
                    .buttonStyle(.bordered)
                    .disabled(saving)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Page") {
                    addItem.toggle()
                }
                .disabled(saving)
            }
        }
        .refreshable {
            await getData()
        }
        .task {
            isLoading = true
            await getData()
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        }
        .sheet(item: $editedItem, content: { page in
            NavigationStack {
                CreatePageView(page: page) { action, page in
                    if action == .update {
                        msg = "Page Updated"
                        Task {
                            await getData()
                        }
                    } else if action == .delete {
                        msg = "Page Deleted"
                        if let index = items.firstIndex(where: { $0.id == page.id }) {
                            items.remove(at: index)
                        }
                    }
                }
            }
        })
        .sheet(isPresented: $addItem) {
            NavigationStack {
                CreatePageView { action, page in
                    if action == .create {
                        msg = "Page added to your site"
                        items.append(page)
                    }
                }
            }
            
        }
        .navigationTitle("Custom Pages")
    }
    
    
    func getData() async {
        if let storeId = UserInformation.shared.user?.storeId {
            if let items = try? await PagesDao(storeId: storeId).getPages() {
                DispatchQueue.main.async {
                    self.items = items
                    self.isLoading = false
                }
            }
        }
    }
}

enum CRUD {
    case create, delete, update
}

struct CreatePageView : View {
    var page:WebsiteSection?
    var callBack:((CRUD, WebsiteSection) -> ())
    
    @State private var title = ""
    @State private var id = ""
    @State private var text = NSAttributedString.empty
    @StateObject var context = RichTextContext()
    
    @ObservedObject private var user = UserInformation.shared
    @State private var saving = false
    @State private var msg:String?
    @State private var deleteConfirmation = false
    @Environment(\.presentationMode) private var presentationMode
    
    @State var focus = false
    var body: some View {
        VStack {
            List {
                FloatingTextField(title: "Link", text: $id, caption: "Only english lowercased letter, no spaces, no special chatcters", required: true, autoCapitalize: .never)
                
                FloatingTextField(title: "Title", text: $title, required: true, autoCapitalize: .words)
                
                
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        RichTextActionButton(action: .increaseFontSize, context: context)
                        RichTextActionButton(action: .decreaseFontSize, context: context)
                        RichTextActionButton(action: .toggleStyle(.underlined), context: context)
                        RichTextActionButton(action: .toggleStyle(.italic), context: context)
                        RichTextActionButton(action: .toggleStyle(.bold), context: context)
                        RichTextActionButton(action: .setAlignment(.right), context: context)
                        RichTextActionButton(action: .setAlignment(.left), context: context)
                        RichTextActionButton(action: .setAlignment(.justified), context: context)
                        RichTextActionButton(action: .copy, context: context)
                    }
                }
                
                
                RichTextEditor(text: $text, context: context, format: .archivedData) {
                    $0.textContentInset = CGSize(width: 10, height: 20)
                }
                .frame(height: 350)
                .background(Material.regular)
                .cornerRadius(5)
                .focusedValue(\.richTextContext, context)
            }
        }
        .toolbar {
            if isEdit() {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Delete", role: .destructive) {
                        deleteConfirmation.toggle()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEdit() ? "Update" : "Add") {
                    if !check() {
                        return
                    }
                    
                    isEdit() ? update() : create()
                }
            }
        }
        .task {
            if isEdit() {
                updateUI()
            }
        }
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        }
        .confirmationDialog("Are you sure you want to delete this page ?", isPresented: $deleteConfirmation, titleVisibility: .visible, actions: {
            Button("Delete", role:.destructive) {
                delete()
            }
            
            Button("No Thanks !", role: .cancel) {
                
            }
        })
        .navigationTitle(isEdit() ? "Edit Page" : "New Page")
    }
    
    func check() -> Bool {
        guard id.containsOnlyEnglishLetters(), id.count > 3 else {
            msg = "Please make sure you inputed a valid link"
            return false
        }
        
        guard title.count > 3 else {
            msg = "Enter a valid title"
            return false
        }
        
        guard !text.string.isEmpty else {
            msg = "Enter a valid Body"
            return false
        }
        
        return true
    }
    
    func update() {
        saving = true
        Task {
            if let storeId = user.user?.storeId, let page = page {
                let newPage = WebsiteSection(id: id, title: title, body: text.string)
                if await PagesDao(storeId: storeId).doesExist(id: newPage.id) && newPage.id != page.id{
                    DispatchQueue.main.async {
                        self.saving = false
                        self.msg = "This link exists before"
                    }
                    return
                }
                
                if let _ = try? await PagesDao(storeId: storeId).delete(page.id) {
                    if let _ = try? await PagesDao(storeId: storeId).addPage(newPage) {
                        DispatchQueue.main.async {
                            self.callBack(.update, newPage)
                            self.saving = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    func create() {
        saving = true
        Task {
            if let storeId = user.user?.storeId {
                let page = WebsiteSection(id: id, title: title, body: String(data: try! text.richTextData(for: .archivedData), encoding: .utf8) ?? "")
                if await !PagesDao(storeId: storeId).doesExist(id: id) {
                    if let _ = try? await PagesDao(storeId: storeId).addPage(page) {
                        DispatchQueue.main.async {
                            self.callBack(.create, page)
                            self.saving = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.saving = false
                        self.msg = "This link exists before"
                    }
                }
                
            }
        }
    }
    
    func delete() {
        saving = true
        Task {
            if let storeId = user.user?.storeId, let page = page {
                if let _ = try? await PagesDao(storeId: storeId).delete(page.id) {
                    DispatchQueue.main.async {
                        self.callBack(.delete, page)
                        self.saving = false
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func updateUI() {
        if let page = page {
            self.title = page.title
            self.id = page.id
            
            if let data = page.body.data(using: .utf8) {
                if let text = try? NSAttributedString(data: data, format: .archivedData) {
                    self.text =  text
                }
            }
        }
    }
    
    func isEdit() -> Bool {
        return page != nil
    }
}

struct CustomPageItem: View {
    var page:WebsiteSection
    @State private var msg:String?
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text("\(page.title)")
                    .font(.headline)
                
                Text("/\(page.id)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                if let link = UserInformation.shared.user?.store?.getStoreDomain() {
                    CopyingData().copyToClipboard(page.getLink(baseLink: link).absoluteString)
                }
            } label: {
                Image(systemName: "doc.on.doc.fill")
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: msg)
        }
    }
}

#Preview {
    CustomPage()
}
