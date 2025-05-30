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

import Realm.Private

extension Realm {
    /**
     A `Configuration` instance describes the different options used to create an instance of a Realm.

     `Configuration` instances are just plain Swift structs. Unlike `Realm`s and `Object`s, they can be freely shared
     between threads as long as you do not mutate them.

     Creating configuration values for class subsets (by setting the `objectClasses` property) can be expensive. Because
     of this, you will normally want to cache and reuse a single configuration value for each distinct configuration
     rather than creating a new value each time you open a Realm.
     */
    public typealias Configuration = RealmConfiguration
}

extension Realm.Configuration {

    /**
     Creates a `Configuration` which can be used to create new `Realm` instances.

     - note: The `fileURL`, and `inMemoryIdentifier`, parameters are mutually exclusive. Only
     set one of them, or none if you wish to use the default file URL.

     - parameter fileURL:            The local URL to the Realm file.
     - parameter inMemoryIdentifier: A string used to identify a particular in-memory Realm.
     - parameter encryptionKey:      An optional 64-byte key to use to encrypt the data.
     - parameter readOnly:           Whether the Realm is read-only (must be true for read-only files).
     - parameter schemaVersion:      The current schema version.
     - parameter migrationBlock:     The block which migrates the Realm to the current version.
     - parameter deleteRealmIfMigrationNeeded: If `true`, recreate the Realm file with the provided
     schema if a migration is required.
     - parameter shouldCompactOnLaunch: A block called when opening a Realm for the first time during the
     life of a process to determine if it should be compacted before being
     returned to the user. It is passed the total file size (data + free space)
     and the total bytes used by data in the file.

     Return `true ` to indicate that an attempt to compact the file should be made.
     The compaction will be skipped if another process is accessing it.
     - parameter objectTypes:        The subset of `Object` and `EmbeddedObject` subclasses persisted in the Realm.
     - parameter seedFilePath:       The path to the realm file that will be copied to the fileURL when opened
     for the first time.
     */
    @preconcurrency
    public convenience init(
      fileURL: URL? = URL(fileURLWithPath: RLMRealmPathForFile("default.realm"), isDirectory: false),
      inMemoryIdentifier: String? = nil,
      encryptionKey: Data? = nil,
      readOnly: Bool = false,
      schemaVersion: UInt64 = 0,
      migrationBlock: MigrationBlock? = nil,
      deleteRealmIfMigrationNeeded: Bool = false,
      shouldCompactOnLaunch: (@Sendable (Int, Int) -> Bool)? = nil,
      objectTypes: [ObjectBase.Type]? = nil,
      seedFilePath: URL? = nil
    ) {
        self.init()
        self.fileURL = fileURL
        if let inMemoryIdentifier {
            self.inMemoryIdentifier = inMemoryIdentifier
        }
        self.encryptionKey = encryptionKey
        self.readOnly = readOnly
        self.schemaVersion = schemaVersion
        self.migrationBlock = migrationBlock
        self.deleteRealmIfMigrationNeeded = deleteRealmIfMigrationNeeded
        self.shouldCompactOnLaunch = shouldCompactOnLaunch
        self.objectTypes = objectTypes
        self.seedFilePath = seedFilePath
    }

    /**
     A block called when opening a Realm for the first time during the
     life of a process to determine if it should be compacted before being
     returned to the user. It is passed the total file size (data + free space)
     and the total bytes used by data in the file.

     Return `true ` to indicate that an attempt to compact the file should be made.
     The compaction will be skipped if another process is accessing it.
     */
    @preconcurrency
    public var shouldCompactOnLaunch: (@Sendable (Int, Int) -> Bool)? {
        get { return __shouldCompactOnLaunch.map(ObjectiveCSupport.convert(object:)) }
        set { __shouldCompactOnLaunch = newValue.map(ObjectiveCSupport.convert(object:)) }
    }

    /// The classes managed by the Realm.
    public var objectTypes: [ObjectBase.Type]? {
        get { return __objectClasses as! [ObjectBase.Type]? }
        set { __objectClasses = newValue }
    }
}
