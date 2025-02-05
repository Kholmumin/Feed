//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Kholmumin Tursinboev on 1/7/25.
//

import Foundation

enum FeedItemMapper{
    private struct Root: Decodable{
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int {return 200}
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws ->  [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

