//
//  RootClass.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on March 31, 2023
//
import Foundation
import SwiftyJSON

struct RootClass {

	var categories: Categories?
    var error : ErrorObject?

	init(_ json: JSON) {
		categories = Categories(json["categories"])
        error = ErrorObject(json["error"])
	}

}

struct ErrorObject {
    var message = ""
    var status = 0
    init(_ json:JSON) {
        message = json["message"].stringValue
        status = json["status"].intValue
    }
    
    init() {
        
    }
}

struct UserProfileParser {

    var displayName: String?
    var type: String?
    var id: String?
    var images: [ItemImages]?
    var followers: Followers?
    var uri: String?
    var externalUrls: ExternalUrls?
    var href: String?

    init(_ json: JSON) {
        displayName = json["display_name"].stringValue
        type = json["type"].stringValue
        id = json["id"].stringValue
        images = json["images"].arrayValue.map {ItemImages($0)}
        followers = Followers(json["followers"])
        uri = json["uri"].stringValue
        externalUrls = ExternalUrls(json["external_urls"])
        href = json["href"].stringValue
    }
    
    init() {
    }

}

struct Followers {

    var href: Any?
    var total: Int?

    init(_ json: JSON) {
        href = json["href"]
        total = json["total"].intValue
    }

}


struct PlaylistRootClass {

    var description: String?
    var name: String?
    var collaborative: Bool?
    var type: String?
    var uri: String?
    var externalUrls: ExternalUrls?
    var images: [ItemImages]?
    var owner: PlayListOwner?
    var publicField: Bool?
    var tracks: Tracks?
    var id: String?
    var primaryColor: Any?
    var href: String?
    var snapshotId: String?
    var followers: Followers?

    init(_ json: JSON) {
        description = json["description"].stringValue
        name = json["name"].stringValue
        collaborative = json["collaborative"].boolValue
        type = json["type"].stringValue
        uri = json["uri"].stringValue
        externalUrls = ExternalUrls(json["external_urls"])
        images = json["images"].arrayValue.map { ItemImages($0) }
        owner = PlayListOwner(json["owner"])
        publicField = json["public"].boolValue
        tracks = Tracks(json["tracks"])
        id = json["id"].stringValue
        primaryColor = json["primary_color"]
        href = json["href"].stringValue
        snapshotId = json["snapshot_id"].stringValue
        followers = Followers(json["followers"])
    }
    
    init() {
        
    }

}
