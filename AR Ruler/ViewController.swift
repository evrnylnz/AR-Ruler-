//
//  ViewController.swift
//  AR Ruler
//
//  Created by Evren Yalnız on 25.07.2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var distanceText: UILabel!
    var textNode = SCNNode()
    var distance: Float = 0.0
    
    var dotNodes = [SCNNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //Use this option to see feature points
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            textNode.removeFromParentNode()
            dotNodes.removeAll()
            
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func addDot(at hitResult: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                      y: hitResult.worldTransform.columns.3.y,
                                      z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2{
            calculate()
        }
        
    }
    
    func calculate() {
        let start = dotNodes[0].position
        let end = dotNodes[1].position
        
        let x = pow((end.x - start.x), 2)
        let y = pow((end.y - start.y), 2)
        let z = pow((end.z - start.z), 2)
        
        distance = sqrt(x + y + z)
        print(distance)
        print(round(distance * 100))
        updateText(text: "\(round(distance * 10000) / 100) cm" , atPosition: start)
    }

    
    func updateText(text: String, atPosition position: SCNVector3){
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor(.blue)
        let scale = distance/30
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        sceneView.scene.rootNode.addChildNode(textNode)
        distanceText.text = text
    }
    
    
}
