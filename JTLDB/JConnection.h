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

#import "sqlite3.h"

@class JOperation;

@interface JConnection : NSObject

@property(nonatomic) int maxCacheSize;

- (id)initWithPath:(NSString *)path flags:(int)flags;

- (void)close;

- (int)queueSize;

- (JOperation *)queueBlock:(void (^)(JConnection *, JOperation *))block;

- (JOperation *)queueBlock:(void (^)(JConnection *, JOperation *))block priority:(NSOperationQueuePriority)queuePriority;

- (sqlite3_stmt *)cachedStatementForSql:(NSString *)sql;

@end