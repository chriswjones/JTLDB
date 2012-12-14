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

#import "JOperation.h"
#import "JConnection.h"

@implementation JOperation {
    JConnection *_connection;
    void (^_block)(JConnection *connection, JOperation *operation);
}

- (id)initWithConnection:(JConnection *)connection block:(void (^)(JConnection *, JOperation *))block {
    self = [super init];
    if (self) {
        _connection = connection;
        _block = block;
    }

    return self;
}

- (void)main {
    if ([self isCancelled] || !_connection || !_block) {
        return;
    }

    _block(_connection, self);
}

@end