//
//  CheckOut.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI
import Combine
import AlertToast
import PhotosUI

class CheckOutViewModel: ObservableObject {
    @Published var id = ""
    @Published var name = ""
    @Published var otherPhone = ""
    @Published var address = ""
    @Published var notes = ""
    @Published var shippingFees:Double = 0.0
    @Published var discount = 0.0
    @Published var paid = false
    @Published var marketPlaceId = ""
    @Published var client:Client?
    
    @AppStorage("whatsapp") var whats = false

    @Published var isSaving = false
    @Published var msg:LocalizedStringKey?
    @Published var openPlan = false
    @Published var selectedPhotos = [UIImage]()
    
    @Published var phone = "" {
        didSet {
            Task {
                await searchForClient()
            }
        }
    }
    
    @Published var gov = "" {
        didSet {
            if let listAreas = myUser?.store?.listAreas, shipping {
                let item = listAreas.first { $0.govName == gov }
                DispatchQueue.main.async {
                    self.shippingFees = item?.price ?? 0
                }
            }
        }
    }
    
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    var storeId:String
    var shipping:Bool

    var listItems:[OrderProductObject]
    
    var ordersDao:OrdersDao
    var clientsDao:ClientsDao
    var myUser = UserInformation.shared.getUser()
    
    init(storeId: String, listItems:[OrderProductObject], shipping: Bool) {
        self.storeId = storeId
        self.shipping = shipping
        self.listItems = listItems
        self.ordersDao = OrdersDao(storeId: storeId)
        self.clientsDao = ClientsDao(storeId: storeId)
        self.myUser = UserInformation.shared.getUser()

        Task {
            if myUser!.store!.listAreas!.isEmpty {
                self.shouldDismissView = true
                return
            }
            
            self.gov = myUser?.store?.listAreas?.first?.govName ?? ""
            self.shippingFees = myUser?.store?.listAreas?.first?.price ?? 0
            
            await genrateId()
            
            if let market = myUser?.store?.listMarkets?.first {
                marketPlaceId = market.id
            }
        }
    }
    
    func generateRandomNumber() -> Int {
        let randomNumber = arc4random_uniform(90000000) + 10000000
        return Int(randomNumber)
    }
    
    func genrateId() async {
        let id:String = "\(generateRandomNumber())"
        if let isExist = try? await ordersDao.isExist(id: id), isExist {
            await genrateId()
            return
        }
        
        self.id = id
    }
    
    var cod: Double {
        return totalPrice + (shipping ? shippingFees : 0) - discount
    }
    
    var totalPrice : Double {
        var price = 0.0
        for item in listItems {
            price += (item.price * item.quantity.double())
        }
        
        return price
    }
    
    func searchForClient() async {
        guard phone.isPhoneNumber else {
            self.client = nil
            return
        }
        
        do {
            let client = try await clientsDao.getClient(phone: phone)
            if let client = client {
                DispatchQueue.main.async {
                    self.client = client
                    self.name = client.name
                    self.address = self.shipping ? client.address ?? "" : ""
                    self.gov = self.shipping ? client.gov ?? "" : ""
                }
            } else {
                self.client = nil
            }
        } catch {
            self.client = nil
            print(error.localizedDescription)
        }
    }
    
    func saveOrder() async {
        guard check() else { return }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        if selectedPhotos.isEmpty {
            await addToFirestore()
        } else {
            FirebaseStorageUploader()
                .uploadImagesToFirebaseStorage(images: selectedPhotos, storageRef: "orders/\(id)/") { urls, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.showToast(error.localizedDescription.localize())
                            self.isSaving = true
                        }
                        return
                    } else if let urls = urls {
                        
                        Task {
                            await self.addToFirestore(attachment:urls)
                        }
                    }
                }
        }
        
    }
    
    func addToFirestore(attachment:[String] = [String]()) async {
        var order = Order(id: id, name: name, address: (shipping ? address : ""), phone: phone, gov: (shipping ? gov : ""), notes: notes, discount: discount, clientShippingFees:(shipping ? shippingFees : 0.0))
        
        order.listAttachments = attachment
        order.listProducts = listItems
        order.paid = paid
        order.marketPlaceId = marketPlaceId
        order.otherPhone = otherPhone
        order.requireDelivery = shipping
        
        order = await OrderManager().addOrder(order: &order)
        
        DispatchQueue.main.async { [order] in
            if self.whats {
                _ = Contact().openWhatsApp(phoneNumber: self.phone, message: order.toString())
            }
            
            self.isSaving = false
            self.shouldDismissView = true
            
            // Show rating store dialog
            AppStoreHelper().showRating()
        }
    }
    
    func check() -> Bool {
        if myUser!.store!.QuoteExceeded() {
            showToast("Your Quote has been exceeded")
            openPlan.toggle()
            
            return false
        }
        
        if !(myUser!.store!.canOrder ?? true) {
            showToast("The owner disabled new orders for now")
            return false
        }
        
        if !phone.isPhoneNumber {
            showToast("Please enter the client phone")
            return false
        }
        
        if name.isBlank {
            showToast("Please enter the client name")
            return false
        }
        
        if gov.isBlank && shipping {
            showToast("Please enter the client state")
            return false
        }
        
        if address.isBlank && shipping {
            showToast("Please enter the client address")
            return false
        }
        
        
        return true
    }
    
    func showToast(_ msg:LocalizedStringKey) {
        DispatchQueue.main.async {
            self.msg = msg
        }
    }
}

struct CheckOut: View {
    @State var images:[PhotosPickerItem] = [PhotosPickerItem]()

    var storeId: String
    var listItems: [OrderProductObject]
    var shipping:Bool
    var onSubmited:(() -> ())
    
