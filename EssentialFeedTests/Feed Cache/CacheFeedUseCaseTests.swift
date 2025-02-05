//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kholmumin Tursinboev on 1/13/25.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase{
    
    func test_init_doesNotMessageCacheUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(){
        let (sut, store) = makeSUT()
        
        sut.save(uniqueImageFeed().model){ _ in}
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().model){ _ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfullDeletion(){
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: {timestamp})
        let feed = uniqueImageFeed()
        
        sut.save(feed.model){ _ in}
        store.completeDeletionSuccessFully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError(){
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError(){
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessFully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion(){
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessFully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHaveBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().model) { receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHaveBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]) { receivedResults.append($0) }
        
        store.completeDeletionSuccessFully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: Helpers
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(uniqueImageFeed().model) { result in
            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueImage() -> FeedImage{
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]){
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
    
    private func anyURL() -> URL{
        return URL(string: "https://any-given.com")!
    }
    
    private func anyNSError() -> NSError{
        return NSError(domain: "Test", code: 1)
    }
}
