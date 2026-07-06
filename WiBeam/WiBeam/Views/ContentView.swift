import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = WiFiListViewModel()
    @State private var showingAddSheet = false
    @State private var showingQRSheet = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingNetwork: WiFiNetworkEntity?
    @State private var selectedNetwork: WiFiNetworkEntity?
    @State private var networkToDelete: WiFiNetworkEntity?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.wifiNetworks.isEmpty {
                    EmptyStateView(onAddTapped: {
                        if viewModel.canAddMoreNetworks() {
                            editingNetwork = nil
                            showingAddSheet = true
                        } else {
                            showingPaywall = true
                        }
                    })
                } else {
                    wifiListView
                }
            }
            .navigationTitle("WiBeam")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Settings")
                }

                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.wifiNetworks.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWiFiView(editing: editingNetwork) {
                    viewModel.fetchNetworks()
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(viewModel.purchaseManager)
            }
            .sheet(isPresented: $showingQRSheet) {
                if let selectedNetwork {
                    QRDisplayView(network: selectedNetwork)
                        .environmentObject(viewModel.purchaseManager)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(viewModel.purchaseManager)
            }
            .alert("Delete WiFi?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let networkToDelete {
                        viewModel.delete(networkToDelete)
                    }
                }
            } message: {
                Text("This will permanently remove the WiFi network and its password. This action cannot be undone.")
            }
        }
        .tint(AppTheme.primary)
        .onAppear {
            viewModel.fetchNetworks()
        }
    }

    private var wifiListView: some View {
        VStack(spacing: 0) {
            if !viewModel.favorites.isEmpty || !viewModel.searchText.isEmpty {
                searchBar
                    .padding(.horizontal, AppTheme.standardSpacing)
                    .padding(.bottom, 8)
            }

            List {
                if viewModel.searchText.isEmpty && !viewModel.favorites.isEmpty {
                    Section("Favorites") {
                        ForEach(viewModel.favorites, id: \.objectID) { network in
                            wifiCardRow(network)
                        }
                    }
                }

                Section(viewModel.searchText.isEmpty ? (viewModel.favorites.isEmpty ? "All Networks" : "Others") : "Search Results") {
                    if viewModel.searchText.isEmpty {
                        ForEach(viewModel.filteredNetworks.filter { !$0.isFavorite }, id: \.objectID) { network in
                            wifiCardRow(network)
                        }
                    } else {
                        ForEach(viewModel.filteredNetworks, id: \.objectID) { network in
                            wifiCardRow(network)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .refreshable {
                viewModel.fetchNetworks()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
                .padding(20)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search WiFi networks", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var addButton: some View {
        Button {
            if viewModel.canAddMoreNetworks() {
                editingNetwork = nil
                showingAddSheet = true
            } else {
                showingPaywall = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.primary)
                .clipShape(Circle())
                .shadow(color: AppTheme.primary.opacity(0.4), radius: 10, y: 5)
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel("Add WiFi")
    }

    @ViewBuilder
    private func wifiCardRow(_ network: WiFiNetworkEntity) -> some View {
        WiFiCard(
            network: network,
            onTap: {
                selectedNetwork = network
                showingQRSheet = true
                viewModel.setLastSelectedWiFi(network.id ?? UUID())
            },
            onEdit: {
                editingNetwork = network
                showingAddSheet = true
            },
            onDelete: {
                networkToDelete = network
                showingDeleteConfirmation = true
            },
            onToggleFavorite: {
                viewModel.toggleFavorite(network)
            }
        )
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
}
