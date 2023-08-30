//
//  OrderDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import MapKit
import AlertToast

struct OrderDetails: View {
    var id:String
    var storeId:String
    @State private var snapshotImage: UIImage?
    @State private var delete = false
    @State var assignDialog = false
    @State var courier:Courier?
    @State var contactSheet = false
    
    @ObservedObject var viewModel:OrderDetailsViewModel
    
    init(id: String, storeId: String) {
        self.id = id
        self.storeId = storeId
        self.viewModel = OrderDetailsViewModel(storeId: storeId, orderId: id)
        
        print("Order code \(id)")
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.order != nil {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // MARK : ORDER HEADER
                            VStack(alignment: .leading) {
                                HStack(alignment: .center) {
                                    Text("Order Details")
                                        .font(.title3)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("#\(viewModel.orderId)")
                                        .bold()
                                        .foregroundStyle(Color.accentColor)
                                }
                                
                                Divider()
                                
                                HStack(alignment: .center) {
                                    Text("Order Statue")
                                        .font(.title3)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.order?.statue ?? "")")
                                        .bold()
                                }
                            }
                            
                            
                            // MARK : SHIPPING OPTIONS
                            VStack(alignment: .leading) {
                                Text("Shipping Info")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer().frame(height: 8)
                                
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.order!.name)
                                        Text("\(viewModel.order!.gov), \(viewModel.order!.address)")
                                        Text(viewModel.order!.gov)
                                        Text(viewModel.order!.phone)
                                    }
                                    
                                    Spacer()
                                    
