//
//  AddProductView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import PhotosUI
import AlertToast

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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            withAnimation {
                viewModel.showPrevPage()
            }
        }){
            Image(systemName: "arrow.left")
        })
        .willProgress(saving: viewModel.isSaving, handleBackButton: false)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
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
                
                FloatingTextField(title: "Product Describtion", text:  $viewModel.desc, caption: "Your product describtion will be visible for users in your website and in the app", required: false, multiLine: true, autoCapitalize: .sentences)
               
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
                viewModel.selectedPhotos = await newValue.getUIImages()
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
