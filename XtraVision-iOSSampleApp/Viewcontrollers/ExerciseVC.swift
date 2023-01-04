//
//  ExerciseVC.swift
//  DemoApp
//
//  Created by XTRA on 25/10/22.
//
//
//  ExerciseVC.swift
//  DemoApp
//
//  Created by XTRA on 25/10/22.
//

import UIKit
import XtraVisionAI
//import Toast
import AVKit

class ExerciseVC : UIViewController, ReusableProtocol {
    
    //MARK:- static variable declaration
    static var instance: ExerciseVC {
        return findViewControllerIn(storyBoard: .main, identifier: ExerciseVC.reusableIdentifier) as! ExerciseVC
    }
    
    //MARK:- Variable declaration
    var assessment : String = ""
    private var xtraVisionMgr = XtraVisionAIManager.shared
    private var isPreJoin = true
    private var fullMessage = ""
    
    //MARK: Outlets
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var vwResponse: UIView!
    @IBOutlet weak var lblResponse: UITextView!
    
    //MARK: View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialiseController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      stopSession()
    }
    
    //MARK: UIButton action methods
    @IBAction func btnClickOnSkip(_ sender: UIButton) {
        btnSkip.isHidden = true
        vwResponse.isHidden = false
        isPreJoin = false
        xtraVisionMgr.disconnectSession()
        connectSession()
    }
    
    @IBAction func btnClickOnCancel(_ sender: UIButton) {
        stopSession()
        self.dismiss(animated: true)
    }
    
    //MARK: Common functions
    func initialiseController() {
        UIApplication.shared.isIdleTimerDisabled = true
        vwResponse.isHidden = true
        xtraVisionMgr.delegate = self
//        connectSocket()
    }
    
    func connectSession() {
        let assessmentConfig = XtraVisionAssessmentConfig(5, grace_time_threshold: 5)
        let connectionData = XtraVisionConnectionData("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3OTliZDI2YS0zYWMzLTQ4MzYtYWQ0NS04NDU4MDE1ZWUzODIiLCJhcHBJZCI6ImFlMjkyMGUyLTQ5MmUtMTFlZC05NzhkLTAyNzNkZDFhMzQ2YyIsIm9yZ0lkIjoiYWI0MzFjMGMtNDkyZS0xMWVkLTk3OGQtMDI3M2RkMWEzNDZjIiwiaWF0IjoxNjY4NTExODQ4LCJleHAiOjE3MDAwNjk0NDh9.BORFCdCr904YazJaFJmXAGjeg7Jpf9W9cxe4TAcc-Nw", assessmentName: assessment, assessmentConfig: assessmentConfig)

        let requestData = XtraVisionRequestData(isPreJoin)
        let skeletonConfig = XtraVisionSkeletonConfig(2.0, dotRadius: 4.0, lineColor: UIColor.red, dotColor: UIColor.blue)
        let libData = XtraVisionLibData(isSkeletonEnable, cameraView: cameraView, skeletonConfig: skeletonConfig)
        xtraVisionMgr.configureData(connectionData, requestData: requestData, libData: libData)
//        stopSession()
    }
    
    func stopSession() {
        xtraVisionMgr.disconnectSession()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

//MARK: XtraVisionAI Delegate method
extension ExerciseVC : XtraVisionAIDelegate {
    func onConnectSuccess() {
        print("Connection done successfully")
    }
    
    func onConnectFailed(_ string: String) {
        print("Connection failed: ", string)
    }
    
    func onConnectClose() {
        print("Connection closed")
    }
    
    
    func onMessageReceived(_ message: String) {
        print("message: \(message)")
        if let response = message.toJSON() as? [String : Any] {
            if isPreJoin {
                if let isPassed = response["isPassed"] as? Bool, isPassed == true {
                    vwResponse.isHidden = false
                    btnSkip.isHidden = true
                    isPreJoin = false
                    xtraVisionMgr.disconnectSession()
                    connectSession()
                } else {
//                    self.view.makeToast(response["message"] as? String, duration: 2.0, position: .bottom)
                }
            } else {
//                timeLeftLabel.text = "\(response["time_left"] as? Int ?? 999)"
                let msg = message + "\n\n" + lblResponse.text
                lblResponse.text = msg
            }
//
        }
    }
}
