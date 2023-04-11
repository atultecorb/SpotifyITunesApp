//
//  PlaylistTableCell.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 05/04/23.
//

import UIKit

protocol OnPlayPlaylistProtocol {
    func playFromPlayList(id:String)
}


class PlaylistTableCell: UITableViewCell {
    
    var playListDelagte : OnPlayPlaylistProtocol?
    
    @IBOutlet weak var collectionView: UICollectionView!
    var playList = PlaylistRootClass()
    var albumList = AlbumRootClass()
    var topTrackers = TopTrackRootClass()
    var mediaType:MediaFlow?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.registerCell()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension PlaylistTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    func registerCell(){
        self.collectionView.register(UINib(nibName: "PlayListCollCell", bundle: nil), forCellWithReuseIdentifier: "PlayListCollCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        // self.collectionViewForCategory.isPagingEnabled = true
        self.collectionView.decelerationRate = .fast
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.reloadData()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.mediaType == .playlist{
            if let count = self.playList.tracks?.items{
                return count.count
            } else {
                return 0
            }
        } else if self.mediaType == .album {
            if let count = self.albumList.tracks?.items{
                return count.count
            } else {
                return 0
            }
        } else if self.mediaType == .topTracker{
            if let count = self.topTrackers.tracks{
                return count.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PlayListCollCell", for: indexPath) as! PlayListCollCell
        if self.mediaType == .playlist{
            cell.image.sd_setImage(with: URL(string:self.playList.tracks?.items[indexPath.row].track.album.images.first?.url ?? ""), placeholderImage: UIImage(named: "spotify"))
            cell.titleOne.text = self.playList.tracks?.items[indexPath.row].track.artists.first?.name.capitalized
            cell.titleTwo.text = self.playList.tracks?.items[indexPath.row].track.name.capitalized
        } else if self.mediaType == .album {
            cell.image.sd_setImage(with: URL(string:self.albumList.itemImages?.first?.url ?? ""), placeholderImage: UIImage(named: "spotify"))
            cell.titleOne.text = self.albumList.tracks?.items[indexPath.row].name.capitalized
            cell.titleTwo.text = self.albumList.tracks?.items[indexPath.row].type.capitalized
        } else if self.mediaType == .topTracker{
            let topTrackerData = topTrackers.tracks?[indexPath.item]
            let url = URL(string: topTrackerData?.album?.images.first?.url ?? "")
            cell.image.sd_setImage(with: url, placeholderImage: UIImage(named: "spotify"))
            cell.titleOne.text = topTrackerData?.name?.capitalized
            cell.titleTwo.text = self.albumList.tracks?.items[indexPath.row].type.capitalized
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width  = (self.collectionView.frame.width)/3
               return CGSize(width: width, height: width)
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.mediaType == .playlist{
            guard let id = self.playList.tracks?.items[indexPath.item].track.uri else {return}
            self.playListDelagte?.playFromPlayList(id: id)
        } else if self.mediaType == .album{
            guard let id = self.albumList.tracks?.items[indexPath.item].uri else {return}
            self.playListDelagte?.playFromPlayList(id: id)
        } else if self.mediaType == .topTracker{
            guard let id = self.topTrackers.tracks?[indexPath.item].uri else {return}
            self.playListDelagte?.playFromPlayList(id: id)
        }
        
    }
}
