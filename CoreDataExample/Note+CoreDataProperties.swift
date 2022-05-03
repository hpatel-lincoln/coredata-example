//
//  Note+CoreDataProperties.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 5/3/22.
//
//

import Foundation
import CoreData

extension Note {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
    return NSFetchRequest<Note>(entityName: "Note")
  }
  
  @NSManaged public var text: String
  @NSManaged public var lastUpdated: Date?
}

extension Note : Identifiable {
  
}
