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

RLM_HEADER_AUDIT_BEGIN(nullability, sendability)

@class RLMObjectSchema;

/// :nodoc:
NS_SWIFT_NAME(ObjectBase)
@interface RLMObjectBase : NSObject

/**
 The object schema which lists the managed properties for the object.
 */
@property (nonatomic, readonly) RLMObjectSchema *objectSchema;

@property (nonatomic, readonly, getter = isInvalidated) BOOL invalidated;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

+ (NSString *)className;

// Returns whether the class is included in the default set of classes managed by a Realm.
+ (BOOL)shouldIncludeInDefaultSchema;

+ (nullable NSString *)_realmObjectName;

#pragma mark - Dynamic Accessors

/// :nodoc:
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/// :nodoc:
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

/**
 Information about a specific property which changed in an `RLMObject` change notification.
 */
@interface RLMPropertyChange : NSObject

/**
 The name of the property which changed.
 */
@property (nonatomic, readonly, strong) NSString *name;

/**
 The value of the property before the change occurred. This will always be `nil`
 if the change happened on the same thread as the notification and for `RLMArray`
 properties.

 For object properties this will give the object which was previously linked to,
 but that object will have its new values and not the values it had before the
 changes. This means that `previousValue` may be a deleted object, and you will
 need to check `invalidated` before accessing any of its properties.
 */
@property (nonatomic, readonly, strong, nullable) id previousValue;

/**
 The value of the property after the change occurred. This will always be `nil`
 for `RLMArray` properties.
 */
@property (nonatomic, readonly, strong, nullable) id value;

@end

/**
 A callback block for `RLMObject` notifications.

 If the object is deleted from the managing Realm, the block is called with
 `deleted` set to `YES` and the other two arguments are `nil`. The block will
 never be called again after this.

 If the object is modified, the block will be called with `deleted` set to
 `NO`, a `nil` error, and an array of `RLMPropertyChange` objects which
 indicate which properties of the objects were modified.

 `error` is always `nil` and will be removed in a future version.
 */
typedef void (^RLMObjectChangeBlock)(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes);

RLM_HEADER_AUDIT_END(nullability, sendability)
