//
//  BloomAddressBookMatcher.h
//  sample
//
//  Created by Harlan on 3/11/17.
//  Copyright © 2017 clojure-objc. All rights reserved.
//

typedef void (^CompletionBlock)(void);
typedef void (^FailureBlock)(void);


@interface BloomAddressBookMatcher : NSObject

-(NSData *)hashPhoneNumbers;
-(NSArray *)matchPhoneNumbers:(NSData*)contactsHash;
+(void)withContactStore:(CompletionBlock)block uponFailure:(FailureBlock)failBlock;

@end
