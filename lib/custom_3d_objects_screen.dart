import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

class Camera3d extends StatefulWidget {
  const Camera3d({super.key});

  @override
  State<Camera3d> createState() => _Camera3dState();
}

class _Camera3dState extends State<Camera3d> {
  ARSessionManager? sessionManager;
  ARObjectManager? objectManager;
  ARAnchorManager? anchorManager;

  List<ARNode> allNodes = [];
  List<ARAnchor> allAnchor = [];
  double distance = 0;

  whenARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    sessionManager = arSessionManager;
    objectManager = arObjectManager;
    anchorManager = arAnchorManager;

    sessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
      handlePans: true,
      handleRotation: true,
    );
    objectManager!.onInitialize();

    sessionManager!.onPlaneOrPointTap = whenPlaneDetectedAndUserTapped;
    // objectManager!.onPanStart = whenOnPanStarted;
    // objectManager!.onPanChange = whenOnPanChanged;
    // objectManager!.onPanEnd = whenOnPanEnded;
    // objectManager!.onRotationStart = whenOnRotationStarted;
    // objectManager!.onRotationChange = whenOnRotationChanged;
    // objectManager!.onRotationEnd = whenOnRotationEnded;
  }

  removeAllPoint() {
    setState(() {
      for (var element in allAnchor) {
        anchorManager!.removeAnchor(element);
      }
      allAnchor.clear();
      distance = 0;
    });
  }

  Future<void> whenPlaneDetectedAndUserTapped(
      List<ARHitTestResult> tapResults) async {
    ARHitTestResult userHitTestResult = tapResults.firstWhere((userTap) {
      return userTap.type == ARHitTestResultType.point;
    });
    var pointAnchor = ARPlaneAnchor(
      transformation: userHitTestResult.worldTransform,
    );

    bool? isAnchorAdded = await anchorManager!.addAnchor(pointAnchor);

    if (isAnchorAdded!) {
      allAnchor.add(pointAnchor);
      var nodeNew3dObject = ARNode(
        type: NodeType.webGLB,
        uri: 'https://eventsapp1.s3.eu-north-1.amazonaws.com/tmp/octt.glb',
        scale: vector64.Vector3(0.1, 0.1, 0.1),
        position: vector64.Vector3(0, 0, 0),
        rotation: vector64.Vector4(1, 0, 0, 0),
      );
      await objectManager!.addNode(
        nodeNew3dObject,
        planeAnchor: pointAnchor,
      );
      allNodes.add(nodeNew3dObject);
    }
    vector64.Vector3 v1 = allAnchor[0].transformation.getTranslation();
    vector64.Vector3 v2 = allAnchor[1].transformation.getTranslation();
    vector64.Vector3 result = v1 - v2;
    Talker().warning(
        "The distance between the two anchors is ${result.length} meters");
    var cylinder = ARNode(
      type: NodeType.webGLB,
      scale: vector64.Vector3(1, 0.1, 0.1),
      position: vector64.Vector3(0, 0, 0),
      rotation: vector64.Vector4(1, 0, 0, 0),
      uri: 'https://eventsapp1.s3.eu-north-1.amazonaws.com/tmp/octt.glb',
    );
    setState(() {
      distance = result.length;
    });
    objectManager!.addNode(cylinder, planeAnchor: pointAnchor);
  }

  //   //new anchor

  @override
  void dispose() {
    super.dispose();

    sessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom 3d Objects"),
        centerTitle: true,
      ),
      body: SizedBox(
        child: Stack(
          children: [
            ARView(
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
              onARViewCreated: whenARViewCreated,
            ),
            Text("Distance between anchors: $distance "),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    removeAllPoint();
                  },
                  child: const Text("Remove"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
