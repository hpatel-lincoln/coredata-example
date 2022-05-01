//
//  NoteViewController.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/28/22.
//

import UIKit

protocol NoteViewControllerDelegate: AnyObject {
  func noteViewController(_ noteViewController: NoteViewController, didAddNote note: Note)
  func noteViewController(_ noteViewController: NoteViewController, didEditNote note: Note)
  func noteViewControllerDidCancel(_ noteViewController: NoteViewController)
}

class NoteViewController: UIViewController {
  
  weak var delegate: NoteViewControllerDelegate?
  var noteToEdit: Note?
  
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
    
    if var note = noteToEdit {
      note.text = text
      delegate?.noteViewController(self, didEditNote: note)
    } else {
      let note = Note(text: text)
      delegate?.noteViewController(self, didAddNote: note)
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
