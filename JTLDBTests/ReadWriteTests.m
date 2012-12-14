//
// Created by chrisjones on 11/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ReadWriteTests.h"
#import "JTLDB.h"


@implementation ReadWriteTests {
    JDatabase *_db;
}

- (void)setUp {
    [super setUp];
    _db = [JDatabase openDatabaseWithName:@"SnowReport.db" database:@"seed.db"];
}

- (void)tearDown {
    [_db close];
    [[NSFileManager defaultManager] removeItemAtPath:JTLDBFolderPath() error:nil];
    [super tearDown];
}

- (void)testReadWrite {
    __block BOOL inProgress = YES;

    NSNumber *intNumber = [NSNumber numberWithInt:3];
    NSString *text = @"Report 3";
    NSDate *date = [NSDate date];
    NSNumber *doubleNumber = [NSNumber numberWithDouble:6.4];

    // Write
    [_db.defaultConnection queueBlock:^(JConnection *connection, JOperation *operation){
        [JResult resultFromSQL:@"INSERT INTO snow_report (id, report, date, snow_fall) VALUES (?,?,?,?)" args:[NSArray arrayWithObjects:intNumber, text, date, doubleNumber, nil] onConnection:connection];
    }];

    // Read
    [_db.defaultConnection queueBlock:^(JConnection *connection, JOperation *operation){
        JResult *result = [JResult resultFromSQL:@"SELECT * FROM snow_report WHERE id = ?" args:[NSArray arrayWithObject:intNumber] onConnection:connection];
        if ([result.rows count] < 1) {
            STFail(@"Read write test failed. Row not found");
        }else {
            JRow *row = [result.rows objectAtIndex:0];
            STAssertEqualObjects([row numberForColumnIdx:0], intNumber, @"int");
            STAssertEqualObjects([row stringForColumnIdx:1], text, @"text");
            STAssertEquals([[row dateForColumnIdx:2] timeIntervalSince1970], [date timeIntervalSince1970], @"date");
            STAssertEqualObjects([row numberForColumnIdx:3], doubleNumber , @"double");
        }
        inProgress = NO;
    }];

    while (inProgress);
}

@end