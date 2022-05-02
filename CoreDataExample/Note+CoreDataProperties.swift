//
//  Note+CoreDataProperties.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/30/22.
//
//

import Foundation
import CoreData

extension Note {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
    return NSFetchRequest<Note>(entityName: "Note")
  }
  
  @NSManaged public var text: String
}

extension Note : Identifiable {
  
}
