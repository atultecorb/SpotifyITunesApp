//
//  TitleCell.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import UIKit

class TitleCell: UITableViewCell {
    
    @IBOutlet weak var titleName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
