# BuoyWatch App

BuoyWatch is a two-node device. The first node is a [detection device](https://github.com/fxs1l/buoywatch-detector) which will be deployed via a buoy. It will be responsible for detecting fishing vessels located within 15-km near the coastline. It has (1) a camera tasked with monitoring and detecting fishing vessels through object detection and (2) a light sensor tasked with detecting sudden changes in illuminance underwater at night. The second node is a [central device](https://github.com/fxs1l/buoywatch-receiver.git) which will receive the data transmitted by the detection system and will be sending an SMS text message to the authorities through the Twilio Library and notification from the BuoyWatch mobile application regarding the detection, together with the coordinates of the fishing vessel.

## Mobile Application

<img align="center" src="https://github.com/fxs1l/Buoywatch/blob/master/images/buoywatch.png" alt="apps">

The mobile application was developed through Flutter, the Mobile App SDK of Google. It uses [Dart](https://dart.dev/) and is cross-platform, meaning it can run on both iOS and Android. GoogleMaps Library has been imported to display the Maps where the boats can be seen. The Boat detection buoy will send its coordinates in order for the authority to quickly locate where the illegal fishing has occured. The mobile application will gather the data from the central device through Bluetooth/WiFi within the Local Government Unit or where the authorities are. Future recommendations would be that the data be logged and stored in a web server so that data can be accessed anywhere as long as the app is connected to the internet.


## Getting Started

The main plugin used in this application is the GoogleMaps module. 

To use this plugin, add google_maps_flutter as a dependency in your pubspec.yaml file.

Next is getting an API key from https://cloud.google.com/maps-platform/.

Steps can be followed [here](https://pub.dev/packages/google_maps_flutter)

With the API-Key, do the following for:

Android
```bash
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

iOS
Specify your API key in the application delegate ios/Runner/AppDelegate.m in XCode:
```bash
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```
You can now add a GoogleMap widget to your widget tree.

The map view can be controlled with the GoogleMapController that is passed to the GoogleMap's onMapCreated callback.

