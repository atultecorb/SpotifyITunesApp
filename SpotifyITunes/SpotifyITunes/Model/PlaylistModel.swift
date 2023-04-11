//
//  PlaylistModel.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 24/03/23.
//

import Foundation


import Foundation
import SwiftyJSON

struct PlayListItems {
    var collaborative: Bool = false
    var description = ""
    var externalUrls = ExternalUrls()
    var href: String = ""
    var id:String = ""
    var images = [ItemImages]()
    var name = ""
    var primaryColor = ""
    var publicc : Bool = false
    var snapshotId = ""
    var type = ""
    var uri = ""
    var owner = PlayListOwner()
    var album = [Album]()

    init(_ json: JSON) {
        collaborative = json["collaborative"].boolValue
        description = json["description"].stringValue
        externalUrls = ExternalUrls(json["external_urls"])
        href = json["href"].stringValue
        id = json["id"].stringValue
        images = json["images"].arrayValue.map{ItemImages($0)}
        name = json["name"].stringValue
        primaryColor = json["primary_color"].stringValue
        publicc = json["public"].boolValue
        snapshotId = json["snapshotId"].stringValue
        type = json["type"].stringValue
        uri = json["uri"].stringValue
        owner = PlayListOwner(json["owner"])
    }
    init() {}
}

struct PlayListTrack {
    var href = ""
    var total = 0
    
    init(_ json:JSON) {
        href = json["href"].stringValue
        total = json["total"].intValue
    }
}

struct ExternalUrls {
    var spotify = ""
    init(_ json: JSON) {
        spotify = json["spotify"].stringValue
    }
    init() {
        
    }
}

struct PlayListOwner {
    var displayName = ""
    var externalUrls = ExternalUrls()
    var href = ""
    var id = ""
    var type = ""
    var uri = ""
    
    init(_ json:JSON) {
        displayName = json["display_name"].stringValue
        externalUrls = ExternalUrls(json["external_urls"])
        href = json["href"].stringValue
        id = json["id"].stringValue
        type = json["type"].stringValue
        uri = json["uri"].stringValue
    }
    init() {
        
    }
}

struct ItemImages {
    var height : Int = 0
    var url = ""
    var width : Int = 0
    init(_ json:JSON) {
        height = json["height"].intValue
        url = json["url"].stringValue
        width = json["width"].intValue
    }
    init() {
    }
}


struct PlayListParser {
    var message = ""
    var code = 0
   // var errorCode: ErrorCode = .failure
    var href = ""
    var items = [PlayListItems]()
    var error = ErrorObject()

    init(_ json: JSON){
       // self.errorCode = ErrorCode(rawValue: json["code"].intValue)
        href = json["href"].stringValue
        self.code = json["code"].intValue
        self.message = json["message"].stringValue
        items = json["items"].arrayValue.map({ (listjson) -> PlayListItems in
            return PlayListItems(listjson)
        })
        error = ErrorObject(json["error"])
    }
    init() {
    }
}




/*
 {
     "href": "https://api.spotify.com/v1/users/31t4dnhmu5mnb7ma5nnwb4cl4q3a/playlists?offset=0&limit=20",
     "items": [
         {
             "collaborative": false,
             "description": "",
             "external_urls": {
                 "spotify": "https://open.spotify.com/playlist/5BAANHwfl0i13sPAoyLtob"
             },
             "href": "https://api.spotify.com/v1/playlists/5BAANHwfl0i13sPAoyLtob",
             "id": "5BAANHwfl0i13sPAoyLtob",
             "images": [
                 {
                     "height": 640,
                     "url": "https://i.scdn.co/image/ab67616d0000b2739c48ffd6b1a9a43b9a74c66c",
                     "width": 640
                 }
             ],
             "name": "Marvel",
             "owner": {
                 "display_name": "Atul",
                 "external_urls": {
                     "spotify": "https://open.spotify.com/user/31t4dnhmu5mnb7ma5nnwb4cl4q3a"
                 },
                 "href": "https://api.spotify.com/v1/users/31t4dnhmu5mnb7ma5nnwb4cl4q3a",
                 "id": "31t4dnhmu5mnb7ma5nnwb4cl4q3a",
                 "type": "user",
                 "uri": "spotify:user:31t4dnhmu5mnb7ma5nnwb4cl4q3a"
             },
             "primary_color": null,
             "public": true,
             "snapshot_id": "MixkYmZmNGNiNDVmODYxYTMwMDdhNjA0ZDg4M2Y1YjEzOWNmZWZkNWVm",
             "tracks": {
                 "href": "https://api.spotify.com/v1/playlists/5BAANHwfl0i13sPAoyLtob/tracks",
                 "total": 1
             },
             "type": "playlist",
             "uri": "spotify:playlist:5BAANHwfl0i13sPAoyLtob"
         }
     ],
     "limit": 20,
     "next": null,
     "offset": 0,
     "previous": null,
     "total": 1
 }
 */

class Token: Decodable {
    var accessToken: String
      var refreshToken: String
}
