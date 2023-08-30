//
//  OrderDetailsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation

class OrderDetailsViewModel: ObservableObject {
    var storeId:String
    var orderId:String
    
    @Published var errorMsg = ""
    @Published var order:Order? = nil
    @Published var isLoading = true
    
    lazy var user:UserData? = nil
    lazy var ordersDao:OrdersDao? = nil
    
    @Published var showToast = false
    @Published var msg = ""
    
    init(storeId:String, orderId:String) {
        self.storeId = storeId
        self.orderId = orderId
        
        initalize()
    }
    
    func confirm() {
        Task {
            if var order = self.order {
                self.order = await OrderManager().confirmOrder(order:&order)
                self.showTosat(msg: "Order Confirmed")
            }
        }
    }
    
    func assign(_ courier:Courier) {
        Task {
            if var order = self.order {
                self.order = await OrderManager().outForDelivery(order: &order, courier: courier)
                self.showTosat(msg: "Order Is with courier")
            }
        }
    }
    
    func ready() {
        Task {
            if var order = self.order {
                self.order = await OrderManager().assambleOrder(order:&order)
                self.showTosat(msg: "Order Is ready for Shipping")
            }
        }
    }
    
    func deliver() {
        Task {
            if var order = self.order {
                self.order = await OrderManager().orderDelivered(order:&order)
                self.showTosat(msg: "Order is Delivered")
            }
        }
    }
    
    func reset() {
        Task {
            if var order = self.order {
                self.order = await OrderManager().resetOrder(order:&order)
                self.showTosat(msg: "Order has been reset")
            }
        }
    }
    
    func delete() {
        Task {
            if var order = self.order {
                self.order = await OrderManager().orderDelete(order:&order)
                self.showTosat(msg: "Order deleted")
            }
        }
    }
    
    func failed() {
        Task {
            if var order = self.order {
                self.order = await OrderManager().orderFailed(order:&order)
                self.showTosat(msg: "Order Confirmed")
            }
        }
    }
    
    func initalize()  {
        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                
                user = await LocalInfo().getLocalUser()!
                
                ordersDao = OrdersDao(storeId: storeId)
                await getOrderData()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
            }
        }
    }
    
    func getOrderData() async {
        do {
            try await ordersDao!.getOrder(id: orderId, completion: { order, here in
                if !here {
                    self.errorMsg = "Order doesn't exist"
                    self.order = nil
                    return
                }
                
                self.order = order
            })
        } catch {
            self.errorMsg = error.localizedDescription
        }
    }
    
    func showTosat(msg: String) {
        DispatchQueue.main.async {
            self.msg = msg
            self.showToast.toggle()
        }
        
    }
}
