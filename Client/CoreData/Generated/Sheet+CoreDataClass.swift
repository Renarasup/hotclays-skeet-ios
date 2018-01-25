//
//  Sheet+CoreDataClass.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Sheet)
public class Sheet: NSManagedObject {
    
    /// Number of characters in a sheet ID.
    static let idLength = 6
    
    /// The maximum number of rounds allowed on a `Sheet`.
    static let maxNumberOfRounds = 8
    
    /// The maximum field number allowed on a `Sheet`.
    static let maxFieldNumber = 10000
    
    // The maximum length (number of characters) of notes allowed on a `Sheet`.
    static let maxLengthOfNotes = 300

    /// Get an array of this sheet's `Round`s, sorted by increasing round number.
    var sortedRounds: [Round]? {
        let sortByRoundNumber = NSSortDescriptor(key: "roundNumber", ascending: true)
        return self.rounds?.sortedArray(using: [sortByRoundNumber]) as? [Round]
    }
    
    /// True if this sheet has any notes, false otherwise.
    var hasNotes: Bool {
        return (self.notes?.count ?? 0) > 0
    }
    
    @discardableResult
    static func insert(date: Date, event: String, range: String, field: String?, notes: String?) -> Sheet {
        let sheet = NSEntityDescription.insertNewObject(forEntityName: "Sheet", into: CoreDataManager.shared.managedObjectContext) as! Sheet
        
        sheet.id = String.random(ofLength: Sheet.idLength)
        sheet.date = date as NSDate
        sheet.event = event
        sheet.range = range
        sheet.field = field
        sheet.notes = notes
        
        CoreDataManager.shared.saveContext()
        
        return sheet
    }
    
    static func get(_ id: String) -> Sheet? {
        let context = CoreDataManager.shared.managedObjectContext
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        var sheet: Sheet?
        context.performAndWait {
            sheet = (try? context.fetch(request))?.first
        }
        return sheet
    }

    func addRound(_ round: Round) {
        self.managedObjectContext?.performAndWait {
            self.addToRounds(round)
        }
        try? self.managedObjectContext?.save()
    }
    
}
