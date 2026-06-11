//
//  AUIShortVideoListMacro.h
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/14.
//

#ifndef AUIShortVideoListMacro_h
#define AUIShortVideoListMacro_h

#import <AUIFoundation/AUIFoundation.h>

#define SVImage(key) AVGetImage(key, @"AUIShortVideoList")
#define SVString(key) AVGetString(key, @"AUIShortVideoList")
#define SVColor(key)  AVGetColor(key, @"AUIShortVideoList")
#define SVCommonImage(key) AVGetCommonImage(key, @"AUIShortVideoList")


#endif /* AUIShortVideoListMacro_h */
