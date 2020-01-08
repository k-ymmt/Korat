//
//  ActionPublished.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/05.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
public struct ActionPublished<Value> {
    private let subject: PassthroughSubject<Value, Never>

    public var wrappedValue: ActionPublisher<Value>

    public init() {
        subject = PassthroughSubject()
        wrappedValue = ActionPublisher(subject: subject)
    }

    public func send(_ input: Value) {
        subject.send(input)
    }
}

public struct ActionPublisher<Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    private let subject: PassthroughSubject<Value, Never>

    public init(subject: PassthroughSubject<Value, Never>) {
        self.subject = subject
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
}

extension ActionPublisher {
    func bind(to other: EventPublished<Value>) -> Combine.Cancellable {
        self.sink { (value) in other.send(value) }
    }
}
