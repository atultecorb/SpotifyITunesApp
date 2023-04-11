//
//  Icons.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on March 31, 2023
//
import Foundation
import SwiftyJSON

struct Icons {

	var height: Int?
	var url: String?
	var width: Int?

	init(_ json: JSON) {
		height = json["height"].intValue
		url = json["url"].stringValue
		width = json["width"].intValue
	}

}