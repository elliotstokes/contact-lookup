var exec = require('cordova/exec');

exports.lookupContacts = function(phoneNumbers, countryCode, success, error) {
  exec(success, error, 'ContactLookup', 'lookupContacts', [phoneNumbers, countryCode]);
};
