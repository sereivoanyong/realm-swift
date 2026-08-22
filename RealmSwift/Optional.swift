////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
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

internal extension Decoder {
    func decodeOptional<T: _RealmSchemaDiscoverable>(_ type: T.Type) throws -> T where T: Decodable {
        let container = try singleValueContainer()
        if container.decodeNil() {
            if let type = T.self as? _ObjcBridgeable.Type, let value = type._rlmFromObjc(NSNull()) {
                return value as! T
            }
            throw DecodingError.typeMismatch(T.self, .init(codingPath: self.codingPath, debugDescription: "Cannot convert nil to \(T.self)"))
        }
        return try container.decode(T.self)
    }
}
