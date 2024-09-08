import Foundation
import FirebaseFirestore
import Combine

class OrderSearchViewModel: ObservableObject {
    var storeId: String
    var ordersDao: OrdersDao
    
    @Published var result = [Order]()
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()

    init(storeId: String) {
        self.storeId = storeId
        self.ordersDao = OrdersDao(storeId: storeId)
        
        initSearch()
    }
    
    private func initSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                self?.searchOrder(newValue)
            }
            .store(in: &cancellables)
    }
    
    private func searchOrder(_ search: String) {
        guard !search.isBlank else {
            result.removeAll()
            return
        }
        
        Task {
            do {
                let indexBy = getIndex(search)
                let result = try await self.ordersDao.search(search: search, field: indexBy, lastSnapShot: nil)
                DispatchQueue.main.async {
                    self.result = result.0
                }
            } catch {
                print("Search failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func getIndex(_ value: String) -> String {
        if value.isPhoneNumber {
            return "phone"
        } else if value.isNumeric && !value.isPhoneNumber {
            return "id"
        }
        return "name"
    }
}
