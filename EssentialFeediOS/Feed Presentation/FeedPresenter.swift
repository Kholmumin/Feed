//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Kholmumin Tursinboev on 3/11/25.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel{
    let isLoading: Bool
}

protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel)
}


protocol FeedView{
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter{
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String{
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for feed View")
    }

    func didStartLoadingFeed(){
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]){
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingWithError(with error: Error){
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
}