    @ObservedObject var viewModel: CheckOutViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, listItems: [OrderProductObject], shipping: Bool, onSubmited : @escaping (() -> ())) {
        self.storeId = storeId
        self.listItems = listItems
        self.shipping = shipping
        self.onSubmited = onSubmited
        
        _viewModel = ObservedObject(initialValue: CheckOutViewModel(storeId: storeId, listItems: listItems, shipping: shipping))
    }
    
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                // MARK : Market Places
                if let markets = viewModel.myUser?.store?.listMarkets, !markets.isEmpty  {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(MarketsManager().getEnabledMarkets(storeMarkets: markets)) { market in
                                MarketHeaderCard(marketId: market.id, withText: true, turnedOff: viewModel.marketPlaceId != market.id)
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.marketPlaceId = market.id
                                        }
                                    }
                            }
                        }
                        
                    }
                }
                
                // MARK : Client Info
                VStack(alignment: .leading) {
                    Text("Client info")
                        .font(.title2)
                        .bold()
                    
                    FloatingTextField(title: "Phone Number", text: $viewModel.phone, required: true, keyboard: .phonePad)
                    
                    
                    FloatingTextField(title: "Full Name", text: $viewModel.name, required: true, autoCapitalize: .words)
                    
                    
                    FloatingTextField(title: "Other Phone Number", text: $viewModel.otherPhone, required: false, keyboard: .phonePad)
                    
                    Divider()
                }
                
                
                // Shipping Info
                if shipping {
                    VStack(alignment: .leading) {
                        Text("Shipping info")
                            .font(.title2)
                            .bold()
                        
                        if let list = viewModel.myUser?.store?.listAreas?.uniqueElements() {
                            HStack {
                                Text("Government")
                                
                                Spacer()
                                
                                Picker("Government", selection: $viewModel.gov) {
                                    ForEach(list, id: \.self) { area in
                                        Text(area.govName)
                                            .tag(area.govName)
                                    }
                                }
                            }
                        }
                        
                        FloatingTextField(title: "Address", text: $viewModel.address, required: true, multiLine: true, autoCapitalize: .sentences)
                        
                        Divider()
                    }
                }
                
                // Notes
                VStack(alignment: .leading) {
                    FloatingTextField(title: "Notes", text: $viewModel.notes, required: false, multiLine: true, autoCapitalize: .sentences)
                    
                    
                    Divider()
                }
                
                // Payments
                VStack(alignment: .leading) {
                    Text("Payment")
                        .font(.title2)
                        .bold()
                    
                    if shipping {
                        FloatingTextField(title: "Shipping Fees", text: .constant(""), required: true, isNumric: true, number: $viewModel.shippingFees)
                    }
                    
                    
                    FloatingTextField(title: "Discount", text: .constant(""), required: false, isNumric: true, number: $viewModel.discount)
                    
                    
                    Divider()
                }
                
                
                VStack(alignment: .leading) {
                    Text("Options")
                        .font(.title2)
                        .bold()
                    
                    if (viewModel.myUser?.store?.orderAttachments ?? false) {
                        HStack {
                            PhotosPicker(selection: $images, maxSelectionCount: 30) {
                                Text("Add Attachments")
                            }
                            
                            Spacer()
                            
                            Text("\(images.count) Attachment")
                        }
                        .onChange(of: images) { newValue in
                            Task {
                                viewModel.selectedPhotos.removeAll()
                                for picker in newValue {
                                    if let image = try? await picker.getImage() {
                                        viewModel.selectedPhotos.append(image)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    if shipping && (viewModel.myUser?.store?.canPrePaid ?? false) {
                        Toggle("Order prepaid", isOn: $viewModel.paid)
                    }
                    
                    
                    Toggle("Send Whatsapp message", isOn: $viewModel.whats)
                    
                    Divider()
                }
                
                VStack(alignment: .leading) {
                    Text("Order Summery")
                        .font(.title2)
                        .bold()
                    
                    
                    if let client = viewModel.client {
                        NavigationLink {
                            CutomerProfile(client: client)
                        } label: {
                            if client.isBanned ?? false {
                                Text("This client is banned")
                                    .font(.headline)
                                    .foregroundStyle(.red)
                            } else {
                                Text("This client ordered \(client.ordersCount ?? 0) times before")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Text("Products price")
                        Spacer()
                        Text("+\(viewModel.totalPrice.toString()) LE")
                    }
                    
                    if shipping {
                        HStack {
                            Text("Shipping Fees")
                            Spacer()
                            Text("+\(viewModel.shippingFees.toString()) LE").foregroundColor(.yellow)
                                
                        }
                    }
                    
                    
                    HStack {
                        Text("Discount")
                        Spacer()
                        Text("-\(viewModel.discount.toString()) LE").foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("COD")
                        Spacer()
                        Text("\(viewModel.cod.toString()) LE").foregroundColor(.green)
                    }
                }
                .bold()
                
                
                
            }
        }
        .padding()
        .navigationTitle("Check out")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Submit")
                    .foregroundColor(.accentColor)
                    .bold()
                    .onTapGesture {
                        Task {
                            await viewModel.saveOrder()
                        }
                    }
            }
        }
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
                onSubmited()
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg?.toString())
        }
        .navigationDestination(isPresented: $viewModel.openPlan) {
            AppPlans(selectedSlide: 3)
        }
        .task {
            if let firstItem = UserInformation.shared.user?.store?.listAreas?.first {
                viewModel.gov = firstItem.govName
            }
        }
    }
}

#Preview {
    CheckOut(storeId: Store.Qotoofs(), listItems: [], shipping: true) {
        
    }
}
