//
//  QrCodeScanner.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI
import CodeScanner

struct QrCodeScanner: View {
    var storeId: String
    @State private var scannedCode: String?
    @State private var navigateToOrderDetails = false

    var body: some View {
        NavigationView {
            VStack {
                
                NavigationLink(destination: NavigationLazyView(OrderDetails(id: scannedCode!, storeId: storeId)), isActive: $navigateToOrderDetails) {
                    EmptyView()
                }

                CodeScannerView(codeTypes: [.qr], scanMode: .continuous, showViewfinder: true) { response in
                    if case let .success(result) = response {
                        scannedCode = result.string
                        navigateToOrderDetails = true // Trigger navigation to OrderDetails
                    }
                }
            }
            .navigationBarHidden(true)
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
        QrCodeScanner(storeId: "")
    }
}
