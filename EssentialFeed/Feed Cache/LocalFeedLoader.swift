//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Kholmumin Tursinboev on 1/15/25.
//

import Foundation

public final class LocalFeedLoader{
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

//MARK: Save
extension LocalFeedLoader{
    public typealias SaveResult = Result<Void, Error>
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void){
        store.deleteCachedFeed{ [weak self] deletionResult in
            guard let self else {return}
            switch deletionResult{
            case .success:
                cache(feed, with: completion)
            case let .failure(cacheDeletionError):
                completion(.failure(cacheDeletionError))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void){
        store.insert(feed.toLocal(), timestamp: currentDate()){ [weak self] error in
            guard self != nil else{return}
            completion(error)
        }
    }
}

//MARK: Load
extension LocalFeedLoader: FeedLoader{
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping(LoadResult) -> Void){
        store.retrieve { [weak self] result in
            guard let self else {return}
            switch result{
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                completion(.success(cache.feed.toModels()))
            case let .failure(error):
                completion(.failure(error))
            case .success:
                completion(.success([]))
            default:
                break
            }
        }
    }
}

//MARK: Validate
extension LocalFeedLoader{
    public func validateCache(){
        store.retrieve { [weak self] result in
            guard let self else {return}
            switch result{
            case .failure:
                self.store.deleteCachedFeed{ _ in}
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                self.store.deleteCachedFeed{ _ in}
            case .success:
                break
            case .none:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage{
    func toLocal() -> [LocalFeedImage]{
        return map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}


private extension Array where Element == LocalFeedImage{
    func toModels() -> [FeedImage]{
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
    }
}
