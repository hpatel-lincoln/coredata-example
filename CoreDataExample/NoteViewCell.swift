//
//  NoteViewCell.swift
//  CoreDataExample
//
//  Created by Hardik Patel on 4/28/22.
//

import UIKit

class NoteViewCell: UITableViewCell {
  
  @IBOutlet var notesLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    notesLabel.numberOfLines = 4
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    notesLabel.text = nil
  }
}
