import Foundation

public struct AnyProperty<T>: PropertyType {
    public typealias Value = T
    public typealias Signal = AnySignal<T>
    
    private let _getValue: () -> T
    private let _getChanged: () -> AnySignal<T>
    
    public var value: T {
        return _getValue()
    }
    
    public var changed: AnySignal<T> {
        return _getChanged()
    }
    
    public init<P: PropertyType where P.Signal.Value == Value>(_ prop: P) {
        _getValue = { prop.value }
        _getChanged = { AnySignal(prop.changed) }
    }
}