//
//  AddProductView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import PhotosUI
import Foundation
import Firebase
import FirebaseStorage
import Combine

class AddProductViewModel : ObservableObject {
    var storeId:String = ""
    var categorysDao:CategoryDao
    var productsDao:ProductsDao
    
    var productId = ""
    
    @Published var page = 1
    @Published var categories = [Category]()
    
    @Published var recentProducts = [StoreProduct]()
    @Published var selectedTemplate:StoreProduct?
    
    
    @Published var selectedCategory:Category? {
        didSet {
            Task {
                await updateRecentProducts()
            }
        }
    }
    
    @Published var isSheetPresented = false
    
    @Published var selectedPhotos: [UIImage] = []
    
    @Published var name = ""
    @Published var desc = ""
    
    @Published var alwaysStocked = false
    @Published var sellingPrice = "0"
    @Published var cost = "0"
    @Published var crossed = "0"
    @Published var quantity = "0"
    @Published var isSaving = false
    
    @Published var listVarients = [[String:[String]]]()
    @Published var listTitles = [String]()
    @Published var listOptions = [[String]]()
    
    @Published var templateVariantDetails = [VariantsDetails]()
    
    var myUser = UserInformation.shared.getUser()
        
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    init(storeId: String) {
        self.storeId = storeId
        self.categorysDao = CategoryDao(storeId: storeId)
        self.productsDao = ProductsDao(storeId: storeId)
        self.myUser = UserInformation.shared.getUser()
        
        Task {
            await createProductId()
            await getStoreCategories()
        }
    }
    
    
    
    func deleteVarient(i:Int) {
        listTitles.remove(at: i)
        listOptions.remove(at: i)
        listVarients.remove(at: i)
    }
    
    func canAddVarient() -> Bool {
        if listVarients.isEmpty { return true }
        if listTitles.last!.isEmpty || listOptions.last!.isEmpty {
            return false
        }
        
        return true
    }
    
    func addVarient() {
        guard canAddVarient() else {
            ToastManager.shared.showToast(msg: "Fill the current varient first", toastType: .error)
            return
        }
        
        listVarients.append(["":[]])
        listTitles.append("")
        listOptions.append([String]())
    }
    
    func nextPage() {
        if page == 1 {
            if (check1()) {page = 2}
        } else if page == 2 {
            if (check2()) {
                if alwaysStocked {
                    uploadPhotos()
                } else {
                    page = 3
                }
            }
        } else if page == 3 {
            if(check3()) { uploadPhotos() }
        }
    }
    
    func showPrevPage() {
        if page == 1 {
            shouldDismissView = true
            return
        }
        
        page -= 1
    }
    
    func check1() -> Bool {
        guard !name.isBlank else {
            ToastManager.shared.showToast(msg: "Enter product name", toastType: .error)
            return false
        }
        
        guard selectedPhotos.count > 0 else {
            ToastManager.shared.showToast(msg: "Select one photo at least", toastType: .error)
            return false
        }
        
        guard selectedCategory != nil else {
            ToastManager.shared.showToast(msg: "Select the product category", toastType: .error)
            return false
        }
        
        guard sellingPrice.isNumeric else {
            ToastManager.shared.showToast(msg: "Enter a valid price amount", toastType: .error)
            return false
        }
        
        guard sellingPrice != "0" else {
            ToastManager.shared.showToast(msg: "Selling price can't be Zero LE", toastType: .error)
            return false
        }
        
        guard cost.isNumeric else {
            ToastManager.shared.showToast(msg:"Enter a valid cost amount", toastType: .error)
            return false
        }
        
        return true
    }
    
    func check2() -> Bool {
        var titleFilled = true
        var optionsProvided = true
        
        for str in listTitles {
            if str.isBlank {titleFilled = false}
        }
        
        for list in listOptions {
            if list.count < 2 {optionsProvided = false}
        }
        
        guard titleFilled else {
            ToastManager.shared.showToast(msg:"Fill all varients titles", toastType: .error)
            return false
        }
        
        guard optionsProvided else {
            ToastManager.shared.showToast(msg:"Add at least 2 options to each varient", toastType: .error)
            return false
        }
        
        return true
    }
    
    func check3() -> Bool {
        guard quantity.isNumeric else {
            ToastManager.shared.showToast(msg: "Enter a valid quantity amount", toastType: .error)
            return false
        }
        
        return true
    }
    
