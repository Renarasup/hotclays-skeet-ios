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
    
    /// The maximum number of rounds allowed on a `Sheet`.
    static let maxNumberOfRounds = 8
    
    /// The maximum field number allowed on a `Sheet`.
    static let maxFieldNumber = 10000
    
    // The maximum length (number of characters) of notes allowed on a `Sheet`.
    static let maxLengthOfNotes = 300

    @discardableResult
    static func insert(date: Date, event: String, range: String, field: Int, notes: String) -> Sheet {
        let sheet = NSEntityDescription.insertNewObject(forEntityName: "Sheet", into: CoreDataManager.shared.managedObjectContext) as! Sheet
        
        sheet.date = date as NSDate
        sheet.event = event
        sheet.range = range
        sheet.field = Int16(field)
        sheet.notes = notes
        
        CoreDataManager.shared.saveContext()
        
        return sheet
    }
    
    static func get(date: Date, event: String, range: String, field: Int) -> Sheet? {
        let context = CoreDataManager.shared.managedObjectContext
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@ && event == %@ && range == %@ && field == %d",
                                        date as NSDate, event, range, field)
        var sheet: Sheet?
        context.performAndWait {
            sheet = (try? context.fetch(request))?.first
        }
        return sheet
    }

    static func getOrInsert(date: Date, event: String, range: String, field: Int, notes: String) -> Sheet {
        let sheet = Sheet.get(date: date, event: event, range: range, field: field)
        
        // Update notes if they don't match. All other fields match because they're specified in the predicate.
        let context = CoreDataManager.shared.managedObjectContext
        if let existingNotes = sheet?.notes, existingNotes != notes {
            context.performAndWait {
                sheet!.notes = notes
                try? context.save()
            }
        }
        
        return sheet ?? Sheet.insert(date: date, event: event, range: range, field: field, notes: notes)
    }

    func addRound(_ round: Round) {
        self.managedObjectContext?.performAndWait {
            self.addToRounds(round)
        }
        try? self.managedObjectContext?.save()
    }
    
}
