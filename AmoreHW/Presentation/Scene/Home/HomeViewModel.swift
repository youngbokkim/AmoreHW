//
//  HomeViewModel.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/01.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class HomeViewModel: ViewModelBase, Stepper {
    let title: String
    let disposeBag: DisposeBag = DisposeBag()
    let steps: PublishRelay<Step> = PublishRelay<Step>()
    
    private let useCase: HitsUseCaseInf
    private let errorHandler: PublishRelay<Error> = PublishRelay<Error>()
    private var hitsData: [Hit] = []
    var maxLength: Int {
        return hitsData.count
    }
    
    init(title:String, useCase:HitsUseCaseInf) {
        self.title = title
        self.useCase = useCase
    }
    
    struct Input {
        let viewLoad: Observable<Void>
        let fetchedHitsData: Observable<Int>
        let cellSelect: Observable<Int>
        let goDetail: Observable<Hit>
    }
    
    struct Output {
        let dataSource: Driver<[Hit]>
        let hitsInfo: Driver<Hit>
        let errorHandler: Driver<Error>
    }
    
    func transform(input: Input) -> Output {
        input.goDetail.subscribe { [weak self] hit in
            self?.steps.accept(AppStep.appHomeDetail(info: hit))
        }.disposed(by: disposeBag)
        
        let dataSource = input.fetchedHitsData
            .flatMap { [weak self] page -> Observable<Result<[Hit],Error>> in
                self?.useCase.getHitsData(page: page, count: 10) ??
                    .just(.success([]))
            }
            .map { [weak self] result -> [Hit] in
                switch result {
                case .success(let data):
                    self?.hitsData.append(contentsOf: data)
                    return self?.hitsData ?? []
                case .failure(let error):
                    self?.errorHandler.accept(error)
                    return []
                }
            }
        
        let hitsInfo = input.cellSelect
            .map { self.hitsData[$0] }
        let output = Output(dataSource: dataSource.asDriverComplete(),
                            hitsInfo: hitsInfo.asDriverComplete(),
                            errorHandler: errorHandler.asDriverComplete())

        return output
    }
    
}
