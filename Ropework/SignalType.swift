import Foundation

public protocol SignalType {
    associatedtype Value
    func subscribe(action: (Value) -> Void) -> SubscriptionType
}

extension SignalType {
    public func map<T>(transform: (Value) -> T) -> LazySignal<T> {
        return LazySignal { bag, emit in
            self.subscribe { value in
                emit(transform(value))
            }.addTo(bag)
        }
    }
    
    public func filter(predicate: (Value) -> Bool) -> LazySignal<Value> {
        return LazySignal { bag, emit in
            self.subscribe { value in
                if predicate(value) {
                    emit(value)
                }
            }.addTo(bag)
        }
    }
    
    public var voidSignal: LazySignal<Void> {
        return map { _ in }
    }
}

public func merge<T: SignalType, U: SignalType where T.Value == U.Value>(s1: T, _ s2: U) -> LazySignal<T.Value> {
    return LazySignal { bag, emit in
        s1.subscribe { emit($0) }.addTo(bag)
        s2.subscribe { emit($0) }.addTo(bag)
    }
}

public func merge<T: SignalType, U: SignalType, V: SignalType where T.Value == U.Value, U.Value == V.Value>(s1: T, _ s2: U, _ s3: V) -> LazySignal<T.Value> {
    return LazySignal { bag, emit in
        s1.subscribe { emit($0) }.addTo(bag)
        s2.subscribe { emit($0) }.addTo(bag)
        s3.subscribe { emit($0) }.addTo(bag)
    }
}
