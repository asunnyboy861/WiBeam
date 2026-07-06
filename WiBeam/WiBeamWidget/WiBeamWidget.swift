import WidgetKit
import SwiftUI
import CoreData

struct WiBeamWidgetEntry: TimelineEntry {
    let date: Date
    let ssid: String?
    let security: String?
    let lastShared: Date?
    let isEmpty: Bool
}

struct WiBeamProvider: TimelineProvider {
    func placeholder(in context: Context) -> WiBeamWidgetEntry {
        WiBeamWidgetEntry(date: Date(), ssid: "My WiFi", security: "WPA2", lastShared: Date(), isEmpty: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (WiBeamWidgetEntry) -> Void) {
        let entry = fetchEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WiBeamWidgetEntry>) -> Void) {
        let entry = fetchEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 30)))
        completion(timeline)
    }

    private func fetchEntry() -> WiBeamWidgetEntry {
        guard let userDefaults = UserDefaults(suiteName: "group.com.zzoutuo.WiBeam"),
              let uuidString = userDefaults.string(forKey: "lastWiFiUUID"),
              let uuid = UUID(uuidString: uuidString) else {
            return WiBeamWidgetEntry(date: Date(), ssid: nil, security: nil, lastShared: nil, isEmpty: true)
        }

        let modelName = "WiBeam"
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            return WiBeamWidgetEntry(date: Date(), ssid: nil, security: nil, lastShared: nil, isEmpty: true)
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description = container.persistentStoreDescriptions.first
        if let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.zzoutuo.WiBeam")?
            .appendingPathComponent("WiBeam.sqlite") {
            description?.url = storeURL
        }

        var entry = WiBeamWidgetEntry(date: Date(), ssid: nil, security: nil, lastShared: nil, isEmpty: true)

        container.loadPersistentStores { _, _ in
            let context = container.viewContext
            let request = NSFetchRequest<NSManagedObject>(entityName: "WiFiNetwork")
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1

            if let network = try? context.fetch(request).first {
                entry = WiBeamWidgetEntry(
                    date: Date(),
                    ssid: network.value(forKey: "ssid") as? String,
                    security: network.value(forKey: "security") as? String,
                    lastShared: network.value(forKey: "lastSharedAt") as? Date,
                    isEmpty: false
                )
            }
        }

        return entry
    }
}

struct WiBeamWidgetEntryView: View {
    var entry: WiBeamWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            if entry.isEmpty {
                Image(systemName: "wifi")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("No WiFi")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "wifi")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(entry.ssid ?? "WiFi")
                    .font(.system(.caption, design: .rounded).bold())
                    .lineLimit(1)
                Image(systemName: "qrcode")
                    .font(.body)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var mediumView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "wifi")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                if entry.isEmpty {
                    Text("Add WiFi")
                        .font(.system(.headline, design: .rounded).bold())
                    Text("Open WiBeam to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(entry.ssid ?? "WiFi")
                        .font(.system(.headline, design: .rounded).bold())
                        .lineLimit(1)
                    if let security = entry.security {
                        Text(security)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let lastShared = entry.lastShared {
                        Text("Shared \(lastShared.formatted(.relative(presentation: .named)))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tap to display QR")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            Image(systemName: "qrcode")
                .font(.title)
                .foregroundColor(.blue)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct WiBeamWidget: Widget {
    let kind: String = "WiBeamWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WiBeamProvider()) { entry in
            WiBeamWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WiBeam Quick Access")
        .description("Tap to display your last-used WiFi QR code.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