                                    if let image = snapshotImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .cornerRadius(12)
                                            .frame(width: 140, height: 100)
                                            .onTapGesture {
                                                openLocation()
                                            }
                                    }
                                    
                                }
                                .font(.body)
                                .foregroundColor(.secondary)
                            }
                            
                            // MARK : CONTACT BUTTON
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color.accentColor)
                                
                                Text("Contact Customer")
                            }
                            .onTapGesture {
                                contactSheet.toggle()
                            }
                            
                                                    
                            // MARK : ORDER SUMMERY
                            VStack(alignment: .leading) {
                                Text("Order Summery")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer().frame(height: 8)
                                
                                HStack {
                                    Text("Products Price")
                                    Spacer()
                                    Text("+\(viewModel.order!.totalPrice) LE")
                                }
                                
                                HStack {
                                    Text("Shipping Fees")
                                    Spacer()
                                    Text("+\(viewModel.order!.clientShippingFees) LE")
                                        .foregroundColor(.yellow)
                                }
                                
                                if viewModel.order!.discount ?? 0 > 0 {
                                    HStack {
                                        Text("Discount")
                                        Spacer()
                                        Text("-\(viewModel.order!.discount ?? 0) LE")
                                            .foregroundColor(.red)
                                    }
                                    
                                    
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("COD")
                                    Spacer()
                                    Text("\(viewModel.order!.COD) LE")
                                        .foregroundColor(.green)
                                }
                                
                            }
                            .bold()
                            
                            
                            //MARK : ORDER PRODUCTS
                            VStack (alignment: .leading){
                                Text("Products Details")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer().frame(height: 8)
                                
                                ForEach(viewModel.order!.listProducts!, id: \.productId) { product in
                                    ProductOrderCard(orderProduct: product)
                                }
                            }
                            
                            // MARK : Updates View
                            if viewModel.order?.listUpdates != nil {
                                VStack (alignment: .leading){
                                    Text("Updates")
                                        .font(.title2)
                                        .bold()
                                    
                                    Spacer().frame(height: 8)
                                    
                                    ForEach(viewModel.order!.listUpdates!.reversed(), id: \.self) { update in
                                        UpdateCard(update: update)
                                    }
                                }
                                Spacer().frame(height: 20)
                            }
                            
                        }
                    }
                    
                    // MARK : BUTTONS
                    buttons.background(Color.background)
                    
                    
                }
            }
            BottomSheet(isShowing: $contactSheet, content: {
                AnyView(ContactDialog(phone: viewModel.order?.phone ?? "", toggle: $contactSheet))
            }())
        }
        
        .onAppear {
            if viewModel.order != nil {
                generateMapSnapshot(latLang: viewModel.order!.latLang)
            }
        }
        .overlay(alignment: .center, content: {
            if viewModel.isLoading || viewModel.order == nil {
                ProgressView()
            }
        })
        .confirmationDialog("Are you sure you want to delete the order ?", isPresented: $delete, titleVisibility: .visible, actions: {
            Button("Delete", role: .destructive) {
                viewModel.delete()
            }
            
            Button("Later", role: .cancel) {
                
            }
        })
        .sheet(isPresented: $assignDialog) {
            CourierPicker(storeId: storeId, selectedOption: $courier)
        }
        
        .onChange(of: courier) { newValue in
            // Handle selectedOption changes here
            if let option = newValue {
                viewModel.assign(option)
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
        .padding()
        .navigationTitle("#\(viewModel.orderId)")
        
    }
    
    var buttons: some View {
       
        VStack (alignment: .leading, spacing: 6){
            HStack(spacing: 6) {
                if showConfirm {
                    ButtonLarge(label: "Confirm") {
                        viewModel.confirm()
                    }
                }
                
                if showAssembleButton {
                    ButtonLarge(label: "Ready to ship") {
                        viewModel.ready()
                    }
                }
                
                if showAssign {
                    ButtonLarge(label: "Assign to Courier") {
                        assignDialog.toggle()
                    }
                }
                
            }
            
            
            HStack(spacing: 6) {
                if showDeliverButton {
                    ButtonLarge(label: "Delivered", background: .green) {
                        viewModel.deliver()
                    }
                }
                
                if showFailed {
                    ButtonLarge(label: "Return Order", background: .gray) {
                        viewModel.failed()
                    }
                }
                
            }
            HStack(spacing: 6) {
                if showResetButton {
                    ButtonLarge(label: "Reset Order", background: .red) {
                        viewModel.reset()
                    }
                }
                
                if showDelete {
                    ButtonLarge(label: "Delete Order", background: .red) {
                        self.delete.toggle()
                    }
                }
                
            }
        }
    }
    
    var showAssign:Bool {viewModel.user!.accountType == "Marketing" ? false : viewModel.order?.statue == "Assembled"}
    
    var showConfirm:Bool { viewModel.order?.statue == "Pending" }
    
    var showAssembleButton: Bool { viewModel.user!.accountType == "Marketing" ? false : viewModel.order?.statue == "Confirmed" }
    
    var showDeliverButton: Bool { viewModel.user!.accountType == "Marketing" ? false : viewModel.order?.statue == "Assembled" || viewModel.order?.statue == "Out For Delivery" }
    
    var showFailed: Bool { viewModel.user!.accountType == "Marketing" ? false : (viewModel.order?.requireDelivery ?? true) && viewModel.order?.statue == "Out For Delivery" }
    
    var showResetButton:Bool {
        if viewModel.order?.statue == "Pending" { return false }
        
        if viewModel.user!.accountType == "Owner" || viewModel.user!.accountType == "Store Admin" {
            return true
        }
        
        if (viewModel.user?.store?.canWorkersReset ?? false) && viewModel.user!.accountType == "Worker" {
            return true
        }
        
        return false
    }
    
    var showDelete:Bool {
        return viewModel.order!.canDeleteOrder(accountType: viewModel.user!.accountType)
    }
    
    func openLocation() {
        if viewModel.order?.latLang == nil { return }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: (viewModel.order?.latLang)!, addressDictionary:nil))
        mapItem.name = "\(viewModel.order!.name) - #\(viewModel.order!.id)"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func generateMapSnapshot(latLang: CLLocationCoordinate2D?) {
        if latLang == nil { return }
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: latLang!, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        options.size = CGSize(width: 140, height: 100) // Adjust the size as needed
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshotImage = snapshot?.image {
                self.snapshotImage = snapshotImage
            }
        }
    }
}
