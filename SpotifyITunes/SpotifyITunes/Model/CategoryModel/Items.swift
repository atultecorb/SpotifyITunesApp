//
//  Items.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on March 31, 2023
//
import Foundation
import SwiftyJSON

struct Items {

	var href: String?
	var icons: [Icons]?
	var id: String?
	var name: String?

	init(_ json: JSON) {
		href = json["href"].stringValue
		icons = json["icons"].arrayValue.map { Icons($0) }
		id = json["id"].stringValue
		name = json["name"].stringValue
	}

}