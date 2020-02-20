//
//  MultiPeerConnectivityManager.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 24/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultiPeerConnectivityManagerDelegate {
    
    // MARK: - Attributes
    var didReceive: ((Data) -> Void)? { get }
    
    
    // MARK: - Methods
    func foundPeer(id: MCPeerID)
    func didReceiveInvitation(fromPeer: MCPeerID, invitationHandler: @escaping((Bool) -> Void))
    func notConnectedToPeer(peerID: MCPeerID)
    func lostPeer(id: MCPeerID)
    func connectedWithPeer(peerID: MCPeerID)
}

extension MultiPeerConnectivityManagerDelegate {
    
    var didReceive: ((Data) -> Void)? {
        get { nil }
    }
    func foundPeer(id: MCPeerID) {}
    func didReceiveInvitation(fromPeer: MCPeerID, invitationHandler: @escaping((Bool) -> Void)) {}
    func notConnectedToPeer(peerID: MCPeerID) {}
    func lostPeer(id: MCPeerID) {}
    func connectedWithPeer(peerID: MCPeerID) {}
}

class MultiPeerConnectivityManager: NSObject {
    
    // MARK: - Private attributes
    private var foundPeers = [MCPeerID]()
    private static let manager = MultiPeerConnectivityManager()
    
    
    // MARK: - Attributes
    static let shared = manager
    var peer: MCPeerID!
    let serviceType: String
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    var session: MCSession!
    var delegate: MultiPeerConnectivityManagerDelegate?
    
    
    // MARK: - Methods
    override init() {
        
        self.peer = MCPeerID(displayName: UIDevice.current.name)
        self.serviceType = "chat-service"
        super.init()
        
        self.session = MCSession(peer: self.peer, securityIdentity: nil, encryptionPreference: .none)
        self.session.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: self.peer, serviceType: self.serviceType)
        self.browser.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peer, discoveryInfo: [:], serviceType: self.serviceType)
        self.advertiser.delegate = self
    }
}

extension MultiPeerConnectivityManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state{
        case MCSessionState.connected:
               print("Connected to session: \(session)")
               delegate?.connectedWithPeer(peerID: peerID)
        
        case MCSessionState.connecting:
               print("Connecting to session: \(session)")
            
           default:
               print("Did not connect to session: \(session)")
               delegate?.notConnectedToPeer(peerID: peerID)
           }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received: \(String(data: data, encoding: .isoLatin1) ?? "Unable to encode data in .isoLatin1")")
        DispatchQueue.main.async { self.delegate?.didReceive?(data) }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceive stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

extension MultiPeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        self.foundPeers.append(peerID)
        self.delegate?.foundPeer(id: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        self.foundPeers.enumerated().forEach {
            if self.foundPeers.count > $0 {
                if $1 == peerID { self.foundPeers.remove(at: $0) }
            }
        }
        self.delegate?.lostPeer(id: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}

extension MultiPeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        self.delegate?.didReceiveInvitation(fromPeer: peerID) { isAccepted in
            invitationHandler(isAccepted, self.session)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}
