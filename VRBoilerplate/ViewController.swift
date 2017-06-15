//
//  ViewController.swift
//  VRBoilerplate
//
//  Created by Andrian Budantsov on 5/19/16.
//  Copyright © 2016 Andrian Budantsov. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, GVRCardboardViewDelegate {

    let VRControllerClassKey = "VRControllerClass";
    
    var vrController: VRControllerProtocol?;
    
    var renderer : SceneKitVRRenderer?;
    var renderLoop: RenderLoop?;
    
    override func loadView() {
        
        let vrControllerClassName = Bundle.main
            .object(forInfoDictionaryKey: VRControllerClassKey) as! String;
        
        guard let vrClass = NSClassFromString(vrControllerClassName) as? VRControllerProtocol.Type else {
            fatalError("#fail Unable to find class \(vrControllerClassName), referenced in Info.plist, key=\(VRControllerClassKey)")
        }
        
        vrController = vrClass.init();
        
        let cardboardView = GVRCardboardView.init(frame: CGRect.zero)
        cardboardView?.delegate = self;
        cardboardView?.autoresizingMask =  [.flexibleWidth, .flexibleHeight];
        
        // VR mode is disabled in simulator by default 
        // double click to enable 
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            cardboardView?.vrModeEnabled = false;
        #else
            cardboardView?.vrModeEnabled = true;
        #endif
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(toggleVR));
        doubleTap.numberOfTapsRequired = 2;
        cardboardView?.addGestureRecognizer(doubleTap);
        
        self.view = cardboardView;
    }

    
    func toggleVR() {
        guard let cardboardView = self.view as? GVRCardboardView else {
            fatalError("view is not GVRCardboardView")
        }
        
        cardboardView.vrModeEnabled = !cardboardView.vrModeEnabled;
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        guard let cardboardView = self.view as? GVRCardboardView else {
            fatalError("view is not GVRCardboardView")
        }
        
        renderLoop = RenderLoop.init(renderTarget: cardboardView,
                                     selector: #selector(GVRCardboardView.render));
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        renderLoop?.invalidate();
        renderLoop = nil;
    }
    
    
    func cardboardView(_ cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!) {
        renderer = SceneKitVRRenderer(scene:vrController!.scene)
        
        renderer?.cardboardView(cardboardView, willStartDrawing: headTransform)
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, prepareDrawFrame headTransform: GVRHeadTransform!) {
        vrController!.prepareFrame(with: headTransform);
        renderer?.cardboardView(cardboardView, prepareDrawFrame: headTransform)
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, draw eye: GVREye, with headTransform: GVRHeadTransform!) {
        print("DRAW >> \(AppDelegate.arVC?.lastState)")
        if AppDelegate.arVC?.lastState.contains("normal") ?? false {
            print("\(AppDelegate.arVC?.lastTransform?.m) \n \(headTransform.headPoseInStartSpace().m)")
            // the idea here is to use the camera's transform from ARKit to stub the headPoseInStartSpace as the initial reference point or the following eye transorms
            /*
 (0.0, 0.993606448, 0.110164315, 0.0247001797, 0.0, -0.112899356, 0.969745815, 0.216441154, 0.0, -0.000108817789, -0.217845947, 0.975983143, 1.0, 0.0, 0.0, 0.0)
 (0.993927777, -0.107428268, 0.0238081142, 0.0, 0.11003451, 0.969874263, -0.217339337, 0.0, 0.000257510692, 0.218639314, 0.975805759, 0.0, 0.0, 0.0, 0.0, 1.0)
 */
            // As you can see there is a mismatch the in .m property o the 4x4 transformation matrix which means that something is very wrong.
            // The net thing to do is to compare the various matrices offered by both SDKs and see which ones are most closely aligned
            // then I could map the matrices from the ARKit to cardboard VR draw function
            renderer?.cardboardViewFromARTransform(cardboardView, draw: eye, with: headTransform, slamTransform: (AppDelegate.arVC?.lastTransform)!)
        } else {
            renderer?.cardboardView(cardboardView, draw: eye, with: headTransform);
        }
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool) {
        renderLoop?.paused = pause;
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, didFire event: GVRUserEvent) {

        if event == GVRUserEvent.trigger {
            vrController!.eventTriggered();
        }
    }

}

