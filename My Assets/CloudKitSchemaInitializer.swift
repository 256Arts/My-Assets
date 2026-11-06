#if DEBUG
import CoreData
import SwiftData

/// `-initializeCloudKitSchema` (run by `Scripts/cloudkit-init-schema`) creates every record type and
/// field in the Development CloudKit schema, then exits. It uses a throwaway store, so real data is
/// untouched. CloudKit otherwise only creates a field when a Development build saves a value in it.
enum CloudKitSchemaInitializer {
    static func runIfRequested(containerID: String, types: [any PersistentModel.Type]) {
        guard ProcessInfo.processInfo.arguments.contains("-initializeCloudKitSchema") else { return }
        guard let model = NSManagedObjectModel.makeManagedObjectModel(for: types) else {
            print("✗ Could not build a managed object model")
            exit(1)
        }
        let description = NSPersistentStoreDescription(url: .temporaryDirectory.appending(path: "\(UUID().uuidString).store"))
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerID)
        description.shouldAddStoreAsynchronously = false
        let container = NSPersistentCloudKitContainer(name: "CloudKitSchema", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                print("✗ Could not open the store: \(error)")
                exit(1)
            }
        }
        do {
            try container.initializeCloudKitSchema()
            print("✓ Development schema initialized for \(containerID)")
            exit(0)
        } catch {
            print("✗ \(error)")
            exit(1)
        }
    }
}
#endif
