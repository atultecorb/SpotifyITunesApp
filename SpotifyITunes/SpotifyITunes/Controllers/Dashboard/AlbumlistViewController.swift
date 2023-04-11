//
//  AlbumlistViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 28/03/23.
//

import UIKit

class AlbumlistViewController: UIViewController {

    @IBOutlet weak var tblViewForAlbum: UITableView!
    
    var albumList = AlbumParser()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.title = "Album"
        self.getAlbumList()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getAlbumList(){
        let token = AppSettings.shared.acToken
        Services.shareInstance.getAlbums(accessToken: token, {(album, error) in
            if error == nil{
                guard let albumlist = album else {
                    return
                }
                self.albumList = albumlist
                print(self.albumList.items.count)
                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                    self.tblViewForAlbum.reloadData()
                })
            } else {
            }
        })
    }
}


extension AlbumlistViewController: UITableViewDataSource, UITableViewDelegate{
    func registerCell(){
        self.tblViewForAlbum.register(UINib(nibName: "PlayListCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
        self.tblViewForAlbum.dataSource = self
        self.tblViewForAlbum.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblViewForAlbum.dequeueReusableCell(withIdentifier: "PlayListCell", for: indexPath) as! PlayListCell
        cell.selectionStyle = .none
        let playListData = self.albumList.items[indexPath.row]
       // cell.songImage.sd_setImage(with: URL(string:playListData.images.first?.url ?? ""), placeholderImage: UIImage(named: "SpotifyTrack"))
        cell.songImage.downloadImage(url: playListData.album.images.first?.url ?? "")
        cell.songImage.image = UIImage(named: "2")
        cell.trackName.text = "\(playListData.album.name.capitalized)"
        cell.ownerName.text = "Album . " +  "\(playListData.album.artists.first?.name.capitalized)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Album"
            label.font = .systemFont(ofSize: 17)
            label.textColor = .cyan
            headerView.addSubview(label)
            return headerView
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
