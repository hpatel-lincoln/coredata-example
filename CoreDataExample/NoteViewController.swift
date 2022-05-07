//
//  NoteViewController.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/28/22.
//

import UIKit
import CoreData

protocol NoteViewControllerDelegate: AnyObject {
  func noteViewControllerDidFinishSaving(_ noteViewController: NoteViewController)
  func noteViewControllerDidCancel(_ noteViewController: NoteViewController)
}

class NoteViewController: UIViewController {
  
  var context: NSManagedObjectContext!
  var note: Note?
  weak var delegate: NoteViewControllerDelegate?
  
  @IBOutlet private var noteTextView: UITextView!
  @IBOutlet private var doneBarButton: UIBarButtonItem!
  private var tapGestureRecognizer: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    noteTextView.textContainerInset = .zero
    noteTextView.textContainer.lineFragmentPadding = 0.0
    noteTextView.delegate = self
    noteTextView.becomeFirstResponder()
    
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
    tapGestureRecognizer?.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGestureRecognizer)
    
    if note == nil {
      note = Note(context: context)
    }
    configureView()
  }
  
  @IBAction private func didTapCancel(sender: UIBarButtonItem) {
    delegate?.noteViewControllerDidCancel(self)
  }
  
  @IBAction private func didTapDone(sender: UIBarButtonItem) {
    updateNote()
    delegate?.noteViewControllerDidFinishSaving(self)
  }
  
  @objc private func onTap(sender: UITapGestureRecognizer) {
    noteTextView.resignFirstResponder()
  }
  
  private func configureView() {
    if let note = note {
      noteTextView.text = note.text
      doneBarButton.isEnabled = note.text.isEmpty == false
    }
  }
  
  private func updateNote() {
    if let note = note {
      note.text = noteTextView.text
      note.lastUpdated = Date()
    }
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
