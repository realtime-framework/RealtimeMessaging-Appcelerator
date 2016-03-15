/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "CoRealtimeOrtcModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"


static CoRealtimeOrtcModule* instance = nil;


@interface CoRealtimeOrtcModule()
@property (nonatomic,readwrite,assign) NSString *sessionId;
@property (nonatomic,readwrite,assign) NSString *appKey;
@property (nonatomic,readwrite,assign) NSString *authToken;
@end

@implementation CoRealtimeOrtcModule

@synthesize ortcClient;
@synthesize clusterUrl;
@synthesize url;
@synthesize announcementSubchannel;
@synthesize connectionMetadata;
@synthesize appKey;
@synthesize authToken;

NSString* const CLUSTERRESPONSEPATTERN = @"^var SOCKET_SERVER = \\\"(.*?)\\\";$";


#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"88a14241-1de3-45ec-9cba-899d3cd4642d";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"co.realtime.ortc";
}

#pragma mark Lifecycle
-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
    instance =self;
    self.clusterUrl =nil;
    self.url =nil;
    self.connectionMetadata =nil;
    self.announcementSubchannel =nil;
    self.appKey =nil;
    self.authToken =nil;
    
    
    ortcClient = [OrtcClient ortcClientWithConfig:self];
    
    onMessage = ^(OrtcClient* ortc, NSString* channel, NSString* message) {
        if (ortc.isConnected) {
            [CoRealtimeOrtcModule passMessage:channel message:message];
        }
    };
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(void)connect:(id)args {
    self.appKey =[args objectAtIndex:0];
    
    if ([args count] > 1)
        self.authToken = [args objectAtIndex:1];
    else
        self.authToken = @"PM.anonymous";
    
    
    if(self.clusterUrl)
        [ortcClient setClusterUrl:self.clusterUrl];
    if(self.url)
        [ortcClient setUrl:self.url];
    if(self.connectionMetadata)
        [ortcClient setConnectionMetadata:self.connectionMetadata];
    if(self.announcementSubchannel)
        [ortcClient setAnnouncementSubChannel:self.announcementSubchannel];
    ENSURE_UI_THREAD(connect, args);
    [ortcClient connect:self.appKey authenticationToken:self.authToken];
}

- (void)disconnect:(id)args {
    [ortcClient disconnect];
}

- (void)send:(id)args {
    NSString *channel =[args objectAtIndex:0];
    NSString *message =[args objectAtIndex:1];
    [ortcClient send:channel message:message];
}

- (void) subscribe:(id)args {
    NSString *channel =[args objectAtIndex:0];
    Boolean subscribeOnReconn = [args objectAtIndex:1];
    [ortcClient subscribe:channel subscribeOnReconnected:subscribeOnReconn onMessage:onMessage];
}

- (void) subscribeWithNotifications:(id)args {
    NSString *channel =[args objectAtIndex:0];
    Boolean subscribeOnReconn = [args objectAtIndex:1];
    [ortcClient subscribeWithNotifications:channel subscribeOnReconnected:subscribeOnReconn onMessage:onMessage];
}

- (void) setDeviceId:(id)args {
    NSString *deviceId = args;//[args objectAtIndex:0]; nao sei porque
    [OrtcClient setDEVICE_TOKEN:deviceId];
}


- (void) unsubscribe:(id)args {
    NSString *channel = [args objectAtIndex:0];
    [ortcClient unsubscribe:channel];
}

- (id) isSubscribed:(id)args {
    NSString *channel =[args objectAtIndex:0];
    return [ortcClient isSubscribed:channel];
}

- (id) isConnected:(id)args {
    if (ortcClient.isConnected){
        return [NSNumber numberWithBool:YES];
    } else {
        return [NSNumber numberWithBool:NO];
    }
}

