//
//  ProbablePhoneNumberMatch.m
//  sample
//
//  Created by Harlan on 3/11/17.
//  Copyright © 2017 clojure-objc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProbablePhoneNumberMatch.h"

@implementation ProbablePhoneNumberMatch {
    
};


-(id)initWithRawPhoneNumber:(NSString*)rawPhoneNumber_
                phoneNumber:(phonenumber_t)phoneNumber_
                  firstName:(NSString *)firstName_
                   nickName:(NSString *)nickName_ {
    
    self->rawPhoneNumber = rawPhoneNumber_;
    self->phoneNumber = phoneNumber_;
    self->firstName = firstName_;
    self->nickName = nickName_;
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ProbablePhoneNumberMatch: Raw=%@ Normalized=%llu FirstName=%@ NickName=%@", rawPhoneNumber, phoneNumber, firstName, nickName];
}

@end
