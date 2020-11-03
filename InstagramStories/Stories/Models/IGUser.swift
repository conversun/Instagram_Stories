//
//  IGUser.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) DrawRect. All rights reserved.
//

import Foundation
import SwiftyInsta

public struct IGUser: Codable {
    public let internalIdentifier: String
    public let name: String
    public let picture: String
    public let responseUser: User?
    
    enum CodingKeys: String, CodingKey {
        case internalIdentifier = "id"
        case name = "name"
        case picture = "picture"
        case responseUser = "responseUser"
    }
}
