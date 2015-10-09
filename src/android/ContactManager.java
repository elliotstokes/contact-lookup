package com.megaphone.cordova.contacts;

import android.provider.ContactsContract;
import org.apache.cordova.CordovaInterface;
import android.util.Log;
import android.content.ContentUris;
import android.database.Cursor;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;
import android.net.Uri;
import java.util.ArrayList;

public class ContactManager {
    protected CordovaInterface mApp;

    public ContactManager(CordovaInterface context) {
        this.mApp = context;
    }

    public JSONArray search(ArrayList<String> numbers, String countryCode) throws JSONException {
        
        String[] columns = new String[] {
            ContactsContract.Data.CONTACT_ID, ContactsContract.Data.MIMETYPE, 
            ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, 
            ContactsContract.CommonDataKinds.Phone.NUMBER,
            ContactsContract.CommonDataKinds.Photo._ID
        };

        String query = ContactsContract.CommonDataKinds.Phone.NUMBER + " is not null";

        JSONArray contacts = new JSONArray();

        try {



            JSONArray contactNumbers = new JSONArray();
            JSONObject contact = new JSONObject();
            Cursor cur = mApp.getActivity().getContentResolver().query(
                ContactsContract.Data.CONTENT_URI,
                columns,
                query,
                null,
                ContactsContract.Data.CONTACT_ID + " ASC");

            int colContactId = cur.getColumnIndex(ContactsContract.Data.CONTACT_ID);
            int colDisplayName = cur.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME);
            int colPhoneNumber = cur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER);
            int colMimetype = cur.getColumnIndex(ContactsContract.Data.MIMETYPE);
            String currentContactId = "";
            boolean newContact = true;
            boolean foundContact = false;
            if (cur.getCount() > 0) {
                while (cur.moveToNext()) {

                    String contactId = cur.getString(colContactId);
                    String mimetype = cur.getString(colMimetype);
                    if (cur.getPosition() == 0) {
                        currentContactId = contactId;
                    }

                    if (!currentContactId.equals(contactId)) {
                        if (foundContact) {
                            String photo = getPhotoUri(currentContactId);
                            if (photo != null) {
                                contact.put("photo", photo);
                            } else {
                                contact.put("photo", JSONObject.NULL);
                            }
                            contact.put("phoneNumbers", contactNumbers);
                            contacts.put(contact);                      
                        }

                        currentContactId = contactId;
                        newContact = true;
                        foundContact = false;
                    }

                    if (newContact) {
                        contact = new JSONObject();
                        contactNumbers = new JSONArray();
                        contact.put("id", contactId);
                        newContact = false;
                    }

                    if (mimetype.equals(ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)) {
                        contact.put("name", cur.getString(colDisplayName));
                    } else if (mimetype.equals(ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)) {
                        String possibleNumber = cur.getString(colPhoneNumber);
                        if (possibleNumber != null) {
                            String telNo = sanitiseNumber(possibleNumber,countryCode);
                            contactNumbers.put(telNo);
                            //check number exists
                            if (numbers.indexOf(telNo) >=0) {
                                foundContact = true;
                            }
                        }
                    } 
                }
            }
            cur.close();

            if (foundContact) {
                contact.put("phoneNumbers", contactNumbers);
                contacts.put(contact);          
            }
        } catch (Exception ex) {
            Log.e("CONTACT_MANAGER", ex.getMessage());
        }



        return contacts;
    }

    private String sanitiseNumber(String number, String countryCode) {

        String zerodNo = number.replaceAll("^00", "+");
        number = zerodNo.replaceAll("\\D", "");
        if (number.length() >= 2) {
            if (zerodNo.charAt(0) != '+') {
                int fromIndex = 0;
                String startDigits = number.substring(0,2);
                
                if (Countries.getTrunked().contains(countryCode)) {
                    fromIndex = Countries.calculateTrunkedFirstIndex(countryCode, number);
                } else if (Countries.getNonTrunked().contains(countryCode)) {
                    fromIndex = Countries.calculateNonTrunkedFirstIndex(countryCode, number);
                }

                number = countryCode + number.substring(fromIndex);
            }
        }

        return number;
    }

    private String getPhotoUri(String contactId) {
        Long cid = Long.valueOf(contactId);
        Uri person = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, cid);
        Uri photoUri = Uri.withAppendedPath(person, ContactsContract.Contacts.Photo.CONTENT_DIRECTORY);
        
        // Query photo existance
        Cursor photoCursor = mApp.getActivity().getContentResolver().query(photoUri, new String[] {ContactsContract.Contacts.Photo.PHOTO}, null, null, null);
        if (photoCursor == null) {
            return null;
        } else {
            if (!photoCursor.moveToFirst()) {
                photoCursor.close();
                return null;
            }
        }
        photoCursor.close();
        return photoUri.toString();
    }
}