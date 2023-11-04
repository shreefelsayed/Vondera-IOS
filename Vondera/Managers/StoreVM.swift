import Foundation
import StoreKit
import FirebaseAuth

//alias
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo //The Product.SubscriptionInfo.RenewalInfo provides information about the next subscription renewal period.
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState // the renewal states of auto-renewable subscriptions.


class StoreVM: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    @Published var msg:String?
    @Published var isBuying = false
    
    private var productIds: [String] = []
    
    var updateListenerTask : Task<Void, Error>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await getProductsId()
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func getProductsId() async {
        let items = try! await PlanDao().getPaid();
        
        productIds = items.map { plan in
            plan.id
        }
    }
    
    
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    // deliver products to the user
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("transaction failed verification")
                }
            }
        }
    }
    
    
    
    // Request the products
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (hardcoded)
            subscriptions = try await Product.products(for: productIds)
            print(subscriptions)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    // purchase the product
    func purchase(planId: String) async throws -> Bool {
        let item = subscriptions.first(where: {$0.id == planId})
        
        guard let product = item else {
            msg = "Can't find the plan"
            return false
        }
        
        isBuying = true
        
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            //The transaction is verified. Deliver content to the user.
            
            
            //Always finish a transaction.
            await transaction.finish()
            msg = "Payment made"
            isBuying = false
            return await subscribeToPlan(planId)
        case .userCancelled, .pending:
            msg = "Purchase was cancelled"
            isBuying = false
            return false
        default:
            isBuying = false
            return false
        }
        
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: {$0.id == transaction.productID}) {
                        purchasedSubscriptions.append(subscription)
                    }
                    
                    //_ = await subscribeToPlan(transaction.productID)
                default:
                    break
                }
                //Always finish a transaction.
                await transaction.finish()
            } catch {
                print("failed updating products")
            }
        }
    }
    
    func subscribeToPlan(_ id:String) async -> Bool  {
        guard let uId = Auth.auth().currentUser?.uid else {
            print("User isn't logged in")
            msg = "Can't access user data, reopen the app"
            return false
        }
        
        isBuying = true
        
        let data = [
            "storeId" : uId,
            "planId" : id,
            "onEnd" : "Unsubscribe"
        ]
        
        do {
            let result = try await FirebaseFunctionCaller().callFunction(functionName: "paymob-paymentMade", data: data)
            if let error = result.data as? [String: Any], let errorMessage = error["error"] as? String {
                print("Function call error: \(errorMessage)")
                msg = "Error happened \(errorMessage)"
                isBuying = false
                return false
            } else {
                msg = "Subscribtion renewed"
                isBuying = false
                return true
            }
        } catch {
            print("Error happened \(error.localizedDescription)")
            msg = "Error \(error.localizedDescription)"
            isBuying = false
            return false
        }
    }
    
}


public enum StoreError: Error {
    case failedVerification
}
