import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    private init() {
        let modelURL = Bundle.main.url(forResource: "WiBeam", withExtension: "momd")
        let model = NSManagedObjectModel(contentsOf: modelURL ?? Bundle.main.url(forResource: "WiBeam", withExtension: "mom")!)

        if let model {
            container = NSPersistentContainer(name: "WiBeam", managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: "WiBeam")
        }

        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

        if AppGroupConfig.userDefaults != nil {
            let storeURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: AppGroupConfig.identifier)?
                .appendingPathComponent("WiBeam.sqlite")
            if let storeURL {
                description?.url = storeURL
            }
        }

        container.loadPersistentStores { _, error in
            if let error {
                print("CoreData store load error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }

    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        save()
    }
}
