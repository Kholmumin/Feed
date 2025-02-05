//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Kholmumin Tursinboev on 1/18/25.
//

import Foundation
import EssentialFeed

final class FeedStoreSpy: FeedStore{
    enum ReceivedMessages: Equatable{
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessages]()
    private var deletetionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion){
        deletetionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0){
        deletetionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessFully(at index: Int = 0){
        deletetionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion){
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0){
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0){
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0){
        retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0){
        retrievalCompletions[index](.success(.none))
    }
}
