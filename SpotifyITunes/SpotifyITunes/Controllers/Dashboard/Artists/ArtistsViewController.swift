//
//  ArtistsViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 06/04/23.
//

import UIKit



class ArtistsViewController: UIViewController {
    
   
    
    @IBOutlet weak var tblViewForArtists: UITableView!
    var albumList = AlbumRootClass()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.setUpLeftBarButton()
        // Do any additional setup after loading the view.
    }
    
    func setUpLeftBarButton() {
        let backButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        backButton.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        backButton.setImage(#imageLiteral(resourceName: "backarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(onClickBackButton(_:)), for: .touchUpInside)
        let viewBacktBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButtonItems(nil, animated: false)
        self.navigationItem.setLeftBarButtonItems([viewBacktBarButton], animated: false)
    }
    @IBAction func onClickBackButton(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension ArtistsViewController: UITableViewDataSource, UITableViewDelegate{
    
    @objc func actionOnAlbum(sender:UIButton){
        let id = self.albumList.artists?[sender.tag].id
        let albumVC = AppStoryboard.Main.viewController(AlbumViewController.self)
        albumVC.artistId = id ?? ""
        albumVC.artistTrack = .album
        self.navigationController?.pushViewController(albumVC, animated: true)
    }
    
    @objc func actionOnTopTrack(sender:UIButton){
        let id = self.albumList.artists?[sender.tag].id
        let albumVC = AppStoryboard.Main.viewController(AlbumViewController.self)
        albumVC.artistId = id ?? ""
        albumVC.artistTrack = .topTracker
        self.navigationController?.pushViewController(albumVC, animated: true)
    }
    
    func registerCell(){
        self.tblViewForArtists.register(UINib(nibName: "ArtistsCell", bundle: nil), forCellReuseIdentifier: "ArtistsCell")
        self.tblViewForArtists.dataSource = self
        self.tblViewForArtists.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let art = self.albumList.artists{
            return art.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblViewForArtists.dequeueReusableCell(withIdentifier: "ArtistsCell", for: indexPath) as! ArtistsCell
        cell.selectionStyle = .none
        cell.name.text = self.albumList.artists?[indexPath.row].name.capitalized
        cell.name.font = UIFont(name: "Helvetica Medium", size: 25)
        cell.albumTitle.addTarget(self, action: #selector(ArtistsViewController.actionOnAlbum(sender:)), for: .touchUpInside)
        cell.trackName.addTarget(self, action: #selector(ArtistsViewController.actionOnTopTrack(sender:)), for: .touchUpInside)
        cell.albumTitle.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Artists"
            label.font = .systemFont(ofSize: 23)
            label.textColor = .cyan
            headerView.addSubview(label)
            return headerView
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
