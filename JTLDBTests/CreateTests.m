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

#import "CreateTests.h"
#import "JTLDB.h"

@implementation CreateTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtPath:JTLDBFolderPath() error:nil];
    [super tearDown];
}

- (void)testCreateDatabaseWithoutSeedFile {
    NSString *dbName = @"SnowReport1.db";
    [JDatabase openDatabaseWithName:dbName seedDatabase:nil];
    NSString *dbPath = [JTLDBFolderPath() stringByAppendingPathComponent:dbName];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:dbPath], @"Create database without seed file");
}

- (void)testCreateDatabaseWithSeedFile {
    __block BOOL inProgress = YES;

    JDatabase *db = [JDatabase openDatabaseWithName:@"SnowReport2.db" seedDatabase:@"seed.db"];

    // Make sure the file was copied.  The seed file has 2 records
    [db.defaultConnection queueBlock:^(JConnection *connection, JOperation *operation){
        JRow *row = [[JResult resultFromSQL:@"SELECT COUNT(id) FROM snow_report" args:nil onConnection:connection].rows objectAtIndex:0];
        STAssertEquals([[row numberForColumnIdx:0] integerValue], 2, @"Create database with seed file");
        inProgress = NO;
    }];

    while (inProgress);
}

@end
