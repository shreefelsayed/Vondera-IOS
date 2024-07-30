//
//  AccessManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 12/07/2024.
//

import Foundation
import SwiftUI

enum AccessFeature {
    case orderRead
    case orderWrite
    case orderAdd
    case orderDelete
    
    // Expenses
    case expensesRead
    case expensesAdd
    case expensesRemove
    case expensesExport
    
    // Statistics
    case statisticsRead
    case statisticsExport
    
    // Customers Data
    case customersDataRead
    case customersDataExport
    
    // Access Couriers
    case accessCouriersAdd
    case accessCouriersAssign
    case accessCouriersRemove
    
    // Warehouse
    case warehouseRead
    case warehouseAdd
    case warehouseExport
    
    // Products
    case productsRead
    case productsWrite
    case productsUpdate
    case productsDelete
    
    // Categories
    case categoriesRead
    case categoriesWrite
    case categoriesUpdate
    case categoriesDelete
    
    // Team Members
    case teamMembersRead
    case teamMembersAdd
    case teamMembersUpdate
    case teamMembersDelete
    
    // VPay
    case vPayRead
    case vPayPayouts
    
    // Complaints
    case complaintsRead
    case complaintsAdd
    case complaintsUpdate
    
    // Subscription
    case subscription
    case websiteCustomization
    case storeSettings
}

extension AccessFeature {
    func canAccess() -> Bool {
        guard let user = UserInformation.shared.user else { return false }
        if user.accountType == "Owner" { return true }
        guard let accessLevels = user.accessLevels else { return false }
        
        switch self {
        case .orderRead:
            return accessLevels.orders.read
        case .orderWrite:
            return accessLevels.orders.write
        case .orderAdd:
            return accessLevels.orders.write
        case .orderDelete:
            return accessLevels.orders.delete
        case .expensesRead:
            return accessLevels.expenses.read
        case .expensesAdd:
            return accessLevels.expenses.add
        case .expensesRemove:
            return accessLevels.expenses.remove
        case .expensesExport:
            return accessLevels.expenses.export
        case .statisticsRead:
            return accessLevels.statistics.read
        case .statisticsExport:
            return accessLevels.statistics.export
        case .customersDataRead:
            return accessLevels.customersData.read
        case .customersDataExport:
            return accessLevels.customersData.export
        case .accessCouriersAdd:
            return accessLevels.accessCouriers.add
        case .accessCouriersAssign:
            return accessLevels.accessCouriers.assign
        case .accessCouriersRemove:
            return accessLevels.accessCouriers.remove
        case .warehouseRead:
            return accessLevels.warehouse.read
        case .warehouseAdd:
            return accessLevels.warehouse.add
        case .warehouseExport:
            return accessLevels.warehouse.export
        case .productsRead:
            return accessLevels.products.read
        case .productsWrite:
            return accessLevels.products.write
        case .productsUpdate:
            return accessLevels.products.update
        case .productsDelete:
            return accessLevels.products.delete
        case .categoriesRead:
            return accessLevels.categories.read
        case .categoriesWrite:
            return accessLevels.categories.write
        case .categoriesUpdate:
            return accessLevels.categories.update
        case .categoriesDelete:
            return accessLevels.categories.delete
        case .teamMembersRead:
            return accessLevels.teamMembers.read
        case .teamMembersAdd:
            return accessLevels.teamMembers.add
        case .teamMembersUpdate:
            return accessLevels.teamMembers.update
        case .teamMembersDelete:
            return accessLevels.teamMembers.delete
        case .vPayRead:
            return accessLevels.vPay.read
        case .vPayPayouts:
            return accessLevels.vPay.payouts
        case .complaintsRead:
            return accessLevels.complaints.read
        case .complaintsAdd:
            return accessLevels.complaints.add
        case .complaintsUpdate:
            return accessLevels.complaints.update
        case .subscription:
            return accessLevels.subscription
        case .websiteCustomization:
            return accessLevels.websiteCustomization
        case .storeSettings:
            return accessLevels.storeSettings
        }
    }
    