- (void) presence:(id)args {
    NSString *channel = [args objectAtIndex:0];
    NSString *purl =nil;
    BOOL isCluster = nil;
    if(self.clusterUrl){
        purl = self.clusterUrl;
        isCluster = true;
    } else {
        purl =self.url;
        isCluster = false;
    }
    //[ortcClient presence:purl isCLuster:isCluster applicationKey:self.appKey authenticationToken:self.authToken channel:channel callback:onPresence];
    /*
     * Sanity Checks.
     */
    if ([self isEmpty:purl]) {
        @throw [NSException exceptionWithName:@"Url" reason:@"URL is null or empty" userInfo:nil];
    }
    else if ([self isEmpty:self.appKey]) {
        @throw [NSException exceptionWithName:@"Application Key" reason:@"Application Key is null or empty" userInfo:nil];
    }
    else if ([self isEmpty:self.authToken]) {
        @throw [NSException exceptionWithName:@"Authentication Token" reason:@"Authentication Token is null or empty" userInfo:nil];
    }
    else if ([self isEmpty:channel]) {
        @throw [NSException exceptionWithName:@"Channel" reason:@"Channel is null or empty" userInfo:nil];
    }
    else if (![self ortcIsValidInput:channel]) {
        @throw [NSException exceptionWithName:@"Channel" reason:@"Channel has invalid characters" userInfo:nil];
    }
    else {
        NSString* connectionUrl = purl;
        if (isCluster) {
            connectionUrl = [[self getClusterServer:YES aPostUrl:purl] copy];
        }
        if (connectionUrl) {
            connectionUrl = [connectionUrl hasSuffix:@"/"] ? connectionUrl : [connectionUrl stringByAppendingString:@"/"];
            NSString* path = [NSString stringWithFormat:@"presence/%@/%@/%@", self.appKey, self.authToken, channel];
            connectionUrl = [connectionUrl stringByAppendingString:path];
            
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:connectionUrl]];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            NSOperationQueue *queue =[[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if(error !=nil){
                    [CoRealtimeOrtcModule passPresence:error result:nil channel:channel];
                } else {
                    NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [CoRealtimeOrtcModule passPresence:nil result:dataStr channel:channel];
                }
            }];
            
        }
    }
}

- (NSString*)getClusterServer:(BOOL) isPostingAuth aPostUrl:(NSString *) postUrl
{
    NSString* result = nil;
    NSString* parsedUrl = postUrl;
    
    if(self.appKey != NULL)
    {
        parsedUrl = [parsedUrl stringByAppendingString:@"?appkey="];
        parsedUrl = [parsedUrl stringByAppendingString:self.appKey];
    }
    
    // Initiate connection
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:parsedUrl]];
    
    // Send request and get response
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString* myString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    NSRegularExpression* resRegex = [NSRegularExpression regularExpressionWithPattern:CLUSTERRESPONSEPATTERN options:0 error:NULL];
    NSTextCheckingResult* resMatch = [resRegex firstMatchInString:myString options:0 range:NSMakeRange(0, [myString length])];
    
    if (resMatch)
    {
        NSRange strRange = [resMatch rangeAtIndex:1];
        
        if (strRange.location != NSNotFound) {
            result = [myString substringWithRange:strRange];
        }
    }
    
    if (!isPostingAuth)
    {
        if ([self isEmpty:result])
        {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"Unable to get URL from cluster", @"info", nil];
            [self fireEvent:@"onException" withObject:event];
        }
    }
    
    return result;
}

- (BOOL)isEmpty:(id) thing
{
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData*)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray*)thing count] == 0);
}
- (BOOL)ortcIsValidInput:(NSString*) input
{
    NSRegularExpression* opRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\w-:/.]*$" options:0 error:NULL];
    NSTextCheckingResult* opMatch = [opRegex firstMatchInString:input options:0 range:NSMakeRange(0, [input length])];
    
    return opMatch ? true : false;
}

- (void) onException:(OrtcClient *)ortc error:(NSError *)error
{
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], @"info", nil];
    [self fireEvent:@"onException" withObject:event];
}

- (void) onConnected:(OrtcClient*) ortc
{
    self.sessionId = ortcClient.sessionId;
    [self fireEvent:@"onConnected"];
}

- (void) onDisconnected:(OrtcClient *)ortc
{
    [self fireEvent:@"onDisconnected"];
}

- (void) onReconnected:(OrtcClient *)ortc
{
    [self fireEvent:@"onReconnected"];
}

- (void) onReconnecting:(OrtcClient *)ortc
{
    [self fireEvent:@"onReconnecting"];
}

