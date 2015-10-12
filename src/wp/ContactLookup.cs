
using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;
using Microsoft.Phone.Tasks;
using Microsoft.Phone.UserData;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Runtime.Serialization;
using System.Windows;

public class ContactLookup : BaseCommand {

	public void lookupContacts(String options)
    {
     	
     	Contacts contacts = new Contacts();   
        contacts.SearchCompleted +=new EventHandler<ContactsSearchEventArgs>(contacts_SearchCompleted);


        try
        {
            contacts.SearchAsync(String.Empty, FilterKind.None, null);
        }
        catch (Exception ex)
        {
            Debug.WriteLine("search contacts exception :: " + ex.Message);
        }
    }

        private void contacts_SearchCompleted(object sender, ContactsSearchEventArgs e)
        {
            Debug.WriteLine(e.Results.Count().ToString());
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.Message = "["  + "]";
            DispatchCommandResult(result);
        }
    }
}