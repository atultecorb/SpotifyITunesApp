//
//  Categories.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on March 31, 2023
//
import Foundation
import SwiftyJSON

struct Categories {

	var href: String?
	var limit: Int?
	var next: String?
	var offset: Int?
	var previous: Any?
	var total: Int?
	var items: [Items]?

	init(_ json: JSON) {
		href = json["href"].stringValue
		limit = json["limit"].intValue
		next = json["next"].stringValue
		offset = json["offset"].intValue
		previous = json["previous"]
		total = json["total"].intValue
		items = json["items"].arrayValue.map { Items($0) }
	}

}