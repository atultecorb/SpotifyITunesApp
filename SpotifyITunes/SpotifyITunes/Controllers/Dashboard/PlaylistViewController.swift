//
//  PlaylistViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 24/03/23.
//

import UIKit
import SpotifyiOS
import SDWebImage

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tblViewForPlaylist: UITableView!
    
    
    lazy var rootViewController = ViewController()
    var playList =  PlayListParser()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        let token = AppSettings.shared.acToken
        self.getPlayList(token: token)
        // Do any additional setup after loading the view.
    }
    
    
    func getPlayList(token:String){
        Services.shareInstance.getPlaylist(accessToken: token, {(responseData, error) in
            if error == nil{
                if let data = responseData{
                    self.playList = data
                    self.tblViewForPlaylist.reloadData()
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate{
    
    func registerCell(){
        self.tblViewForPlaylist.register(UINib(nibName: "PlayListCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
        self.tblViewForPlaylist.dataSource = self
        self.tblViewForPlaylist.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblViewForPlaylist.dequeueReusableCell(withIdentifier: "PlayListCell", for: indexPath) as! PlayListCell
        cell.selectionStyle = .none
        let playListData = self.playList.items[indexPath.row]
        cell.songImage.sd_setImage(with: URL(string:playListData.images.first?.url ?? ""), placeholderImage: UIImage(named: "SpotifyTrack"))
        let url = URL(string: playListData.images.first?.url ?? "")
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            DispatchQueue.main.async {
//                cell.imageView?.image = UIImage(data: data!)
//            }
//        }
       // cell.songImage.downloadImage(url: playListData.images.first?.url ?? "")
        cell.songImage.image = UIImage(named: "2")
        cell.trackName.text = "\(playListData.name.capitalized)"
        cell.ownerName.text = "Playlist . " +  "\(playListData.owner.displayName.capitalized)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Playlist"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackId = self.playList.items[indexPath.row].uri
        self.nextToDetailsPlayerScreen(trackId: trackId)
    }
    
    
    func nextToDetailsPlayerScreen(trackId:String){
        let playerDetailsVC = AppStoryboard.Main.viewController(PlayerDetailsViewController.self)
        playerDetailsVC.trackId = trackId
        self.navigationController?.pushViewController(playerDetailsVC, animated: true)
    }
    
}


