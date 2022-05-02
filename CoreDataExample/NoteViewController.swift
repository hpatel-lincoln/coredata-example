//
//  NoteViewController.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/28/22.
//

import UIKit
import CoreData

protocol NoteViewControllerDelegate: AnyObject {
  func noteViewControllerDidFinishAdding(_ noteViewController: NoteViewController)
  func noteViewControllerDidFinishEditing(_ noteViewController: NoteViewController)
  func noteViewControllerDidCancel(_ noteViewController: NoteViewController)
}

class NoteViewController: UIViewController {
  
  weak var delegate: NoteViewControllerDelegate?
  var noteToEdit: Note?
  
  private var context: NSManagedObjectContext {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    return delegate.persistentContainer.viewContext
  }
  
  @IBOutlet private var noteTextView: UITextView!
  @IBOutlet private var doneBarButton: UIBarButtonItem!
  private var tapGestureRecognizer: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    noteTextView.textContainerInset = .zero
    noteTextView.textContainer.lineFragmentPadding = 0.0
    noteTextView.delegate = self
    
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
    tapGestureRecognizer?.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGestureRecognizer)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let noteToEdit = noteToEdit {
      noteTextView.text = noteToEdit.text
    }
  }
  
  @IBAction private func didTapCancel(sender: UIBarButtonItem) {
    delegate?.noteViewControllerDidCancel(self)
  }
  
  @IBAction private func didTapDone(sender: UIBarButtonItem) {
    guard let text = noteTextView.text else { return }
    
    if let note = noteToEdit {
      note.text = text
      delegate?.noteViewControllerDidFinishEditing(self)
    } else {
      let note = Note(entity: Note.entity(), insertInto: context)
      note.text = text
      delegate?.noteViewControllerDidFinishAdding(self)
    }
  }
  
  @objc private func onTap(sender: UITapGestureRecognizer) {
    noteTextView.resignFirstResponder()
  }
}

extension NoteViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    guard
      let oldText = textView.text,
      let stringRange = Range(range, in: oldText)
    else { return false }
    
    let newText = oldText.replacingCharacters(in: stringRange, with: text)
    if newText.isEmpty {
      doneBarButton.isEnabled = false
    } else {
      doneBarButton.isEnabled = true
    }
    return true
  }
}
