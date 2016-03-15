/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "OrtcClient.h"

@interface CoRealtimeOrtcModule : TiModule<OrtcClientDelegate> 
{
    OrtcClient *ortcClient;
    void (^onMessage)(OrtcClient* ortc, NSString* channel, NSString* message);
    void (^onPresence)(NSError* error, NSDictionary* result);
    NSString *clusterUrl;
    NSString *url;
}

@property (nonatomic,readonly)  OrtcClient *ortcClient;
@property (nonatomic,readwrite,retain) NSString *clusterUrl;
@property (nonatomic,readwrite,retain) NSString *url;
@property (nonatomic,readwrite,retain) NSString *connectionMetadata;
@property (nonatomic,readwrite,retain) NSString *announcementSubchannel;
@property (nonatomic,readonly,assign) NSString *sessionId;

+ (void)passMessage:(NSString*) channel message:(NSString*) aMessage;
+ (void)passPresence:(NSError*) error result:(NSString*) aResult channel:(NSString*) aChannel;


@end
