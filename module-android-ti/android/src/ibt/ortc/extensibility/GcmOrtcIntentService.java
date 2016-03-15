package ibt.ortc.extensibility;

import ibt.ortc.api.Ortc;
import ibt.ortc.plugins.IbtRealtimeSJ.OrtcMessage;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONValue;

import com.google.android.gms.gcm.GoogleCloudMessaging;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;


public class GcmOrtcIntentService extends Service {	
	int mStartMode;
	HashMap<Integer, WeakReference<OrtcClient>> ortcs;
	private int clientsCount;
	
	@Override
    public void onCreate() {
        ortcs = new HashMap<Integer, WeakReference<OrtcClient>>();
        clientsCount = 0;
    }
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) { 
    	//System.out.println("got start command");
    	if(intent != null){
    		Bundle extras = intent.getExtras();
            GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
            String messageType = gcm.getMessageType(intent);        
            if(extras != null){
    	        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
    	        	if (GoogleCloudMessaging.MESSAGE_TYPE_MESSAGE.equals(messageType)) {
    	            	String message = extras.getString("M");
    	            	String channel = extras.getString("C");
    	            	String appkey  = extras.getString("A");
    	            	String payload  = extras.getString("P");
    	            	
    	            	if(message == null || channel == null)
    	            		return mStartMode;
    	            	try {
    	            		String fstPass = JSONValue.toJSONString(message);
    	            		fstPass = fstPass.substring(1, fstPass.length()-1);
    	            		String sndPass = JSONValue.toJSONString(fstPass);
    	            		sndPass = sndPass.substring(1, sndPass.length()-1);
    	            		String messageForOrtc = String.format("a[\"{\\\"ch\\\":\\\"%s\\\",\\\"m\\\":\\\"%s\\\"}\"]", channel, sndPass);

    						OrtcMessage ortcMessage = OrtcMessage.parseMessage(messageForOrtc);
    						
     						List<Integer> clientsToRemove = new ArrayList<Integer>();
     						Boolean pushNotificationHandlerExecuted = false;
     						
    						for(Map.Entry<Integer, WeakReference<OrtcClient>> entry : ortcs.entrySet()){
    							Integer clientId = entry.getKey();
    							OrtcClient oc = entry.getValue().get();
    							if(oc == null){
    								clientsToRemove.add(clientId);
    							} else {
    								if(oc.applicationKey.equals(appkey)){
    									ChannelSubscription subscription = oc.subscribedChannels.get(channel);
    									if(payload == null && subscription!=null && ( Ortc.getOnPushNotification() == null || (oc.isConnected && !oc.isReconnecting))){
    										if(subscription.isWithNotification()){
    											String messId = ortcMessage.getMessageId();
    											if(messId!=null && oc.multiPartMessagesBuffer.containsKey(messId)){
    												continue;
    											}
    											oc.raiseOrtcEvent(EventEnum.OnReceived, ortcMessage.getMessageChannel(),
    														ortcMessage.getMessage(), messId,
    														ortcMessage.getMessagePart(), ortcMessage.getMessageTotalParts());
    										}
    									}else if(!pushNotificationHandlerExecuted && Ortc.getOnPushNotification() != null){
    										pushNotificationHandlerExecuted = true;
    										Log.i("INTENT SERVICE", "Intent service onStartCommand");
    										Ortc.getOnPushNotification().run(null, ortcMessage.getMessageChannel(), ortcMessage.getMessage(), payload);    										
    									} 
    								}
    							}
    						}
    						for(Integer clientId : clientsToRemove){
    							ortcs.remove(clientId);
    						}

    					} catch (IOException e) {
    						e.printStackTrace();						
    					}
    	            }
    	        }
            }            
    	}
    	return mStartMode;    	
    }
	
    public class ServiceBinder extends Binder {
    	GcmOrtcIntentService getService() {
    		return GcmOrtcIntentService.this;
    	}
    }
    private IBinder mBinder = new ServiceBinder();
    
	@Override
	public IBinder onBind(Intent arg0) {
		return mBinder;
	}
	
	@Override
	public void onDestroy(){		
	}
	
	public void setServiceOrtcClient(OrtcClient ortcClient){
		ortcs.put(clientsCount, new WeakReference<OrtcClient>(ortcClient));
		ortcClient.gcmServiceId = clientsCount;
		clientsCount++;
	}
	
	public void removeServiceOrtcClient(OrtcClient ortcClient){	
		ortcs.remove(ortcClient.gcmServiceId);
	}
}
