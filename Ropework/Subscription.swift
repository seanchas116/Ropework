import Foundation

public protocol SubscriptionType {
    func unsubscribe()
}

public struct Subscription: SubscriptionType {
    private let _unsubscribe: () -> Void
    
    public init(unsubscribe: () -> Void) {
        _unsubscribe = unsubscribe
    }
    
    public init(object: AnyObject) {
        var ref: AnyObject? = object
        unused(ref)
        self.init {
            ref = nil
        }
    }
    
    public func unsubscribe() {
        _unsubscribe()
    }
}

private func unused<T>(x: T) {}

extension SubscriptionType {
    public func addTo(bag: SubscriptionBag) {
        bag._subscriptions.append(self)
    }
}

public class SubscriptionBag {
    private var _subscriptions = [SubscriptionType]()
    
    public init() {
    }
    
    deinit {
        for s in _subscriptions {
            s.unsubscribe()
        }
    }
}
