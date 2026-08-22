////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private

// A type which we can get the runtime schema information from
public protocol _RealmSchemaDiscoverable {
    // The Realm property type associated with this type
    static var _rlmType: PropertyType { get }
    static var _rlmOptional: Bool { get }
    // Does this type require @objc for legacy declarations? Not used for modern
    // declarations as no types use @objc.
    static var _rlmRequireObjc: Bool { get }

    // Set any fields of the property applicable to this type other than type/optional.
    // There are both static and non-static versions of this function because
    // some times need data from an instance (e.g. LinkingObjects, where the
    // source property name is runtime data and not part of the type), while
    // wrappers like Optional need to be able to recur to the wrapped type
    // without creating an instance of that.
    func _rlmPopulateProperty(_ prop: Property)
    static func _rlmPopulateProperty(_ prop: Property)
}

extension ObjectBase {
    /// Allow client code to generate properties (ie. via Swift Macros)
    @_spi(RealmSwiftPrivate)
    @objc open class func _customRealmProperties() -> [Property]? {
        return nil
    }
}

internal protocol SchemaDiscoverable: _RealmSchemaDiscoverable {}
extension SchemaDiscoverable {
    public static var _rlmOptional: Bool { false }
    public static var _rlmRequireObjc: Bool { true }
    public func _rlmPopulateProperty(_ prop: Property) { }
    public static func _rlmPopulateProperty(_ prop: Property) { }
}

extension Property {
    internal convenience init(name: String, value: _RealmSchemaDiscoverable) {
        let valueType = Swift.type(of: value)
        self.init()
        self.name = name
        self.type = valueType._rlmType
        self.isOptional = valueType._rlmOptional
        value._rlmPopulateProperty(self)
        valueType._rlmPopulateProperty(self)
        if valueType._rlmRequireObjc {
            self.updateAccessors()
        }
    }

    /// Exposed for Macros.
    /// Important: Keep args in same order & default value as `@Persisted` property wrapper
    @_spi(RealmSwiftPrivate)
    public convenience init<V: _Persistable>(
        name: String,
        objectType: ObjectBase.Type,
        valueType _: V.Type,
        isIndexed: Bool = false,
        isPrimaryKey: Bool = false,
        originProperty: String? = nil
    ) {
        self.init()
        self.name = name
        self.type = V._rlmType
        self.isOptional = V._rlmOptional
        self.isIndexed = isPrimaryKey || isIndexed
        self.isPrimaryKey = isPrimaryKey
        self.linkOriginPropertyName = originProperty
        V._rlmPopulateProperty(self)
        V._rlmSetAccessor(self)
        self.swiftIvar = ivar_getOffset(class_getInstanceVariable(objectType, "_" + name)!)
    }
}

private func getModernProperties(_ object: ObjectBase) -> [Property] {
    let columnNames: [String: String] = type(of: object).propertiesMapping()
    return Mirror(reflecting: object).children.compactMap { prop in
        guard let label = prop.label else { return nil }
        guard let value = prop.value as? DiscoverablePersistedProperty else {
            return nil
        }
        let property = Property(name: label, value: value)
        property.swiftIvar = ivar_getOffset(class_getInstanceVariable(type(of: object), label)!)
        property.columnName = columnNames[property.name]
        return property
    }
}

// If the property is a storage property for a lazy Swift property, return
// the base property name (e.g. `foo.storage` becomes `foo`). Otherwise, nil.
private func baseName(forLazySwiftProperty name: String) -> String? {
    // A Swift lazy var shows up as two separate children on the reflection tree:
    // one named 'x', and another that is optional and is named "$__lazy_storage_$_propName"
    if let storageRange = name.range(of: "$__lazy_storage_$_", options: [.anchored]) {
        return String(name[storageRange.upperBound...])
    }
    return nil
}

private func getProperties(_ cls: ObjectBase.Type) -> [Property] {
    if let props = cls._customRealmProperties() {
        return props
    }
    // Check for any modern properties and only scan for legacy properties if
    // none are found.
    let object = cls.init()
    let props = getModernProperties(object)
    return props
}

internal class ObjectUtil {
    private static let runOnce: Void = {
        RLMSetSwiftBridgeCallback { (value: Any) -> Any? in
            // `as AnyObject` required on iOS <= 13; it will compile but silently
            // fail to cast otherwise
            if let value = value as AnyObject as? _ObjcBridgeable {
                return value._rlmObjcValue
            }
            return nil
        }
    }()

    internal class func getSwiftProperties(_ cls: ObjectBase.Type) -> [Property] {
        _ = ObjectUtil.runOnce
        return getProperties(cls)
    }
}
