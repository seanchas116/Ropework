import Foundation

public protocol PropertyType {
    associatedtype Signal: SignalType
    var changed: Signal { get }
    var value: Signal.Value { get }
}

public protocol MutablePropertyType: class, PropertyType {
    var value: Signal.Value { get set }
}

extension PropertyType {
    typealias Value = Signal.Value
    
    public func map<T>(transform: (Value) -> T) -> LazyProperty<T> {
        return LazyProperty(changed: changed.map { transform($0) }) { transform(self.value) }
    }
    
    @warn_unused_result(message="Subscription must be stored in SubscriptionBag to keep it alive")
    public func bindTo<T: MutablePropertyType where T.Signal.Value == Value>(dest: T) -> SubscriptionType {
        return bindTo { dest.value = $0 }
    }
    
    @warn_unused_result(message="Subscription must be stored in SubscriptionBag to keep it alive")
    public func bindTo<T: MutablePropertyType where T.Signal.Value == Value?>(dest: T) -> SubscriptionType {
        return bindTo { dest.value = $0 }
    }
    
    @warn_unused_result(message="Subscription must be stored in SubscriptionBag to keep it alive")
    public func bindTo(setter: (Value) -> Void) -> SubscriptionType {
        setter(value)
        return changed.subscribe { newValue in
            setter(newValue)
        }
    }
}

extension PropertyType where Signal.Value: Equatable {
    public var distinct: LazyProperty<Signal.Value> {
        let changed = LazySignal<Signal.Value> { bag, emit in
            var lastValue = self.value
            self.changed.subscribe { newValue in
                if lastValue != newValue {
                    lastValue = newValue
                    emit(newValue)
                }
            }.addTo(bag)
        }
        return LazyProperty(changed: changed) { self.value }
    }
}

public func combine<P1: PropertyType, P2: PropertyType, V>(p1: P1, _ p2: P2, transform: (P1.Signal.Value, P2.Signal.Value) -> V) -> LazyProperty<V> {
    let getValue = { transform(p1.value, p2.value) }
    let changed = merge(p1.changed.voidSignal, p2.changed.voidSignal).map(getValue)
    return LazyProperty(changed: changed, getValue: getValue)
}

public func combine<P1: PropertyType, P2: PropertyType, P3: PropertyType, V>(p1: P1, _ p2: P2, _ p3: P3, transform: (P1.Signal.Value, P2.Signal.Value, P3.Signal.Value) -> V) -> LazyProperty<V> {
    let getValue = { transform(p1.value, p2.value, p3.value) }
    let changed = merge(p1.changed.voidSignal, p2.changed.voidSignal, p3.changed.voidSignal).map(getValue)
    return LazyProperty(changed: changed, getValue: getValue)
}
