//
//  OrderDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct StatueButton : View {
    @Binding var order:Order
    @State var selecting:String = ""
    
    @State var failedScreen = false
    @State var deliverScreen = false
    @State var courierScreen = false
    @State var selectedCourier:Courier?
    
    @State var deleteWarning = false
    @State var resetWarning = false
    
    
    var body: some View {
        VStack {
            Picker(selection: $selecting) {
                ForEach(OrderStatues.allCases, id: \.rawValue) { statue in
                    Text("\(statue.rawValue)")
                        .tag(statue)
                }
            } label: {
                Text(order.getStatueLocalized())
            }
            .accentColor(getStatueColor())
            .foregroundStyle(getStatueColor())
        }
        
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(getStatueColor().opacity(0.2))
        )
        .task {
            self.selecting = order.statue
        }
        .sheet(isPresented: $courierScreen) {
            CourierPicker(selectedOption: $selectedCourier)
        }
        .sheet(isPresented: $failedScreen, content: {
            NavigationStack {
                OrderFailed(order: $order)
            }
        })
        .confirmationDialog("Reset order", isPresented: $resetWarning, actions: {
            Button("Later", role: .cancel) {
                self.selecting = order.statue
            }
            
            Button("Reset", role: .destructive) {
                reset()
            }
        }, message: {
            Text("This will reset your order statue to pending, are you sure you want to reset the order ?")
        })
        .confirmationDialog("Delete order", isPresented: $deleteWarning, actions: {
            Button("Later", role: .cancel) {
                self.selecting = order.statue
            }
            
            Button("Delete", role: .destructive) {
                delete()
            }
        }, message: {
            Text("This will delete the order, but you can restore it later.")
        })
        .onChange(of: selecting) { _ in
            
            // --> Then we make the action
            makeActionOnNewStatue(selecting)
        }
        .onChange(of: courierScreen) { newValue in
            guard !courierScreen else {
                return
            }
            
            guard let selectedCourier = selectedCourier else {
                self.selecting = order.statue
                return
            }
            
            assign(selectedCourier)
            self.selectedCourier = nil
        }
    }
    
    private func makeActionOnNewStatue(_ statue:String) {
        guard selecting != order.statue else { return }

        switch OrderStatues(rawValue: statue) {
        case .pending:
            resetWarning.toggle()
            break
        case .confirmed:
            confirm()
            break
        case .assembled:
            ready()
            break
        case .withCourier:
            if AccessFeature.accessCouriersAssign.canAccess() {
                courierScreen.toggle()
            }
            break
        case .delivered:
            deliver()
            break
        case .failed:
            failedScreen.toggle()
            break
        case .deleted:
            if AccessFeature.orderDelete.canAccess() {
                deleteWarning.toggle()
            }
            break
        case .none:
            break
        
        }
    }
    
    func confirm() {
        Task {
            let order = await OrderManager().confirmOrder(order:&order)
            DispatchQueue.main.async { [order] in
                self.order = order
                self.showToast("Order Confirmed")
            }
        }
    }
    
    func delete() {
        Task {
            let order = await OrderManager().orderDelete(order:&order)
            if order.success {
                DispatchQueue.main.async { [order] in
                    self.order = order.result
                    self.showToast("Order has been deleted")
                }
            }
        }
    }
    
    func assign(_ courier: Courier) {
        Task {
            let updatedOrder = await OrderManager().outForDelivery(order: &order, courier: courier)
            DispatchQueue.main.async { [updatedOrder] in
                self.order = updatedOrder
                self.showToast("Order is with courier")
            }
        }
    }
    
    func ready() {
        Task {
            do {
                let order = await OrderManager().assambleOrder(order:&order)
                DispatchQueue.main.async { [order] in
                    self.order = order
                    self.showToast("Order Is ready for Shipping")
                }
            } catch {
                print("Failed to set order as ready")
            }
        }
    }
    
    func deliver() {
        Task {
            let order  = await OrderManager().orderDelivered(order:&order)
            DispatchQueue.main.async { [order] in
                self.order = order
                self.showToast("Order is Delivered")
            }
        }
    }
    
    func reset() {
        Task {
            self.order = await OrderManager().resetOrder(order:&order)
            self.showToast("Order has been reset")
        }
    }
    
    func failed() {
        Task {
            let order = await OrderManager().orderFailed(order:&order)
            DispatchQueue.main.async { [order] in
                self.order = order
                self.showToast("Order Failed")
            }
        }
    }
    
    private func showToast(_ msg: LocalizedStringKey) {
        DispatchQueue.main.async {
            ToastManager.shared.showToast(msg: msg)
        }
    }
    
    private func getStatueColor() -> Color {
        switch OrderStatues(rawValue: order.statue) {
        case .pending:
            return Color.yellow
        case .assembled:
            return Color.yellow
        case .withCourier:
            return Color.yellow
        case .confirmed:
            return Color.green
        case .delivered:
            return Color.green
        case .failed:
            return Color.red
        case .deleted:
            return Color.red
        case .none:
            return Color.black
        }
    }
}

