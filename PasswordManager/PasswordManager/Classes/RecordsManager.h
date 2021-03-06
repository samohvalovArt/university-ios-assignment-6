//
//  RecordsManager.h
//  PasswordManager
//
//  Created by Maxim Zabelin on 20/02/14.
//  Copyright (c) 2014 Noveo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preferences.h"

@interface RecordsManager : NSObject

/**
 *  Performs no initialization; please use @c -initWithURL: instead.
 */
- (id)init;

/**
 *  Initializes a newly created instance with the specifed URL.
 */
- (instancetype)initWithURL:(NSURL *)url
        passwordStorageMode:(PasswordStorageMethod*) mode;

/**
 *  Registers the specified record.
 */
- (void)registerRecord:(NSDictionary *)record;

/**
 *  Returns the records the receiver manages.
 */
- (NSArray *)records;
- (void)deleteRecord:(NSDictionary*) record;

/**
 *  Writes any modifications to the persistent domains to disk.
 *
 *  @return @c YES if the records were saved successfully to disk.
 */
- (BOOL)synchronize;

@end
