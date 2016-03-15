package co.realtime.ortc;

import ibt.ortc.api.Ortc;
import ibt.ortc.plugins.IbtRealtimeSJ.OrtcMessage;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.LinkedBlockingQueue;

import org.appcelerator.titanium.TiApplication;
import org.json.simple.JSONValue;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ComponentName;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Binder;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;

public class BackgroundService extends Service {

	private static final String TAG = "Backgroundservice";
	private static final int MAX_QUEUE_IDS = 50;
	private IBinder binder = new ServiceBinder();
	private HashMap<String, String> IDS = new HashMap<String, String>();
	private LinkedBlockingQueue<String> FIFOIDS = new LinkedBlockingQueue<String>();
	
	@Override
	public void onCreate() {
		super.onCreate();
		Log.i(TAG, "Service onCreate");
//			if(OrtcModule.client == null){
//				try {
//					Ortc ortc = new Ortc();
//
//					OrtcFactory factory;
//					factory = ortc.loadOrtcFactory("IbtRealtimeSJ");
//					OrtcModule.client = factory.createClient();
//					OrtcModule.client.setHeartbeatActive(true);
//					
//				} catch (Exception e) {
//					Log.i(TAG, String.format("ORTC CREATE ERROR: %s", e.toString()));
//				}
//			}
//			if(OrtcModule.client != null){
//
//				if(!OrtcModule.client.getIsConnected()){
//					TiApplication appContext = TiApplication.getInstance();
//					OrtcModule.client.setApplicationContext(appContext);
//					
//					SharedPreferences settings = appContext.getSharedPreferences("ortcInfo", 0);
//
//					OrtcModule.client.setGoogleProjectId(settings.getString("projectId","").toString());
//					OrtcModule.client.setClusterUrl(settings.getString("clusterUrl","").toString());
//					OrtcModule.client.setConnectionMetadata(settings.getString("metadata", "").toString());
//					
//					OrtcModule.client.connect(settings.getString("appKey", ""), settings.getString("token","").toString());
//				}
//			}
	}


	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		Log.i(TAG, "Background service onStartCommand");
		if(intent != null){
    		Bundle extras = intent.getExtras();
            GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
            String messageType = gcm.getMessageType(intent);        
            if(extras != null){
    	        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
    	        	Log.i(TAG, "INTENT: " + intent.toString());
    	        	if (GoogleCloudMessaging.MESSAGE_TYPE_MESSAGE.equals(messageType)) {
    	        		String payload = extras.getString("P");
    	            	String message = extras.getString("M");
    	            	String channel = extras.getString("C");
    	            	
    	            	if(message == null || channel == null)
    	            		return Service.START_STICKY;
    	            	
    	            	String fstPass = JSONValue.toJSONString(message);
	            		fstPass = fstPass.substring(1, fstPass.length()-1);
	            		String sndPass = JSONValue.toJSONString(fstPass);
	            		sndPass = sndPass.substring(1, sndPass.length()-1);
	            		String messageForOrtc = String.format("a[\"{\\\"ch\\\":\\\"%s\\\",\\\"m\\\":\\\"%s\\\"}\"]", channel, sndPass);
	            		OrtcMessage ortcMessage = null;
						try {
							
							ortcMessage = OrtcMessage.parseMessage(messageForOrtc);
							if(Ortc.getOnPushNotification() != null && !IDS.containsKey(ortcMessage.getMessageId())){
								
								if(ortcMessage.getMessageId() != null && !ortcMessage.getMessageId().equals(""))
								{
									this.setOnQueue(ortcMessage.getMessageId());
								}
								
								if(!OrtcModule.client.getIsConnected())
								{
									Ortc.getOnPushNotification().run(null, ortcMessage.getMessageChannel(), ortcMessage.getMessage(), payload); 
									Log.i(TAG, "get on push notification");
								} 
							}
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
    	            	
						if (!this.isForeground( getApplicationContext().getPackageName())){
					    	displayNotification(ortcMessage.getMessageChannel(), ortcMessage.getMessage(), payload);
					    }					
    	            }
    	        }
            }            
    	}
		return Service.START_STICKY;
	}
	
	private void setOnQueue(String id){
		this.IDS.put(id, id);
		this.FIFOIDS.add(id);
		
		if(this.FIFOIDS.size() > MAX_QUEUE_IDS){
			String temp = this.FIFOIDS.poll();
			this.IDS.remove(temp);
		}
	}
	
	
	public boolean isForeground(String myPackage) {
	    ActivityManager manager = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
	    @SuppressWarnings("deprecation")
		List<ActivityManager.RunningTaskInfo> runningTaskInfo = manager.getRunningTasks(1); 
	    ComponentName componentInfo = runningTaskInfo.get(0).topActivity;
	    return componentInfo.getPackageName().equals(myPackage);
	}

	@Override
	public void onDestroy() {
		Log.i(TAG, "Service onDestroy");
	}

    
    @Override
    public IBinder onBind(Intent intent) {
        Log.d(TAG, "onBind done");
        return binder;
    }
 
    @Override
    public boolean onUnbind(Intent intent) {
        return false;
    }
 
    public class ServiceBinder extends Binder {
        BackgroundService getService() {
            return BackgroundService.this;
        }
    }
    
	private void displayNotification(String channel, String message, String payload) {
		
		String packageName = getApplicationContext().getPackageName();
		Intent launchIntent = getApplicationContext().getPackageManager().getLaunchIntentForPackage(packageName);
		String className = launchIntent.getComponent().getClassName();
		
		Class<?> c = null;
		if(className != null) {
		    try {
		        c = Class.forName(className );
		    } catch (ClassNotFoundException e) {
		        // TODO Auto-generated catch block
		        e.printStackTrace();
		    }
		}
		
        Intent notificationIntent = new Intent(this, c);
        notificationIntent.putExtra("channel", channel);
        notificationIntent.putExtra("message", message);
        
        if(payload != null)
        	notificationIntent.putExtra("payload", ""+payload.toString());
        
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

    	NotificationManager nm = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
        
      	TiApplication appContext = TiApplication.getInstance();
    	SharedPreferences settings = appContext.getSharedPreferences("ortcInfo", 0);
    	String title = settings.getString("pushTitle","").toString();
    	
    	String pName = getApplicationContext().getPackageName();

		ApplicationInfo info = null;
        try {
            info = getApplicationContext().getPackageManager().getApplicationInfo(pName, 0);
        } catch (NameNotFoundException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
        int icon = info.icon;

//    	icon = getApplicationContext().getResources().getIdentifier(icon_name, "drawable", getApplicationContext().getPackageName());    	
    	
        Notification notification = new NotificationCompat.Builder(this).setContentTitle((title!= null) ? title : channel).setContentText(message).setSmallIcon(icon)
        .setContentIntent(PendingIntent.getActivity(getApplicationContext(), 0, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT)).setAutoCancel(true).build();
        nm.notify(9999, notification);
    }
}
