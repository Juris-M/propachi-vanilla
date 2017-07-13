const {classes: Cc, interfaces: Ci, utils: Cu} = Components;
Cu.import("resource://gre/modules/Services.jsm");

var Zotero;
var oldProcessor;
var installFlag = false;

const PREF_BRANCH = 'extensions.propachi.';
const PREFS = {
  uppercase: false
};

function getPref(key) {
  // Cache the prefbranch after first use
  if (getPref.branch == null)
    getPref.branch = Services.prefs.getBranch(PREF_BRANCH);

  // Figure out what type of pref to fetch
  switch (typeof PREFS[key]) {
    case "boolean":
      return getPref.branch.getBoolPref(key);
    case "number":
      return getPref.branch.getIntPref(key);
    case "string":
      return getPref.branch.getCharPref(key);
  }
}

function setDefaultPrefs() {
  let branch = Services.prefs.getDefaultBranch(PREF_BRANCH);
  for (let [key, val] in Iterator(PREFS)) {
    switch (typeof val) {
      case "boolean":
        branch.setBoolPref(key, val);
        break;
      case "number":
        branch.setIntPref(key, val);
        break;
      case "string":
        branch.setCharPref(key, val);
        break;
    }
  }
}

var installProcessor = function() {
    Zotero = Cc["@zotero.org/Zotero;1"]
	    .getService(Ci.nsISupports)
	    .wrappedJSObject;
    oldProcessor = Zotero.CiteProc.CSL;
    
    let UPPERCASE = getPref("uppercase");
    if(UPPERCASE) {
      Services.scriptloader.loadSubScript("chrome://propachi-vanilla/content/citeprocUppercase.js", this, "UTF-8");
    } else {
      Services.scriptloader.loadSubScript("chrome://propachi-vanilla/content/citeprocVanilla.js", this, "UTF-8");
    }
	
    Zotero.CiteProc.CSL = CSL;
}.bind(this);

var uiObserver = {
    observe: function(subject, topic, data) {
        installProcessor();
    },
    register: function() {
        var observerService = Components.classes["@mozilla.org/observer-service;1"]
            .getService(Components.interfaces.nsIObserverService);
        observerService.addObserver(this, "final-ui-startup", false);
    },
    unregister: function() {
        var observerService = Components.classes["@mozilla.org/observer-service;1"]
            .getService(Components.interfaces.nsIObserverService);
        observerService.removeObserver(this, "final-ui-startup");
    }
}

/*
 * Bootstrap functions
 */

function startup (data, reason) {
    setDefaultPrefs();
    if (installFlag) {
        installProcessor();
    } else {
        uiObserver.register();
    }
}

function shutdown (data, reason) {
    if (installFlag) {
        Zotero.CiteProc.CSL = oldProcessor;
        installFlag = false;
    } else {
        uiObserver.unregister();
        Zotero.CiteProc.CSL = oldProcessor;
    }
}

function install (data, reason) {
    installFlag = true;
}
function uninstall (data, reason) {}
