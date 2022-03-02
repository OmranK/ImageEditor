//
//  ManagedImageData.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import CoreData

@objc(ManagedImageData)
internal class ManagedImageData: NSManagedObject {
    @NSManaged var url: URL
    @NSManaged var createdDate: Date
    @NSManaged var updatedDate: Date
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedImageData {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedImageData? {
        let request = NSFetchRequest<ManagedImageData>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedImageData.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    var local: LocalImageData {
        return LocalImageData(url: url, created: createdDate, updated: updatedDate)
    }
}
