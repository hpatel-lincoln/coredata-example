//
//  CoreDataStack.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 5/6/22.
//

import CoreData

class CoreDataStack {
  
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  lazy var container: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: modelName)
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  lazy var mainContext: NSManagedObjectContext = {
    return container.viewContext
  }()
  
  func saveContext () {
    guard mainContext.hasChanges else { return }
    
    do {
      try mainContext.save()
    } catch let error as NSError {
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
  }
}
