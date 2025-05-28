//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kholmumin Tursinboev on 2/11/25.
//

import UIKit

protocol FeedViewControllerDeletage{
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView{
    
    var delegate: FeedViewControllerDeletage?
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    var tableModel = [FeedImageCellController]() {
        didSet{
            tableView.reloadData()
        }
    }
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        refreshOnAppear()
    }
    
    private func refreshOnAppear(){
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refresh()
        }
    }
    
    @IBAction private func refresh(){
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading{
            refreshControl?.beginRefreshing()
        }else{
            refreshControl?.endRefreshing()
        }
    }
    
    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellControllerForRowAt(at: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoads(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllerForRowAt(at: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoads)
    }
    
    private func cellControllerForRowAt(at indexPath: IndexPath)->FeedImageCellController{
        tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoads(forRowAt indexPath: IndexPath) {
        cellControllerForRowAt(at: indexPath).cancelLoad()
    }
}
