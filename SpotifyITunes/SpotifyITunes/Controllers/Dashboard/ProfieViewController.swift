//
//  ProfieViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 04/04/23.
//

import UIKit

class ProfieViewController: UIViewController {
    
    
    @IBOutlet weak var tblViewForProfile: UITableView!
    
    var userProfile = UserProfileParser()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.getUserProfile()
        self.title = "Profile"
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
    
    
    func getUserProfile(){
        let token = AppSettings.shared.acToken
        Services.shareInstance.getUserProfile(accessToken: token, {(userData, error) in
            if error == nil{
                if let userProfile = userData{
                    self.userProfile = userProfile
                    self.tblViewForProfile.reloadData()
                }
            } else {
                
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

extension ProfieViewController: UITableViewDataSource, UITableViewDelegate {
    
    func registerCell(){
        self.tblViewForProfile.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        self.tblViewForProfile.dataSource = self
        self.tblViewForProfile.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblViewForProfile.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        cell.selectionStyle = .none
        if let newUrl = self.userProfile.images?.first?.url {
            if let url = URL(string: newUrl) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell.userImage.image = UIImage(data: data!)
                    }
                }
            }
        }
        cell.ownerName.text = self.userProfile.displayName?.capitalized
        if let followersCount = self.userProfile.followers?.total{
            cell.followersCount.text = "\(followersCount)"
            cell.follwingCount.text = "\(followersCount)"
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ProfileCell{
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
            cell.userImage.clipsToBounds = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    
    
    
}
