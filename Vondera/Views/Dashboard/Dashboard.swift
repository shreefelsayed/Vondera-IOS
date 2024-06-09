import SwiftUI

struct Dashboard: View {
    var store:Store
    
    var body: some View {
        List() {
            Section("Store Users") {
                //
                NavigationLink {
                    StoreEmployees()
                } label: {
                    Label {
                        Text("Team members")
                    } icon: {
                        Image(.btnEmployees)
                    }
                }

                NavigationLink {
                    CustomersScreen()
                } label: {
                    Label {
                        Text("Customers")
                    } icon: {
                        Image(.btnCustomers)
                    }
                }
                
                NavigationLink {
                    StoreCouriers()
                } label: {
                    Label {
                        Text("Couriers")
                    } icon: {
                        Image(.btnShipping)
                    }
                }
            }
        
            Section() {
                NavigationLink {
                    StoreReport()
                } label: {
                    Label {
                        Text("Reports")
                    } icon: {
                        Image(.btnReports)
                    }
                }
                
                NavigationLink {
                    StoreExpanses()
                } label: {
                    Label {
                        Text("Expanses")
                    } icon: {
                        Image(.btnExpanses)
                    }
                }
                
                NavigationLink {
                    StoreComplaints()
                } label: {
                    Label {
                        Text("Complaints")
                    } icon: {
                        Image(.btnComplaints)
                    }
                }

                
                //TODO : Create order sheet screen
                //NavigationLink("Create Orders Sheet", destination: EmptyView())
                
                // TODO : Complaints Screen
                //NavigationLink("Create Orders Sheet", destination: EmptyView())
            }
        }
        .navigationTitle("Dashboard")
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Dashboard(store: Store.example())
        }
    }
}
