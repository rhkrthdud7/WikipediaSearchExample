//
//  ViewModel.swift
//  WikipediaSearchExample
//
//  Created by Soso on 2020/05/09.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {
    let disposeBag = DisposeBag()
    
    let fetchSearches: AnyObserver<String>
    let allSearches: Observable<[ModelSearch]>

    init() {
        let fetching = PublishSubject<String>()
        
        let searches = BehaviorSubject<[ModelSearch]>(value: [])
        
        fetchSearches = fetching.asObserver()
        allSearches = searches
        
        fetching
            .distinctUntilChanged()
            .flatMap(fetchData)
            .subscribe(onNext: searches.onNext)
            .disposed(by: disposeBag)
    }
    
    func fetchData(_ text: String) -> Observable<[ModelSearch]> {
        if text.isEmpty {
            return .just([])
        } else {
            return ApiService.fetchSearchRx(text: text)
                .map { zip($0.titles, $0.urls).map(ModelSearch.init) }
        }
    }
    
}
