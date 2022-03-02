//
//  FeedUIComposer.swift
//  PresentationLayer
//
//  Created by Omran Khoja on 2/26/22.
//
import UIKit
import CoreLayer
import PresentationLayer

final public class FeedUIComposer {

    public typealias Routing = (Data, URL) -> Void
    
    public static func feedControllerComposedWith(feedLoader: FeedLoader, imageLoader: ImageLoader, routing: @escaping Routing) -> FeedViewController {
        let presentationAdapter = FeedLoadingPresentationAdapter(feedLoader: MainQueueDispatchDecorator(feedLoader))
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let feedViewAdapter = FeedViewAdapter(
            feedController: feedController,
            imageLoader: MainQueueDispatchDecorator(imageLoader),
            routing: routing
        )
        
        let presenter = FeedPresenter(
            feedView: feedViewAdapter,
            loadingView: WeakRefVirtualProxy(feedController),
            loadingErrorView: WeakRefVirtualProxy(feedController))
        
        presentationAdapter.presenter = presenter
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}

