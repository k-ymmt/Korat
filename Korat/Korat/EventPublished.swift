//
//  EventPublished.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/08.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct EventPublished<Value> {
    private let subject: PassthroughSubject<Value, Error>
    
    var wrappedValue: AnyPublisher<Value, Error> {
        subject.eraseToAnyPublisher()
    }
    
    init() {
        subject = PassthroughSubject()
    }

    func send(_ value: Value) {
        subject.send(value)
    }
    
    func send(completion: Subscribers.Completion<Error>) {
        subject.send(completion: completion)
    }
}
