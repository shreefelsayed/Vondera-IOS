//
//  CheckOut.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI
import Combine
import AlertToast

class CheckOutViewModel: ObservableObject {
    @Published var id = ""
    @Published var name = ""
    @Published var otherPhone = ""
    @Published var address = ""
    @Published var notes = ""
    @Published var shippingFees = "0"
    @Published var discount = "0"
    @Published var paid = false
    @Published var whats = false
    
    @Published var isSaving = false
    @Published var showToast = false
    @Published var msg = ""
    
    @Published var phone = "" {
        didSet {
            Task {
                await searchForClient()
            }
        }
    }
    
    @Published var gov = "" {
        didSet {
            if let listAreas = myUser?.store?.listAreas {
                let item = listAreas.first { $0.govName == gov }
                DispatchQueue.main.async {
                    self.shippingFees = "\(String(describing: item?.price ?? 0))"
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
    var listItems:[OrderProductObject]
    
    var ordersDao:OrdersDao
    var clientsDao:ClientsDao
    var myUser:UserData?
    
    init(storeId: String, listItems:[OrderProductObject]) {
        self.storeId = storeId
        self.listItems = listItems
        self.ordersDao = OrdersDao(storeId: storeId)
        self.clientsDao = ClientsDao(storeId: storeId)
        
        Task {
            myUser = await LocalInfo().getLocalUser()
            
            if myUser!.store!.listAreas!.isEmpty {
                self.shouldDismissView = true
                return
            }
            
            self.gov = myUser?.store?.listAreas?.first?.govName ?? ""
            await genrateId()
        }
    }
    
    func generateRandomNumber() -> Int {
        let randomNumber = arc4random_uniform(90000000) + 10000000
        return Int(randomNumber)
    }
    
    func genrateId() async {
        let id:String = "\(generateRandomNumber())"
        let isExist = try! await ordersDao.isExist(id: id)
        if isExist {
            await genrateId()
            return
        }
        
        self.id = id
    }
    
    var cod: Int {
        return totalPrice + (Int(shippingFees) ?? 0) - (Int(discount) ?? 0)
    }
    var totalPrice : Int {
        var price = 0
        for item in listItems {
            price += (Int(item.price) * item.quantity)
        }
        
        return price
    }
    
    func searchForClient() async {
        guard phone.isPhoneNumber else {
            return
        }
        
        do {
            let client = try await clientsDao.getClient(phone: phone)
            if let client = client {
                DispatchQueue.main.async {
                    self.name = client.name
                    self.address = client.address ?? ""
                    self.gov = client.gov ?? ""
                }
                
                //TODO : Make view visible
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveOrder() async {
        guard check() else { return }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        
        var order = Order(id: id, name: name, address: address, phone: phone, gov: gov, notes: notes, discount: Int(discount) ?? 0, clientShippingFees: Int(shippingFees) ?? 0)
        
        order.listProducts = listItems
        order.addBy = myUser?.id ?? ""
        order.isPaid = paid
        order.storeId = storeId
        order.otherPhone = otherPhone
        order.owner = myUser?.name ?? ""
        order.listUpdates?.append(Updates(uId: myUser?.id ?? "", code: 12))
        
        await OrderManager().addOrder(order: &order)

        DispatchQueue.main.async { [order] in
            if self.whats {
                Contact().openWhatsApp(phoneNumber: self.phone, message: order.toString())
            }
            
            self.isSaving = false
            self.shouldDismissView = true
        }
    }
    
    func check() -> Bool {
        if myUser!.store!.QuoteExceeded() {
            showToast("Your Quote has been exceeded")
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
        
        if gov.isBlank {
            showToast("Please enter the client state")
            return false
        }
        
        if address.isBlank {
            showToast("Please enter the client address")
            return false
        }
        
        if !shippingFees.isNumeric {
            showToast("Please enter a valid shipping fees")
            return false
        }
        
        if !discount.isNumeric {
            showToast("Please enter a valid Discount")
            return false
        }
        
        return true
    }
    
    func showToast(_ msg:String) {
        DispatchQueue.main.async {
            self.msg = msg
            self.showToast.toggle()
        }
    }
}

struct CheckOut: View {
    var storeId: String
    var listItems: [OrderProductObject]
    @State var shipping = true
    
    @ObservedObject var viewModel: CheckOutViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, listItems: [OrderProductObject], shipping: Bool = true) {
        self.storeId = storeId
        self.listItems = listItems
        self._shipping = State(initialValue: shipping)
        _viewModel = ObservedObject(initialValue: CheckOutViewModel(storeId: storeId, listItems: listItems))
    }
    
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                
                VStack(alignment: .leading) {
                    Text("Client info")
                        .font(.title2)
                        .bold()
                    
                    TextField("Phone Number", text: $viewModel.phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                    
                    TextField("Full Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                    
                    TextField("Other Phone Number", text: $viewModel.otherPhone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                    
                    Divider()
                }
                
                
                // Picker
                VStack(alignment: .leading) {
                    Text("Shipping info")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Text("Government")
                        
                        Spacer()
                        
                        Picker("Government", selection: $viewModel.gov) {
                            ForEach(viewModel.myUser!.store!.listAreas!, id: \.self) { area in
                                Text(area.govName)
                                    .tag(area.govName)
                            }
                        }
                    }
                    
                    TextField("Address", text: $viewModel.address, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                        .textFieldStyle(.roundedBorder)
                    
                    Divider()
                }
                
                VStack(alignment: .leading) {
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                        .textFieldStyle(.roundedBorder)
                    
                    Divider()
                }
                
                VStack(alignment: .leading) {
                    Text("Payment")
                        .font(.title2)
                        .bold()
                    
                    TextField("Shipping Fees", text: $viewModel.shippingFees)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    TextField("Discount", text: $viewModel.discount)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Divider()
                }
                
                VStack(alignment: .leading) {
                    Text("Options")
                        .font(.title2)
                        .bold()
                    
                    Toggle("Order prepaid", isOn: $viewModel.paid)
                    
                    Toggle("Send Whatsapp message", isOn: $viewModel.whats)
                    
                    Divider()
                }
                
                VStack(alignment: .leading) {
                    Text("Summery")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Text("Product Prices")
                        Spacer()
                        Text("+\(viewModel.totalPrice) LE")
                    }
                    
                    HStack {
                        Text("Shipping Fees")
                        Spacer()
                        Text("+\(viewModel.shippingFees) LE").foregroundColor(.yellow)
                    }
                    
                    HStack {
                        Text("Discount")
                        Spacer()
                        Text("-\(viewModel.discount) LE").foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("COD")
                        Spacer()
                        Text("\(viewModel.cod) LE").foregroundColor(.green)
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
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
        
    }
}

struct CheckOut_Previews: PreviewProvider {
    static var previews: some View {
        CheckOut(storeId: Store.Qotoofs(), listItems: [])
    }
}
