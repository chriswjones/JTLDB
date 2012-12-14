//
//  CreateTests.m
//  CreateTests
//
//  Created by Chris Jones on 11/19/12.
//  Copyright (c) 2012 Chris Jones. All rights reserved.
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
    [JDatabase openDatabaseWithName:dbName database:nil];
    NSString *dbPath = [JTLDBFolderPath() stringByAppendingPathComponent:dbName];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:dbPath], @"Create database without seed file");
}

- (void)testCreateDatabaseWithSeedFile {
    __block BOOL inProgress = YES;

    JDatabase *db = [JDatabase openDatabaseWithName:@"SnowReport2.db" database:@"seed.db"];

    // Make sure the file was copied.  The seed file has 2 records
    [db.defaultConnection queueBlock:^(JConnection *connection, JOperation *operation){
        JRow *row = [[JResult resultFromSQL:@"SELECT COUNT(id) FROM snow_report" args:nil onConnection:connection].rows objectAtIndex:0];
        STAssertEquals([[row numberForColumnIdx:0] integerValue], 2, @"Create database with seed file");
        inProgress = NO;
    }];

    while (inProgress);
}

@end
