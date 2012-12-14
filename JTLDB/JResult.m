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
#import "JResult.h"
#import "JRow.h"
#import "JConnection.h"

@implementation JResult
@synthesize sql = _sql;
@synthesize args = _args;
@synthesize SQLiteResultCode = _SQLiteResultCode;
@synthesize rows = _rows;

+ (JResult *)resultFromSQL:(NSString *)sql args:(NSArray *)args onConnection:(JConnection *)connection {
    if (!connection) {
        NSLog(@"JResult [ERROR]: JTLDBConnection is nil");
        return nil;
    }

    JResult *result = [[JResult alloc] init];
    result.sql = sql;
    result.args = args;

    // get cached statement

    sqlite3_stmt *stmt = [connection cachedStatementForSql:sql];
    [JResult bindArgs:args toStatement:stmt];
    result.SQLiteResultCode = sqlite3_step(stmt);

    // If SQLite result code is SQLITE_ROW, it is a read statement

    if (result.SQLiteResultCode == SQLITE_ROW) {

        // Create the column-name map

        int columnCount = sqlite3_column_count(stmt);
        NSMutableDictionary *columnMap = [NSMutableDictionary dictionary];
        for (int c = 0; c < columnCount; c++) {
            const char *n = sqlite3_column_name(stmt, c);
            if (n) {
                NSString *fieldName = [NSString stringWithUTF8String:n];
                const char *t = sqlite3_column_table_name(stmt, c);
                if (t) {
                    NSString *tableName = [NSString stringWithUTF8String:t];
                    [columnMap setValue:[NSNumber numberWithInt:c] forKey:[NSString stringWithFormat:@"%@.%@", tableName, fieldName]];
                }
            }
        }

        // Process rows

        result.rows = [NSMutableArray array];
        while (result.SQLiteResultCode == SQLITE_ROW) {
            NSMutableArray *values = [NSMutableArray array];
            for (int c = 0; c < columnCount; c++) {
                id obj;
                switch (sqlite3_column_type(stmt, c)) {
                    case SQLITE_INTEGER: {
                        int i = sqlite3_column_int(stmt, c);
                        obj = [NSNumber numberWithInt:i];
                        break;
                    }
                    case SQLITE_FLOAT: {
                        double d = sqlite3_column_double(stmt, c);
                        obj = [NSNumber numberWithDouble:d];
                        break;
                    }
                    case SQLITE_TEXT: {
                        const char *t = (const char *) sqlite3_column_text(stmt, c);
                        obj = [NSString stringWithUTF8String:t];
                        break;
                    }
                    case SQLITE_BLOB: {
                        obj = [NSData dataWithBytes:sqlite3_column_blob(stmt, c) length:sqlite3_column_bytes(stmt, c)];
                        break;
                    }
                    case SQLITE_NULL: {
                        obj = [NSNull null];
                        break;
                    }
                    default: {
                        obj = [NSNull null];
                        NSLog(@"JResult [ERROR]: sqlite3_column_type type not mapped for type: %d", sqlite3_column_type(stmt, c));
                        break;
                    }
                }
                [values addObject:obj];
            }

            JRow *row = [[JRow alloc] initWithValues:values columnMap:columnMap];
            [result.rows addObject:row];
            result.SQLiteResultCode = sqlite3_step(stmt);
        }
    }

    return result;
}

+ (NSArray *)rowsFromSQL:(NSString *)sql args:(NSArray *)args onConnection:(JConnection *)connection {
    return [JResult resultFromSQL:sql args:args onConnection:connection].rows;
}

#pragma mark - Helpers

+ (void)bindArgs:(NSArray *)args toStatement:(sqlite3_stmt *)stmt {
    int argCount = sqlite3_bind_parameter_count(stmt);
    if (argCount != [args count]) {
        NSLog(@"JResult [ERROR]: Argument count in args NSArray does not match SQL bindable parameters.");
        return;
    }

    for (int i = 0; i < argCount; i++) {
        int rc = [JResult bindObject:[args objectAtIndex:i] toColumn:(i + 1) inStatement:stmt];
        if (rc != SQLITE_OK) {
            NSLog(@"JResult [ERROR]: Error binding args to statement. Sqlite Result Code: %d", rc);
        }
    }
}

+ (int)bindObject:(id)object toColumn:(int)idx inStatement:(sqlite3_stmt *)stmt {
    int rc;

    if (!object || object == [NSNull null]) {
        rc = sqlite3_bind_null(stmt, idx);
    } else if ([object isKindOfClass:[NSData class]]) {
        rc = sqlite3_bind_blob(stmt, idx, [object bytes], (int) [object length], SQLITE_STATIC);
    } else if ([object isKindOfClass:[NSDate class]]) {
        rc = sqlite3_bind_double(stmt, idx, [object timeIntervalSince1970]);
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if (strcmp([object objCType], @encode(BOOL)) == 0) {
            rc = sqlite3_bind_int(stmt, idx, ([object boolValue] ? 1 : 0));
        } else if (strcmp([object objCType], @encode(int)) == 0) {
            rc = sqlite3_bind_int64(stmt, idx, [object longValue]);
        } else if (strcmp([object objCType], @encode(long)) == 0) {
            rc = sqlite3_bind_int64(stmt, idx, [object longValue]);
        } else if (strcmp([object objCType], @encode(long long)) == 0) {
            rc = sqlite3_bind_int64(stmt, idx, [object longLongValue]);
        } else if (strcmp([object objCType], @encode(float)) == 0) {
            rc = sqlite3_bind_double(stmt, idx, [object floatValue]);
        } else if (strcmp([object objCType], @encode(double)) == 0) {
            rc = sqlite3_bind_double(stmt, idx, [object doubleValue]);
        } else {
            NSLog(@"JResult [ERROR]: Error finding the correct type of number to bind to sqlite statement. Object trying to bind: %@", object);
            rc = sqlite3_bind_text(stmt, idx, [[object description] UTF8String], -1, SQLITE_STATIC);
        }
    } else {
        rc = sqlite3_bind_text(stmt, idx, [(NSString *) object cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_STATIC);
    }

    return rc;
}

@end