//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Kholmumin Tursinboev on 2/27/25.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
