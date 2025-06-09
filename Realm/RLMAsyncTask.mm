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

#import "RLMAsyncTask_Private.h"

#import "RLMError_Private.hpp"
#import "RLMRealm_Private.hpp"
#import "RLMRealmConfiguration_Private.hpp"
#import "RLMScheduler.h"
#import "RLMUtil.hpp"

#import <realm/exceptions.hpp>
#import <realm/object-store/thread_safe_reference.hpp>

@implementation RLMAsyncWriteTask {
    // Mutex guards _realm and _completion
    RLMUnfairMutex _mutex;

    // _realm is non-nil only while waiting for an async write to begin. It is
    // set to `nil` when it either completes or is cancelled.
    RLMRealm *_realm;
    dispatch_block_t _completion;

    RLMAsyncTransactionId _id;
}

// No locking needed for these two as they have to be called before the
// cancellation handler is set up
- (instancetype)initWithRealm:(RLMRealm *)realm {
    if (self = [super init]) {
        _realm = realm;
    }
    return self;
}
- (void)setTransactionId:(RLMAsyncTransactionId)transactionID {
    _id = transactionID;
}

- (void)complete:(bool)cancel {
    // The swap-under-lock pattern is used to avoid invoking the callback with
    // a lock held
    dispatch_block_t completion;
    {
        std::lock_guard lock(_mutex);
        std::swap(completion, _completion);
        if (cancel) {
            // This is a no-op if cancellation is coming after the wait completed
            [_realm cancelAsyncTransaction:_id];
        }
        _realm = nil;
    }
    if (completion) {
        completion();
    }
}

- (void)wait:(void (^)())completion {
    {
        std::lock_guard lock(_mutex);
        // `_realm` being non-nil means it's neither completed nor been cancelled
        if (_realm) {
            _completion = completion;
            return;
        }
    }

    // It has either been completed or cancelled, so call the callback immediately
    completion();
}
@end
