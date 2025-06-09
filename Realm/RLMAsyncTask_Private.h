////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

#import <Realm/RLMAsyncTask.h>

#import "RLMRealm_Private.h"

RLM_HEADER_AUDIT_BEGIN(nullability)

// A cancellable task for beginning an async write
NS_SWIFT_SENDABLE
@interface RLMAsyncWriteTask : NSObject
// Must only be called from within the Actor
- (instancetype)initWithRealm:(RLMRealm *)realm;
- (void)setTransactionId:(RLMAsyncTransactionId)transactionID;
- (void)complete:(bool)cancel;

// Can be called from any thread
- (void)wait:(void (^)(void))completion;
@end

RLM_HEADER_AUDIT_END(nullability)
