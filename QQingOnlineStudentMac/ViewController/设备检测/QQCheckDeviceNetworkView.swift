//
//  QQCheckDeviceNetworkView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/26.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa
import AgoraRtcEngineKit

class QQCheckDeviceNetworkView: NSView,QQNibLoadProtocol,AgoraManagerProtocol {
    

    //连接中。。。
    @IBOutlet weak var connectingView: NSView!
    @IBOutlet weak var animatorBackView: NSView!
    //连接失败
    @IBOutlet weak var connectFailView: NSView!
    //连接成功
    @IBOutlet weak var connectSuccessView: NSView!
    
    var ignoreBlock:Block?
    var knownBlock:Block?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.startConnectingAnimation()
        self.connectFailView.isHidden = true
        self.connectSuccessView.isHidden = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.setAgoraManagerDelegate()
    }
    
    func setAgoraManagerDelegate() {
        AgoraManager.sharedInstance.delegate = self
    }

}



//MARK:connectingView
extension QQCheckDeviceNetworkView {
    
    func startConnectingAnimation(){
        
        let image:NSImage? = NSImage.init(named: NSImage.Name(rawValue: "check_device_snap"))
        let imageView:NSImageView = NSImageView.init(frame: CGRect(x: 0, y: (self.animatorBackView.frame.size.height-5)/2, width: 26, height: 5))
        imageView.image = image
        self.animatorBackView.addSubview(imageView)
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 2
            imageView.animator().setFrameOrigin(NSPoint(x: self.animatorBackView.frame.size.width, y: imageView.frame.origin.y))
        }) {
            imageView.removeFromSuperview()
            self.startConnectingAnimation()
        }
    }
}

//MARK:connectFailView
extension QQCheckDeviceNetworkView {
    
    @IBAction func didClickOnReconnectButton(_ sender: Any) {
        self.connectFailView.isHidden = true
        self.connectSuccessView.isHidden = true
        self.connectingView.isHidden = false
        AgoraManager.sharedInstance.checkNetwork()
    }
    
    @IBAction func didClickOnIgnoreButton(_ sender: Any) {
        self.ignoreBlock?()
    }
}

//MARK:connectSuccessView
extension QQCheckDeviceNetworkView {
    
    @IBAction func didClickOnKnowButton(_ sender: Any) {
        self.knownBlock?()
    }

}

extension QQCheckDeviceNetworkView {
    
    func lastmileQuality(quality: AgoraNetworkQuality) {
        switch quality {
        case AgoraNetworkQuality.unknown,
             AgoraNetworkQuality.down: do {
//                self.connectFailView.isHidden = true
//                self.connectSuccessView.isHidden = false
//                self.connectingView.isHidden = true
                
                self.connectFailView.isHidden = false
                self.connectSuccessView.isHidden = true
                self.connectingView.isHidden = true

        }
        case AgoraNetworkQuality.excellent,
             AgoraNetworkQuality.good,
             AgoraNetworkQuality.poor,
             AgoraNetworkQuality.bad,
             AgoraNetworkQuality.vBad: do {
//                self.connectFailView.isHidden = false
//                self.connectSuccessView.isHidden = true
//                self.connectingView.isHidden = true
                
                self.connectFailView.isHidden = false
                self.connectSuccessView.isHidden = true
                self.connectingView.isHidden = true

            }
        }
    }
}
