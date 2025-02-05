//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Kholmumin Tursinboev on 1/16/25.
//

import Foundation

struct RemoteFeedItem: Decodable{
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
