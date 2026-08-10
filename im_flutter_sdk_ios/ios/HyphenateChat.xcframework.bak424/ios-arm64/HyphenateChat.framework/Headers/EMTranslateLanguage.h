//
//  EMTranslateLanguage.h
//  HyphenateChat
//
//  Created by lixiaoming on 2022/2/28.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  \~chinese
 *  翻译语言类。
 *
 *  \~english
 *  The translate language class
 */
@interface EMTranslateLanguage : NSObject

/**
 *  \~chinese
 *  语言代码，如中文简体为"zh-Hans"
 *
 *  \~english
 *  Language code.
 */
@property (nonatomic,strong) NSString* languageCode;

/**
 *  \~chinese
 *  语言名称，如中文简体为"Chinese Simplified"
 *
 *  \~english
 *  Language name.
 */
@property (nonatomic,strong) NSString* languageName;

/**
 *  \~chinese
 *  语言的原生名称，如中文简体为"中文 (简体)"
 *
 *  \~english
 *  Language native name.
 */
@property (nonatomic,strong) NSString* languageNativeName;
@end

NS_ASSUME_NONNULL_END
