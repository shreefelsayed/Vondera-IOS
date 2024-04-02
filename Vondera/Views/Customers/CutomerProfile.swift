//
//  ClientOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI

struct CutomerProfile: View {
    var client:Client
    @State private var showContact = false
    @State private var sheetHeight: CGFloat = .zero
    @StateObject var viewModel:ClientOrdersViewModel
    
    init(client:Client) {
        self.client = client
        _viewModel = StateObject(wrappedValue:ClientOrdersViewModel(id:client.phone))
    }
    
    var body: some View {
        List {
            // MARK : Customer info
            VStack (alignment: .leading) {
                Text(client.name)
                    .font(.headline)
                    .bold()
                
                Label {
                    Text(client.phone)
                } icon: {
                    Image(.icCall)
                }
                
                Label {
                    Text("\(client.gov ?? "") - \(client.address ?? "")")
                } icon: {
                    Image(.icLocation)
                }
                
                if let lastOrder = client.lastOrder {
                    Label {
                        Text("Last ordered at : \(lastOrder.toString())")
                    } icon: {
                        Image(.icDate)
                    }
                }
                
                Label {
                    Text("Contact Customer")
                } icon: {
                    Image(.icContact)
                }
                .padding(6)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .onTapGesture {
                    showContact.toggle()
                }


                Divider()
                
                HStack {
                    if let ordersCount = client.ordersCount {
                        HStack {
                            Image(.btnOrders)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Text("\(ordersCount) Orders")
                        }
                        
                        Spacer()
                    }
                                    
                    if let total = client.total, !total.isNaN, !total.isInfinite {
                        HStack {
                            Image(.btnMoney)
                                .resizable()
                                .frame(width: 32, height: 32)
                                                
                            Text("\(Int(total)).0 EGP")
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .padding(.bottom, 12)
            
            
            // MARK : Customer orders
            if viewModel.items.count > 0 {
                Section("Latest orders") {
                    ForEach($viewModel.items.indices, id: \.self) { index in
                        OrderCard(order: $viewModel.items[index])
                    }
                }
                .listStyle(.plain)
            }
            
        }
        .listStyle(.plain)
        .padding()
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    CustomerBanScreen(phone: client.phone)
                } label: {
                    Image(.btnBan)
                }
            }
        }
        .refreshable {
            await refreshData()
        }
        .background(Color.background)
        .sheet(isPresented: $showContact) {
            ContactDialog(phone: client.phone, toggle: $showContact)
        }
        .navigationTitle("Customer Details")
    }
    
    func refreshData() async {
        await viewModel.refreshData()
    }
    
    func loadItem() {
        Task {
            await viewModel.getData()
        }
    }
}

#Preview {
    CutomerProfile(client: Client.example())
}
