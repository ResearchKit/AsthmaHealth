// 
//  APHAirQualityDataModel.m 
//  Asthma 
// 
// Copyright (c) 2015, Icahn School of Medicine at Mount Sinai. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APHAirQualityDataModel.h"
#import "APHTableViewDashboardAQAlertItem.h"//aqiObject
#import "APCAppCore/APCCMS.h"
@import APCAppCore;

static NSTimeInterval kAQICheckInterval = 3600;
static NSString * kAQILastChecked           = @"AQILastChecked";
static NSString * kLatitudeKey              = @"latitude";
static NSString * kLongitudeKey             = @"longitude";
static NSString * kLifemapURL               = @"https://alerts.lifemap-solutions.com";
static NSString * kAlertGetJson             = @"/alert/get_aqi.json";
static NSString * klifemapCertificateFilename = @"mssm_asthma_public_04092015";
static NSString * kFileInfoNameKey          = @"filename";
static NSString * kFileInfoTimeStampKey     = @"timestamp";
static NSString * kFileInfoContentTypeKey   = @"contentType";
static NSString * kTaskRunKey               = @"taskRun";
static NSString * kFilesKey                 = @"files";
static NSString * kAppNameKey               = @"appName";
static NSString * kAppVersionKey            = @"appVersion";
static NSString * kPhoneInfoKey             = @"phoneInfo";
static NSString * kItemKey                  = @"item";
static NSString * kItemName                 = @"Air Quality Report";

@interface APHAirQualityDataModel ()
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) SBBNetworkManager * networkManager;
@property (nonatomic, strong) NSMutableDictionary *aqiResponse;
@property (nonatomic) BOOL fetchingAirQualityReport;

//compression and encryption
@property (nonatomic, strong) ZZArchive * zipArchive;
@property (nonatomic, strong) NSMutableArray * zipEntries;
@property (nonatomic, strong) NSURL *zipArchiveURL;
@property (nonatomic, strong) NSString *encryptedArchiveFilename;
@property (nonatomic, strong) NSString * tempOutputDirectory;
@property (nonatomic, strong) NSMutableArray * filesList;
@property (nonatomic, strong) NSMutableDictionary * infoDict;
@end

@implementation APHAirQualityDataModel
-(id)init{
    self = [super init];
    if (self) {
        self.aqiObject = [APHTableViewDashboardAQAlertItem new];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:kAQILastChecked];
        _networkManager = [[SBBNetworkManager alloc] initWithBaseURL:kLifemapURL];
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

-(void)dealloc{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - compression, encryption, and upload
-(void)createZipArchive{
    self.tempOutputDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    self.zipArchiveURL = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"unencrypted.zip"]];
    self.encryptedArchiveFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"encrypted.dat"];
    [self createTempDirectoryIfDoesntExist];
    self.zipEntries = [NSMutableArray array];
    self.filesList = [NSMutableArray array];
    self.infoDict = [NSMutableDictionary dictionary];
    [self createTempDirectoryIfDoesntExist];
    NSError * error;
    _zipArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:[self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"]]
                                         options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                           error:&error];
    if (!_zipArchive) {
        APCLogError2(error);
    }
}

-(void) prepareDictionaries{
    if (self.aqiResponse.count > 0 && [self.aqiResponse objectForKey:@"results"]) {
        NSDictionary *results = [self.aqiResponse objectForKey:@"results"];
        //do we actually have air quality reports, not just a reporting area?
        if ([results objectForKey:@"reports"] && ![[results objectForKey:@"reporting_area"] isKindOfClass:[NSNull class]]) {
            [self insertIntoZipArchive:results filename:@"aqiResponse"];
            
            NSMutableDictionary *latLongDictionary = [[NSMutableDictionary alloc]init];
            [latLongDictionary setObject:[NSNumber numberWithFloat:self.locationManager.location.coordinate.latitude] forKey:kLatitudeKey];
            [latLongDictionary setObject:[NSNumber numberWithFloat:self.locationManager.location.coordinate.longitude] forKey:kLongitudeKey];
            
            if (latLongDictionary.count > 0) {
                [self insertIntoZipArchive:latLongDictionary filename:@"latlong"];
            }
            
            //when done adding files, call prepareJSONInfo
            [self prepareJSONInfo];
        }
    }
}

-(void)insertIntoZipArchive:(NSDictionary *)dictionary filename: (NSString *)filename{

    NSError * error;
    NSData * jsonData;
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        
        if ([filename isEqualToString:@"latlong"]) {
            //encrypt the latLongDictionary before inserting into zip archive
            jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            NSError * encryptionError;
            jsonData = cmsEncrypt(jsonData, [self pemPath], &encryptionError);
            if (!jsonData) {
                APCLogError2(encryptionError);
            }
        }else {
            jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        }
    }else{
        APCLogDebug(@"%@ is not a valid JSON object, attempting to fix...", filename);
        APCDataArchiver *archiver = [[APCDataArchiver alloc]init];
        NSDictionary *newDictionary = [archiver generateSerializableDataFromSourceDictionary:dictionary];
        if ([NSJSONSerialization isValidJSONObject:newDictionary]) {
            [self insertIntoZipArchive:newDictionary filename:filename];
        }
    }
    
    if (jsonData !=nil) {
        NSString * fullFileName = [filename stringByAppendingPathExtension:@"json"];
        
        APCLogFilenameBeingArchived (fullFileName);

        [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                                    compress:YES
                                                                   dataBlock:^(NSError** __unused error){ return jsonData;}]];
        
        NSMutableDictionary * fileInfoEntry = [NSMutableDictionary dictionary];
        fileInfoEntry[kFileInfoNameKey] = fullFileName;
        fileInfoEntry[kFileInfoTimeStampKey] = [NSDate new];
        fileInfoEntry[kFileInfoContentTypeKey] = @"application/json";
        [self.filesList addObject:fileInfoEntry];
    }
    else {
        APCLogError2(error);
    }
}

