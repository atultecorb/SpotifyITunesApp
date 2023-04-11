//
//  ProfileCell.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 04/04/23.
//

import UIKit

class ProfileCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var ownerName: UILabel!
    
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var follwingCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
