//!javascript
//<adblock_subscriptions___SCRIPT
extensions.load("adblock_subscriptions", {
//<adblock_subscriptions___CONFIG

// Shortcut to subscribe to a filterlist
scSubscribe : null, 
// Command to subscribe to a filterlist
cmdSubscribe : "adblock_subscribe", 

// Shortcut to unsubscribe from a filterlist
scUnsubscribe : null, 

// Command to unsubscribe from a filterlist
cmdUnsubscribe : "adblock_unsubscribe",

// Shortcut to update subscriptions and reload filter rules
// Note that dwb will also update all subscriptions on startup
scUpdate : null, 

// Command to update subscriptions and reload filter rules
// Note that dwb will also update all subscriptions on startup
cmdUpdate : "adblock_update", 

// Path to the filterlist directory, will be created if it doesn't exist. 
filterListDir : data.configDir + "/adblock_lists"
//>adblock_subscriptions___CONFIG
});
//>adblock_subscriptions___SCRIPT
//<autoquvi___SCRIPT
extensions.load("autoquvi", {
//<autoquvi___CONFIG
  // The quvi command
  quvi      : "quvi",  

  // External player command
  player    : "mplayer %u", 

  // Whether to automatically play videos when quvi find a playable
  // video
  autoPlay  : false, 

  // Whether to choose the quality before quvi starts
  chooseQuality : true,

  // A shortcut that spawns quvi for the current website
  shortcut  : "Control q",

  // A command that spawns quvi for the current website 
  command  : "autoquvi"

//>autoquvi___CONFIG
});
//>autoquvi___SCRIPT
//<supergenpass___SCRIPT
extensions.load("supergenpass", {
//<supergenpass___CONFIG
// Compatibility mode, always generate passwords that are
// compatible with the original supergenpass bookmarklet
compat : false,

// Additional salts that are added on a domain basis. 
// domainSalts has to be an object of the form
// { "example.com" : "foo", "example.co.uk" : "bar" }
// In Compatibility mode domain salts are disabled
domainSalts : {},

// The hash-algorithm to use, either ChecksumType.md5,
// ChecksumType.sha1 or ChecksumType.sha256, in
// compatibility mode it is set to ChecksumType.md5
hashMethod : ChecksumType.md5,

// Length of the password, the minimum length is 4, the
// maximum length depends on the hashMethod, for md5 it is
// 24, for sha1 it is 28 and for sha256 it is 44. 
length : 20, 

// Minimum number of rehashes, in compatibility mode it is
// set to 10
rehash : 10, 

// A salt that will additionally be added to the password, 
// in compatibility mode set to ""
salt : "Spiderman3", 

// Whether to save the master password or ask every time
// a password is generated
saveMasterPassword : false, 

// The shortcut to invoke this extension
shortcut : "Control x",

// A shortcut that prints the generated password to stdout
// instead of injecting it into the website
shortcutPrint :  "",

// Whether to strip subdomains
stripSubdomains : true
//>supergenpass___CONFIG
});
//>supergenpass___SCRIPT
