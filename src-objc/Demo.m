

#import "BloomAddressBookMatcher.h"
#import "ProbablePhoneNumberMatch.h"
#import "ContactMatcherAPI.h"


void friendfinder_demo () {
    BloomAddressBookMatcher *matcher = [[BloomAddressBookMatcher alloc] init];

    [BloomAddressBookMatcher withContactStore:^{
        NSData *myPhoneHash = [matcher hashPhoneNumbers];
        
        ContactMatcherAPI *api = [[ContactMatcherAPI alloc] initWithAPILocation:@"http://192.168.3.3:3000/db/test/$@"];
        
        // if you NEED a test server this may be available...
        //ContactMatcherAPI *api = [[ContactMatcherAPI alloc] initWithAPILocation:@"https://analogzen.com/BETA/bb/api/v1/db/test/$@"];
        
        [api myMatchesHashWithHash:myPhoneHash identifiedBy:@"1234567" success:^(NSData* responsePhoneHash) {
            
            NSLog( @"API Success");
            
            NSArray *matches = [matcher matchPhoneNumbers:responsePhoneHash];
            
            [matches enumerateObjectsUsingBlock:^(ProbablePhoneNumberMatch *  _Nonnull p, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"Possible match: %@", p);
            }];
            
            NSLog(@"Possible matches: %u", [matches count]);
        } fail: ^{
            NSLog(@"API Error");
        }];
    } uponFailure:^{
        NSLog(@"Could not access contacts.");
    }];

}
