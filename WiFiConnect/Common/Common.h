//
//  Common.h
//  BlackBear
//
//  Created by IOS on 14-5-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#define ProvinceId          @"Id"
#define ProvinceName        @"Province"
#define ProvinceSimplified  @"ProSimplified"
#define CityId              @"Id"
#define CityName            @"City"
#define CitySimplified      @"CitySimplified"
@class MainViewCtl;
@class AppDelegate;
@interface Common : NSObject
+(Common *)shareCommon;

- (NSData *)convertXmlDataToUtf8:(NSData *)data;

/*
 * Describe : 十六进制转换为十进制
 * @pragram : hexStr : 十六进制的字符串
 * return   : 返回十进制的数
 */
- (long long int)HexcovertToDecimal:(NSString *)hexStr;


/*
 * Describe : 将Mac地址转换为十进制的数
 * @pragram : macAddressStr : Mac地址
 * return   : 返回转换后的十进制数
 */
- (long long int)convertMacAdressToDecimal:(NSString *)macAddressStr;

/*
 * Describe : 注册跟踪区域到系统里面
 * @pragram : locationsAry : 需要跟踪的区域的信息
 * return   : void
 */
- (void)regionLocations:(NSArray *)locationsAry managerObj:(AppDelegate *)managerObj;
@end
