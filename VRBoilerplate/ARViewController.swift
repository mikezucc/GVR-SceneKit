//
//  ViewController.swift
//  MEmes22
//
//  Created by Michael Zuccarino on 6/14/17.
//  Copyright © 2017 Michael Zuccarino. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!

    var dLink: CADisplayLink?

    var lastTransform: GLKMatrix4?
    var lastState = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!

        // Set the scene to the view
        sceneView.scene = scene
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self

//        dLink = CADisplayLink(target: self, selector: #selector(tick))
//        dLink?.preferredFramesPerSecond = 0
//        dLink?.add(to: .main, forMode: RunLoopMode.commonModes)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Failed with error \(error)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session was interrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("session was interrupted")
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        lastState = "\(frame.camera.trackingState)"
        if lastState.contains("normal") {
            lastTransform = convertSimDFloat4x4ToGLKMat4(frame.camera.transform)
        }
    }

    func convertSimDFloat4x4ToGLKMat4(_ simdTransform: matrix_float4x4) -> GLKMatrix4 {
        let slamGLKTransform = GLKMatrix4Make(simdTransform.columns.0.w, simdTransform.columns.0.x, simdTransform.columns.0.y, simdTransform.columns.0.z,
                                              simdTransform.columns.1.w, simdTransform.columns.1.x, simdTransform.columns.1.y, simdTransform.columns.1.z,
                                              simdTransform.columns.2.w, simdTransform.columns.2.x, simdTransform.columns.2.y, simdTransform.columns.2.z,
                                              simdTransform.columns.3.w, simdTransform.columns.3.x, simdTransform.columns.3.y, simdTransform.columns.3.z)
        return slamGLKTransform
    }

    // MARK: - ARSCNViewDelegate

    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()

     return node
     }
     */
//- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame

//    @objc func tick() {
//        if let transform = sceneView.session.currentFrame?.camera.transform {
//            lastTransform = transform
//        }
//    }

}

