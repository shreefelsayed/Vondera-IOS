//
//  ProductDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI
import FirebaseFirestore

struct ProductLoadingScreen: View {
    var id:String
    @State var product:StoreProduct = StoreProduct.example()
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            if !isLoading {
                ProductDetails(product: $product)
            } else {
                ProgressView()
            }
        }
        .task {
            await getProduct()
        }
    }
    
    private func getProduct() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        do {
            let result = try await ProductsDao(storeId: storeId).getProduct(id: id)
            if let result = result {
                self.product = result
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

struct ProductDetails: View {
    @Binding var product:StoreProduct
    var onDelete:((StoreProduct) -> ())?
    
    @State private var myUser = UserInformation.shared.getUser()
    @State private var addToCard = false
    @State private var settings = false
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var lastDoc:DocumentSnapshot?
    @State private var items = [ReviewModel]()
    @State private var isLoading = false
    @State private var hasMore = true
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                VStack (alignment: .leading) {
                    NavigationLink(destination: FullScreenImageView(imageURLs: product.listPhotos)) {
                        SlideNetworkView(imageUrls: product.listPhotos, autoChange: true)
                            .id(product.listPhotos)
                    }
                    .ignoresSafeArea()
                    .frame(height: 320)
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(product.name.uppercased())
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                            
                            Image(systemName: (product.visible ?? true) ? "eye" : "eye.slash")
                        }
                        
                        Text(product.categoryName?.uppercased() ?? "None")
                            .font(.title3)
                        
                        HStack {
                            Text("\(Int(product.price)) LE")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color.accentColor)
                            
                            if let crossedPrice = product.crossedPrice, crossedPrice > 0 {
                                Text("\(Int(crossedPrice)) LE")
                                    .font(.body)
                                    .foregroundStyle(.red)
                                    .strikethrough()
                            }
                            
                           
                        }
                        
                        if let reviews = UserInformation.shared.user?.store?.siteData?.reviewsEnabled, reviews {
                            
                            StarRatingView(rating: Double(product.avgRating ?? 0))
                        }
                    }
                    .padding()
                    
                    
                    VStack(alignment: .leading) {
                        if let desc = product.desc, !desc.isBlank {
                            // MARK : Product Desc
                            VStack(alignment: .leading) {
                                Text("Product Description")
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment:.leading)
                                
                                Spacer().frame(height: 8)
                                
                                Text((product.desc?.isBlank ?? true) ? "No Description provided".localize() : (product.desc ?? "").localize())
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            Spacer().frame(height: 12)
                        }
                        
                        
                        
                        // MARK : Product Varients
                        if let options = product.hashVarients, !options.isEmpty  {
                            VStack(alignment: .leading) {
                                Text("Varients")
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment:.leading)
                                
                                Spacer().frame(height: 8)
                                
                                
                                ForEach(options, id: \.self) { hash in
                                    VStack {
                                        HStack {
                                            Text("\(hash.keys.first?.capitalizeFirstLetter() ?? "")")
                                                .font(.headline)
                                                .bold()
                                            
                                            Spacer()
                                            
                                            Text("\(getVarientOptions(hash: hash))")
                                            
                                        }
                                        
                                        
                                        Divider()
                                    }
                                    
                                }
                                
                                
                            }
                            
                            Spacer().frame(height: 12)
                        }
                        
                        
                        // MARK : Product Options
                        VStack(alignment: .leading) {
                            Text("Info")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment:.leading)
                            
                            Spacer().frame(height: 8)
                            
                            HStack {
                                Text("Sold Products")
                                    .font(.headline)
                                    .bold()
                                
                                Spacer()
                                
                                Text("\(product.sold ?? 0) Pieces")
                                    .font(.headline)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("In Stock")
                                    .font(.headline)
                                    .bold()
                                
                                Spacer()
                                
                                Text(product.alwaysStocked ?? false ? "Always Stokced" : "\(product.quantity) Pieces")
                                    .font(.headline)
                            }
                        }
                        Spacer().frame(height: 12)
                        
                        //MARK : Settings
                        if (myUser?.canAccessAdmin ?? false) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Margin")
                                        .bold()
                                    
                                    Text("\(product.getMargin())%")
                                }
                                .padding(24)
                                .background(.secondary.opacity(0.2))
                                .cornerRadius(12)
                                
                                VStack(alignment: .leading) {
                                    Text("Profit")
                                        .bold()
                                    
                                    Text("EGP \(product.getProfit())")
                                }
                                .padding(24)
                                .background(.secondary.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        
                        
                    }
                    .padding()
                    
                    // MARK : Reviews
                    if !items.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Reviews")
                                    .font(.headline)
                                    .bold()
                                
                                Text("(\(Int(product.totalReviews ?? 0)) Reviews)")
                                    .foregroundStyle(.secondary)
                            }
                            
                            ForEach(items.indices, id: \.self) { index in
                                ReviewCard(review: items[index]) {
                                    removeReview(index: index)
                                }
                                
                                if hasMore, items.last?.id == items[index].id {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .onAppear {
                                        Task {
                                            await getReviews()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            
            
            Spacer()
            
            //MARK : Add to cart button
            ButtonLarge(label: "Add to Cart") {
                addToCard.toggle()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .background(Color.background)
        .task {
            await getReviews()
        }
        .sheet(isPresented: $addToCard, content: {
            ProductBuyingSheet(product: $product, onAddedToCard: { product, options in
                CartManager().addItem(product: product, options: options)
            })
        })
        .refreshable {
            await refreshProduct()
        }
        .sheet(isPresented: $settings) {
            NavigationStack {
                ProductSettings(product: product, onDeleted: { value in
                    if let onDelete = onDelete {
                        onDelete(value)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let link =  myUser?.store?.getStoreDomain(), (product.visible ?? true) {
                        ShareLink(item: product.getProductLink(baseLink: link)) {
                            Label("Share Product", systemImage: "square.and.arrow.up")
                        }
                        
                        Link(destination: product.getProductLink(baseLink: link)) {
                            Label("Visit Product", systemImage: "link")
                        }
                    }
                    
                    if (myUser?.canAccessAdmin ?? false) {
                        Button {
                            settings.toggle()
                        } label: {
                            Label("Options", systemImage: "gearshape")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
        .navigationTitle("Product info")
    }
    
    func removeReview(index:Int) {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        let id = items[index].id
        withAnimation {
            items.remove(at: index)
        }
        
        Task {
            try? await ReviewsDao(storeId: storeId, productId: product.id).removeReview(id:id)
            ToastManager.shared.showToast(msg: "Review Deleted")
        }
    }
    
    func refreshProduct() async {
        if let productData = try? await ProductsDao(storeId: product.storeId).getProduct(id: product.id) {
            DispatchQueue.main.async {
                self.product = productData
            }
        }
    }
    
    func getVarientOptions(hash:[String:[String]]) -> String {
        guard let arr = hash[hash.keys.first!] else {
            return ""
        }
        
        let capitalizedArr = arr.map { $0.capitalizeFirstLetter() }
        return capitalizedArr.joined(separator: ", ")
    }
    
    private func getReviews() async {
        guard let storeId = UserInformation.shared.user?.storeId, !isLoading, hasMore else {
            print("Something is null")
            return
        }
        
        do {
            let result = try await ReviewsDao(storeId: storeId, productId: product.id).getReviews(lastSnapshot: lastDoc)
            self.isLoading = true
            print("Result \(result.items.count)")
            
            DispatchQueue.main.async {
                print("Got \(items.count) Reviews")
                self.items.append(contentsOf: result.items)
                self.lastDoc = result.lastDocument
                self.hasMore = !result.items.isEmpty
                self.isLoading = false
            }
        } catch {
            print("Reviews error \(error)")
        }
    }
}

struct ProductDetails_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetails(product: .constant(StoreProduct.example()))
    }
}
