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

#import "JRow.h"

@implementation JRow {
    NSArray *_values;
    NSDictionary *_columnMap;
}

- (id)initWithValues:(NSArray *)values columnMap:(NSDictionary *)columnMap {
    self = [super init];
    if (self) {
        _values = values;
        _columnMap = columnMap;
    }
    return self;
}

- (NSString *)stringForColumnIdx:(int)idx {
    if (idx >= [_values count]) {
        return nil;
    }
    id object = [_values objectAtIndex:idx];
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *) object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *) object stringValue];
    } else {
        return nil;
    }
}

- (NSString *)stringForTableName:(NSString *)tableName columnName:(NSString *)columnName {
    NSNumber *index = [self indexForTableName:tableName columnName:columnName];
    return index ? [self stringForColumnIdx:[index integerValue]] : nil;
}

- (NSData *)dataForColumnIdx:(int)idx {
    if (idx >= [_values count]) {
        return nil;
    }
    id object = [_values objectAtIndex:idx];
    if ([object isKindOfClass:[NSData class]]) {
        return (NSData *) object;
    } else {
        return nil;
    }
}

- (NSData *)dataForTableName:(NSString *)tableName columnName:(NSString *)columnName {
    NSNumber *index = [self indexForTableName:tableName columnName:columnName];
    return index ? [self dataForColumnIdx:[index integerValue]] : nil;
}

- (NSDate *)dateForColumnIdx:(int)idx {
    if (idx >= [_values count]) {
        return nil;
    }
    id object = [_values objectAtIndex:idx];
    if ([object isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *) object doubleValue]];
    } else {
        return nil;
    }
}

- (NSDate *)dateForTableName:(NSString *)tableName columnName:(NSString *)columnName {
    NSNumber *index = [self indexForTableName:tableName columnName:columnName];
    return index ? [self dateForColumnIdx:[index integerValue]] : nil;
}

- (NSNumber *)numberForColumnIdx:(int)idx {
    if (idx >= [_values count]) {
        return nil;
    }
    id object = [_values objectAtIndex:idx];
    if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    } else{
        return nil;
    }
}

- (NSNumber *)numberForTableName:(NSString *)tableName columnName:(NSString *)columnName {
    NSNumber *index = [self indexForTableName:tableName columnName:columnName];
    return index ? [self numberForColumnIdx:[index integerValue]] : nil;
}

#pragma mark - Helpers

- (NSNumber *)indexForTableName:(NSString *)tableName columnName:(NSString *)columnName {
    NSString *key = [NSString stringWithFormat:@"%@.%@", tableName, columnName];
    return [_columnMap objectForKey:key];
}

@end