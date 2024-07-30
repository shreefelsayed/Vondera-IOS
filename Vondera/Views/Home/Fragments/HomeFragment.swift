import SwiftUI
import LineChartView
import FirebaseFirestore

struct StoreToolbar : View {
    @ObservedObject var user = UserInformation.shared
    @State var notificationCount = 0
    
    var body: some View {
        HStack {
            if let myUser = user.getUser() {
                NavigationLink(destination: Dashboard(store: myUser.store!)) {
                    IconAndName(myUser: myUser)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: notificationCount > 0 ? "bell.badge" :"bell")
                        .font(.title2)
                        
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
            // MARK : TOOLBAR
            StoreToolbar()
            
            if let myUser = myUser.getUser() {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        if let warning = myUser.store?.planWarning() {
                            HStack {
                                Spacer()
                                
                                Text(warning)
                                    .bold()
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                            }
                            .padding()
                            .background(.red.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // MARK : USER HEADER
                        UserHomeHeader()
                        
                        Spacer().frame(height: 20)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            // MARK : STEPS VIEW
                            if !(myUser.store?.finishedSteps() ?? true){
                                StoreStepsView()
                            }
                            
                            // MARK : Tip Of the day
                            if let tip = viewModel.tip {
                                TipCard(tip: tip)
                            }
                            
                            // MARK : Statics Cards
                            if !viewModel.storeStatics.isEmpty {
                                HomeReports(reportsDays: $viewModel.staticsDays, reports: viewModel.storeStatics)
                            }
 
                            // MARK : TOP SELLING AREAS
                            TopSellingAreas(list: viewModel.topAreas)
                            
                        }
                    }
                }
                .isHidden(viewModel.isLoading)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .overlay(alignment: .center) {
            ProgressView().isHidden(!viewModel.isLoading)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

#Preview {
    StoreToolbar()
}
