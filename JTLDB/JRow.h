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

@interface JRow : NSObject

- (id)initWithValues:(NSArray *)values columnMap:(NSDictionary *)columnMap;

// NSString Methods

- (NSString *)stringForColumnIdx:(int)idx;

- (NSString *)stringForTableName:(NSString *)tableName columnName:(NSString *)columnName;

// NSData Methods

- (NSData *)dataForColumnIdx:(int)idx;

- (NSData *)dataForTableName:(NSString *)tableName columnName:(NSString *)columnName;

// NSDate Methods

- (NSDate *)dateForColumnIdx:(int)idx;

- (NSDate *)dateForTableName:(NSString *)tableName columnName:(NSString *)columnName;

// NSNumber Methods

- (NSNumber *)numberForColumnIdx:(int)idx;

- (NSNumber *)numberForTableName:(NSString *)tableName columnName:(NSString *)columnName;

@end