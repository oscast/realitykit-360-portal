//
//  ContentView.swift
//  RealityKitPortal
//
//  Created by Oscar Castillo on 19/9/24.
//

import SwiftUI
import RealityKit
import ARKit
import AVKit

struct ContentView: View {
    var body: some View {
        if let path = Bundle.main.path(forResource: "360nature", ofType: "mp4") {
            ARVideoView(videoPath: path)
                .edgesIgnoringSafeArea(.all)
        } else {
            Text("Video not found.")
                .foregroundColor(.red)
                .font(.headline)
        }
    }
}

struct ARVideoView: UIViewRepresentable {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARVideoView
        
        init(parent: ARVideoView) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let anchorEntity = parent.anchorEntity
            let cameraTransform = frame.camera.transform
            let distance = simd_distance(cameraTransform.translation, anchorEntity.transform.translation)
            
            if distance < 0.8, parent.player.timeControlStatus != .playing {
                parent.player.play()
            }
        }
    }
    
    let player: AVPlayer
    let anchorEntity: AnchorEntity
    
    init(videoPath: String) {
        let fileUrl = URL(fileURLWithPath: videoPath)
        let player = AVPlayer(url: fileUrl)
        self.player = player
        
        let videoMaterial = VideoMaterial(avPlayer: player)
        let videoMesh = MeshResource.generateSphere(radius: 1.5)
        let videoEntity = ModelEntity(mesh: videoMesh, materials: [videoMaterial])
        
        videoEntity.scale = [1, 1, -1]
        
        let anchorEntity = AnchorEntity(world: [0, 0, -2])
        anchorEntity.addChild(videoEntity)
        
        self.anchorEntity = anchorEntity
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(anchorEntity)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

extension simd_float4x4 {
    var translation: simd_float3 {
        let translation = self.columns.3
        return simd_float3(translation.x, translation.y, translation.z)
    }
}
