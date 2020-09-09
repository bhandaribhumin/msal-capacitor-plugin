#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(msal, "msal",
           CAP_PLUGIN_METHOD(msalInit, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(initMSAL, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(aquireTokenAsync, CAPPluginReturnPromise);
           
           
)
