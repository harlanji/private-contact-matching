//
//  ContactMatcherAPI.h
//  sample
//
//  Created by Harlan on 3/14/17.
//  Copyright © 2017 clojure-objc. All rights reserved.
//


typedef void (^CMCompletionBlock)(NSData *contactsHash);
typedef void (^CMFailureBlock)(void);


@interface ContactMatcherAPI : NSObject


-(id)init;
-(id)initWithAPILocation:(NSString *)apiLocation;

-(NSData*)myMatchesHashWithHash:(NSData *)contactsHash identifiedBy:(NSString*)identifier success:(CMCompletionBlock)block fail:(CMFailureBlock)failBlock;
-(NSData*)friendMatchesHashForIdentifier:(NSString *)identifier success: (CMCompletionBlock)block fail:(CMFailureBlock)failBlock;


@end
