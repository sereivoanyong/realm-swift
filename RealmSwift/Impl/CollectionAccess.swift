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

import Realm

private func isSameCollection<C: RLMCollection>(_ lhs: C, _ rhs: Any) -> Bool {
    // Managed isEqual checks if they're backed by the same core field, so it does exactly what we need
    if lhs.realm != nil {
        return lhs.isEqual(rhs)
    }
    // For unmanaged we want to check if the backing collection is the same instance
    if let rhs = rhs as? RLMSwiftCollectionBase<C> {
        return lhs === rhs.collection
    }
    return lhs === rhs as AnyObject
}

internal protocol MutableRealmCollection {
    func assign(_ value: Any)

    // Unmanaged collection properties need a reference to their parent object for
    // KVO to work because the mutation is done via the collection object but the
    // observation is on the parent.
    func setParent(_ object: ObjectBase, _ property: Property)
}

extension List: MutableRealmCollection {
    func assign(_ value: Any) {
        guard !isSameCollection(collection, value) else { return }
        RLMAssignToCollection(collection, value)
    }
    func setParent(_ object: ObjectBase, _ property: Property) {
        collection.setParent(object, property: property)
    }
}

extension MutableSet: MutableRealmCollection {
    func assign(_ value: Any) {
        guard !isSameCollection(collection, value) else { return }
        RLMAssignToCollection(collection, value)
    }
    func setParent(_ object: ObjectBase, _ property: Property) {
        collection.setParent(object, property: property)
    }
}

extension Map: MutableRealmCollection {
    func assign(_ value: Any) {
        guard !isSameCollection(collection, value) else { return }
        collection.setDictionary(value)
    }
    func setParent(_ object: ObjectBase, _ property: Property) {
        collection.setParent(object, property: property)
    }
}
