//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kholmumin Tursinboev on 2/11/25.
//

import UIKit
import EssentialFeed

final public class FeedRefreshController: NSObject{
    public lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let feedLoader: FeedLoader
    var onRefresh: (([FeedImage]) -> Void)?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc func refresh(){
        view.beginRefreshing()
        feedLoader.load{ [weak self] result in
            if let feed = try? result.get(){
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}


final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching{
    
    private var refreshController: FeedRefreshController?
    private var viewIsAppearing: ((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]() {
        didSet{
            tableView.reloadData()
        }
    }
    private var imageLoader: FeedImageDataLoader?
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) {
        self.init()
        self.refreshController = FeedRefreshController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        
        viewIsAppearing = {[weak self] vc in
            self?.refreshController?.refresh()
            vc.viewIsAppearing = nil
        }
        tableView.prefetchDataSource = self
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        viewIsAppearing?(self)
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadedImage = { [weak self, weak cell] in
            guard let self else{return}
            self.tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil )
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadedImage
        loadedImage()
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
