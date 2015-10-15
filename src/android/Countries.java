package com.megaphone.cordova.contacts;

import java.util.ArrayList;
import java.util.Arrays;

public class Countries {

	private static ArrayList<String> trunked = new ArrayList<String> (Arrays.asList("33", "34", "44", "49", "61", "64", "91", "353", "971", "972"));
	private static ArrayList<String> nonTrunked = new ArrayList<String> (Arrays.asList("1"));
	// private static ArrayList<String> all = null;
	
	public static ArrayList<String> getTrunked() {
		return trunked;
	}

	public static ArrayList<String> getNonTrunked() {
		return nonTrunked;
	}

	public static int calculateNonTrunkedFirstIndex(String countryCode, String number) {
		return (number.startsWith(countryCode)) ? countryCode.length() : 0;
	}

	public static int calculateTrunkedFirstIndex(String countryCode, String number) {
    	if (number.startsWith(countryCode)) return countryCode.length();
    	if (number.startsWith("0"))         return 1;
    	return 0;
	}
}