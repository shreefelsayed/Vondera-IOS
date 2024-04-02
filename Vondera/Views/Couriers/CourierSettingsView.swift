//
//  CourierSettingsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct CourierSettingsView: View {
    var courier:Courier
    var storeId:String
    
    var body: some View {
        List {
            Section {
                NavigationLink("Shipping Fees") {
                    CourierFees(id: courier.id, storeId: storeId)
                }
                
                NavigationLink("Courier Contact Info") {
                    CourierEdit(id: courier.id, storeId: storeId)
                }
                
                NavigationLink("Finished Orders") {
                    CourierFinishedOrders(courier: courier)
                }
                
                NavigationLink("Provider Integration") {
                    ProviderIntegrationView(courierId: courier.id)
                }
                
                NavigationLink("Reports") {
                    CourierReports(courier: courier)
                }
                
                /*NavigationLink("Failed Orders Sheet") {
                    EmptyView()
                }*/
            }
        }
        .navigationTitle("Courier Settings")
    }
}
