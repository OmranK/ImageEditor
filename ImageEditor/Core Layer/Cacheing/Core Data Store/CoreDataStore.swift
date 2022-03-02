//
//  CoreDataFeedStore.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import CoreData

public final class CoreDataStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}
//
//public final class CoreDataFeedStore: FeedStore {
//
//    private let persistentContainer: NSPersistentContainer
//    private let context: NSManagedObjectContext
//
//    public init(storeURL: URL, bundle: Bundle = .main) throws {
//        persistentContainer = try NSPersistentContainer.load(modelName: "FeedDataStore", url: storeURL, in: bundle)
//        context = persistentContainer.newBackgroundContext()
//    }
//
//    public func insert(_ feed: [LocalImageData], timestamp: Date, completion: @escaping InsertionCompletion) {
//        context.perform { [context] in
//            completion(Result {
//                let managedCache = try ManagedCache.newUniqueInstance(in: context)
//                managedCache.timestamp = timestamp
//                managedCache.feed = managedCache.managedImageFeed(from: feed, in: context)
//                try context.save()
//            })
//        }
//    }
//
//    public func retrieve(completion: @escaping RetrievalCompletion) {
//        context.perform { [context] in
//            completion(Result {
//                try ManagedCache.find(in: context).map {
//                    return CachedFeedData(feed: $0.localFeed, timestamp: $0.timestamp)
//                }
//            })
//        }
//    }
//
//    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
//        context.perform { [context] in
//            completion(Result {
//                try ManagedCache.find(in: context).map(context.delete).map(context.save)
//            })
//        }
//    }
//
//}
