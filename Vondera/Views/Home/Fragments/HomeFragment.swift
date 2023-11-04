import SwiftUI
import NetworkImage
import LineChartView
import FirebaseFirestore

struct StoreToolbar : View {
    @ObservedObject var user = UserInformation.shared
    @State var notificationCount = 0
    
    var body: some View {
        HStack {
            if let myUser = user.user {
                if myUser.canAccessAdmin {
                    NavigationLink(destination: Dashboard(store: myUser.store!)) {
                        IconAndName(myUser: myUser)
                    }
                    .buttonStyle(.plain)
                } else {
                    IconAndName(myUser: myUser)
                }
                
                Spacer()
                
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: notificationCount > 0 ? "bell.badge" :"bell")
                }
            }
        }
        .font(.title)
        .bold()
        .task {
            if let id = user.user?.id {
                NotificationsDao(userId: id).notificationListener().addSnapshotListener { query, error in
                    if let query = query {
                        self.notificationCount = query.count
                    }
                }
            }
        }
    }
}

struct HomeFragment: View {
    @StateObject var myUser = UserInformation.shared
    @StateObject var viewModel = HomeFragmentViewModel()
    
    var body: some View {
        VStack {
            if let myUser = myUser.user {
                StoreToolbar()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        // MARK : USER HEADER
                        UserHomeHeader()
                        
                        Spacer().frame(height: 20)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            // MARK : STEPS VIEW
                            if !(myUser.store?.finishedSteps() ?? true){
                                StoreStepsView()
                            }
                            
                            // MARK : Orders count
                            if myUser.store?.ordersCountObj != nil {
                                StoreOrdersCount()
                            }
                            
                            // MARK : Tip Of the day
                            if viewModel.tip != nil {
                                TipCard(tip: viewModel.tip!)
                            }
                            
                            if !viewModel.storeStatics.isEmpty && myUser.canAccessAdmin {
                                HomeReports(reportsDays: $viewModel.staticsDays, reports: viewModel.storeStatics)
                            }
 
                            if viewModel.topAreas.count > 0 && myUser.canAccessAdmin {
                                TopSellingAreas(list: viewModel.topAreas)
                            }
                            
                        }
                    }
                }
                .isHidden(viewModel.isLoading)
            }
        }
        .padding()
        .overlay(alignment: .center) {
            ProgressView().isHidden(!viewModel.isLoading)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

#Preview {
    HomeFragment()
}
