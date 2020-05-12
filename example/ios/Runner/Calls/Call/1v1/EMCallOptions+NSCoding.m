//
//  EMCallOptions+NSCoding.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 15/10/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "EMCallOptions+NSCoding.h"

@implementation EMCallOptions (NSCoding)

#pragma mark - NSKeyedArchiver

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.isSendPushIfOffline = [aDecoder decodeBoolForKey:@"emIsSendPushIfOffline"];
        self.videoResolution = (EMCallVideoResolution)[aDecoder decodeIntegerForKey:@"emVideoResolution"];
        self.maxVideoKbps = [aDecoder decodeIntForKey:@"emVideoKbps"];
        self.offlineMessageText = @"You have incoming call...";
        self.isFixedVideoResolution = [aDecoder decodeBoolForKey:@"emEnableFixedVideoResolution"];
        self.maxVideoFrameRate = [aDecoder decodeIntForKey:@"emMaxVideoFrameRate"];
        self.minVideoKbps = [aDecoder decodeIntForKey:@"emMinVideoKbps"];
    }

    return self;
}

//归档
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.isSendPushIfOffline forKey:@"emIsSendPushIfOffline"];
    [aCoder encodeInteger:self.videoResolution forKey:@"emVideoResolution"];
    [aCoder encodeInt:(int)self.maxVideoKbps forKey:@"emVideoKbps"];
    [aCoder encodeBool:self.isFixedVideoResolution forKey:@"emEnableFixedVideoResolution"];
    [aCoder encodeInt:(int)self.maxVideoFrameRate forKey:@"emMaxVideoFrameRate"];
    [aCoder encodeInt:(int)self.minVideoKbps forKey:@"emMinVideoKbps"];
}

@end
