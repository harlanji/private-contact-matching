//
//  BloomAddressBookMatcher.m
//  sample
//
//  Created by Harlan on 3/11/17.
//  Copyright © 2017 clojure-objc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BloomAddressBookMatcher.h"
#import "ProbablePhoneNumberMatch.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <Contacts/Contacts.h>


@implementation BloomAddressBookMatcher {
}



-(NSArray *)matchPhoneNumbers:(NSData*)contactsHash
{
    
    // given an NSData (filter) compare our contact book
    
    JSContext *context = [[JSContext alloc] init];
    
    
    
    context[@"consoleLog"] = ^(NSString *message) {
        NSLog(@"JS: %@", message);
    };
    
    context[@"iosRequire"] = ^(NSString *moduleName) {
        NSLog(@"iosRequire(\'%@\')", moduleName);
        
        NSStringEncoding encoding;
        NSString* path = [[NSBundle mainBundle] pathForResource:moduleName ofType:@"js"];
        NSString* content = [NSString stringWithContentsOfFile:path  usedEncoding:&encoding  error:NULL];
        
        [context evaluateScript:content withSourceURL:[NSURL fileURLWithPath:path]];
    };
    
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        //NSLog(@"JS EXCEPTION: %@", [[context evaluateScript:@"Object.keys"] callWithArguments:@[value]]);
        // 2017-03-09 13:21:35.067077 sample[2284:1374985] JS EXCEPTION: line,column,sourceURL
        
        
        NSLog(@"JS EXCEPTION: %@:%@", [value objectForKeyedSubscript:@"sourceURL"], [value objectForKeyedSubscript:@"line"] );
        
        
    }];
    
    //[context evaluateScript:@"iosRequire('lib/murmurhash3')"];
    [context evaluateScript:@"iosRequire('lib/bloom-filter')"];
    
    JSValue *contactsHashJs = [[context evaluateScript:@"JSON.parse"] callWithArguments:@[[[NSString alloc] initWithData:contactsHash encoding:NSUTF8StringEncoding]]];
    

    

    JSValue *contactsBloomFilter = [[context evaluateScript:@"Filter"] constructWithArguments:@[contactsHashJs]];
    

    
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    
    NSError* contactError;
    CNContactStore* addressBook = [[CNContactStore alloc] init];
    [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
    NSArray * keysToFetch =@[CNContactPhoneNumbersKey, CNContactNicknameKey, CNContactGivenNameKey];
    
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
        
        
        NSString * firstName =  contact.givenName;
        NSString * nickName =  contact.nickname;
        NSArray * phoneNumbers = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
        //NSString * email = [contact.emailAddresses valueForKey:@"value"];
        
        for (NSString *phone in phoneNumbers) {
            //NSLog(@"Contact %@ - (%@ / %@)", phone, firstName, nickName);
            
            phonenumber_t p = [self normalizeNumber:phone];
            
//            NSData *containedData = [NSData dataWithBytes: &p length: sizeof(p)];
            
            if ([[contactsBloomFilter invokeMethod:@"contains" withArguments:@[[NSString stringWithFormat:@"%llu", p]]] toBool]) {
                
                //NSLog(@"PROBABLE MATCH: %@ - (%@ / %@)", phone, firstName, nickName);
                
                // crashes if we don't  copy phone...
                ProbablePhoneNumberMatch *probableMatch = [[ProbablePhoneNumberMatch alloc]
                                                           initWithRawPhoneNumber:[phone copy]
                                                           phoneNumber:p
                                                           firstName:[firstName copy]
                                                           nickName:[nickName copy]];
                
                [matches addObject:probableMatch];
            }
        }
    }];
    
    return matches; //[matches copy]; immutable?
}



