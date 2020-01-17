//
//  PropertyPublished.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/05.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
public struct PropertyPublished<Value> {
    public var wrappedValue: PropertyPublisher<Value>

    public var value: Value {
        get { wrappedValue.value }
        set { wrappedValue.send(newValue) }
    }

    public init(defaultValue: Value) {
        wrappedValue = PropertyPublisher(defaultValue: defaultValue)
    }

    public func forceNotify() {
        wrappedValue.send(value)
    }
}

public struct PropertyPublisher<Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    private let subject: CurrentValueSubject<Value, Never>

    public var value: Value {
        subject.value
    }
    
    fileprivate init(defaultValue: Value) {
        self.subject = CurrentValueSubject(defaultValue)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
    
    fileprivate func send(_ value: Value) {
        subject.send(value)
    }
}

extension PropertyPublisher {
    public func bind(to other: PropertyPublished<Value>) -> Combine.Cancellable {
        var other = other
        return self.sink { other.value = $0 }
    }
}
