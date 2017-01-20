const {classes: Cc, interfaces: Ci, utils: Cu} = Components;
var Zotero;
var oldProcessor;
var installFlag = false;

var installProcessor = function() {
    Zotero = Cc["@zotero.org/Zotero;1"]
	    .getService(Ci.nsISupports)
	    .wrappedJSObject;
    oldProcessor = Zotero.CiteProc.CSL;
    Cu.import("resource://gre/modules/Services.jsm");
    Services.scriptloader.loadSubScript("chrome://propachi/content/citeproc.js", this, "UTF-8");
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
