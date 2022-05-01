//
//  NotesViewController.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/28/22.
//

import UIKit

class NotesViewController: UIViewController {
  
  private var notes: [Note] = []
  private var selectedIndexPath: IndexPath?
  
  @IBOutlet private var notesTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Notes"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    notesTableView.delegate = self
    notesTableView.dataSource = self
  }
  
  @IBAction private func didTapAdd(sender: UIBarButtonItem) {
    performSegue(withIdentifier: "AddNote", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "AddNote":
      if let noteViewController = segue.destination as? NoteViewController {
        noteViewController.delegate = self
      }
    case "EditNote":
      if
        let noteViewController = segue.destination as? NoteViewController,
        let indexPath = selectedIndexPath
      {
        noteViewController.delegate = self
        noteViewController.noteToEdit = notes[indexPath.row]
      }
    default:
      break
    }
  }
}

extension NotesViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    performSegue(withIdentifier: "EditNote", sender: nil)
  }
}

extension NotesViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "\(NoteViewCell.self)", for: indexPath) as! NoteViewCell
    cell.prepareForReuse()
    let note = notes[indexPath.row]
    cell.notesLabel.text = note.text
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      notes.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    default:
      break
    }
  }
}

extension NotesViewController: NoteViewControllerDelegate {
  
  func noteViewController(_ noteViewController: NoteViewController, didAddNote note: Note) {
    self.dismiss(animated: true, completion: nil)
    self.notes.append(note)
    let indexPath = IndexPath(row: notes.count-1, section: 0)
    self.notesTableView.insertRows(at: [indexPath], with: .automatic)
  }
  
  func noteViewController(_ noteViewController: NoteViewController, didEditNote note: Note) {
    self.dismiss(animated: true, completion: nil)
    
    if let indexPath = selectedIndexPath {
      notes[indexPath.row] = note
      self.notesTableView.reloadRows(at: [indexPath], with: .automatic)
      selectedIndexPath = nil
    }
  }
  
  func noteViewControllerDidCancel(_ noteViewController: NoteViewController) {
    self.dismiss(animated: true, completion: nil)
  }
}
