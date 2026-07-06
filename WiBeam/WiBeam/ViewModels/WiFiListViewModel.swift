import Foundation
import CoreData
import Combine
import SwiftUI

@MainActor
final class WiFiListViewModel: ObservableObject {
    @Published var wifiNetworks: [WiFiNetworkEntity] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var purchaseManager: PurchaseManager

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    var filteredNetworks: [WiFiNetworkEntity] {
        if searchText.isEmpty {
            return wifiNetworks
        }
        return wifiNetworks.filter {
            ($0.ssid ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.note ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var favorites: [WiFiNetworkEntity] {
        wifiNetworks.filter { $0.isFavorite }
    }

    init(context: NSManagedObjectContext? = nil,
         purchaseManager: PurchaseManager? = nil) {
        self.context = context ?? CoreDataStack.shared.viewContext
        self.purchaseManager = purchaseManager ?? .shared
        fetchNetworks()
    }

    func fetchNetworks() {
        isLoading = true
        let request = WiFiNetworkEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "isFavorite", ascending: false),
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            wifiNetworks = try context.fetch(request)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func delete(_ network: WiFiNetworkEntity) {
        do {
            try KeychainService.delete(account: network.keychainAccount)
        } catch {
            self.error = error.localizedDescription
        }

        context.delete(network)
        CoreDataStack.shared.save()
        fetchNetworks()
    }

    func toggleFavorite(_ network: WiFiNetworkEntity) {
        network.isFavorite.toggle()
        network.updatedAt = Date()
        CoreDataStack.shared.save()
        fetchNetworks()
    }

    func incrementShareCount(for network: WiFiNetworkEntity) {
        network.shareCount += 1
        network.lastSharedAt = Date()
        CoreDataStack.shared.save()
    }

    func canAddMoreNetworks() -> Bool {
        if purchaseManager.isPro { return true }
        return wifiNetworks.count < 3
    }

    func setLastSelectedWiFi(_ uuid: UUID) {
        AppGroupConfig.userDefaults?.set(uuid.uuidString, forKey: AppGroupConfig.lastWiFiUUIDKey)
        AppSettings.lastSelectedWiFiUUID = uuid.uuidString
    }

    func getLastSelectedWiFi() -> WiFiNetworkEntity? {
        if let uuidString = AppGroupConfig.userDefaults?.string(forKey: AppGroupConfig.lastWiFiUUIDKey),
           let uuid = UUID(uuidString: uuidString) {
            return wifiNetworks.first { $0.id == uuid }
        }
        return wifiNetworks.first
    }
}
