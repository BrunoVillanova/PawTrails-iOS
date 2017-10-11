//
//  SocketIO+RxSwift.swift
//  PawTrails
//
//  Created by Bruno Villanova on 03/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import RxSwift
import SocketIO

extension Reactive where Base: SocketIOClient {

    public func on(_ event: String) -> Observable<[Any]> {
        return Observable.create { observer in
            let id = self.base.on(event) { items, _ in
                observer.onNext(items)
            }

            return Disposables.create {
                self.base.off(id: id)
            }
        }
    }
}
