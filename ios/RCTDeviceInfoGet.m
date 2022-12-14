//
//  RCTDeviceInfoGet.m
//  Teravin
//
//  Created by Khairul Baharuddin on 13/12/22.
//

#import <Foundation/Foundation.h>
#import "RCTDeviceInfoGet.h"
#import <sys/utsname.h>

@implementation RCTDeviceInfoGet

RCT_EXPORT_MODULE(DeviceInfoGet);

typedef NS_ENUM(NSInteger, DeviceType) {
    DeviceTypeHandset,
    DeviceTypeTablet,
    DeviceTypeTv,
    DeviceTypeDesktop,
    DeviceTypeUnknown
};

#define DeviceTypeValues [NSArray arrayWithObjects: @"Handset", @"Tablet", @"Tv", @"Desktop", @"unknown", nil]

+ (BOOL)requiresMainQueueSetup
{
   return NO;
}

- (NSDictionary *)constantsToExport {
    return @{
         @"deviceId": [self getDeviceId],
         @"systemVersion": [self getSystemVersion],
         @"brand": @"Apple",
         @"model": [self getModel],
         @"deviceType": [self getDeviceTypeName],
         @"systemName": [self getSystemName],
     };
}

- (NSString *) getDeviceId {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceId = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
    #if TARGET_IPHONE_SIMULATOR
        deviceId = [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    #endif
    return deviceId;
}

- (NSString *) getSystemName {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.systemName;
}

- (NSString *) getSystemVersion {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.systemVersion;
}


- (NSString *) getModel {
    NSString* deviceId = [self getDeviceId];
    NSDictionary* deviceNamesByCode = [self getDeviceNamesByCode];
    NSString* deviceName =[deviceNamesByCode valueForKey:deviceId];

    if (deviceName) {
        return deviceName;
    }

    if ([deviceId hasPrefix:@"iPod"]) {
        return @"iPod Touch";
    } else if ([deviceId hasPrefix:@"iPad"]) {
        return @"iPad";
    } else if ([deviceId hasPrefix:@"iPhone"]) {
        return @"iPhone";
    } else if ([deviceId hasPrefix:@"AppleTV"]) {
        return @"Apple TV";
    }
    return @"unknown";
}

- (DeviceType) getDeviceType
{
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPhone: return DeviceTypeHandset;
        case UIUserInterfaceIdiomPad:
            if (TARGET_OS_MACCATALYST) {
                return DeviceTypeDesktop;
            }
            if (@available(iOS 14.0, *)) {
                if ([NSProcessInfo processInfo].isiOSAppOnMac) {
                    return DeviceTypeDesktop;
                }
            }
            return DeviceTypeTablet;
        case UIUserInterfaceIdiomTV: return DeviceTypeTv;
        case UIUserInterfaceIdiomMac: return DeviceTypeDesktop;
        default: return DeviceTypeUnknown;
    }
}

- (NSString *) getDeviceTypeName {
    return [DeviceTypeValues objectAtIndex: [self getDeviceType]];
}

