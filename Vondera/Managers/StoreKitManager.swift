import Foundation
import SwiftUI
import StoreKit
import FirebaseAuth

typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState


class StoreKitManager: ObservableObject {
        
    @Published var msg:String?
    @Published var isBuying = false
    
    private var productIds: [String] = []
    @Published private(set) var appStoreProducts: [Product] = []
    var updateListenerTask : Task<Void, Error>? = nil
    @Published private(set) var purchasedSubscriptions: [Product] = []

    init() {
        Task {
            await getProductsId()
            await requestProducts()
            await updateCustomerProductStatus()
            updateListenerTask = listenForTransactions()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: Map our server products to Apple Products
    func getProductsId() async {
        self.productIds.removeAll()
        if let items = try? await PlanDao().getPaid() {
            for plan in items {
                self.productIds.append("\(plan.id).month")
                self.productIds.append("\(plan.id).quartar")
                self.productIds.append("\(plan.id).year")
            }
        } else {
            msg = "Couldn't get the plans, check your network"
        }
    }
    
    ///MARK: Request the products from App Store
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (hardcoded)
            appStoreProducts = try await Product.products(for: productIds)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    /// MARK :  purchase the product
    func purchase(planId: String, subPlanId:String) async throws {
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        let item = appStoreProducts.first(where: {$0.id == "\(planId).\(subPlanId)"})
        
        guard let product = item else {
            msg = "Can't find the plan"
            return
        }
        
        isBuying = true
        let uuid = UUID(uuidString: storeId) ?? UUID()
        let result = try await product.purchase(options: [.appAccountToken(uuid)])
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            let trx = transaction.originalID
            let amount = NSDecimalNumber(decimal: product.price).intValue
            isBuying = false
            await subscribeToPlan(planId: planId, subPlanId: subPlanId, trx: "\(trx)", amount: amount)
        case .userCancelled, .pending:
            isBuying = false
        default:
            isBuying = false
        }
        
    }
    
    /// MARK : This code is called once a promo code is made
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    let planId = transaction.productID.components(separatedBy: ".")[0]
                    let subPlanId = transaction.productID.components(separatedBy: ".")[1]
                    let trx = transaction.originalID
                    let amount = NSDecimalNumber(decimal: transaction.price ?? 0).intValue
                    
                    await self.subscribeToPlan(planId: planId, subPlanId: subPlanId, trx: "\(trx)", amount: amount)
                    //
                    print("A New Offer was made for amount \(amount)")
                    await transaction.finish()
                } catch {
                    print("transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                    // MARK : Check if user is subscribed to any plan
                case .autoRenewable:
                    if let subscription = appStoreProducts.first(where: {$0.id == transaction.productID}) {
                        purchasedSubscriptions.append(subscription)
                        print("This user is in \(subscription.id)")
                    }
                default:
                    break
                }
                //Always finish a transaction.
                await transaction.finish()
            } catch {
                print("Failed updating products")
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    
    // MARK : This code calls our api to subscribe to a plan
    func subscribeToPlan(planId:String, subPlanId:String, trx:String, amount:Int) async  {
        guard let store = UserInformation.shared.user?.store else {
            print("User isn't logged in")
            msg = "Can't access user data, reopen the app"
            return
        }
        
        isBuying = true

        let data:[String:Any] = [
            "merchantId" : store.merchantId,
            "planId" : planId,
            "discountCode" : "",
            "subPlan" : subPlanId,
            "paidAmount": amount,
            "method": "Apple",
            "record" : true,
            "trx": trx
        ]
        
        print("Data \(data)")
        
        do {
            let result = try await FirebaseFunctionCaller().callFunction(functionName: "subscribtions-subscribeToPlan", data: data)
            if let error = result.data as? [String: Any], let errorMessage = error["error"] as? String {
                print("Function call error: \(errorMessage)")
                msg = "Error happened \(errorMessage)"
                isBuying = false
            } else {
                msg = "Subscribtion renewed"
                isBuying = false
                DynamicNavigation.shared.navigate(to: AnyView(OnPaymentSuccess()))
            }
        } catch {
            print("Error happened \(error.localizedDescription)")
            msg = "Error \(error.localizedDescription)"
            isBuying = false
        }
    }
    
}


public enum StoreError: Error {
    case failedVerification
}
