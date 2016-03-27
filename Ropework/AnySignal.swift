import Foundation

public struct AnySignal<T>: SignalType {
    public typealias Value = T
    private let _subscribe: ((Value) -> Void) -> SubscriptionType
    
    public init<S: SignalType where S.Value == Value>(_ signal: S) {
        _subscribe = { action in signal.subscribe(action) }
    }
    
    public func subscribe(callback: (Value) -> Void) -> SubscriptionType {
        return _subscribe(callback)
    }
}