- (void) onSubscribed:(OrtcClient *)ortc channel:(NSString *)channel
{
    NSDictionary *event =[NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel", nil];
    [self fireEvent:@"onSubscribed" withObject:event];
}

- (void) onUnsubscribed:(OrtcClient *)ortc channel:(NSString *)channel
{
    NSDictionary *event =[NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel", nil];
    [self fireEvent:@"onUnsubscribed" withObject:event];
}


+ (void)passMessage:(NSString*) channel message:(NSString*) aMessage {
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:channel, @"channel", aMessage, @"message", nil];
    [instance fireEvent:@"onMessage" withObject:event];
}

+ (void)passPresence:(NSError*) error result:(NSString*) aResult channel:(NSString*) aChannel{
    NSString *errorMessage = @"";
    if(error)
        errorMessage = [NSString stringWithFormat:@"%@", error.userInfo];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage, @"error", aResult, @"result", aChannel, @"channel", nil];
    [instance fireEvent:@"onPresence" withObject:event];
}

- (void)passNotification:(id)args {
    NSDictionary *userInfo = [args objectAtIndex:0];
    //copy&paste of Antonio's RealtimePushAppDelegate.didReceiveRemoteNotification
    if ([userInfo objectForKey:@"C"] && [userInfo objectForKey:@"M"] && [userInfo objectForKey:@"A"]) {
        [self processPush:userInfo];
	}
}

- (void)processPush:(NSDictionary *)userInfo
{
    NSMutableDictionary *pushInfo = [[NSMutableDictionary alloc] init];
    
    if ([[[userInfo objectForKey:@"aps" ] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        if (!([ortcClient isConnected] && [ortcClient isSubscribed:[userInfo objectForKey:@"C"]])) {
            [self handleStd:pushInfo from:userInfo];
        }
    }else
    {
        [self handleCustom:pushInfo from:userInfo];
    }
}



- (void)handleStd:(NSMutableDictionary*)pushInfo from:(NSDictionary*)userInfo
{
    NSString* msg = [userInfo objectForKey:@"M"];
    int num = 0;
    NSUInteger      len = [msg length];
    unichar         buffer[len+1];
    [msg getCharacters: buffer range: NSMakeRange(0, len)];
    
    NSString *finalM;
    for (int i=0; i<len; i++) {
        if (buffer[i] == '_') {
            num++;
            if (num == 2 && len > i + 1) {
                finalM = [msg substringFromIndex:i+1];
            }
        }
    }
    
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setObject:[userInfo objectForKey:@"C"] forKey: @"channel"];
    [payload setObject:finalM forKey: @"message"];
    [payload setObject:[userInfo objectForKey:@"A"] forKey: @"appkey"];
    
    [instance fireEvent:@"onNotification" withObject:payload];
}


- (void)handleCustom:(NSMutableDictionary*)pushInfo from:(NSDictionary*)userInfo
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    for (NSString* key  in [[userInfo objectForKey:@"aps"] allKeys]) {
        if (![key isEqualToString:@"sound"] && ![key isEqualToString:@"badge"] && ![key isEqualToString:@"alert"]) {
            [payload setObject:[[userInfo objectForKey:@"aps"] objectForKey:key] forKey:key];
        }
    }
    
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    [content setObject:[userInfo objectForKey:@"C"] forKey: @"channel"];
    [content setObject:[userInfo objectForKey:@"M"] forKey: @"message"];
    [content setObject:[userInfo objectForKey:@"A"] forKey: @"appkey"];
    [content setObject:[self converDictionaryToString:payload] forKey: @"payload"];
    
    [instance fireEvent:@"onNotification" withObject:content];
}

- (NSString*)converDictionaryToString:(NSDictionary*)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}



- (int) getHeartbeatTime:(id)args {
    return [ortcClient getHeartbeatTime];
}

- (void) setHeartbeatTime:(id)args {
    int hbTime = (int)args;
    [ortcClient setHeartbeatTime:hbTime];
}

- (int) getHeartbeatFails:(id)args {
    return [ortcClient getHeartbeatFails];
}

- (void) setHeartbeatFails:(id)args {
    int hbFails = (int)args;
    [ortcClient setHeartbeatFails:hbFails];
}

- (int) isHeartbeatActive:(id)args {
    return [ortcClient isHeartbeatActive];

}

- (void) enableHeartbeat:(id)args {
    [ortcClient enableHeartbeat];
}

- (void) disableHeartbeat:(id)args {
    [ortcClient disableHeartbeat];
}


@end
