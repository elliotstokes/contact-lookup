package com.megaphone.cordova.contacts;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;
import java.util.ArrayList;



public class ContactLookup extends CordovaPlugin {

	private static final String ACTION_LOOKUP_CONTACTS = "lookupContacts";
	private ContactManager contactManager;
	private static final String NOT_SUPPORTED_ERROR = "Plugin not supported on this platform";

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		
        if (android.os.Build.VERSION.RELEASE.startsWith("1.")) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, ContactLookup.NOT_SUPPORTED_ERROR));
            return true;
        }

        JSONArray numbers = args.optJSONArray(0);
        String countryCode = args.optString(1);

        contactManager = new ContactManager(this.cordova);

		if (action.equals(ACTION_LOOKUP_CONTACTS)) {
			ArrayList<String> list = new ArrayList<String>();  
			for (int i=0; i< numbers.length(); i++) {
				list.add(numbers.get(i).toString());
			}
			JSONArray contacts = contactManager.search(list);
			callbackContext.success(contacts);
			return true;
		}

		return false;
		
	}
 

}