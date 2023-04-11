//
//  ArtistsCell.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 06/04/23.
//

import UIKit

class ArtistsCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var albumTitle: UIButton!
    
    @IBOutlet weak var trackName: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