struct OrderDetailLoading : View {
    var id:String
    @State var order:Order = Order.example()
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            if !isLoading {
                OrderDetails(order: $order)
            } else {
                ProgressView()
            }
        }
        
        .task {
            await getOrderData()
        }
    }
    
    private func getOrderData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        do {
            let result = try await OrdersDao(storeId: storeId).getOrder(id: id)
            guard result.exists, let order = result.item else { return }
            
            self.order = order
            self.isLoading = false
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Order Details")
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

struct OrderDetails: View {
    @Binding var order:Order
    @State var orderCourier:Courier?

    @State var isLoading = false
    @State var comment = ""
    
    @State var myUser = UserInformation.shared.user
    
    @State private var snapshotImage: UIImage?
    
    // SHEETs
    @State var assignDialog = false
    @State var failedScreen = false
    @State var collectMoney = false
    
    // CONTACT CLIENT
    @State var contactSheet = false
    @State var showOptions = false
    
    // CONTACT INFO
    @State var contactUser:String?
    @State private var sheetHeight: CGFloat = .zero
    
    @Environment(\.presentationMode) private var presentationMode

    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK : ORDER HEADER
                VStack(alignment: .leading) {
                    
                    // MARKET PLACE
                    HStack(alignment: .center) {
                        if order.marketPlaceId != nil && !order.marketPlaceId!.isBlank {
                            MarketHeaderCard(marketId: order.marketPlaceId!, withText: false)
                        }
                        
                        Text("at \(order.date.toString())")
                            .font(.callout)
                        
                        // TODO : Statue Spinner
                        
                        Spacer()
                        
                        StatueButton(order: $order)
                    }
                    
                    // Stepper
                    /*if order.statue != "Deleted" {
                        StatueSteps(currentStep: order.getCurrentStep(), steps: order.getOrderSteps())
                    }*/
                }
                
                //MARK : ORDER PRODUCTS
                if let products = order.listProducts {
                    ForEach(products, id: \.self) { product in
                        NavigationLink {
                            ProductLoadingScreen(id: product.productId)
                        } label: {
                            ProductOrderCard(orderProduct: product)

                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK : ORDER SUMMERY
                VStack(alignment: .leading) {
                    Text("Order Summery")
                        .font(.title2)
                        .bold()
                    
                    Spacer().frame(height: 8)
                    
                    // MARK : Product Price
                    HStack {
                        Text("Products prices")
                        Spacer()
                        Text("\(order.totalPrice.toString()) LE")
                            .bold()
                    }
                    
                    // MARK : Shipping Fees
                    if (order.requireDelivery ?? true) {
                        HStack {
                            Text("Shipping Fees")
                            Spacer()
                            Text("\(order.clientShippingFees.toString()) LE")
                                .foregroundColor(.yellow)
                                .bold()
                        }
                    }
                    
                    // MARK : Discount
                    if let discount = order.discount, discount > 0 {
                        HStack {
                            Text("Discount")
                            Spacer()
                            Group {
                                if let code = order.discountCode, !code.isBlank {
                                    Text("\(discount.toString()) LE #\(code)")
                                } else {
                                    Text("\(discount.toString()) LE")
                                }
                            }
                            
                                .foregroundColor(.red)
                                .bold()
                        }
                    }
                              
                    // MARK : Deposit
                    if let deposit = order.deposit, deposit > 0{
                        HStack {
                            Text("Deposit")
                            Spacer()
                            Text("\(deposit.toString()) LE")
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                    
                    // MARK : COD
                    HStack {
                        Text("COD")
                        Spacer()
                        Text("\(order.COD.toString()) LE")
                            .foregroundColor(.green)
                            .bold()
                    }
                    
                    // MARK : Collect Payment Button
                    if order.canCollectMoney() {
                        ButtonLarge(label: "Collect Money") {
                            collectMoney = true
                        }
                        .navigationDestination(isPresented: $collectMoney) {
                            CollectOrderPayment(orderId: order.id)
                        }
                    }
                }
                .cardView()
                
                // MARK :  Customer Info
                HStack {
                    VStack(alignment: .leading) {
                        Text("Customer Info")
                            .font(.title2)
                            .bold()
                        
                        Spacer().frame(height: 8)
                        
                        Text(order.name)
                            .bold()
                        
                        Label {
                            Text(order.phone)
                        } icon: {
                            Image(.icCall)
                        }

                        if let email = order.email, !email.isBlank {
                            Label {
                                Text(email)
                                    .underline()
                                
                            } icon: {
                                Image(.icEmail)
                            }
                            .onTapGesture {
                                // TODO : Mark open the mail app
                            }
                        }
                        
                        if (order.requireDelivery ?? true) {
                            Label {
                                Text("\(order.gov) - \(order.address)")
                            } icon: {
                                Image(.icLocation)
                            }
                        }
                        
                        Spacer().frame(height: 4)
                        
                        if !(order.notes?.isBlank ?? true) {
                            Text(order.notes ?? "")
                                .foregroundStyle(.red)
                                .bold()
                        }
                        
                        // MARK : CONTACT BUTTON
                        Label {
                            Text("Contact Customer")
                        } icon: {
                            Image(.icContact)
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.top, 8)
                        .onTapGesture {
                            contactSheet.toggle()
                        }
                    }
                    Spacer()
                }
                .cardView()
                
                // MARK : Payment Info
                VStack(alignment: .leading) {
                    Text("Payment Info")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 12)
                    
                    HStack {
                        Text("Payment Statue")
                        
                        Spacer()
                        
                        Text(order.getPaymentStatue)
                            .font(.caption)
                            .foregroundStyle(order.getPaymentStatueColor)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(order.getPaymentStatueColor.opacity(0.2))
                            )
                    }
                    
                    HStack {
                        Text("Gateway")
                        
                        Spacer()
                        
                        Text("\(order.payment?.gateway ?? "COD")")
                    }
                    
                    HStack {
                        Text("Payment Method")
                        
                        Spacer()
                        
                        Text("\(order.payment?.paymentMethod ?? "COD")")
                    }
                    
                    if let trans = order.payment?.transId, !trans.isBlank {
                        HStack {
                            Text("Payment Transaction")
                            
                            Spacer()
                            
                            Text(trans)
                        }
                    }
                }
                .cardView()
                
                // MARK : Courier Info
                if let courier = orderCourier {
                    VStack(alignment: .leading) {
                        Text("Courier")
                            .font(.title2)
                            .bold()
                        
                        HStack {
                            CachcedCircleView(imageUrl: courier.imageUrl ?? "", scaleType: .centerCrop, placeHolder: defaultCourier)
                                .frame(width: 45, height: 45)
                            
                            Text(courier.name)
                                .bold()
                            
                            Spacer()
                            
                            Button {
                                contactUser = courier.phone
                            } label: {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                            
                        }
                        
                        if let serialNumber = order.courierInfo?.receiptId, !serialNumber.isBlank {
                            
                            Text("Provider serial no . \(serialNumber)")
                        }
                    }
                    .cardView()
                }
                
                // MARK : Attachments
                if let images = order.listAttachments, images.count > 0 {
                    HStack {
                        Label("Attachments", systemImage: "paperclip")
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing : 18) {
                            NavigationLink {
                                FullScreenImageView(imageURLs: images, currentIndex: 0)
                            } label: {
                                Image(systemName: "eye.circle.fill")
                            }
                            
                            Button {
                                DownloadManager().saveImagesToDevice(imageURLs: images.map({ URL(string: $0)! }))
                                self.showTosat("Downloading started")
                            } label: {
                                Image(systemName: "square.and.arrow.down.fill")
                            }
                            
                            Button {
                                CopyingData().copyToClipboard(images)
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                        .font(.headline)
                        .bold()
                    }
                }
                
                // MARK : Updates View
                if let updates =  order.listUpdates, !updates.isEmpty {
                    VStack (alignment: .leading){
                        Text("Order Updates")
                            .font(.title2)
                            .bold()
                        
                        Spacer().frame(height: 8)
                        
                        ForEach(updates.reversed(), id: \.self) { update in
                            UpdateCard(update: update)
                        }
                    }
                }
                
                // MARK : Add New Comment
                HStack {
                    FloatingTextField(title: "Add Comment", text: $comment, required: nil)
                        .padding(4)
                        .background(.secondary.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button {
                        withAnimation {
                            addComment()
                        }
                    } label: {
                        Image(systemName: "paperplane")
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                
                Spacer().frame(height: 20)
            }
        }
        .padding()
        .background(Color.background)
        .refreshable {
            await getOrderData()
        }
        .overlay(alignment: .center) {
            if isLoading {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if let link = order.getLink() {
                        Button(action: {
                            CopyingData().copyToClipboard(link.absoluteString)
                        }, label: {
                            Label("Copy Order Link", systemImage: "doc.on.clipboard")
                        })
                        
                        Link(destination: link) {
                            Label("Visit", systemImage: "link")
                        }
                        
                        Button {
                            showOptions.toggle()
                        } label: {
                            Label("Options", systemImage: "gearshape")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
        .task {
            await getCoureirData()
        }
        .sheet(isPresented: $showOptions, content: {
            OrderOptionsSheet(order: $order, isPreseneted: $showOptions)
        })
        .sheet(isPresented: $contactSheet, content: {
            ContactDialog(phone: order.phone , toggle: $contactSheet)
        })
        .navigationTitle("Order #\(order.id)")
        .withPaywall(accessKey: .maxOrders(order.hidden ?? false), presentation: presentationMode)
    }
    
    func getCoureirData() async {
        guard let courierId = order.courierId, !courierId.isBlank, let storeId = UserInformation.shared.user?.storeId else {
            print("Something iw wrong")
            return
        }
        
        print("Getting data")
        
        do {
            let result = try await CouriersDao(storeId: storeId).getCourier(id: courierId)
            self.orderCourier = result
            print("Updated Courier")
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Order Details")
            print("Courier error \(error)")
        }
    }
    
    func getOrderData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        do {
            let orderData = try await OrdersDao(storeId: storeId).getOrder(id: order.id)
            guard orderData.exists, let order = orderData.item else { return }
            DispatchQueue.main.async { self.order = order }
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Order Details")
            showTosat(error.localizedDescription.localize())
        }
    }

    
    func addComment() {
        Task {
            let order = await OrderManager().addComment(order: &order, msg: comment, code: 0)
            DispatchQueue.main.async { [order] in
                self.order = order
                self.comment = ""
                showTosat("Comment added")
            }
        }
    }
    
    func showTosat(_ msg: LocalizedStringKey) {
        DispatchQueue.main.async {
            ToastManager.shared.showToast(msg: msg)
        }
    }
}

#Preview {
    StatueSteps()
    /*NavigationStack {
        OrderDetails(order: .constant(Order.example()))
    }*/
}

struct StatueSteps: View {
    var currentStep: Int = 1
    var steps = ["Pending", "Confirmed", "Ready", "With Courier", "Delivered"]

    var lineColor: Color = .accentColor
    var doneColor: Color = .accentColor
    var nextColor: Color = .gray
    var currentColor: Color = .accentColor
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            if index < currentStep {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(stepColor(steps[index]))
                            } else {
                                Text("\(index + 1)")
                                    .foregroundColor(stepColor(steps[index]))
                                    .font(.caption)
                                    .padding(5)
                                    .background(Circle()
                                        .stroke(nextColor, lineWidth: 2))
                            }
                        }
                        if index != steps.count - 1 {
                            Line(lineColor: stepColor(steps[index]), width: lineWidthForIndex(index))
                        }
                    }
                    
                }
            }
            
            HStack(spacing: 0) {
                ForEach(steps, id: \.self) { step in
                    Text(step)
                        .font(.subheadline)
                        .foregroundColor(stepColor(step))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: true)
                    
                    if let last = steps.last, last != step {
                        Spacer()
                    }
                    
                }
            }
        }
    }
    
    // Calculate dynamic line width based on the number of steps
    private func lineWidthForIndex(_ index: Int) -> CGFloat {
        let stepWidth = UIScreen.main.bounds.width / CGFloat(steps.count)
        return stepWidth - 20 // Adjust as needed
    }
    
    private func stepColor(_ step: String) -> Color {
        if let lastStep = steps.last, lastStep == "Failed", step == lastStep {
            return .red
        }
        if let stepIndex = steps.firstIndex(of: step) {
            if stepIndex < currentStep {
                return doneColor
            } else if stepIndex == currentStep {
                return currentColor
            } else if stepIndex > currentStep {
                return nextColor
            } else {
                return .secondary
            }
        }
        return .secondary
    }
}

struct Line: View {
    var lineColor: Color = .accentColor
    var width: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(lineColor)
            .frame(width: width, height: 2) // Use dynamic width
    }
}