-(void)prepareJSONInfo{
    if (self.filesList.count) {
        [_infoDict setObject:self.filesList forKey:kFilesKey];
        [_infoDict setObject:[APCUtilities appName] forKey:kAppNameKey];
        [_infoDict setObject:[APCUtilities appVersion] forKey:kAppVersionKey];
        [_infoDict setObject:[APCUtilities phoneInfo] forKey:kPhoneInfoKey];
        [_infoDict setObject:[NSUUID new].UUIDString forKey:kTaskRunKey];
        [_infoDict setObject:kItemName forKey:kItemKey];
        
        [self insertIntoZipArchive:self.infoDict filename:@"info"];
        
        NSError * error;
        if (![self.zipArchive updateEntries:self.zipEntries error:&error]) {
            APCLogError2(error);
        }else{
            APCLogDebug(@"Outputting AirQuality infoDict to console\n%@", self.infoDict);
            [self encryptZip];
        }
    }
}

-(void)encryptZip{
    NSError *reachableError;
    if (![self.zipArchive.URL checkResourceIsReachableAndReturnError:&reachableError]) {
        APCLogDebug(@"resource is unreachable: %@", reachableError.message);
    }else{
        if ([APCDataArchiver encryptZipFile:[self.zipArchive.URL relativePath] encryptedPath:self.encryptedArchiveFilename]){
            [self uploadEncryptedZip];
        }else{
            APCLogDebug(@"Encryption of zip file failed, won't upload");
        }
    }
    [self cleanUp];
}

-(void)uploadEncryptedZip{
    
    NSURL *encryptedZipURL = [NSURL URLWithString:[@"file://" stringByAppendingString:self.encryptedArchiveFilename]];
                              
    NSError *reachableError;
    if (![encryptedZipURL checkResourceIsReachableAndReturnError:&reachableError]) {
        APCLogDebug(@"resource is unreachable: %@", reachableError.message);
    }else{
        APCLogFilenameBeingUploaded (encryptedZipURL.absoluteString);

        [SBBComponent(SBBUploadManager) uploadFileToBridge:encryptedZipURL contentType:@"application/zip" completion:^(NSError *error) {
            if (!error) {
                APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"Uploaded Passive Collector File: %@", self.encryptedArchiveFilename.lastPathComponent]}));
            }else{
                APCLogDebug(@"%@", error.message);
            }
            
        }];
    }
}

- (void)createTempDirectoryIfDoesntExist {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_tempOutputDirectory]) {
        NSError * fileError;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:_tempOutputDirectory withIntermediateDirectories:YES attributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication } error:&fileError];
        if (!created) {
            APCLogError2 (fileError);
        }
    }
}

-(void)cleanUp{
    NSError *err;
    if (![[NSFileManager defaultManager] removeItemAtPath:self.encryptedArchiveFilename error:&err]) {
        APCLogError2(err);
    }
    
    if (![[NSFileManager defaultManager] removeItemAtPath:[self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"] error:&err]) {
        APCLogError2(err);
    }
}

- (NSString*) pemPath
{
    NSString * path = [[NSBundle mainBundle] pathForResource:klifemapCertificateFilename ofType:@"pem"];
    return path;
}

#pragma mark - Location Manager

- (CLLocationManager*) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *) __unused manager
     didUpdateLocations:(NSArray *)locations
{

    CLLocation * currentLocation = [locations lastObject];
    CLLocationCoordinate2D coordinate = [currentLocation coordinate];
    
    float lat = coordinate.latitude;
    float lon = coordinate.longitude;
    
    NSDate *lastAQICheckedTime = [[NSUserDefaults standardUserDefaults] objectForKey:kAQILastChecked] ?: nil;
    
    NSDate *currentTime = [NSDate date];
    self.aqiResponse = [[NSMutableDictionary alloc]init];
    
    __weak APHAirQualityDataModel *weakSelf = self;
    
    if (!self.fetchingAirQualityReport && (([currentTime timeIntervalSinceDate: lastAQICheckedTime]) >= kAQICheckInterval)) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:kAQILastChecked];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self createZipArchive];
        self.fetchingAirQualityReport = YES;
        //Make Network call for Air Quality in block
        [self.networkManager get:kAlertGetJson headers:nil parameters:@{@"lat":@(lat),@"lon":@(lon)} completion:^(NSURLSessionDataTask __unused *task, id responseObject, NSError *error) {
            __typeof__(self) strongSelf = weakSelf;
            
            APCLogError2(error);
            strongSelf.fetchingAirQualityReport = NO;
            if (!error) {
                strongSelf.aqiObject.aqiDictionary = responseObject;
                strongSelf.aqiResponse = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
                
                //send notification for [APHDashboardViewController to prepareData];
                APCLogEventWithData(kNetworkEvent, (@{
                                                      @"event_detail" : @"Received Air Quality Info from Server"
                                                      }));
                
                //sends a new AQIAlert to the dashboard. The dashboard should receive it on the main thread.
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([strongSelf.airQualityReportReceiver respondsToSelector:@selector(airQualityModel:didDeliverAirQualityAlert:)]) {
                        [strongSelf.airQualityReportReceiver airQualityModel:strongSelf didDeliverAirQualityAlert:strongSelf.aqiObject];
                    }
                    
                    [strongSelf prepareDictionaries];
                });
            }}];
    }
}

- (void) locationManager:(CLLocationManager *)__unused manager didFailWithError:(NSError *)error
{
    APCLogError2(error);
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    }
}

@end