- (NSDictionary *) getDeviceNamesByCode {
    return @{
        @"iPod1,1": @"iPod Touch", // (Original)
        @"iPod2,1": @"iPod Touch", // (Second Generation)
        @"iPod3,1": @"iPod Touch", // (Third Generation)
        @"iPod4,1": @"iPod Touch", // (Fourth Generation)
        @"iPod5,1": @"iPod Touch", // (Fifth Generation)
        @"iPod7,1": @"iPod Touch", // (Sixth Generation)
        @"iPod9,1": @"iPod Touch", // (Seventh Generation)
        @"iPhone1,1": @"iPhone", // (Original)
        @"iPhone1,2": @"iPhone 3G", // (3G)
        @"iPhone2,1": @"iPhone 3GS", // (3GS)
        @"iPad1,1": @"iPad", // (Original)
        @"iPad2,1": @"iPad 2", //
        @"iPad2,2": @"iPad 2", //
        @"iPad2,3": @"iPad 2", //
        @"iPad2,4": @"iPad 2", //
        @"iPad3,1": @"iPad", // (3rd Generation)
        @"iPad3,2": @"iPad", // (3rd Generation)
        @"iPad3,3": @"iPad", // (3rd Generation)
        @"iPhone3,1": @"iPhone 4", // (GSM)
        @"iPhone3,2": @"iPhone 4", // iPhone 4
        @"iPhone3,3": @"iPhone 4", // (CDMA/Verizon/Sprint)
        @"iPhone4,1": @"iPhone 4S", //
        @"iPhone5,1": @"iPhone 5", // (model A1428, AT&T/Canada)
        @"iPhone5,2": @"iPhone 5", // (model A1429, everything else)
        @"iPad3,4": @"iPad", // (4th Generation)
        @"iPad3,5": @"iPad", // (4th Generation)
        @"iPad3,6": @"iPad", // (4th Generation)
        @"iPad2,5": @"iPad Mini", // (Original)
        @"iPad2,6": @"iPad Mini", // (Original)
        @"iPad2,7": @"iPad Mini", // (Original)
        @"iPhone5,3": @"iPhone 5c", // (model A1456, A1532 | GSM)
        @"iPhone5,4": @"iPhone 5c", // (model A1507, A1516, A1526 (China), A1529 | Global)
        @"iPhone6,1": @"iPhone 5s", // (model A1433, A1533 | GSM)
        @"iPhone6,2": @"iPhone 5s", // (model A1457, A1518, A1528 (China), A1530 | Global)
        @"iPhone7,1": @"iPhone 6 Plus", //
        @"iPhone7,2": @"iPhone 6", //
        @"iPhone8,1": @"iPhone 6s", //
        @"iPhone8,2": @"iPhone 6s Plus", //
        @"iPhone8,4": @"iPhone SE", //
        @"iPhone9,1": @"iPhone 7", // (model A1660 | CDMA)
        @"iPhone9,3": @"iPhone 7", // (model A1778 | Global)
        @"iPhone9,2": @"iPhone 7 Plus", // (model A1661 | CDMA)
        @"iPhone9,4": @"iPhone 7 Plus", // (model A1784 | Global)
        @"iPhone10,3": @"iPhone X", // (model A1865, A1902)
        @"iPhone10,6": @"iPhone X", // (model A1901)
        @"iPhone10,1": @"iPhone 8", // (model A1863, A1906, A1907)
        @"iPhone10,4": @"iPhone 8", // (model A1905)
        @"iPhone10,2": @"iPhone 8 Plus", // (model A1864, A1898, A1899)
        @"iPhone10,5": @"iPhone 8 Plus", // (model A1897)
        @"iPhone11,2": @"iPhone XS", // (model A2097, A2098)
        @"iPhone11,4": @"iPhone XS Max", // (model A1921, A2103)
        @"iPhone11,6": @"iPhone XS Max", // (model A2104)
        @"iPhone11,8": @"iPhone XR", // (model A1882, A1719, A2105)
        @"iPhone12,1": @"iPhone 11",
        @"iPhone12,3": @"iPhone 11 Pro",
        @"iPhone12,5": @"iPhone 11 Pro Max",
	@"iPhone12,8": @"iPhone SE", // (2nd Generation iPhone SE),
        @"iPhone13,1": @"iPhone 12 mini",
        @"iPhone13,2": @"iPhone 12",
        @"iPhone13,3": @"iPhone 12 Pro",
        @"iPhone13,4": @"iPhone 12 Pro Max",
	@"iPhone14,4": @"iPhone 13 mini",
	@"iPhone14,5": @"iPhone 13",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPad4,1": @"iPad Air", // 5th Generation iPad (iPad Air) - Wifi
        @"iPad4,2": @"iPad Air", // 5th Generation iPad (iPad Air) - Cellular
        @"iPad4,3": @"iPad Air", // 5th Generation iPad (iPad Air)
        @"iPad4,4": @"iPad Mini 2", // (2nd Generation iPad Mini - Wifi)
        @"iPad4,5": @"iPad Mini 2", // (2nd Generation iPad Mini - Cellular)
        @"iPad4,6": @"iPad Mini 2", // (2nd Generation iPad Mini)
        @"iPad4,7": @"iPad Mini 3", // (3rd Generation iPad Mini)
        @"iPad4,8": @"iPad Mini 3", // (3rd Generation iPad Mini)
        @"iPad4,9": @"iPad Mini 3", // (3rd Generation iPad Mini)
        @"iPad5,1": @"iPad Mini 4", // (4th Generation iPad Mini)
        @"iPad5,2": @"iPad Mini 4", // (4th Generation iPad Mini)
        @"iPad5,3": @"iPad Air 2", // 6th Generation iPad (iPad Air 2)
        @"iPad5,4": @"iPad Air 2", // 6th Generation iPad (iPad Air 2)
        @"iPad6,3": @"iPad Pro 9.7-inch", // iPad Pro 9.7-inch
        @"iPad6,4": @"iPad Pro 9.7-inch", // iPad Pro 9.7-inch
        @"iPad6,7": @"iPad Pro 12.9-inch", // iPad Pro 12.9-inch
        @"iPad6,8": @"iPad Pro 12.9-inch", // iPad Pro 12.9-inch
        @"iPad6,11": @"iPad (5th generation)", // Apple iPad 9.7 inch (5th generation) - WiFi
        @"iPad6,12": @"iPad (5th generation)", // Apple iPad 9.7 inch (5th generation) - WiFi + cellular
        @"iPad7,1": @"iPad Pro 12.9-inch", // 2nd Generation iPad Pro 12.5-inch - Wifi
        @"iPad7,2": @"iPad Pro 12.9-inch", // 2nd Generation iPad Pro 12.5-inch - Cellular
        @"iPad7,3": @"iPad Pro 10.5-inch", // iPad Pro 10.5-inch - Wifi
        @"iPad7,4": @"iPad Pro 10.5-inch", // iPad Pro 10.5-inch - Cellular
        @"iPad7,5": @"iPad (6th generation)", // iPad (6th generation) - Wifi
        @"iPad7,6": @"iPad (6th generation)", // iPad (6th generation) - Cellular
        @"iPad7,11": @"iPad (7th generation)", // iPad 10.2 inch (7th generation) - Wifi
        @"iPad7,12": @"iPad (7th generation)", // iPad 10.2 inch (7th generation) - Wifi + cellular
        @"iPad8,1": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - Wifi
        @"iPad8,2": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - 1TB - Wifi
        @"iPad8,3": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - Wifi + cellular
        @"iPad8,4": @"iPad Pro 11-inch (3rd generation)", // iPad Pro 11 inch (3rd generation) - 1TB - Wifi + cellular
        @"iPad8,5": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - Wifi
        @"iPad8,6": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - 1TB - Wifi
        @"iPad8,7": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - Wifi + cellular
        @"iPad8,8": @"iPad Pro 12.9-inch (3rd generation)", // iPad Pro 12.9 inch (3rd generation) - 1TB - Wifi + cellular
        @"iPad11,1": @"iPad Mini 5", // (5th Generation iPad Mini)
        @"iPad11,2": @"iPad Mini 5", // (5th Generation iPad Mini)
        @"iPad11,3": @"iPad Air (3rd generation)",
        @"iPad11,4": @"iPad Air (3rd generation)",
        @"iPad13,1": @"iPad Air (4th generation)",
        @"iPad13,2": @"iPad Air (4th generation)",
        @"AppleTV2,1": @"Apple TV", // Apple TV (2nd Generation)
        @"AppleTV3,1": @"Apple TV", // Apple TV (3rd Generation)
        @"AppleTV3,2": @"Apple TV", // Apple TV (3rd Generation - Rev A)
        @"AppleTV5,3": @"Apple TV", // Apple TV (4th Generation)
        @"AppleTV6,2": @"Apple TV 4K" // Apple TV 4K
    };
}

