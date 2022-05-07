//
//  NotesViewController.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/28/22.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
  
  var coreDataStack: CoreDataStack!
  
  private var resultsController: NSFetchedResultsController<Note>!
  
  @IBOutlet private var notesTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Notes"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    notesTableView.delegate = self
    notesTableView.dataSource = self
    notesTableView.rowHeight = UITableView.automaticDimension
    notesTableView.estimatedRowHeight = 100
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh()
  }
  
  @IBAction private func didTapAdd(sender: UIBarButtonItem) {
    performSegue(withIdentifier: "AddNote", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "AddNote":
      guard
        let noteViewController = segue.destination as? NoteViewController
      else { fatalError("Storyboard not setup as expected") }
      
      let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      childContext.parent = coreDataStack.mainContext
      
      noteViewController.context = childContext
      noteViewController.delegate = self
    case "EditNote":
      guard
        let noteViewController = segue.destination as? NoteViewController,
        let indexPath = notesTableView.indexPathForSelectedRow
      else { fatalError("Storyboard not setup as expected") }
      
      let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      childContext.parent = coreDataStack.mainContext
      
      let note = resultsController.object(at: indexPath)
      let childNote = childContext.object(with: note.objectID) as? Note
      
      noteViewController.context = childContext
      noteViewController.note = childNote
      noteViewController.delegate = self
    default:
      break
    }
  }
  
  private func refresh() {
    let request = Note.fetchRequest()
    let sort = NSSortDescriptor(key: #keyPath(Note.lastUpdated), ascending: false)
    request.sortDescriptors = [sort]
    do {
      resultsController = NSFetchedResultsController(fetchRequest: request,
                                                     managedObjectContext: coreDataStack.mainContext,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: nil)
      resultsController.delegate = self
      try resultsController.performFetch()
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
}

extension NotesViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "EditNote", sender: nil)
  }
}

extension NotesViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard
      let sections = resultsController.sections,
      let objects = sections[section].objects
    else { return 0 }
    
    return objects.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "\(NoteViewCell.self)", for: indexPath) as! NoteViewCell
    cell.prepareForReuse()
    let note = resultsController.object(at: indexPath)
    cell.notesLabel.text = note.text
    if let date = note.lastUpdated {
      cell.lastUpdatedLabel.text = "Last Updated: \(date.formatted())"
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      let note = resultsController.object(at: indexPath)
      coreDataStack.mainContext.delete(note)
      coreDataStack.saveContext()
    default:
      break
    }
  }
}

extension NotesViewController: NoteViewControllerDelegate {
  
  func noteViewControllerDidFinishSaving(_ noteViewController: NoteViewController) {
    guard
      let childContext = noteViewController.context,
      childContext.hasChanges
    else {
      self.dismiss(animated: true, completion: nil)
      return
    }
    
    childContext.perform {
      do {
        try childContext.save()
      } catch let error as NSError {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
      self.coreDataStack.saveContext()
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  func noteViewControllerDidCancel(_ noteViewController: NoteViewController) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    if let indexPath = indexPath ?? newIndexPath {
      switch type {
      case .insert:
        notesTableView.insertRows(at: [indexPath], with: .automatic)
      case .delete:
        notesTableView.deleteRows(at: [indexPath], with: .automatic)
      case .move:
        notesTableView.reloadData()
      case .update:
        notesTableView.reloadRows(at: [indexPath], with: .automatic)
      default:
        break
      }
    }
  }
}