    func listVarient() -> [[String: [String]]] {
        var listVars = [[String: [String]]]()
        for (index, title) in listTitles.enumerated() {
            listVars.append([title:listOptions[index]])
        }
        
        return listVars
    }
    
    func uploadPhotos() {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        if let storeId = myUser?.storeId {
            FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: selectedPhotos, storageRef: "stores/\(storeId)/products/\(productId)") { imageURLs, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isSaving = false
                        ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
                    }
                } else if let imageURLs = imageURLs {
                    self.saveProduct(uris: imageURLs)
                }
            }
        }
    }
    
    func updateRecentProducts() async {
        DispatchQueue.main.async {
            self.selectedTemplate = nil
            self.recentProducts.removeAll()
        }
        
        if let id = selectedCategory?.id {
            if let templetes = try? await ProductsDao(storeId: storeId).getCategoryRecent(categoryId: id) {
                DispatchQueue.main.async {
                    self.recentProducts = templetes
                }
            }
        }
    }
    
    func chooseTemplete(product:StoreProduct) {
        self.selectedTemplate = product
        self.desc = product.desc ?? ""
        self.cost = "\(Int(product.buyingPrice))"
        self.crossed = "\(Int(product.crossedPrice ?? 0))"
        self.sellingPrice = "\(Int(product.price))"
        self.alwaysStocked = product.alwaysStocked ?? false
        self.quantity = "\(product.quantity)"
        self.templateVariantDetails = product.getVariant()
        
        self.listVarients = product.hashVarients ?? []
        self.listTitles = product.hashVarients?.getTitles() ?? []
        self.listOptions = product.hashVarients?.getOptions() ?? []
        
        ToastManager.shared.showToast(msg: "Template date filled")
    }
    
    func saveProduct(uris: [String]) {
        Task {
            // MARK : Create a product Object
            var product = StoreProduct(name: name.lowercased(), id: productId, quantity: Int(quantity) ?? 0, addedBy: "", price: Double(sellingPrice) ?? 0, buyingPrice: Double(cost) ?? 0)
            
            product.desc = desc
            product.storeId = storeId
            product.crossedPrice = Double(crossed) ?? 0
            product.listPhotos = uris
            product.hashVarients = listVarient()
            product.alwaysStocked = alwaysStocked
            product.categoryId = selectedCategory?.id ?? ""
            product.categoryName = selectedCategory?.name ?? ""
            
            product.variantsDetails = listVarient().isEmpty ? [] : templateVariantDetails.map { detail in
                var modifiedDetail = detail // Create a copy of the detail
                modifiedDetail.image = ""
                modifiedDetail.optimizedImage = ""
                modifiedDetail.cost = Double(cost) ?? 0
                modifiedDetail.price = Double(sellingPrice) ?? 0
                return modifiedDetail
            }
            
            // MARK : Save the product to database
            do {
                try await productsDao.create(product)
                ToastManager.shared.showToast(msg: "Product has been added", toastType: .success)
                
                // --> Saving Local
                if let myUser = UserInformation.shared.getUser() {
                    if var productsCount = myUser.store?.productsCount {
                        productsCount = productsCount + 1
                        myUser.store?.productsCount = productsCount
                        UserInformation.shared.updateUser(myUser)
                    }
                }
                
                DispatchQueue.main.async { [product] in
                    if product.hasVariants() {
                        DynamicNavigation.shared.navigate(to: AnyView(VarientsSettings(product: .constant(product))))
                    } else {
                        self.shouldDismissView = true
                    }
                }
            } catch {
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            }
            
            DispatchQueue.main.async {
                self.isSaving = false
            }
        }
    }
    
    func getStoreCategories() async {
        do {
            categories = try await categorysDao.getAll()
            if let cat = categories.first {
                selectedCategory = cat
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func removePhoto(image: UIImage) {
        if let index = selectedPhotos.firstIndex(of: image) {
            selectedPhotos.remove(at: index)
        }
    }
    
    // Add a function to clear the selected photos
    func clearSelectedPhotos() {
        selectedPhotos.removeAll()
    }
    
    func createProductId() async {
        let id:String = "\(generateRandomNumber())"
        let isExist = try? await productsDao.productExist(id: id)
        if (isExist ?? true) {
            await createProductId()
            return
        }
        
        self.productId = id
    }
    
    func generateRandomNumber() -> Int {
        let randomNumber = arc4random_uniform(9000) + 1000
        return Int(randomNumber)
    }
}


struct AddProductView: View {
    var storeId:String = UserInformation.shared.user?.storeId ?? ""
    
    @State var images:[PhotosPickerItem] = [PhotosPickerItem]()
    
    @StateObject private var viewModel:AddProductViewModel
    @Environment(\.presentationMode) private var presentationMode

    init(storeId: String = "") {
        self.storeId = UserInformation.shared.user?.storeId ?? ""
        _viewModel = StateObject(wrappedValue: AddProductViewModel(storeId: UserInformation.shared.user?.storeId ?? ""))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            currentPage
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            NavigationStack {
                CategoryPicker(items: $viewModel.categories, storeId: viewModel.myUser?.storeId ?? "", selectedItem: $viewModel.selectedCategory)
            }
        }
        .padding()
        .navigationTitle("New Product")
        .navigationBarItems(leading: Button(action : {
            withAnimation {
                viewModel.showPrevPage()
            }
        }){
            Image(systemName: "arrow.left")
        })
        .willProgress(saving: viewModel.isSaving, handleBackButton: false)
        .navigationBarBackButtonHidden(true)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var page3: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Warehouse Quantity")
                .font(.title)
                .bold()
            
            FloatingTextField(title: "Quantity", text:  $viewModel.quantity, caption: "TEnter how many of this product do you have right now in the warehouse", required: nil, keyboard: .numberPad)
            
            
            ButtonLarge(label:"Create Product") {
                withAnimation {
                    viewModel.nextPage()
                }
            }
        }
    }
    
    var page2: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Variants")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button {
                    viewModel.addVarient()
                } label: {
                    Text("Add")
                }
            }
            
            
            Spacer().frame(height: 10)
            
            Text("Variants are used to create different versions of the same product. For example, if you have a t-shirt, you can create a variant for each size and color, just click next if you don\'t have any variants")
                .font(.caption)
            
            Spacer().frame(height: 20)

            ForEach(Array($viewModel.listVarients.indices), id: \.self) { i in
                VStack(alignment: .leading, spacing: 6) {
                    FloatingTextField(title: "Varient Title", text: $viewModel.listTitles[i], caption: "This is your varient title for example (Color, Size, ..)", required: true, autoCapitalize: .words)
                    
                                        
                    OptionsView(items: $viewModel.listOptions[i])
                    
                    HStack {
                        ButtonLarge(label: "Delete Varient", background: .gray) {
                            viewModel.deleteVarient(i : i)
                        }
                    }
                    
                    Divider()
                }
            }
            
            Spacer().frame(height: 20)
        
            
            ButtonLarge(label: viewModel.alwaysStocked ? "Create Product" : viewModel.listVarients.isEmpty ? "Skip" : "Next") {
                withAnimation {
                    viewModel.nextPage()
                }
            }
            
        }
    }
    
    
    var page1: some View {
        VStack(alignment: .leading) {
            Text("Main info")
                .font(.title)
                .bold()
            
            if !viewModel.recentProducts.isEmpty {
                Text("Fill from recent products")
                    .bold()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.recentProducts) { prod in
                            ProductTemplete(isSelected: viewModel.selectedTemplate == prod, product: prod) { selected in
                                withAnimation {
                                    viewModel.chooseTemplete(product: selected)
                                }
                                
                            }
                        }
                    }
                }
                .padding(.bottom, 12)
            }
            
            VStack(alignment: .leading, spacing: 24) {
                FloatingTextField(title: "Product Name", text:  $viewModel.name, caption: "This is the name of the product, which will appear on the website and the app", required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Product Description", text:  $viewModel.desc, caption: "Your product describtion will be visible for users in your website and in the app", required: false, multiLine: true, autoCapitalize: .sentences)
               
                // MARK : Pick up photos
                
                photos
                
                
                // MARK : Stock Options
                VStack(alignment: .leading) {
                    Toggle(isOn: $viewModel.alwaysStocked) {
                        Text("Always Stokced")
                    }
                    
                    Text("Enabling this will not track your items in the warehouse")
                        .font(.caption)
                }
                
                
                // MARK : Select the Category
                categories
                
                // MARK : Pricing
                pricing
            }
            
            
            ButtonLarge(label:"Next") {
                withAnimation {
                    viewModel.nextPage()
                }
            }

        }
    }
    
    var currentPage: some View {
        switch viewModel.page {
        case 1:
            return AnyView(page1)
        case 2:
            return AnyView(page2)
        case 3:
            return AnyView(page3)
        default:
            return AnyView(EmptyView())
        }
    }
    
    
    var categories: some View {
        VStack(alignment: .leading) {
            Text("Category")
                .font(.title2)
            
            HStack {
                Text(viewModel.selectedCategory == nil ? "None was selected" : viewModel.selectedCategory!.name)
                
                Spacer()
                
                Image(systemName: "arrow.right")
            }
        }
        .onTapGesture {
            viewModel.isSheetPresented = true
        }
    }
    
    var pricing: some View {
        VStack(alignment: .leading) {
            Text("Price and cost")
                .font(.title2)
            
            FloatingTextField(title: "Product Price", text:  $viewModel.sellingPrice, caption: "This is how much you are selling your product for", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "Product Cost", text:  $viewModel.cost, caption: "This is how much your product costs you", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "Crossed Price", text:  $viewModel.crossed, caption: "This marks the product as a sale", required: false, keyboard: .numberPad)
        }
    }
    
    var photos: some View {
        VStack(alignment: .leading) {
            // MARK : Photos title
            HStack {
                Text("Product photos")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                PhotosPicker(selection: $images, maxSelectionCount: 6, matching: .images) {
                    Text("Add")
                }
                .disabled(images.count >= 6)
            }
            
            // MARK : Selected Photos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.selectedPhotos.indices, id: \.self) { index in
                        ImageView(image: viewModel.selectedPhotos[index], removeClicked: {
                            images.remove(at: index)
                        })
                    }
                    
                    if images.count < 6 {
                        PhotosPicker(selection: $images, maxSelectionCount: 6, matching: .images) {
                            ImageView(removeClicked: {
                            }, showDelete: false) {
                                
                            }
                        }
                        .disabled(images.count >= 6)
                    }
                }
            }
            
            Text("At least choose 1 photo for your product, you can choose up to 6 photos, note that you can download them later easily.")
                .font(.caption)
        }
        .onChange(of: images) { newValue in
            Task {
                do {
                    let result = try await newValue.getUIImages()
                    DispatchQueue.main.async {
                        self.viewModel.selectedPhotos = result
                    }
                } catch {
                    
                }
            }
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddProductView(storeId: Store.Qotoofs())
        }
    }
}

