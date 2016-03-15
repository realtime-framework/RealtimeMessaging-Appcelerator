package ibt.ortc.extensibility;

import co.realtime.ortc.BackgroundService;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.support.v4.content.WakefulBroadcastReceiver;


public class GcmOrtcBroadcastReceiver extends WakefulBroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        ComponentName comp = new ComponentName(context.getPackageName(), GcmOrtcIntentService.class.getName());
        startWakefulService(context, (intent.setComponent(comp)));
        
        ComponentName comp2 = new ComponentName(context.getPackageName(), BackgroundService.class.getName());
        startWakefulService(context, (intent.setComponent(comp2)));
        
        setResultCode(Activity.RESULT_OK);
    }
}
