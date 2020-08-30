import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;
  bool get isConnected => connection != null && connection.isConnected;

  int _deviceState;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0;

    enableBluetooth();

    FlutterBluetoothSerial.instance
      .onStateChanged()
      .listen((BluetoothState state) {
    setState(() {
      _bluetoothState = state;

      // For retrieving the paired devices list      
      getPairedDevices();
    });
  });
  }

  Future<void> enableBluetooth() async {
  // Retrieving the current Bluetooth state
  _bluetoothState = await FlutterBluetoothSerial.instance.state;
 
  // If the Bluetooth is off, then turn it on first
  // and then retrieve the devices that are paired.
  if (_bluetoothState == BluetoothState.STATE_OFF) {
    await FlutterBluetoothSerial.instance.requestEnable();
    await getPairedDevices();
    return true;
  } else {
    await getPairedDevices();
  }
  return false;
}

  List<BluetoothDevice> _devicesList = [];

Future<void> getPairedDevices() async {
  List<BluetoothDevice> devices = [];

  // It is an error to call [setState] unless [mounted] is true.
  if (!mounted) {
    return;
  }

  // Store the [devices] list in the [_devicesList] for accessing
  // the list outside this class
  setState(() {
    _devicesList = devices;
  });
}

bool isDisconnecting = false;

@override
void dispose() {
  if (isConnected) {
    isDisconnecting = true;
    connection.dispose();
    connection = null;
  }

  super.dispose();
}

  
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(10.3157, 123.8854);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  static final CameraPosition _position1 = CameraPosition(
    bearing: 192.833,
    target: LatLng(10.101193, 123.450346),
    zoom: 15.0,
  );

  Future<void> _goToPosition1() async{
    setState(() {
      _markers.add(
        Marker(
          position: LatLng(10.101193, 123.450346), 
          markerId: MarkerId("Tañon Strait"),
          infoWindow: InfoWindow(
            title: "Tañon Straight",
            snippet: "August 11, 2020 3:20pm"),
      ),
      );
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
   
  }

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position){
    _lastMapPosition = position.target;
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

//   showAlertDialog(BuildContext context) {
//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Text("Fishing Boat Seen in Municipal Waters"),
//     content: Image.asset("assets/boat.png",
//     height: 100,),
//     actions: [
//       FlatButton(
//     child: Text("OK"),
//     onPressed: () {
//       Navigator.pop(context,true);
//     },
//   )
//     ],
//   );

//   // show the dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }

  _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.satellite 
          : MapType.normal;
    });
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
          body: SlidingUpPanel(
            renderPanelSheet: false,
            panel: _floatingPanel(),
            collapsed: _floatingCollapsed(),
            minHeight: 70,
          body: Stack(
          children: <Widget>[
            Container(
              height: 1000,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 8.0),
                mapType: _currentMapType,
                markers: _markers,
                onCameraMove: _onCameraMove,
                ),
            ),
            Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color(0xFF004D40)
                    )
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search
                      ),
                      SizedBox(width:20),
                      Text("Learn more about Illegal Fishing"),
                    ]
                  ),
                ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget> [
                    SizedBox(
                      height: 100
                    ),
                    button(_onMapTypeButtonPressed, Icons.map),
                    SizedBox(
                      height: 16.0
                    ),
                    FloatingActionButton(
                      child: Icon(Icons.add_alert),
                      onPressed: ()
                        async{
                            await showDialog(
                            context: this.context,
                            child:  AlertDialog(
                              title: Text("Fishing Boat Spotted in Municipal Waters"),
                              content: ListTile(
                                  leading: Image.asset("assets/boat.png"),
                                  title: Text("Tañon Strait"),
                                  subtitle: Text("10.101193, 123.450346")
                                ),
                                actions: [
                                  FlatButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.pop(context,true);
                                    },
                                   )
                                ],
                              ),
                            );
                        setState(() {
                             _goToPosition1();
                          });
                      },
                    )
                  ],)
              ),
            ),
          ],
        ),
      )
    );
  }
}

Widget _floatingCollapsed(){
  return Container(
    decoration: BoxDecoration(
      color: Colors.blueGrey,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
    ),
    margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    child: Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))
                ),
              ),
          // SizedBox(height: 10),
          // Text("Check Buoy",
          //   style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 16),)   
        ]
        
      ),
    ),
  );
}

Widget _floatingPanel(){
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(24.0)),
      boxShadow: [
        BoxShadow(
          blurRadius: 20.0,
          color: Colors.grey,
        ),
      ]
    ),
    margin: const EdgeInsets.all(24.0),
    child: Center(
      child: Column(
        children: <Widget> [
          SizedBox(height: 20),
          Text("Buoy Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          Image.asset("assets/buoy.png"),
          Row(
            children: <Widget> [
            SizedBox(width: 30),
            Text("Boat Detection Camera:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(width: 20),
            Text("Active Status")
          ],
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget> [
            SizedBox(width: 70),
            Text("Light Sensor:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(width: 40),
            Text("Active Status")
          ],
          )
        ]
      )
    ),
  );
}