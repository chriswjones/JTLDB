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
#import "JDatabase.h"
#import "JConnection.h"
#import "JOperation.h"
#import "JResult.h"

@implementation JDatabase
@synthesize defaultConnection = _defaultConnection;
@synthesize readUncommittedConnection = _readUncommittedConnection;

+ (JDatabase *)openDatabaseWithName:(NSString *)databaseFileName seedDatabase:(NSString *)seedFile {
    JDatabase *database = [[JDatabase alloc] init];

    // Check if DB exists in filesystem

    NSString *path = [JTLDBFolderPath() stringByAppendingPathComponent:databaseFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {

        // Database file does not exist, attempt to copy a seed file from bundle

        if (seedFile && [seedFile length] > 0) {

#if TESTING
            NSString *pathForBundleDB = [[NSBundle bundleForClass:[self class]] pathForResource:seedFile ofType:nil];
#else 
            NSString *pathForBundleDB = [[NSBundle mainBundle] pathForResource:seedFile ofType:nil];
#endif

            if (pathForBundleDB) {
                BOOL success = [[NSFileManager defaultManager] copyItemAtPath:pathForBundleDB toPath:path error:NULL];
                if (!success) {
                    NSLog(@"JDatabase [ERROR]: Copying database file %@ from main bundle failed.", databaseFileName);
                }
            } else {
                NSLog(@"JDatabase [INFO]: File doesn't exist: %@", databaseFileName);
            }
        }
    }

    [database setupConnectionsForPath:path];
    return database;
}

- (void)setupConnectionsForPath:(NSString *)path {
    _defaultConnection = [[JConnection alloc] initWithPath:path flags:(SQLITE_OPEN_READWRITE| SQLITE_OPEN_CREATE | SQLITE_OPEN_SHAREDCACHE)];
    _readUncommittedConnection = [[JConnection alloc] initWithPath:path flags:(SQLITE_OPEN_READONLY| SQLITE_OPEN_SHAREDCACHE)];

    // Read Uncommitted connection settings

    [_readUncommittedConnection queueBlock:^(JConnection *connection, JOperation *operation) {
        NSString *sql = @"PRAGMA read_uncommitted = 1";
        JResult *result = [JResult resultFromSQL:sql args:nil onConnection:connection];
        if (result.SQLiteResultCode != SQLITE_DONE) {

            // Read uncommitted setup failed

            NSLog(@"JDatabase [ERROR]: Error setting read_uncommitted = 1");
        }
    }];
}

- (void)close {
    [_defaultConnection close];
    [_readUncommittedConnection close];
}

@end