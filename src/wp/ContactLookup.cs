
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
using DeviceContacts = Microsoft.Phone.UserData.Contacts;
using System.Text.RegularExpressions;
using System.IO;

public class ContactLookup : BaseCommand {
    private List<String> _Numbers = null;
    private String _CountryCode = null;

	public void lookupContacts(String options)
    {
        string[] args = WPCordovaClassLib.Cordova.JSON.JsonHelper.Deserialize<string[]>(options);

        if (args.Length != 2) {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR);
            DispatchCommandResult(result);
            return;
        }

        this._Numbers = new List<String>(WPCordovaClassLib.Cordova.JSON.JsonHelper.Deserialize<string[]>(args[0]));
        this._CountryCode = WPCordovaClassLib.Cordova.JSON.JsonHelper.Deserialize<string>(args[1]);

        DeviceContacts contacts = new DeviceContacts();   
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
        List<String> foundContacts = new List<String>();

        Debug.WriteLine(e.Results.Count().ToString());
        foreach(Contact contact in e.Results)
        {
            foreach( ContactPhoneNumber contactPhoneNumber in contact.PhoneNumbers)
            {
                String sanitisedNo = SanitiseNumber(contactPhoneNumber.PhoneNumber, "44");
                if (this._Numbers.Contains(sanitisedNo))
                {
                    Stream s = contact.GetPicture();
                    if (s != null)
                    {
                        using (BinaryReader binaryReader = new BinaryReader(s))
                        {
                            Byte[] b = binaryReader.ReadBytes((int)s.Length);
 
                            String contactJson = "{" + "name: \"" + contact.DisplayName + "\", phoneNumbers: [\"" + sanitisedNo + "\"]" + ", photo: \"" + Convert.ToBase64String(b) + "\"}";
                            foundContacts.Add(contactJson);
                        }
                    }
                    
                    break;
                }
            }
        }


        PluginResult result = new PluginResult(PluginResult.Status.OK);
        result.Message = "[" + String.Join(",",foundContacts) + "]";
        DispatchCommandResult(result);



    }

    private String SanitiseNumber(String number, String countryCode)
    {
        String zerodNumber = Regex.Replace(number,"^00", "+");
        number = Regex.Replace(number, "\\D", "");
        if (number.Length >= 2)
        {
            int fromIndex = 0;
            String startDigits = number.Substring(0, 2);
            if (Countries.Trunked.Contains(countryCode))
            {
                fromIndex = Countries.CalculateTrunkedFirstIndex(countryCode, number);
            }
            else if (Countries.NonTrunked.Contains(countryCode))
            {
                fromIndex = Countries.CalculateNonTrunkedFirstIndex(countryCode, number);
            }

            number = countryCode + number.Substring(fromIndex);
        }

        return number;
    }
}