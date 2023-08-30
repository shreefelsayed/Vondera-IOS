//
//  AddProductView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import PhotosUI
import AlertToast
import NetworkImage

struct AddProductView: View {
    var storeId:String = ""
    @StateObject private var viewModel:AddProductViewModel
    @Environment(\.presentationMode) private var presentationMode

    init(storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: AddProductViewModel(storeId: storeId))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            currentPage
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            CategoryPicker(items: viewModel.categories, selectedItem: $viewModel.category)
        }
        .padding()
        .navigationTitle("New Product")
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
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
            
            TextField("Quantity", text: $viewModel.quantity)
                .roundedTextFieldStyle()
                .autocapitalization(.words)
            
            Text("Enter how many of this product do you have right now in the warehouse")
                .font(.caption)
            
            ButtonLarge(label:"Create Product") {
                Task {
                    await viewModel.nextPage()
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
                    TextField("Variant Title", text: $viewModel.listTitles[i])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Spacer().frame(height: 6)
                    
                    ChipView(chips: $viewModel.listOptions[i], placeholder: "Enter Varients", useSpaces: true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Spacer().frame(height: 6)

                    
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
                Task {
                    await viewModel.nextPage()
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
    
    var page1: some View {
        VStack(alignment: .leading) {
            Text("Main info")
                .font(.title)
                .bold()
            VStack(alignment: .leading) {
                TextField("Product Name", text: $viewModel.name)
                    .roundedTextFieldStyle()
                    .autocapitalization(.words)
                
                Spacer().frame(height: 12)
                
                // MARK : Pick up photos
                photos
                Spacer().frame(height: 12)
                
                // MARK : Stock Options
                Toggle(isOn: $viewModel.alwaysStocked) {
                    Text("Always in stock")
                }
                
                // MARK : Select the Category
                categories
                Spacer().frame(height: 12)
                
                // MARK : Pricing
                pricing
                Spacer().frame(height: 12)
            }
            
            
            ButtonLarge(label:"Next") {
                Task {
                    await viewModel.nextPage()
                }
            }

        }
    }
    
    var categories: some View {
        VStack(alignment: .leading) {
            Text("Category")
                .font(.title2)
            
            HStack {
                Text(viewModel.category == nil ? "None was selected" : viewModel.category!.name)
                
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
            
            TextField("Product Price", text: $viewModel.sellingPrice)
                .keyboardType(.numberPad)
                .roundedTextFieldStyle()
            
            Text("This is how much you are selling your product for")
                .font(.caption)
            
            TextField("Product Cost", text: $viewModel.cost)
                .keyboardType(.numberPad)
                .roundedTextFieldStyle()
            
            Text("This is how much your product costs you")
                .font(.caption)
        }
    }
    
    var photos: some View {
        VStack(alignment: .leading) {
            // MARK : Photos title
            HStack {
                Text("Product Photos")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                if viewModel.selectedPhotos.count < 6 {
                    Button {
                        viewModel.pickPhotos()
                    } label: {
                        Text("Add")
                    }
                }
            }
            
            // MARK : Selected Photos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.selectedPhotos, id: \.self) { image in
                        ImageView(image: image, removeClicked: {
                            viewModel.removePhoto(image: image)
                        })
                    }
                    
                    if viewModel.selectedPhotos.count < 6 {
                        ImageView(removeClicked: {
                        }, showDelete: false) {
                            viewModel.pickPhotos()
                        }
                    }
                }
            }
            
            Text("At least choose 1 photo for your product, you can choose up to 6 photos, note that you can download them later easily.")
                .font(.caption)
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddProductView(storeId: "")
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
            if image != nil {
                Image(uiImage: image)
                    .centerCropped()
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    ).onTapGesture {
                        if onImageClick != nil {onImageClick!()}
                    }
            } else {
                Image(systemName: "photo")
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    ).onTapGesture {
                        if onImageClick != nil {onImageClick!()}
                    }
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

struct ImageViewNetwork: View {
    var image:String
    var removeClicked: (() -> ())
    var showDelete:Bool = true
    var onImageClick: (() -> ())?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if image != nil {
                NetworkImage(url: URL(string: image)) { image in
                  image.centerCropped()
                } placeholder: {
                  ProgressView()
                }
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, lineWidth: 2)
                ).onTapGesture {
                    if onImageClick != nil {onImageClick!()}
                }
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
