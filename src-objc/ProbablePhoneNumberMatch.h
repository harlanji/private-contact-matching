//
//  ProbablePhoneNumberMatch.h
//  sample
//
//  Created by Harlan on 3/11/17.
//  Copyright © 2017 Harlan Iverson. All rights reserved.
//

#pragma once

typedef unsigned long long phonenumber_t;

@interface ProbablePhoneNumberMatch : NSObject {
    NSString *rawPhoneNumber;
    phonenumber_t phoneNumber;
    NSString *firstName;
    NSString *nickName;
};

-(id)initWithRawPhoneNumber:(NSString*)rawPhoneNumber
                phoneNumber:(phonenumber_t)phoneNumber
                  firstName:(NSString *)firstName
                   nickName:(NSString *)nickName;



- (NSString *)description;

@end
