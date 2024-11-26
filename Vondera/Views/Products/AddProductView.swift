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
import Combine

class AddProductViewModel: ObservableObject {
    var storeId: String
    var categorysDao: CategoryDao
    var productsDao: ProductsDao
    
    @Published var page = 1
    @Published var isSaving = false
    @Published var isUploading = false
    
    @Published var categories = [Category]()
    @Published var allSubCategories = [SubCategory]()
    @Published var selectedSubCategoryId = ""
    @Published var displayedSubCategories = [SubCategory]()

    @Published var recentProducts = [StoreProduct]()
    @Published var selectedTemplate: StoreProduct?
    @Published var selectedCategory: Category? {
        didSet {
            refresSubCategories()
            Task { await updateRecentProducts() }
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
    
    @Published var listVarients = [[String: [String]]]()

    @Published var templateVariantDetails = [VariantsDetails]()
    var myUser: UserData?

    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    var productId = "" // Added productId property to maintain product ID
    var listTitles: [String] = []
    var listOptions: [[String]] = []

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
    
    // MARK: - Photo Management
    @MainActor
    func removePhoto(image: UIImage) {
        selectedPhotos.removeAll { $0 == image }
    }
    
    @MainActor
    func clearSelectedPhotos() {
        selectedPhotos.removeAll()
    }
    
    // MARK: - Variant Management
    @MainActor
    func deleteVarient(at index: Int) {
        listVarients.remove(at: index)
        listTitles.remove(at: index)
        listOptions.remove(at: index)
    }
    
    @MainActor
    func canAddVariant() -> Bool {
        guard !listVarients.isEmpty else { return true }
        let lastTitleEmpty = listTitles.last?.isEmpty ?? true
        let lastOptionsEmpty = listOptions.last?.isEmpty ?? true
        return !(lastTitleEmpty || lastOptionsEmpty)
    }
    
    @MainActor
    func addVariant() {
        guard canAddVariant() else {
            ToastManager.shared.showToast(msg: "Fill the current variant first", toastType: .error)
            return
        }
        
        listVarients.append(["":[]])
        listTitles.append("")
        listOptions.append([String]())
    }
    
    // MARK: - Navigation & Validation
    @MainActor
    func nextPage() {
        print("Current page \(page)")
        switch page {
        case 1:
            if check1() { page = 2 }
            break
        case 2:
            if check2() {
                if !alwaysStocked {
                    page = 3
                } else {
                    uploadPhotos()
                }
            }
            break
        case 3:
            if check3() { uploadPhotos() }
            break
        default:
            break
        }
    }

    @MainActor
    func showPrevPage() {
        if page == 1 {
            viewDismissalModePublisher.send(true)
        } else {
            page -= 1
        }
    }

    @MainActor
    func check1() -> Bool {
        guard !name.isBlank else {
            ToastManager.shared.showToast(msg: "Enter product name", toastType: .error)
            return false
        }
        guard !selectedPhotos.isEmpty else {
            ToastManager.shared.showToast(msg: "Select at least one photo", toastType: .error)
            return false
        }
        guard selectedCategory != nil else {
            ToastManager.shared.showToast(msg: "Select the product category", toastType: .error)
            return false
        }
        guard sellingPrice.isNumeric else {
            ToastManager.shared.showToast(msg: "Enter a valid price", toastType: .error)
            return false
        }
        guard sellingPrice != "0" else {
            ToastManager.shared.showToast(msg: "Selling price can't be Zero LE", toastType: .error)
            return false
        }
        guard cost.isNumeric else {
            ToastManager.shared.showToast(msg: "Enter a valid cost amount", toastType: .error)
            return false
        }
        return true
    }

    @MainActor
    func check2() -> Bool {
        let titleFilled = listTitles.allSatisfy { !$0.isBlank }
        let optionsProvided = listOptions.allSatisfy { $0.count >= 2 }

        if !titleFilled {
            ToastManager.shared.showToast(msg: "Fill all variants titles", toastType: .error)
        }
        if !optionsProvided {
            ToastManager.shared.showToast(msg: "Add at least 2 options to each variant", toastType: .error)
        }
        
        let result = titleFilled && optionsProvided
        print("Validation Result \(result)")
        return result
    }

    @MainActor
    func check3() -> Bool {
        guard quantity.isNumeric else {
            ToastManager.shared.showToast(msg: "Enter a valid quantity amount", toastType: .error)
            return false
        }
        return true
    }
    
    // MARK: - Product Handling
    func saveProduct(uris: ([String], [String?])) async {
        await MainActor.run { self.isSaving = true }
        
        var product = StoreProduct(name: name.lowercased(), id: productId, quantity: Int(quantity) ?? 0, addedBy: "", price: Double(sellingPrice) ?? 0, buyingPrice: Double(cost) ?? 0)
        product.desc = desc
        product.storeId = storeId
        product.crossedPrice = Double(crossed) ?? 0
        product.listPhotos = uris.0
        product.listOptamized = uris.1.compactMap { $0 ?? "" }
        product.hashVarients = listVarient()
        product.alwaysStocked = alwaysStocked
        product.categoryId = selectedCategory?.id ?? ""
        product.categoryName = selectedCategory?.name ?? ""
        product.subCategoryId = selectedSubCategoryId
        product.subCategoryName = getSubCategoryById()?.name ?? ""
        
        product.variantsDetails = templateVariantDetails.map {
            var detail = $0
            detail.image = ""
            detail.optimizedImage = ""
            detail.cost = Double(cost) ?? 0
            detail.price = Double(sellingPrice) ?? 0
            return detail
        }
        
        do {
            try await productsDao.create(product)
            
            await MainActor.run { [product] in
                self.isSaving = false
                self.updateUserProductCount()
                ToastManager.shared.showToast(msg: "Product has been added", toastType: .success)
                if product.hasVariants() {
                    DynamicNavigation.shared.navigate(to: AnyView(VarientsSettings(product: .constant(product))))
                } else {
                    self.viewDismissalModePublisher.send(true)
                }
            }
        } catch {
            await MainActor.run {
                self.isSaving = false
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            }
        }
    }
    
    // MARK: - Template Handling
    @MainActor
    func chooseTemplate(product: StoreProduct) {
        selectedTemplate = product
        desc = product.desc ?? ""
        cost = "\(Int(product.buyingPrice))"
        crossed = "\(Int(product.crossedPrice ?? 0))"
        sellingPrice = "\(Int(product.price))"
        alwaysStocked = product.alwaysStocked ?? false
        quantity = "\(product.quantity)"
        templateVariantDetails = product.getVariant()
        listVarients = product.hashVarients ?? []
        listTitles = product.hashVarients?.getTitles() ?? []
        listOptions = product.hashVarients?.getOptions() ?? []
        selectedSubCategoryId = product.subCategoryId ?? ""
        ToastManager.shared.showToast(msg: "Template data filled")
    }
    
    // MARK: - Helper Functions
    func listVarient() -> [[String: [String]]] {
        return zip(listTitles, listOptions).map { [$0: $1] }
    }

    @MainActor
    func uploadPhotos() {
        guard let storeId = myUser?.storeId else { return }
        self.isUploading = true
        let path = "stores/\(storeId)/products/\(productId)"
        
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds in nanoseconds
            S3Handler.uploadImages(imagesToUpload: selectedPhotos, maxSizeMB: 2, path: path, createThumbnail: true) { uploadResults in
                self.isUploading = false
                Task { await self.saveProduct(uris: uploadResults) }
            }
        }
    }

    
    func updateRecentProducts() async {
        await MainActor.run {
            self.selectedTemplate = nil
            self.recentProducts.removeAll()
        }
        
        guard let categoryId = selectedCategory?.id else { return }
        
        do {
            let items = try await productsDao.getCategoryRecent(categoryId: categoryId)
            await MainActor.run {
                self.recentProducts = items
            }
        } catch {
            print("Failed to load recent products: \(error.localizedDescription)")
        }
    }

    func getStoreCategories() async {
        do {
            let categories = try await categorysDao.getAll()
            let subCategories = try await SubStoreCategoryDao(storeId: storeId).getAll()
            
            await MainActor.run {
                self.categories = categories
                self.allSubCategories = subCategories
                self.selectedCategory = categories.first
            }
        } catch {
            print("Failed to load categories: \(error.localizedDescription)")
        }
    }
    
    func refresSubCategories() {
        guard let selectedCategory else {
            displayedSubCategories = []
            return
        }
        
        var items =  allSubCategories.filter { $0.categoryId == selectedCategory.id }
        items.insert(SubCategory(name: "None", id: "", categoryId: selectedCategory.id, sortValue: 0), at: 0)
        selectedSubCategoryId = items.first?.id ?? ""
        displayedSubCategories = items
    }
    
    func getSubCategoryById() -> SubCategory? {
        if selectedSubCategoryId.isBlank { return nil }
        let cate = allSubCategories.first { $0.id == selectedSubCategoryId }
        return cate
    }
    
    func createProductId() async {
        productId = "\(generateRandomNumber())"
        let exists = try? await productsDao.productExist(id: productId)
        if exists ?? false {
            await createProductId() // Recursively generate a new ID if exists
        }
    }

    func generateRandomNumber() -> Int {
        return Int(arc4random_uniform(9000) + 1000)
    }
    
    // MARK: - User Update
    func updateUserProductCount() {
        /*myUser?.store?.productsCount += 1
        UserInformation.shared.saveUser(user: myUser!)*/
    }
}


struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel(storeId: UserInformation.shared.user?.storeId ?? "")
    @Environment(\.presentationMode) private var presentationMode
    @State private var images: [PhotosPickerItem] = []
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            currentPage
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            NavigationStack {
                CategoryPicker(items: $viewModel.categories,
                               storeId: viewModel.myUser?.storeId ?? "",
                               selectedItem: $viewModel.selectedCategory)
            }
        }
        .padding()
        .navigationTitle("New Product")
        
        .navigationBarItems(leading: Button(action: {
            withAnimation { viewModel.showPrevPage() }
        }) {
            Image(systemName: "arrow.left")
        })
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .withAccessLevel(accessKey: .productsWrite, presentation: presentationMode)
        .willProgress(saving: viewModel.isSaving, handleBackButton: false, msg: "Creating products ..")
        .willProgress(saving: viewModel.isUploading, handleBackButton: false, msg: "Uploading images ..")
        .navigationBarBackButtonHidden(true)
    }

    
    var page3: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Warehouse Quantity")
                .font(.title)
                .bold()
            
            FloatingTextField(title: "Quantity", text:  $viewModel.quantity, caption: "Enter how many of this product do you have right now in the warehouse", required: nil, keyboard: .numberPad)
            
            
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
                    viewModel.addVariant()
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
                    // Binding the variant title to listTitles
                    FloatingTextField(
                        title: "Variant Title",
                        text: $viewModel.listTitles[i], // Binding to each variant's title
                        caption: "This is your variant title, for example (Color, Size, ...)",
                        required: true,
                        autoCapitalize: .words
                    )
                    
                    // Binding the options to listOptions
                    OptionsView(items: $viewModel.listOptions[i])  // Binding each variant's options
                    
                    HStack {
                        ButtonLarge(label: "Delete Variant", background: .gray) {
                            viewModel.deleteVarient(at: i) // Call to delete the variant at index `i`
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
                                    viewModel.chooseTemplate(product: selected)
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
                               
                buildPhotos
                
                
                // MARK : Stock Options
                VStack(alignment: .leading) {
                    Toggle(isOn: $viewModel.alwaysStocked) {
                        Text("Always Stokced")
                    }
                    
                    Text("Enabling this will not track your items in the warehouse")
                        .font(.caption)
                }
                
                
                // MARK : Select the Category
                buildCategoryPicker
                
                // MARK : Sub Category
                if viewModel.displayedSubCategories.count > 0 {
                    HStack {
                        Text("Sub Category")
                        
                        Spacer()
                        
                        Picker("Sub Category", selection: $viewModel.selectedSubCategoryId, content: {
                            ForEach(viewModel.displayedSubCategories, id: \.id) { item in
                                Text(item.name)
                                    .id(item.id)
                            }
                        })
                    }
                }
                
                // MARK : Pricing
                buildPricingInput
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
    
    var buildCategoryPicker: some View {
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
    
    var buildPricingInput: some View {
        VStack(alignment: .leading) {
            Text("Price and cost")
                .font(.title2)
            
            FloatingTextField(title: "Product Price", text:  $viewModel.sellingPrice, caption: "This is how much you are selling your product for", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "Product Cost", text:  $viewModel.cost, caption: "This is how much your product costs you", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "Crossed Price", text:  $viewModel.crossed, caption: "This marks the product as a sale", required: false, keyboard: .numberPad)
        }
    }
    
    var buildPhotos: some View {
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
