import Foundation

public class LazySignal<T>: SignalType {
    public typealias Value = T
    private let _subscribe: (SubscriptionBag, (Value) -> Void) -> Void
    private var _bag = SubscriptionBag()
    private var _signal = Signal<Value>()
    
    init(subscribe: (SubscriptionBag, (Value) -> Void) -> Void) {
        _subscribe = subscribe
    }
    
    public var subscriptionsCount: Int {
        return _signal.subscriptionsCount
    }
    
    public func subscribe(callback: (Value) -> Void) -> SubscriptionType {
        let subscription = _signal.subscribe(callback)
        if subscriptionsCount == 1 {
            _subscribe(_bag) { [weak self] in self?._signal.emit($0) }
        }
        return Subscription {
            subscription.unsubscribe()
            if self.subscriptionsCount == 0 {
                self._bag = SubscriptionBag()
            }
        }
    }
}