struct ImageView: View {
    var image:UIImage?
    var removeClicked: (() -> ())
    var showDelete:Bool = true
    var onImageClick: (() -> ())?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .centerCropped()
                        .onTapGesture {
                            if onImageClick != nil {onImageClick!()}
                        }
                } else {
                    Image(systemName: "photo")
                        .onTapGesture {
                            if onImageClick != nil {onImageClick!()}
                        }
                }
            }
            .frame(width: 100, height: 100)

            
            
            if showDelete {
                Button(action: {
                    removeClicked()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                .padding(5)
                .background(Color.white)
                .clipShape(Circle())
                .offset(x: 5, y: 5)
            }
            
        }
    }
}

struct ImageViewNetwork: View {
    var image:String
    var removeClicked: (() -> ())
    var showDelete:Bool = true
    var onImageClick: (() -> ())?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CachedImageView(imageUrl: image, scaleType: .centerCrop)
                .frame(width: 100, height: 100)
                .background(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1))
            
            .onTapGesture {
                if onImageClick != nil {onImageClick!()}
            }
            
            if showDelete {
                Button(action: {
                    removeClicked()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                .padding(5)
                .background(Color.white)
                .clipShape(Circle())
                .offset(x: 5, y: 5)
            }
            
        }
    }
}

struct ProductTemplete : View {
    var isSelected:Bool
    var product:StoreProduct
    var onSelected:((StoreProduct) -> ())
    
    var body: some View {
        HStack {
            ImagePlaceHolder(url: product.defualtPhoto(), reduis: 40)
            
            Text(product.name)
                .foregroundStyle(isSelected ? Color.white : .black)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : .white)
        .cornerRadius(6)
        .onTapGesture {
            onSelected(product)
        }
    }
}
