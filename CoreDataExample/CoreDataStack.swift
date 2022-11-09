//
//  CoreDataStack.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 5/6/22.
//

import CoreData

class CoreDataStack {
  
  let container: NSPersistentCloudKitContainer
  let mainContext: NSManagedObjectContext
  
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
    
    container = NSPersistentCloudKitContainer(name: modelName)
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    mainContext = container.viewContext
    mainContext.automaticallyMergesChangesFromParent = true
  }
  
  func saveContext () {
    guard mainContext.hasChanges else { return }
    
    do {
      try mainContext.save()
    } catch let error as NSError {
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
  }
}
