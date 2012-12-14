//
//  Copyright 2012 JTL Systems
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//          http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "JConnection.h"
#import "JOperation.h"

@implementation JConnection {
    sqlite3 *_db;
    NSOperationQueue *_queue;
    NSMutableDictionary *_statementCache;
}
@synthesize maxCacheSize = _maxCacheSize;

- (id)initWithPath:(NSString *)path flags:(int)flags {
    self = [super init];

    if (self) {

        // Open database connection

        int rc = sqlite3_open_v2([path fileSystemRepresentation], &_db, flags, NULL);
        if (rc != SQLITE_OK) {
            NSLog(@"JConnection [ERROR]: Error opening connection for path [%@] with flags [%d]", path, flags);
        }

        // New-up the cache and queue, set default max cache size

        _statementCache = [[NSMutableDictionary alloc] init];
        _maxCacheSize = 50;
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];


        // Add listener for low memory warning

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self close];
}

- (void)close {
    [_queue cancelAllOperations];
    sqlite3_close(_db);
}

- (int)queueSize {
    return [_queue operationCount];
}

- (JOperation *)queueBlock:(void (^)(JConnection *, JOperation *))block {
    return [self queueBlock:block priority:NSOperationQueuePriorityNormal];
}

- (JOperation *)queueBlock:(void (^)(JConnection *, JOperation *))block priority:(NSOperationQueuePriority)queuePriority {
    JOperation *operation = [[JOperation alloc] initWithConnection:self block:block];
    [operation setQueuePriority:queuePriority];
    [_queue addOperation:operation];
    return operation;
}

#pragma mark - Statement cache

- (sqlite3_stmt *)cachedStatementForSql:(NSString *)sql {

    // Check cache for statement

    NSValue *stmtObj = [_statementCache objectForKey:sql];
    sqlite3_stmt *stmt = (sqlite3_stmt *) [stmtObj pointerValue];

    if (!stmt) {

        // Statement not cached, check max cache size if caching enabled

        if (_maxCacheSize > 0 && [_statementCache count] >= _maxCacheSize) {

            // Remove oldest entry

            NSString *lastKey = [[_statementCache allKeys] objectAtIndex:0];
            NSValue *statement = [_statementCache objectForKey:lastKey];
            [self finalizeStatement:statement];
            [_statementCache removeObjectForKey:lastKey];
        }

        // Create statement

        if (sqlite3_prepare_v2(_db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &stmt, 0) != SQLITE_OK) {
            NSLog(@"JConnection [ERROR]: Error preparing a statement for %@", sql);
            return nil;
        }

        // Add statement to cache if caching enabled

        if (_maxCacheSize > 0) {
            NSValue *cacheStmt = [NSValue valueWithPointer:stmt];
            [_statementCache setObject:cacheStmt forKey:sql];
        }
    } else {

        // Statement already exists, reset it so it can be re-used

        sqlite3_reset(stmt);
    }

    return stmt;
}

#pragma mark - Memory warning

- (void)didReceiveMemoryWarning:(NSNotification *)notification {

    // Finalize SQLite statements

    [_statementCache enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSValue *stmtObj, BOOL *stop) {
        [self finalizeStatement:stmtObj];
    }];

    // Empty dictionary

    [_statementCache removeAllObjects];
}

#pragma mark - Helpers

- (void)finalizeStatement:(NSValue *)statement {
    sqlite3_stmt *stmt = (sqlite3_stmt *) [statement pointerValue];
    sqlite3_finalize(stmt);
}

@end