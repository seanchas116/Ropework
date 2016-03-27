import Foundation

private class Subscriber <T> {
    let action: (T) -> Void
    
    init(_ action: (T) -> Void) {
        self.action = action
    }
}

public class Signal<T>: SignalType {
    public typealias Value = T
    
    private var _subscribers = Dictionary<ObjectIdentifier, Subscriber<T>>()
    
    public var subscriptionsCount: Int {
        return _subscribers.count
    }
    
    public func emit(value: T) {
        for s in _subscribers.values {
            s.action(value)
        }
    }
    
    public func subscribe(action: (Value) -> Void) -> SubscriptionType {
        let subscriber = Subscriber(action)
        let id = ObjectIdentifier(subscriber)
        _subscribers[id] = subscriber
        return Subscription {
            self._subscribers.removeValueForKey(id)
        }
    }
}