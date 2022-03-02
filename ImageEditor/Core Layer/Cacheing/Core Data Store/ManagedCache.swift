//
//  ManagedCache.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}

extension ManagedCache {
    var localFeed: [LocalImageData] {
        return feed.compactMap { ($0 as? ManagedImageData)?.local}
    }
    
    func managedImageFeed(from localFeed: [LocalImageData], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { localImageData in
            let managedImageData = ManagedImageData(context: context)
            managedImageData.url = localImageData.url
            managedImageData.createdDate = localImageData.created
            managedImageData.updatedDate = localImageData.updated
            return managedImageData
        })
    }
}

