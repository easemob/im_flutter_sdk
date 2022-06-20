//
//  EMTranslateLanguage+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/3.
//

#import "EMTranslateLanguage+Helper.h"

@implementation EMTranslateLanguage (Helper)

- (nonnull NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"code"] = self.languageCode;
    ret[@"name"] = self.languageName;
    ret[@"nativeName"] = self.languageNativeName;
    return ret;
}

@end
