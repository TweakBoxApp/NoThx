//
//  TweakBoxAntiRevoke.swift
//  AntiRevoke
//
//  Created by Ignacio Sepulveda on 03/06/2018.
//  Copyright © 2018 Joseph Shenton. All rights reserved.
//

import UIKit
import NetworkExtension
import Pulsator
import StatusAlert


class TweakBoxAntiRevoke: UIViewController {

    @IBOutlet weak var cube: UIImageView!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    let pulsator = Pulsator()
    let alreadyAlert = StatusAlert.instantiate(
        withImage: UIImage(named: "checkmark"),
        title: "Already Protecting!",
        message: "",
        canBePickedOrDismissed: false
    )
    let followAlert = StatusAlert.instantiate(
        withImage: UIImage(named: "checkmark"),
        title: "Already Protecting!",
        message: "",
        canBePickedOrDismissed: false
    )
    
    var status: VPNStatus {
        didSet(o) {
            updateConnectButton()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.status = .off
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(onVPNStatusChanged), name: NSNotification.Name(rawValue: kProxyServiceVPNStatusNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cube.layer.superlayer?.insertSublayer(pulsator, below: cube.layer)
        checkStatusAndStartPulse()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.status = VpnManager.shared.vpnStatus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.checkStatusAndStartPulse()
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = cube.layer.position
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.status = VpnManager.shared.vpnStatus
    }
    
    func onVPNStatusChanged(){
        self.status = VpnManager.shared.vpnStatus
    }
    
    
    func updateConnectButton(){
        switch status {
        case .connecting:
            statusLabel.text = "Connecting"
            pulsator.stop()
            setupConnectedValues()
            let alertController = UIAlertController(title: "Protected!", message: "Follow us on Twitter to receive Updates!", preferredStyle: UIAlertControllerStyle.alert)

            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Follow", style: UIAlertActionStyle.default,handler: {
                (action) in
                UIApplication.shared.open(URL(string: "http://twitter.com/TweakBoxApp")!, options: [:], completionHandler: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
            
        case .disconnecting:
            statusLabel.text = "Disconnecting"
            pulsator.stop()
            setupDisconnectedValues()
        case .on:
            connectButton.setTitle("Protected", for: UIControlState())
            statusLabel.text = ""

            pulsator.start()
        case .off:
            connectButton.setTitle("Protect", for: UIControlState())
            statusLabel.text = "Disconnected"

            pulsator.start()
            
        }
        connectButton.isEnabled = [VPNStatus.on,VPNStatus.off].contains(VpnManager.shared.vpnStatus)
        
        
    }
    
    func pulsatorStart() {
        setupConnectedValues()
        pulsator.start()
}
    
    @IBAction func connectToAntiRevoke(_ sender: AnyObject) {
        print("Connecting to AntiRevoke")

        if(VpnManager.shared.vpnStatus == .off){
            VpnManager.shared.connect()
        }else if (VpnManager.shared.vpnStatus == .on){
//            alreadyAlert.showInKeyWindow()
            VpnManager.shared.disconnect()
        }
    }
    
    @IBAction func followTW(_ sender: Any) {
    UIApplication.shared.open(URL(string: "http://twitter.com/TweakBoxApp")!, options: [:], completionHandler: nil)
    }
    func checkStatusAndStartPulse() {
        if (VpnManager.shared.vpnStatus == .on) {
            setupConnectedValues()
            pulsator.start()
        } else if (VpnManager.shared.vpnStatus == .off) {
            setupDisconnectedValues()
            pulsator.start()
        }
    }
    // ANIMATION
    private func setupConnectedValues() {
        pulsator.numPulse = 7
        pulsator.radius = 180
        pulsator.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor
        pulsator.animationDuration = 5
    }
    private func setupDisconnectedValues() {
        pulsator.numPulse = 7
        pulsator.radius = 180
        pulsator.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        pulsator.animationDuration = 5
    }

}
