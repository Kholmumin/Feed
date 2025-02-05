//
//  FeedCacheTestHelper.swift
//  EssentialFeedTests
//
//  Created by Kholmumin Tursinboev on 1/20/25.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage{
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]){
    let feed = [uniqueImage(), uniqueImage()]
    let localItems = feed.map{
        LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url)
    }
    
    return (feed, localItems)
}

extension Date{
    private var feedCacheMaxAgeInDays: Int{
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date{
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private func adding(days: Int) -> Date{
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date{
    func adding(seconds: TimeInterval) -> Date{
        return self + seconds
    }
}
