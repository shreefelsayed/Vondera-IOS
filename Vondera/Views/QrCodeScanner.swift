//
//  QrCodeScanner.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI
import CodeScanner
import AlertToast

struct QrCodeScanner: View {
    var myUser = UserInformation.shared.user
    @State var scannedOrder:Order?
    @State var msg:LocalizedStringKey?
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], scanMode: .continuous, showViewfinder: true) { response in
            if case let .success(result) = response {
                getOrder(id:result.string)
            }
        }
        .sheet(item: $scannedOrder, content: { order in
            NavigationStack {
                OrderDetails(order: .constant(order))
            }
        })
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .alert, type: .error(.red), title: msg?.toString())
        }
    }
    
    func getOrder(id:String) {
        Task {
            if let user = myUser, id.isNumeric {
                do {
                    
                    let order = try await OrdersDao(storeId: user.storeId).getOrder(id: id)
                    
                    
                    if order.exists {
                        self.scannedOrder = order.item
                    } else {
                        msg = "Order not found !".localize()
                    }
                    
                    
                } catch {
                    msg = error.localizedDescription.localize()
                }
            }
        }
    }
}


struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct QrCodeScanner_Previews: PreviewProvider {
    static var previews: some View {
        QrCodeScanner()
    }
}
