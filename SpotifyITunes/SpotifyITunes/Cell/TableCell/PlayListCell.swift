//
//  PlayListCell.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 27/03/23.
//

import UIKit

class PlayListCell: UITableViewCell {

    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var trackName: UILabel!
    
    @IBOutlet weak var ownerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
