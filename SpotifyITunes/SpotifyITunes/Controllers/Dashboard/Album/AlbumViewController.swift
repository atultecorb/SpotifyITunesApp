//
//  AlbumViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 06/04/23.
//

import UIKit

enum ArtistTrack {
case album, topTracker
}

class AlbumViewController: UIViewController {
    
    var artistTrack: ArtistTrack?
    @IBOutlet weak var collectionView: UICollectionView!
    
    var albums = AlbumRootClass()
    var topTrackers = TopTrackRootClass()
    var artistId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        let token = AppSettings.shared.acToken
        if artistTrack == .album{
            self.getAllAlbumByArtist(artistId: artistId, token: token)
        }else {
            self.getTopTrackerList(artistId: artistId, token: token)
        }
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
    
    func getAllAlbumByArtist(artistId:String, token:String){
        Services.shareInstance.getAllAlbumByArtist(artistId: artistId, accessToken: token, {(responseData, error) in
            if error == nil{
                if let data = responseData{
                    self.albums = data
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    func getTopTrackerList(artistId:String, token:String){
        Services.shareInstance.getTopTracker(artistId: artistId, accessToken: token, {(responseData, error) in
            if error == nil{
                if let data = responseData{
                    self.topTrackers = data
                    self.collectionView.reloadData()
                }
            }
            
        })
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



extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    func registerCell(){
        self.collectionView.register(UINib(nibName: "PlayListCollCell", bundle: nil), forCellWithReuseIdentifier: "PlayListCollCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
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
        if artistTrack == .album{
            return self.albums.albums.count
        } else if self.artistTrack == .topTracker {
            return topTrackers.tracks?.count ?? 0
        } else {
            return 0
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PlayListCollCell", for: indexPath) as! PlayListCollCell
        
        if artistTrack == .album {
            let albumData = self.albums.albums[indexPath.item]
            let url = URL(string: albumData.images.first?.url ?? "")
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.image.image = UIImage(data: data!)
                }
            }
            cell.titleOne.text = albumData.name.capitalized
            cell.titleTwo.text = albumData.artists.first?.name.capitalized
        } else {
            let topTrackerData = topTrackers.tracks?[indexPath.item]
            let url = URL(string: topTrackerData?.album?.images.first?.url ?? "")
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.image.image = UIImage(data: data!)
                }
            }
            cell.titleOne.text = topTrackerData?.name?.capitalized
            cell.titleTwo.text = topTrackerData?.artists?.first?.name.capitalized
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
               let width  = (view.frame.width)/3
               return CGSize(width: width, height: width)
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.artistTrack == .album{
            let id = self.albums.albums[indexPath.item].uri
            NotificationCenter.default.post(name: .STARTSPOTIFYPLAYER, object: nil, userInfo: ["uri":id])
        } else {
            guard let id = self.topTrackers.tracks?[indexPath.row].uri else {return}
            NotificationCenter.default.post(name: .STARTSPOTIFYPLAYER, object: nil, userInfo: ["uri":id])
        }
        
    }
}
