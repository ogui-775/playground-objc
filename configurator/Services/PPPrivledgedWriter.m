//Created by Salty on 9/6/26.

#import "PPPrivledgedWriter.h"
#import <Swingset/Swingset.h>

@implementation PPPrivledgedWriter
+ (BOOL)createMasterOptionsIfNotExists{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:kPPOptionsPath])
        return YES;
    
    NSDictionary *dictionary = @{
        @"disablePAC" : @NO,
        @"pauseInjection" : @NO,
        @"useLegacyAmmonia" : @NO,
        @"globalBlacklist" : @[]
    };
    
    NSData *plistData =
        [NSPropertyListSerialization dataWithPropertyList:dictionary
                                                   format:NSPropertyListXMLFormat_v1_0
                                                  options:0
                                                    error:nil];

    NSString *b64 = [plistData base64EncodedStringWithOptions:0];

    NSString *script =
        [NSString stringWithFormat:
            @"do shell script \"echo %@ | base64 -D > '%@'\" "
             "with administrator privileges",
            b64,
            kPPOptionsPath];

    NSAppleScript *appleScript =
        [[NSAppleScript alloc] initWithSource:script];

    NSDictionary *errorInfo = nil;

    [appleScript executeAndReturnError:&errorInfo];

    return errorInfo == nil;
}

+ (BOOL)changeFileExtensionForFileAtURL:(NSURL *)originalURL
                                  toURL:(NSURL *)newURL{
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:originalURL.path])
        return NO;

    NSError *err = nil;

    if ([fm moveItemAtURL:originalURL toURL:newURL error:&err])
        return YES;

    NSString *script = [NSString stringWithFormat:
        @"do shell script \"mv %@ %@\" with administrator privileges",
        [originalURL.path stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],
        [newURL.path stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
    ];

    NSAppleScript *aScript = [[NSAppleScript alloc] initWithSource:script];

    NSDictionary *errorInfo = nil;
    NSAppleEventDescriptor *result =
        [aScript executeAndReturnError:&errorInfo];

    return result != nil &&
            errorInfo == nil;
}

+ (BOOL)writeToPlistAtURL:(NSURL *)URL
           withDictionary:(NSDictionary *)dictionary{
    if ([dictionary writeToURL:URL error:nil])
        return YES;

    NSData *plistData =
        [NSPropertyListSerialization dataWithPropertyList:dictionary
                                                   format:NSPropertyListXMLFormat_v1_0
                                                  options:0
                                                    error:nil];

    NSString *b64 = [plistData base64EncodedStringWithOptions:0];

    NSString *path =
        [[URL path] stringByReplacingOccurrencesOfString:@"'"
                                                withString:@"'\\''"];

    NSString *script =
        [NSString stringWithFormat:
            @"do shell script \"echo %@ | base64 -D > '%@'\" "
             "with administrator privileges",
            b64,
            path];

    NSAppleScript *appleScript =
        [[NSAppleScript alloc] initWithSource:script];

    NSDictionary *errorInfo = nil;

    [appleScript executeAndReturnError:&errorInfo];

    return errorInfo == nil;
}
@end
