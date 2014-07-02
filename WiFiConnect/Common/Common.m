//
//  Common.m
//  BlackBear
//
//  Created by IOS on 14-5-23.
//  Copyright (c) 2014年 IOS. All rights reserved.
//


#import "Common.h"
#import "AppDelegate.h"
#import "MainViewCtl.h"

@implementation Common
static Common * shareCommon = nil;

+(Common *)shareCommon
{
    @synchronized(self){
        if( nil == shareCommon){
            shareCommon = [[self alloc] init] ;
        }
    }
    return shareCommon;
}


+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if ( nil == shareCommon ) {
            shareCommon = [super allocWithZone:zone];
            return  shareCommon;
        }
    }
    return nil;
}


- (NSData *)convertXmlDataToUtf8:(NSData *)data
{
    if ([data length] < 40) {
        return nil;
    }
    NSData * xmldata = [data subdataWithRange:NSMakeRange(0,40)];
    NSString *xmlstr = [[NSString alloc] initWithData:xmldata encoding:NSUTF8StringEncoding];
    if ([xmlstr rangeOfString:@"\"GB2312\"" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *utf8str = [[[NSString alloc] initWithData:data encoding:enc] autorelease];
        utf8str = [utf8str stringByReplacingOccurrencesOfString:@"\"GB2312\"" withString:@"\"utf-8\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,40)];
        NSData *newData = [utf8str dataUsingEncoding:NSUTF8StringEncoding];
        data = newData;
    }
    return data;
}


/*
 * Describe : 十六进制转换为十进制
 * @pragram : hexStr : 十六进制的字符串
 * return   : 返回十进制的数
 */
- (long long int)HexcovertToDecimal:(NSString *)hexStr
{
    long long int tHexResult = 0;
    long long int tPow = 1;
    int j = 0;
    for (int i = hexStr.length-1 ; i >= 0; i--) {
        tPow = pow(16, j);
        j++;
        long long int tHexCur ;
        char tChar = [hexStr characterAtIndex:i];
        
        if(tChar >= '0'&& tChar <='9')
            tHexCur = (tChar - 48)*tPow;
        else {
            tHexCur = (tChar-'a'+10)*tPow;
        }
        
        tHexResult = tHexResult + tHexCur;
    }
    
    return tHexResult;
}


/*
 * Describe : 将Mac地址转换为十进制的数
 * @pragram : macAddressStr : Mac地址
 * return   : 返回转换后的十进制数
 */
- (long long int)convertMacAdressToDecimal:(NSString *)macAddressStr
{
    macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    long long int  tBassidDecimal = [self HexcovertToDecimal:macAddressStr];
    return tBassidDecimal;
}


/*
 * Describe : 注册跟踪区域到系统里面
 * @pragram : locationsAry : 需要跟踪的区域的信息
 * return   : void
 */
- (void)regionLocations:(NSArray *)locationsAry managerObj:(CLLocationManager *)managerObj
{
    NSMutableArray *geofences = [NSMutableArray array];
    
    for(CLLocation *location in locationsAry) {
        NSString* identifier = [NSString stringWithFormat:@"%f%f", location.coordinate.latitude, location.coordinate.longitude];
        
        CLRegion* geofence = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate
                                                                     radius:300
                                                                 identifier:identifier];
        [geofences addObject:geofence];
    }
    
    if (geofences.count > 0) {
        for (CLRegion * geofence in geofences) {
            [managerObj startMonitoringForRegion:geofence];
        }
    }
}

@end
