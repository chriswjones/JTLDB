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

static inline NSString *JTLDBFolderPath() {

#if TESTING
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
#endif

    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"JTLDB"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"JDatabase [ERROR]: Create JTLDB directory failed. Error: %@", error);
        }
    }
    return path;
}

@class JConnection;

@interface JDatabase : NSObject

@property(nonatomic, readonly) JConnection *defaultConnection;
@property(nonatomic, readonly) JConnection *readUncommittedConnection;

+ (JDatabase *)openDatabaseWithName:(NSString *)databaseFileName database:(NSString *)seedFile;

- (void)close;

@end