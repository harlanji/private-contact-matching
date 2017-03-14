//
//  ContactMatcherAPI.m
//  sample
//
//  Created by Harlan on 3/14/17.
//  Copyright © 2017 clojure-objc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContactMatcherAPI.h"

@implementation ContactMatcherAPI {
    NSString *apiLocation_;
    NSMutableData *responseData;
    CMCompletionBlock block_;
    CMFailureBlock failBlock_;
}

-(id)init {
    return [self initWithAPILocation:@"https://192.168.3.3:3000/db/phones/%@"];
}

-(id)initWithAPILocation:(NSString *)apiLocation {
    apiLocation_ = apiLocation;

    [super init];
    
    return self;
}

-(NSData*)myMatchesHashWithHash:(NSData *)contactsHash identifiedBy:(NSString*)identifier success:(CMCompletionBlock)block fail:(CMFailureBlock)failBlock {
    
    if (block_) {
        NSLog(@"Request already in progres... I know this is crappy implementation but it's a demo... contribute!");
        return nil;
    }
    
    block_ = Block_copy(block);
    failBlock_ = Block_copy(failBlock);
    responseData = [[NSMutableData alloc] init];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postLength = [NSString stringWithFormat:@"%d",[contactsHash length]];
    
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json; charset=utf8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:contactsHash];


    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:apiLocation_, identifier]]];

    [request setHTTPMethod:@"PUT"];

    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    return nil;
}

-(NSData*)friendMatchesHashForIdentifier:(NSString *)identifier success: (CMCompletionBlock)block fail:(CMFailureBlock)failBlock
{
    if (block_) {
        NSLog(@"Request already in progres... I know this is crappy implementation but it's a demo... contribute!");
        return nil;
    }
    
    block_ = Block_copy(block);
    failBlock_ = Block_copy(failBlock);
    responseData = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:apiLocation_, identifier]]];

    [request setHTTPMethod:@"GET"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    return nil;
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSLog(@"didReceiveData");
    
    [responseData appendData:data];
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    failBlock_();
    
    Block_release(block_);
    Block_release(failBlock_);
    
    block_ = nil;
    failBlock_ = nil;
    responseData = nil;
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    block_(responseData);
    
    Block_release(block_);
    Block_release(failBlock_);
    
    block_ = nil;
    failBlock_ = nil;
    responseData = nil;
}

@end
