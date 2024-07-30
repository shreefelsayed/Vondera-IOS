import SwiftUI
import FirebaseFirestore

class VonderaTransactionsScreenVM: ObservableObject {
    @Published var isLoading = false
    @Published var isFetching = false
    @Published var items = [AdminTransaction]()
    
    var lastDoc: DocumentSnapshot? = nil
    var hasMore = true
    
    init() {
        Task {
            await fetch()
        }
    }
    
    func refresh() async {
        isLoading = false
        isFetching = false
        items.removeAll()
        lastDoc = nil
        hasMore = true
        await fetch()
    }
    
    func fetch() async {
        guard hasMore, !isLoading, !isFetching else { return }
        
        isLoading = lastDoc == nil
        isFetching = lastDoc != nil
        
        do {
            let result = try await AdminTransDao().getTransactions(lastDoc: lastDoc)
            DispatchQueue.main.async {
                self.hasMore = !result.0.isEmpty
                self.items.append(contentsOf: result.0)
                self.lastDoc = result.1
                self.isLoading = false
                self.isFetching = false
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.isLoading = false
                self.isFetching = false
            }
        }
    }
    
    func groupedByDate() -> [Date: [AdminTransaction]] {
        let grouped = Dictionary(grouping: items) { item in
            Calendar.current.startOfDay(for: item.date)
        }
        return grouped
    }
}

struct VonderaTransactionsScreen: View {
    @StateObject private var viewModel = VonderaTransactionsScreenVM()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        List {
            let groupedItems = viewModel.groupedByDate()
            let sortedDates = groupedItems.keys.sorted(by: >)

            
            ForEach(sortedDates, id: \.self) { date in
                Section {
                    if let transactions = groupedItems[date] {
                        ForEach(transactions, id: \.id) { trans in
                            VStack {
                                NavigationLink(destination: TransactionDetail(transaction: trans)) {
                                    HStack {
                                        Image(trans.getImage())
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                            .scaledToFit()
                                        
                                        VStack(alignment: .leading) {
                                            Text("\(trans.amount.toString()) EGP")
                                                .font(.headline)
                                                .bold()
                                            
                                            HStack {
                                                Text("\((trans.count ?? 0) <= 1 ? "Subscribed" : "Renew")")
                                                    .bold()
                                                    .foregroundStyle((trans.count ?? 0) <= 1 ? .green : .yellow)
                                                
                                                Text("to the \(trans.planId ?? "") Plan")
                                            }
                                            .font(.body)
        
                                            HStack {
                                                Text("@\(trans.mId ?? "None")")
                                                    .bold()
                                                
                                                
                                                
                                                Spacer()
                                                
                                                Text("\(trans.date.asFormatedString("dd MMM, h a"))")
                                            }
                                            
                                            Text("By : \(trans.method ?? "Admin")")
                                        }
                                        
                                    }
                                    
                                }
                                
                                if trans.id == viewModel.items.last?.id && viewModel.hasMore && sortedDates.last ==  date {
                                    ProgressView()
                                        .onAppear {
                                            Task { await viewModel.fetch() }
                                        }
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("\(date, formatter: dateFormatter)")
                        
                        Spacer()
                        
                        if let transactions = groupedItems[date] {
                            let total = transactions.map({$0.amount}).reduce(0, +).toString()
                            Text("Total : \(total) EGP - \(transactions.count) items")
                                .font(.caption)
                        }
                    }
                } footer: {
                    HStack {
                        if let transactions = groupedItems[date] {
                            let new = transactions.filter({($0.count ?? 0) <= 1})
                            let renew = transactions.filter({($0.count ?? 0) > 1})
                            
                            if !new.isEmpty {
                                Text("New \(new.count) - \(new.map({$0.amount}).reduce(0, +).toString()) EGP")
                                    .foregroundStyle(.green)
                            }
                            
                            Spacer()

                            if !renew.isEmpty {
                                Text("Renew : \(renew.count) - \(renew.map({$0.amount}).reduce(0, +).toString()) EGP")
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }
                
                
            }
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        )
        .navigationTitle("Transactions")
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    VonderaTransactionsScreen()
}
