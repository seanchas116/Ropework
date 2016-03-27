import Foundation

public struct LazyProperty<T>: PropertyType {
    public typealias Value = T
    private let _getValue: () -> T
    public let changed: AnySignal<T>
    
    public var value: T {
        return _getValue()
    }
    
    public init<S: SignalType where S.Value == Value>(changed: S, getValue: () -> T) {
        _getValue = getValue
        self.changed = AnySignal(changed)
    }
}
