//Created by Salty on 9/6/26.

#import <Foundation/Foundation.h>

@interface PPPrivledgedWriter : NSObject
+ (BOOL)changeFileExtensionForFileAtURL:(NSURL *)originalURL
                                  toURL:(NSURL *)newURL;

+ (BOOL)writeToPlistAtURL:(NSURL *)URL
           withDictionary:(NSDictionary *)dictionary;

+ (BOOL)createMasterOptionsIfNotExists;
@end
