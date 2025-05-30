////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
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

#import <Realm/RLMConstants.h>

#ifdef __cplusplus
extern "C" {
#endif

@class RLMRealm, RLMSchema, RLMObjectBase, RLMResults, RLMProperty;

/**
 What to do when an object being added to or created in a Realm has a primary key that already exists.
 */
typedef NS_CLOSED_ENUM(NSUInteger, RLMUpdatePolicy) {
    /**
     Throw an exception. This is the default when no policy is specified for `add()` or `create()`.

     This behavior is the same as passing `update: false` to `add()` or `create()`.
     */
    RLMUpdatePolicyError = 1,

    /**
     Overwrite only properties in the existing object which are different from the new values. This results
     in change notifications reporting only the properties which changed, and influences the sync merge logic.

     If few or no of the properties are changing this will be faster than .all and reduce how much data has
     to be written to the Realm file. If all of the properties are changing, it may be slower than .all (but
     will never result in *more* data being written).
     */
    RLMUpdatePolicyModified = 3,

    /**
     Overwrite all properties in the existing object with the new values, even if they have not changed. This
     results in change notifications reporting all properties as changed, and influences the sync merge logic.

     This behavior is the same as passing `update: true` to `add()` or `create()`.
     */
    RLMUpdatePolicyAll = 2,
} NS_SWIFT_NAME(UpdatePolicy);

RLM_HEADER_AUDIT_BEGIN(nullability)

void RLMVerifyHasPrimaryKey(Class cls);

void RLMVerifyInWriteTransaction(RLMRealm *const realm);

//
// Adding, Removing, Getting Objects
//

// add an object to the given realm
void RLMAddObjectToRealm(RLMObjectBase *object, RLMRealm *realm, RLMUpdatePolicy);

// delete an object from its realm
void RLMDeleteObjectFromRealm(RLMObjectBase *object, RLMRealm *realm);

// deletes all objects from a realm
void RLMDeleteAllObjectsFromRealm(RLMRealm *realm);

// get objects of a given class
RLMResults *RLMGetObjects(RLMRealm *realm, NSString *objectClassName, NSPredicate * _Nullable predicate)
NS_RETURNS_RETAINED;

// get an object with the given primary key
id _Nullable RLMGetObject(RLMRealm *realm, NSString *objectClassName, id _Nullable key) NS_RETURNS_RETAINED;

// create object from array or dictionary
RLMObjectBase *RLMCreateObjectInRealmWithValue(RLMRealm *realm, NSString *className,
                                               id _Nullable value, RLMUpdatePolicy updatePolicy)
NS_RETURNS_RETAINED;

//
// Accessor Creation
//


// Perform the per-property accessor initialization for a managed RealmSwiftObject
// promotingExisting should be true if the object was previously used as an
// unmanaged object, and false if it is a newly created object.
void RLMInitializeSwiftAccessor(RLMObjectBase *object, bool promotingExisting);

#ifdef __cplusplus
}

namespace realm {
    class Obj;
    class Table;
    struct ColKey;
    struct ObjLink;
}
class RLMClassInfo;

// get an object with a given table & object key
RLMObjectBase *RLMObjectFromObjLink(RLMRealm *realm,
                                    realm::ObjLink&& objLink,
                                    bool parentIsSwiftObject) NS_RETURNS_RETAINED;

// Create accessors
RLMObjectBase *RLMCreateObjectAccessor(RLMClassInfo& info, int64_t key) NS_RETURNS_RETAINED;
RLMObjectBase *RLMCreateObjectAccessor(RLMClassInfo& info, const realm::Obj& obj) NS_RETURNS_RETAINED;
#endif

RLM_HEADER_AUDIT_END(nullability)