- (double) getTotalMemory {
    return [NSProcessInfo processInfo].physicalMemory;
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getTotalMemorySync) {
    return @(self.getTotalMemory);
}

RCT_EXPORT_METHOD(getTotalMemory:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@(self.getTotalMemory));
}

- (NSDictionary *) getStorageDictionary {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: nil];
}

- (double) getTotalDiskCapacity {
    uint64_t totalSpace = 0;
    NSDictionary *storage = [self getStorageDictionary];

    if (storage) {
        NSNumber *fileSystemSizeInBytes = [storage objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
    }
    return (double) totalSpace;
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getTotalDiskCapacitySync) {
    return @(self.getTotalDiskCapacity);
}

RCT_EXPORT_METHOD(getTotalDiskCapacity:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@(self.getTotalDiskCapacity));
}

- (double) getFreeDiskStorage {
    uint64_t freeSpace = 0;
    NSDictionary *storage = [self getStorageDictionary];

    if (storage) {
        NSNumber *freeFileSystemSizeInBytes = [storage objectForKey: NSFileSystemFreeSize];
        freeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    return (double) freeSpace;
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getFreeDiskStorageSync) {
    return @(self.getFreeDiskStorage);
}

RCT_EXPORT_METHOD(getFreeDiskStorage:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@(self.getFreeDiskStorage));
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getName) {
    return [[UIDevice currentDevice] name];
}

@end
