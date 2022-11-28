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
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    //MARK: Outlets
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var vwResponse: UIView!
    @IBOutlet weak var lblResponse: UITextView!
    
    //MARK: View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        initialiseController()
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
        connectSocket()
    }

    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = cameraView.frame
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            previewLayer.connection?.videoOrientation = .landscapeLeft
        } else {
            previewLayer.connection?.videoOrientation = .portrait
        }
    }
    
    //MARK: UIButton action methods
    @IBAction func btnClickOnSkip(_ sender: UIButton) {
        btnSkip.isHidden = true
        vwResponse.isHidden = false
        isPreJoin = false
        xtraVisionMgr.disconnectSocket()
        connectSocket()
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
    
    func connectSocket() {
        let assessmentConfig = XtraVisionAssessmentConfig(5, grace_time_threshold: 5)
        let connectionData = XtraVisionConnectionData("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJkOTU1NTVkNS0wNmFhLTExZWQtOGJkYy0xMmZhYjRmZmFiZWQiLCJhcHBJZCI6IjY5YTdmMmU2LTA2YWEtMTFlZC04YmRjLTEyZmFiNGZmYWJlZCIsIm9yZ0lkIjoiNmQ5MWZlN2YtMDZhOS0xMWVkLThiZGMtMTJmYWI0ZmZhYmVkIiwiaWF0IjoxNjYwMTA3MjI0LCJleHAiOjE2OTE2NjQ4MjR9._i4MJbwPznHzxoStcRAcK7N7k_xGdUjvKwmHXv1zixM", assessmentName: assessment, assessmentConfig: assessmentConfig)

        let requestData = XtraVisionRequestData(isPreJoin)
        let skeletonConfig = XtraVisionSkeletonConfig(2.0, dotRadius: 4.0, lineColor: UIColor.red, dotColor: UIColor.blue)
        let libData = XtraVisionLibData(isSkeletonEnable, cameraView: cameraView, previewLayer: previewLayer, skeletonConfig: skeletonConfig)
        xtraVisionMgr.configureData(connectionData, requestData: requestData, libData: libData)
    }
    
    private func setUpCaptureSessionOutput() {
        weak var weakSelf = self
        sessionQueue.async {
          guard let strongSelf = weakSelf else {
            print("Self is nil!")
            return
          }
          strongSelf.captureSession.beginConfiguration()
          // When performing latency tests to determine ideal capture settings,
          // run the app in 'release' mode to get accurate performance metrics
          strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.medium

          let output = AVCaptureVideoDataOutput()
          output.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
          ]
          output.alwaysDiscardsLateVideoFrames = true
          let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
          output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
          guard strongSelf.captureSession.canAddOutput(output) else {
            print("Failed to add capture session output.")
            return
          }
          strongSelf.captureSession.addOutput(output)
          strongSelf.captureSession.commitConfiguration()
        }
      }
    
    private func setUpCaptureSessionInput() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            let cameraPosition: AVCaptureDevice.Position = .front
            guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                strongSelf.captureSession.beginConfiguration()
                let currentInputs = strongSelf.captureSession.inputs
                for input in currentInputs {
                    strongSelf.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard strongSelf.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                strongSelf.captureSession.addInput(input)
                strongSelf.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        return discoverySession.devices.first { $0.position == position }
    }
    
    private func startSession() {
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        UIApplication.shared.isIdleTimerDisabled = false
        weak var weakSelf = self
        sessionQueue.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.stopRunning()
            strongSelf.xtraVisionMgr.disconnectSocket()
        }
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension ExerciseVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        xtraVisionMgr.detectPose(sampleBuffer)
    }
}

//MARK: XtraVisionAI Delegate method
extension ExerciseVC : XtraVisionAIDelegate {
    
    func onMessageReceived(_ message: String) {
        print("message: \(message)")
        if let response = message.toJSON() as? [String : Any] {
            if isPreJoin {
                if let isPassed = response["isPassed"] as? Bool, isPassed == true {
                    vwResponse.isHidden = false
                    btnSkip.isHidden = true
                    isPreJoin = false
                    xtraVisionMgr.disconnectSocket()
                    connectSocket()
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

private enum Constant {
  static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
}