-(NSData *)hashPhoneNumbers
{
    
//    NSUInteger expectedNumberOfItems = pow(2,32); // 1000 friends, each with 1000 friends
//    double falsePositiveRate = pow(2, -24);

    NSUInteger expectedNumberOfItems = pow(2,8); // 1000 friends, each with 1000 friends
    double falsePositiveRate = pow(2, -8);
    
    uint32_t seed = 612415366;
    
    JSContext *context = [[JSContext alloc] init];
    
    
    context[@"consoleLog"] = ^(NSString *message) {
        NSLog(@"JS: %@", message);
    };
    
    context[@"iosRequire"] = ^(NSString *moduleName) {
        NSLog(@"iosRequire(\'%@\')", moduleName);
        
        NSStringEncoding encoding;
        NSString* path = [[NSBundle mainBundle] pathForResource:moduleName ofType:@"js"];
        NSString* content = [NSString stringWithContentsOfFile:path  usedEncoding:&encoding  error:NULL];
        
        [context evaluateScript:content withSourceURL:[NSURL fileURLWithPath:path]];
    };
    
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        //NSLog(@"JS EXCEPTION: %@", [[context evaluateScript:@"Object.keys"] callWithArguments:@[value]]);
        // 2017-03-09 13:21:35.067077 sample[2284:1374985] JS EXCEPTION: line,column,sourceURL
        
        
        NSLog(@"JS EXCEPTION: %@:%@", [value objectForKeyedSubscript:@"sourceURL"], [value objectForKeyedSubscript:@"line"] );
        
        
    }];
    
    //[context evaluateScript:@"iosRequire('lib/murmurhash3')"];
    [context evaluateScript:@"iosRequire('lib/bloom-filter')"];
    
    JSValue *contactsBloomFilter = [context evaluateScript:@"Filter.create(Math.pow(2,10),Math.pow(2,-11))"];
    
    
    NSError* contactError;
    CNContactStore* addressBook = [[CNContactStore alloc]init];
    [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
    NSArray * keysToFetch =@[CNContactPhoneNumbersKey, CNContactNicknameKey, CNContactGivenNameKey];
    
    // NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
        
        
        NSString * firstName =  contact.givenName;
        NSString * nickName =  contact.nickname;
        NSArray * phoneNumbers = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
        //NSString * email = [contact.emailAddresses valueForKey:@"value"];
        
        for (NSString *phone in phoneNumbers) {
            //NSLog(@"Contact %@ - (%@ / %@)", phone, firstName, nickName);
            
            phonenumber_t p = [self normalizeNumber:phone];
            
            //NSLog(@"%@", phone);
            
//            NSData *containedData = [NSData dataWithBytes: &p length: sizeof(p)];
//            
//            [data appendData:containedData];
//            
//            NSUInteger capacity = containedData.length * 2;
//            NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
//            const unsigned char *buf = containedData.bytes;
//            NSInteger i;
//            for (i=0; i<containedData.length; ++i) {
//                [sbuf appendFormat:@"%02X", (NSUInteger)buf[i]];
//            }
//            
//            NSLog(@"encoded: %@", sbuf);
            
            //NSLog(@"filter keys: %@", [[context evaluateScript:@"Object.keys"] callWithArguments:@[contactsBloomFilter]]);
        
            
            [contactsBloomFilter invokeMethod:@"insert" withArguments:@[[NSString stringWithFormat:@"%llu", p]]];
            
            if (![[contactsBloomFilter invokeMethod:@"contains" withArguments:@[[NSString stringWithFormat:@"%llu", p]]] toBool]) {
                NSLog(@"MISS: Contact %@", phone);
            }
        }
    }];
    
    //    NSLog(@"Done with contacts... vecor length: %lu", (unsigned long)bloomFilter.data.length);
    
    JSValue *contactsHashJs = [contactsBloomFilter invokeMethod:@"toObject" withArguments:@[]];
    
    NSLog(@"Done with contacts... data length: %u vs. vecor length: %u.", data.length, 0 /*contactsHash.length*/);
    
    // Serialization
    
    //BloomFilter *deserializedBloomFilter = [[BloomFilter alloc] initWithData:bloomFilter.data exceptedNumberOfItems:expectedNumberOfItems falsePositivePercentage:falsePositiveRate seed:seed];
    
    
    //NSLog(@"contactsHash keys: %@", [[context evaluateScript:@"Object.keys"] callWithArguments:@[contactsHashJs]]);
    
    // STOPPED HERE: BUG vData should not be undefined... but it is
    
    //NSLog(@"contactsHash vData: %@", [contactsHashJs valueForProperty:@"vData"]);
    
    JSValue *contactsHashString = [[context evaluateScript:@"JSON.stringify"] callWithArguments:@[contactsHashJs]];
    
    
    
    return [[contactsHashString toString] dataUsingEncoding:NSUTF8StringEncoding];
}



+(void)withContactStore:(CompletionBlock)block uponFailure:(FailureBlock)failBlock
{
    // https://gist.github.com/willthink/024f1394474e70904728
    if([CNContactStore class])
    {
        CNEntityType entityType = CNEntityTypeContacts;
        if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined)
        {
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(granted){
                    block();
                } else {
                    failBlock();
                }
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusAuthorized)
        {
            block();
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusRestricted || [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusDenied)
        {
            failBlock();
        } else {
            NSLog(@"SEVERE -- should not get here!");
        }
    }
}



-(phonenumber_t)normalizeNumber:(NSString*)phoneNumber
{
    NSUInteger phoneLen = [phoneNumber length];
    unichar buffer[phoneLen+1];
    [phoneNumber getCharacters:buffer range:NSMakeRange(0, phoneLen)];
    
    phonenumber_t p = 0;
    unsigned int d = 0;
    
    for(int i = phoneLen - 1; i >= 0; i--) {
        unichar c = buffer[i];
        int pos = phoneLen - 1 - i;
        
        //if (pos < 4 || pos >= (phoneLen - 1 - (i - d)) || (i % 7 == 0)) {
        if (c >= '0' && c <= '9') {
            p += (c - '0') * pow(10, d++);
        }
        //}
    }
    return p;
}


@end

