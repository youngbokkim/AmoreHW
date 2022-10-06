//
//  HomeDetailViewModel.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/04.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class HomeDetailViewModel: ViewModelBase, ImageLoadViewModelBase, Stepper {
    let title: String
    private var hitInfo: Hit
    let disposeBag: DisposeBag = DisposeBag()
    let steps: PublishRelay<Step> = PublishRelay<Step>()
    
    init(title: String, info: Hit) {
        self.title = title
        self.hitInfo = info
    }
    
    struct Input {
        let viewLoad: Observable<Void>
    }
    
    struct Output {
        let hitInfo: Driver<Hit>
    }
    
    func transform(input: Input) -> Output {
        let hitInfo = input.viewLoad
            .map{ self.hitInfo }
        let output = Output(hitInfo: hitInfo.asDriverComplete())
        return output
    }
    
    var webFormatUrl: URL? {
        return URL(string: hitInfo.webformatURL)
    }
    
    func imageKeyPath(url: URL) -> String {
        return saveKeyPath(rootKey: hitInfo.rootKey(), url: url)
    }
}
