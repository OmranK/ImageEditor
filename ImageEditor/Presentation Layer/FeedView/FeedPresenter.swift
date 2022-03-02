//
//  FeedPresenter.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation
import CoreLayer

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewVM)
}

public protocol FeedLoadingErrorView {
    func display(_ viewModel: FeedLoadingErrorViewVM)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewVM)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let loadingErrorView: FeedLoadingErrorView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, loadingErrorView: FeedLoadingErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.loadingErrorView = loadingErrorView
    }
    
    public func didStartLoadingFeed() {
        loadingErrorView.display(FeedLoadingErrorViewVM.noError)
        loadingView.display(FeedLoadingViewVM(isLoading: true))
        
    }
    
    public func didFinishLoadingFeed(feed: [ImageData]) {
        feedView.display(FeedViewVM(feed: feed))
        loadingView.display(FeedLoadingViewVM(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingErrorView.display(FeedLoadingErrorViewVM.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewVM(isLoading: false))
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from server.")
    }
}