    func getTitle() -> LocalizedStringKey {
        switch self {
        case .orderRead, .orderWrite, .orderAdd, .orderDelete:
            return "Order Management"
        case .expensesRead, .expensesAdd, .expensesRemove, .expensesExport:
            return "Expenses Management"
        case .statisticsRead, .statisticsExport:
            return "Statistics Access"
        case .customersDataRead, .customersDataExport:
            return "Customer Data Access"
        case .accessCouriersAdd, .accessCouriersAssign, .accessCouriersRemove:
            return "Courier Management"
        case .warehouseRead, .warehouseAdd, .warehouseExport:
            return "Warehouse Management"
        case .productsRead, .productsWrite, .productsUpdate, .productsDelete:
            return "Product Management"
        case .categoriesRead, .categoriesWrite, .categoriesUpdate, .categoriesDelete:
            return "Category Management"
        case .teamMembersRead, .teamMembersAdd, .teamMembersUpdate, .teamMembersDelete:
            return "Team Members Management"
        case .vPayRead, .vPayPayouts:
            return "VPay Access"
        case .complaintsRead, .complaintsAdd, .complaintsUpdate:
            return "Complaints Management"
        case .subscription:
            return "Subscription Access"
        case .websiteCustomization:
            return "Website Customization"
        case .storeSettings:
            return "Store Settings"
        }
    }
    
    func getDesc() -> LocalizedStringKey {
        switch self {
        case .orderRead, .orderWrite, .orderAdd, .orderDelete:
            return "You do not have access to manage orders. Please contact your administrator for more information."
        case .expensesRead, .expensesAdd, .expensesRemove, .expensesExport:
            return "You do not have access to manage expenses. Please contact your administrator for more information."
        case .statisticsRead, .statisticsExport:
            return "You do not have access to view or export statistics. Please contact your administrator for more information."
        case .customersDataRead, .customersDataExport:
            return "You do not have access to view or export customer data. Please contact your administrator for more information."
        case .accessCouriersAdd, .accessCouriersAssign, .accessCouriersRemove:
            return "You do not have access to manage couriers. Please contact your administrator for more information."
        case .warehouseRead, .warehouseAdd, .warehouseExport:
            return "You do not have access to manage the warehouse. Please contact your administrator for more information."
        case .productsRead, .productsWrite, .productsUpdate, .productsDelete:
            return "You do not have access to manage products. Please contact your administrator for more information."
        case .categoriesRead, .categoriesWrite, .categoriesUpdate, .categoriesDelete:
            return "You do not have access to manage categories. Please contact your administrator for more information."
        case .teamMembersRead, .teamMembersAdd, .teamMembersUpdate, .teamMembersDelete:
            return "You do not have access to manage team members. Please contact your administrator for more information."
        case .vPayRead, .vPayPayouts:
            return "You do not have access to VPay features. Please contact your administrator for more information."
        case .complaintsRead, .complaintsAdd, .complaintsUpdate:
            return "You do not have access to manage complaints. Please contact your administrator for more information."
        case .subscription:
            return "You do not have access to subscription features. Please contact your administrator for more information."
        case .websiteCustomization:
            return "You do not have access to customize the website. Please contact your administrator for more information."
        case .storeSettings:
            return "You do not have access to manage store settings. Please contact your administrator for more information."
        }
    }
}

extension View {
    func withAccessLevel(accessKey:AccessFeature, presentation:Binding<PresentationMode>) -> some View {
        return self
            .fullScreenCover(isPresented: .constant(accessKey.canAccess() == false)) {
                VStack(spacing: 24) {
                    // Close Button
                    HStack {
                        Spacer()
                        
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.gray)
                            .clipShape(Circle())
                            .onTapGesture {
                                presentation.wrappedValue.dismiss()
                            }
                    }
                    
                    Spacer()
                    // IMAGE
                    Image(.imgAccessDenied)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(46)
                    
                    Spacer()
                    
                    // Title
                    Text(accessKey.getTitle())
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                    
                    
                    Text(accessKey.getDesc())
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Close")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.black)
                            .padding()
                            .background(.white)
                            .cornerRadius(32)
                            .padding()
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.black.ignoresSafeArea())
            }
    }
}
