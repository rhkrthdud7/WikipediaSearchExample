//
//  ViewController.swift
//  WikipediaSearchExample
//
//  Created by Soso on 2020/05/09.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SafariServices

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    let identifier = "UITableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupViewModel()
    }
    
    func setupViews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    func setupViewModel() {
        viewModel.allSearches
            .bind(to: tableView.rx.items(cellIdentifier: identifier, cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.title
                cell.selectionStyle = .none
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ModelSearch.self)
            .map { $0.url }
            .compactMap { URL(string: $0) }
            .map { SFSafariViewController(url: $0) }
            .subscribe(onNext: { [weak self] vc in
                self?.present(vc, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.fetchSearches)
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
    }
    
}
