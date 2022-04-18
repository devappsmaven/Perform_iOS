//
//  PromptDocumentViewController.swift
//  PerformDemo
//
//  Created by mac on 17/11/21.
//

import UIKit
import PDFKit
import AVFoundation
import AVKit

class PromptDocumentViewController: UIViewController, PDFViewDelegate,VideoOptControllerDelegate,checkDeleteRecording {
   

    //    MARK: - IBOUTLETS(s)
    
    @IBOutlet weak var showMeSwitch: UISwitch!
    @IBOutlet weak var recordMeSwitch: UISwitch!
    @IBOutlet weak var viewDiagonal: UIView!
    @IBOutlet weak var viewAudioVideoPopUp: UIView!
    @IBOutlet weak var viewAVBackground: UIView!
    @IBOutlet weak var pdfSuperView: UIView!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblDocTitle: UILabel!
    @IBOutlet weak var btnSpeedIncrease: UIButton!
    @IBOutlet weak var recorderViewOutlet: UIView!
    @IBOutlet weak var ipadRecorderView: UIView!
    @IBOutlet weak var audioTrackSlider: UISlider!
    @IBOutlet weak var audioTrackSlideriPad: UISlider!
    
    @IBOutlet weak var scrollingTrackSlider: UISlider!
    
    @IBOutlet weak var viewScrollingSlider: UIView!
    
    @IBOutlet weak var pauseBtnOutlet: UIButton!
    @IBOutlet weak var pauseBtnOutletiPad: UIButton!
    @IBOutlet weak var playBtnOutlet: UIButton!
    @IBOutlet weak var playBtnOutletiPad: UIButton!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var currentTimeLbliPad: UILabel!
    @IBOutlet weak var audioFilesBtnOutlet: UIButton!
    @IBOutlet weak var audioFilesBtnOutletiPad: UIButton!
    @IBOutlet weak var camPreview: UIView!
    
    @IBOutlet weak var voiceBtnOutlet: UIButton!
    @IBOutlet weak var videoBtnOutlet: UIButton!
    //MARK: - AFTER IN-APP PURCHASE
    
    @IBOutlet weak var recorderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSpeedDecrease: UIButton!
    @IBOutlet weak var lblSpeedCount: UILabel!
    @IBOutlet weak var btnZoomIn: UIButton!
    @IBOutlet weak var btnZoomOut: UIButton!
    @IBOutlet weak var bottomTabHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTopOutlet: UIView!
    @IBOutlet weak var viewBottomOutlet: UIView!
    @IBOutlet weak var viewTitleOutlet: UIView!
    @IBOutlet weak var nextDocumentBtnOutlet: UIButton!
    @IBOutlet weak var previouseDocumentBtnOutlet: UIButton!
    @IBOutlet weak var lblTitleSetlist: UILabel!
    @IBOutlet weak var lblTitleDocumentName: UILabel!
    
    
    var isPurchased:Bool!
    var feature:FeaturesPurchased = .None
    let panGesture = UIPanGestureRecognizer()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    
    var updateTimer = Timer()
    var sliderTimer = Timer()
    
    
    var isAudioRecordingGranted: Bool!
    var isReadyToRecordVoice = false
    var isPlaying = false
    var isAudioRecorderOpen = false
    
    var recordedUrl: URL?
    var recordedData: Data?
    var recordingCount = 1
   

    
    //MARK: - VIDEO RECORDING VARIABLES
    var captureSession = AVCaptureSession()
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var currentOrientation: AVCaptureVideoOrientation?
    var videoConnection: AVCaptureConnection?
    var camCount:Int! = 1
    var isShowMeActive:Bool? = false
    var isRecordMeActive:Bool? = false
    var isVideoRecording:Bool! = false
    var isFaceUpAndLSRight:Bool! = false
    
    //MARK: - VARIABLES:
    var scrollRate: Int16!
    var pdfView: PDFView!
    var document : Document?
    var isScrolling:Bool!
    var playlistData:[Document]?
    var playlistDataIndex:Int = 0
    var playlistName:String?
    var isPerformPressed:Bool? = false
    
    
    var isShowMe:Bool?
    var isRecordMe:Bool?
    
    //    MARK:- VIEW CYCLE(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        viewDiagonal.rotate(angle: 45)
        viewAudioVideoPopUp.layer.cornerRadius = 10.0

        recordingSession = AVAudioSession.sharedInstance()
        check_record_permission()
        
        self.recorderViewHeightConstraint.constant = 0
        self.isPurchased = true
        self.feature = .All
        if isPurchased {
            self.showOptionsAfterPurchase()
        }
        if isPurchased {
            if feature == .All || feature == .AudioVideo {
                // self.setupView()
            }
        }
        
        self.manageLocalNotifications()
        
        addCaptureSession()
        
        setCamPreviewLayer()
    }
    
    func addCaptureSession() {
        self.captureSession = AVCaptureSession()
        self.movieOutput = AVCaptureMovieFileOutput()
        self.movieOutput.movieFragmentInterval = CMTime.invalid
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if ((captureSession.canAddInput(input)) != nil) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
        }
        if let microphone = AVCaptureDevice.default(.builtInMicrophone , for: AVMediaType.audio  , position: .unspecified) {
            do {
                let micInput = try AVCaptureDeviceInput(device: microphone)
                if ((captureSession.canAddInput(micInput)) != nil) {
                    captureSession.addInput(micInput)
                }
            } catch {
                print("Error setting device audio input: \(error)")
            }
        }
        if ((captureSession.canAddOutput(movieOutput)) != nil) {
            self.captureSession.addOutput(movieOutput)
            videoConnection = movieOutput.connection(with: .video)
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func showMeThumnail() {
        self.captureSession.startRunning()
        self.previewLayer?.removeFromSuperlayer()
        if self.previewLayer != nil {
            self.camPreview.layer.addSublayer(previewLayer!)
            self.previewLayer!.frame = self.camPreview.bounds
        }
    }
    
    
    func startRecordingVideo() {
            if self.movieOutput.isRecording == false {
                _ = self.movieOutput.connection(with: .video)
                if let device = self.activeInput?.device {
                    if (device.isSmoothAutoFocusSupported) {
                        do {
                            try device.lockForConfiguration()
                            device.isSmoothAutoFocusEnabled = false
                            device.unlockForConfiguration()
                        } catch {
                            print("Error setting configuration: \(error)")
                        }
                    }
                    self.outputURL = self.tempURL()
                    self.movieOutput.startRecording(to: self.outputURL, recordingDelegate: self)
                }
            }
            else {
                self.stopRecording()
            }
        }
    
    
    func setCamPreviewLayer() {
        camPreview.layer.cornerRadius = 12.0
        camPreview.clipsToBounds = true
        camPreview.addGestureRecognizer(panGesture)
        camPreview.isUserInteractionEnabled = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        isShowMe = UserDefaults.standard.bool(forKey: "isShowMe")
        if isShowMe ?? false {
            showMeSwitch.isOn = true
        } else {
            showMeSwitch.isOn = false
        }
        
        isRecordMe = UserDefaults.standard.bool(forKey: "isRecordMe")
        if isRecordMe ?? false {
            recordMeSwitch.isOn = true
        } else {
            recordMeSwitch.isOn = false
        }
        
        if self.isShowMeActive! {
            showMeThumnail()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        getOrientation()
        self.manageUI()
        if let doc = self.document {
            setCurrentDoc(document: doc)
        }
        
        if isPerformPressed! {
            self.setLayoutWhenGigPressed()
        }

        UIApplication.shared.isIdleTimerDisabled = true

        isShowMeActive = UserDefaults.standard.bool(forKey: "isShowMe")
        isRecordMeActive = UserDefaults.standard.bool(forKey: "isRecordMe")
      //  videoBtnOutlet.setImage(UIImage(named: "icon_video"), for: .normal)
      //  videoBtnOutlet.tintColor = UIColor.white
       
        if isShowMeActive == true {
            self.camPreview.isHidden = false
            camPreview.backgroundColor = .clear
            self.showMeThumnail()
        } else {
            self.camPreview.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.topHeaderHeightConstraint.constant = 64.0
        self.bottomTabHeightConstraint.constant = 64.0
        self.titleViewHeightConstraint.constant = 30.0
        
        self.viewTopOutlet.isHidden = false
        self.viewTitleOutlet.isHidden = false
        self.viewBottomOutlet.isHidden = false
    
        if isShowMeActive! {
            hideCamView(showCamera: false)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.camCount = 1
        
        if pdfView != nil {
            pdfView.frame = view.frame
        }
        var orientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = .portrait
        case .landscapeLeft:
            orientation = .landscapeRight
        case .landscapeRight:
            orientation = .landscapeLeft
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        default:
            if self.view.frame.width > self.view.frame.height {
                if isFaceUpAndLSRight {
                    orientation = .landscapeLeft
                } else {
                    orientation = .portrait
                }
            } else {
                orientation = .portrait
            }
        }
        currentOrientation = orientation
        if !ipadRecorderView.isHidden {
            self.camPreview.center = self.camPreview.center
        } else {
            self.camPreview.center = self.camPreview.center
        }
        if previewLayer != nil {
            previewLayer.videoGravity = .resizeAspectFill
            if currentOrientation != nil{
                previewLayer.connection?.videoOrientation = currentOrientation!
            }
        }
        if recorderViewOutlet.isHidden {
            self.recorderViewHeightConstraint.constant = 0.0
        }
    }
    
    func getOrientation() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
//            print(UIApplication.shared.statusBarOrientation)
            break
        case .portraitUpsideDown:
//            print(UIApplication.shared.statusBarOrientation)
            break
        case .landscapeLeft:
//            print(UIApplication.shared.statusBarOrientation)
            self.isFaceUpAndLSRight = true
            break
        case .landscapeRight:
//            print(UIApplication.shared.statusBarOrientation)
            break
        case .unknown:
//            print(UIApplication.shared.statusBarOrientation)
            break
        }
    }
    
    
    func manageLocalNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSelectedRecording(notification:)), name: .passRecording, object: nil)
        
    }
    
    
    @objc func handleSelectedRecording(notification: Notification) {
        
        self.isReadyToRecordVoice = false
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            self.pauseBtnOutletiPad.setImage(UIImage(named: "btn_record_off"), for: .normal)
            
        } else {
            
            self.pauseBtnOutlet.setImage(UIImage(named: "btn_record_off"), for: .normal)
            
        }
        
        
        let object = notification.object as! [String:Any]
        
        if let recording = object["recording"] as? Recording {
            
            self.recordedData = recording.recData
            
            self.isPlaying = false
           
            self.prepare_play(name: recording.recStr ?? "")
        
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                self.pauseBtnOutletiPad.setImage(UIImage(named: "btn_record_off"), for: .normal)
                
                self.playBtn(self.playBtnOutletiPad)
                
            } else {
                
                self.pauseBtnOutlet.setImage(UIImage(named: "btn_record_off"), for: .normal)
                
                self.playBtn(self.playBtnOutlet)
            }
        }
        
    }
    
    
    func showOptionsAfterPurchase() {
        if feature == .All {
            self.videoBtnOutlet.isHidden = false
            self.voiceBtnOutlet.isHidden = false
            
        } else if feature == .SetLists {
            self.videoBtnOutlet.isHidden = true
            self.voiceBtnOutlet.isHidden = true
            
        } else if feature == .AudioVideo {
            self.videoBtnOutlet.isHidden = false
            self.voiceBtnOutlet.isHidden = false
            
        } else if feature == .None {
            self.videoBtnOutlet.isHidden = true
            self.voiceBtnOutlet.isHidden = true
        }
    }

    //    MARK:- PRIVATE METHODS(s)
    func manageUI() {
        self.pdfView = PDFView.init()
        self.btnStop.isHidden = true
    }
    
    func setCurrentDoc(document: Document) {
        
        self.lblDocTitle.text = document.docName
        
        
        if UserDefaults.standard.value(forKey: document.docName ?? "") as? Int ?? 1 != recordingCount {
            recordingCount = UserDefaults.standard.value(forKey: document.docName ?? "") as? Int ?? 1
        }
                
        if let documentData = document.docData {
            pdfView.document = PDFDocument(data: documentData)
            
        } else {
            pdfView?.document = nil
        }
        pdfView.delegate = self
        pdfView.frame = CGRect.init(x: 0, y: 0, width: self.pdfSuperView.frame.width, height: self.pdfSuperView.frame.height)
        pdfView.autoScales = true
        self.pdfSuperView.addSubview(pdfView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapText))
        tapGesture.numberOfTapsRequired = 1
        pdfView.addGestureRecognizer(tapGesture)
        lblSpeedCount.text = String(document.docPromptSpeed)
        scrollRate = document.docPromptSpeed
//        pdfView.scaleFactor = CGFloat(document.docPromptSize)
        scrollingTrackSlider.value = Float(document.docPromptSpeed)
    }
    
    func addSwipeGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        if self.playlistData!.count > 1 {
            self.pdfView.addGestureRecognizer(leftSwipe)
            self.pdfView.addGestureRecognizer(rightSwipe)
        }
    }
    
    func stopScrolling() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollLoop), object: nil)
        UIView.animate(withDuration: 0.0,
                       delay: 0.0,
                       options: [],
                       animations: {
        },completion: nil)
        self.isScrolling = false
    }
    
    
    
    func setLayoutWhenGigPressed() {
        self.addSwipeGesture()
        self.lblDocTitle.isHidden = true
        self.lblTitleDocumentName.isHidden = false
        self.lblTitleSetlist.isHidden = false
        self.nextDocumentBtnOutlet.isHidden = false
        self.lblTitleSetlist.text = self.playlistName
        self.playlistDataIndex = 0
        if self.playlistData?.count == 1 || self.playlistData?.count == 0 {
            self.previouseDocumentBtnOutlet.isHidden = true
            self.nextDocumentBtnOutlet.isHidden = true
        } else {
            if self.playlistDataIndex == 0 {
                self.previouseDocumentBtnOutlet.isHidden = true
            } else {
                self.previouseDocumentBtnOutlet.isHidden = false
            }
            if self.playlistDataIndex >= self.playlistData!.count - 1 {
                self.nextDocumentBtnOutlet.isHidden = true
            } else {
                self.nextDocumentBtnOutlet.isHidden = false
            }
        }
        self.document = playlistData?.first
        self.lblTitleDocumentName.text = document?.docName
        self.setCurrentDoc(document: self.document!)
    }
    
    //MARK:- OBJECTIVE METHODS
    @objc func tapText() {
        if self.btnStart.isHidden {
            if isScrolling {
                self.stopScrolling()
            } else {
                self.scrollLoop()
            }
        } else {
            self.stopScrolling()
        }
    }
    
    @objc func scrollLoop() {
        
        if let scrollView = pdfView.subviews.first as? UIScrollView {
            
            if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height / 2) {
            } else {
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollLoop), object: nil)
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationCurve(.linear)
                UIView.animate(withDuration: 1.0,
                               delay: 0.0,
                               options: [],
                               animations: {
                    var scrollPoint = scrollView.contentOffset
                    var scrollAmount: CGFloat
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        scrollAmount = CGFloat(2 * self.scrollRate)
                        
                    } else {
                        scrollAmount = CGFloat(2 * self.scrollRate)
                    }
                    
                    scrollPoint.y = scrollPoint.y + scrollAmount
                    scrollView.setContentOffset(scrollPoint, animated: true)
                    UIView.commitAnimations()
                    self.perform(#selector(self.scrollLoop), with: nil, afterDelay: TimeInterval(0.1))
                },
                               completion: nil)
                self.isScrolling = true
            }
            
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if self.playlistData == nil {
            
        } else {
            if (sender.direction == .left) {
                DispatchQueue.main.async {
                    self.previouseDocumentBtnOutlet.isHidden = false
                    if self.playlistDataIndex < self.playlistData!.count {
                        let lastDataIdx = (self.playlistData?.count ?? 0) - 2
                        if self.playlistDataIndex == lastDataIdx {
                            self.nextDocumentBtnOutlet.isHidden = true
                            self.playlistDataIndex += 1
                            self.document = self.playlistData?[self.playlistDataIndex]
                            self.lblTitleDocumentName.text = self.document?.docName
                            self.setCurrentDoc(document: self.document!)
                        } else {
                            if self.playlistDataIndex == self.playlistData!.count - 1 {
                                
                            } else {
                                self.playlistDataIndex += 1
                                self.previouseDocumentBtnOutlet.isHidden = false
                                self.document = self.playlistData?[self.playlistDataIndex]
                                self.lblTitleDocumentName.text = self.document?.docName
                                self.setCurrentDoc(document: self.document!)
                                
                            }
                        }
                    } else {
                        self.nextDocumentBtnOutlet.isHidden = true
                    }
                }
            }
            
            if (sender.direction == .right) {
                DispatchQueue.main.async {
                    self.nextDocumentBtnOutlet.isHidden = false
                    if self.playlistDataIndex < 1 {
                        self.previouseDocumentBtnOutlet.isHidden = true
                    } else {
                        if self.playlistDataIndex == 1 {
                            self.previouseDocumentBtnOutlet.isHidden = true
                            self.playlistDataIndex -= 1
                            
                            self.document = self.playlistData?[self.playlistDataIndex]
                            self.lblTitleDocumentName.text = self.document?.docName
                            self.setCurrentDoc(document: self.document!)
                        } else {
                            self.playlistDataIndex -= 1
                            self.document = self.playlistData?[self.playlistDataIndex]
                            self.lblTitleDocumentName.text = self.document?.docName
                            self.setCurrentDoc(document: self.document!)
                        }
                    }
                }
            }
        }
    }
    
    //    MARK:- IBACTIONS(s)
    @IBAction func btnSetListAction(_ sender: UIButton) {
        let dict = ["document":self.document]
        NotificationCenter.default.post(name: .passPdfDocument, object: dict)
        if let viewController = navigationController?.viewControllers.first(where: {$0 is EditViewController}) {
            navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    //MARK: - IBACTIONS
    @IBAction func btnStopAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            
            self.camCount = 1
            
            self.stopScrolling()
            
            if self.isReadyToRecordVoice {
                self.finishAudioRecording(success: true)
            }
            
            self.manageScreenLayoutOnStop()
        }
        
    }
    
    @IBAction func btnStartAction(_ sender: UIButton) {
        self.camCount = 1
        
        if self.isRecordMeActive == true{
            self.videoBtnOutlet.tintColor = UIColor.red
            self.isVideoRecording = true
            self.startRecordingVideo()
        }
        self.scrollLoop()
        
        if self.isReadyToRecordVoice {
            setup_recorder()
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
        }
        
        self.manageScreenLayoutOnStart()
        
    }
    
    
    func manageScreenLayoutOnStart() {
        
        self.viewAVBackground.isHidden = true
        self.viewTopOutlet.isHidden = true
        self.viewTitleOutlet.isHidden = true
        self.viewBottomOutlet.isHidden = true
        
        self.topHeaderHeightConstraint.constant = 0.0
        self.bottomTabHeightConstraint.constant = 0.0
        self.titleViewHeightConstraint.constant = 0.0
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            self.ipadRecorderView.isHidden = true
            
        } else {
            
            self.recorderViewOutlet.isHidden = true
         //   self.recorderViewHeightConstraint.constant = 0
            
        }
    
        self.btnStart.isHidden = true
        self.btnStop.isHidden = false
        self.viewScrollingSlider.isHidden = false
    
    }
    
    
    func manageScreenLayoutOnStop() {
        self.topHeaderHeightConstraint.constant = 64.0
        self.bottomTabHeightConstraint.constant = 64.0
        self.titleViewHeightConstraint.constant = 30.0
        
        self.viewTopOutlet.isHidden = false
        self.viewTitleOutlet.isHidden = false
        self.viewBottomOutlet.isHidden = false
        
        if self.isRecordMeActive == true{
            self.videoBtnOutlet.tintColor = UIColor.white
            self.isVideoRecording = false
            self.stopRecording()
        } else {
            if isAudioRecorderOpen {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                    self.ipadRecorderView.isHidden = false
                    
                } else {
                    
                    self.recorderViewOutlet.isHidden = false
                    self.recorderViewHeightConstraint.constant = 110.0
                }
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                    self.ipadRecorderView.isHidden = true
                    
                } else {
                    
                    self.recorderViewOutlet.isHidden = true
                    self.recorderViewHeightConstraint.constant = 0.0
                }
            }
        }
        
        self.btnStart.isHidden = false
        self.btnStop.isHidden = true
        self.viewScrollingSlider.isHidden = true
    }
    
    
    @IBAction func btnSpeedIncreaseAction(_ sender: UIButton) {
        if self.scrollRate == 15 {
            
        } else {
            self.scrollRate! +=  1
            self.scrollingTrackSlider.value = Float(self.scrollRate)
            self.lblSpeedCount.text = "\(scrollRate!)"
        }
        document?.docPromptSpeed = scrollRate
//        self.document =  CoreDataManager.sharedInstance.updateDocumentSpeedSize(documnet: document!, docSize: document!.docPromptSize, docSpeed: document!.docPromptSpeed)
        
        self.document = CoreDataManager.sharedInstance.updateDocument(documnet: document!, docDict: ["docName": document!.docName ?? "" , "docData": document!.docData ?? Data(),"docPromptSize":document!.docPromptSize ,"docPromptSpeed":document!.docPromptSpeed ])
    }
    @IBAction func btnSpeedDecreaseAction(_ sender: UIButton) {
        if self.scrollRate == 1 {
            
        } else {
            self.scrollRate! -= 1
            self.scrollingTrackSlider.value = Float(self.scrollRate)
            self.lblSpeedCount.text = "\(scrollRate!)"
        }
        document?.docPromptSpeed = scrollRate
//        self.document =  CoreDataManager.sharedInstance.updateDocumentSpeedSize(documnet: document!, docSize: document!.docPromptSize, docSpeed: document!.docPromptSpeed)
        
        self.document = CoreDataManager.sharedInstance.updateDocument(documnet: document!, docDict: ["docName": document!.docName ?? "" , "docData": document!.docData ?? Data(),"docPromptSize":document!.docPromptSize ,"docPromptSpeed":document!.docPromptSpeed ])
    }
    @IBAction func btnZoomInAction(_ sender: UIButton) {
        pdfView.scaleFactor += 0.5
        
        document?.docPromptSize = Int16(pdfView.scaleFactor)
//        self.document =  CoreDataManager.sharedInstance.updateDocumentSpeedSize(documnet: document!, docSize: document!.docPromptSize, docSpeed: document!.docPromptSpeed)
        
        self.document = CoreDataManager.sharedInstance.updateDocument(documnet: document!, docDict: ["docName": document!.docName ?? "" , "docData": document!.docData ?? Data(),"docPromptSize":document!.docPromptSize ,"docPromptSpeed":document!.docPromptSpeed ])
    }
    @IBAction func btnZoomOutAction(_ sender: UIButton) {
        pdfView.scaleFactor -= 0.5
        document?.docPromptSize = Int16(pdfView.scaleFactor)
//        self.document =  CoreDataManager.sharedInstance.updateDocumentSpeedSize(documnet: document!, docSize: document!.docPromptSize, docSpeed: document!.docPromptSpeed)
        
        self.document = CoreDataManager.sharedInstance.updateDocument(documnet: document!, docDict: ["docName": document!.docName ?? "" , "docData": document!.docData ?? Data(),"docPromptSize":document!.docPromptSize ,"docPromptSpeed":document!.docPromptSpeed])
    }
    @IBAction func btnSetlistAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextDocumentAction(_ sender: UIButton) {
        DispatchQueue.main.async {

            self.previouseDocumentBtnOutlet.isHidden = false
            if self.playlistDataIndex < self.playlistData?.count ?? 0 {
                let lastDataIdx = (self.playlistData?.count ?? 0) - 2
                if self.playlistDataIndex == lastDataIdx {
                    self.nextDocumentBtnOutlet.isHidden = true
                    self.playlistDataIndex += 1
                    
                    self.document = self.playlistData?[self.playlistDataIndex]
                    self.lblTitleDocumentName.text = self.document?.docName
                    self.setCurrentDoc(document: self.document!)
                    
                } else {
                    self.playlistDataIndex += 1
                    self.previouseDocumentBtnOutlet.isHidden = false
                    self.document = self.playlistData?[self.playlistDataIndex]
                    self.lblTitleDocumentName.text = self.document?.docName
                    self.setCurrentDoc(document: self.document!)
                }
                
            } else {
                self.nextDocumentBtnOutlet.isHidden = true
            }
        }
        self.document = playlistData?.first
        self.lblTitleDocumentName.text = self.document?.docName
        self.setCurrentDoc(document: self.document!)
    }
    
    @IBAction func btnPreviousDocumentAction(_ sender: UIButton) {
        DispatchQueue.main.async {
          
            self.nextDocumentBtnOutlet.isHidden = false
            if self.playlistDataIndex < 1 {
                self.previouseDocumentBtnOutlet.isHidden = true
            } else {
                if self.playlistDataIndex == 1 {
                    self.previouseDocumentBtnOutlet.isHidden = true
                    self.playlistDataIndex -= 1
                    
                    self.document = self.playlistData?[self.playlistDataIndex]
                    self.lblTitleDocumentName.text = self.document?.docName
                    self.setCurrentDoc(document: self.document!)
                    
                } else {
                    self.playlistDataIndex -= 1
                    self.document = self.playlistData?[self.playlistDataIndex]
                    self.lblTitleDocumentName.text = self.document?.docName
                    self.setCurrentDoc(document: self.document!)
                }
                
            }
        }
        self.document = playlistData?.first
        self.lblTitleDocumentName.text = self.document?.docName
        self.setCurrentDoc(document: self.document!)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if audioPlayer != nil {
            
            audioPlayer.currentTime = TimeInterval(sender.value)
            
        }
    }
    
    
    @IBAction func scrollingValueChanged(_ sender: UISlider) {
        let sliderValue = scrollingTrackSlider.value
        self.scrollRate = Int16(sliderValue)
    }
    
    
    @IBAction func pauseBtn(_ sender: UIButton) {
        
        self.isReadyToRecordVoice = !self.isReadyToRecordVoice
        
        if self.isReadyToRecordVoice {
            
            self.isPlaying = false
            self.recordedData = nil
            self.recordedUrl = nil
            self.audioPlayer = nil
            self.sliderTimer.invalidate()
            self.updateTimer.invalidate()
            
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.audioTrackSlideriPad.value = 0
                self.pauseBtnOutletiPad.setImage(UIImage(named: "btn_record_on"), for: .normal)
                self.playBtnOutletiPad.setImage(UIImage(named: "btn_play_off"), for: .normal)
                
            } else {
                self.audioTrackSlider.value = 0
                self.playBtnOutlet.setImage(UIImage(named: "btn_play_off"), for: .normal)
                self.pauseBtnOutlet.setImage(UIImage(named: "btn_record_on"), for: .normal)
            }
            
        } else {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.pauseBtnOutletiPad.setImage(UIImage(named: "btn_record_off"), for: .normal)
            } else {
                self.pauseBtnOutlet.setImage(UIImage(named: "btn_record_off"), for: .normal)
            }
            
        }
        
    }
    
    @IBAction func playBtn(_ sender: UIButton) {
        if !self.isReadyToRecordVoice {
            
            self.isPlaying = !isPlaying
            
            if isPlaying {
                if audioPlayer != nil {
                    audioPlayer.play()
                }
                
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.playBtnOutletiPad.setImage(UIImage.init(named: "btn_play_on"), for: .normal)
                    
                } else {
                    self.playBtnOutlet.setImage(UIImage.init(named: "btn_play_on"), for: .normal)
                }
                
                
            } else {
                if audioPlayer != nil {
                    audioPlayer.pause()
                }
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.playBtnOutletiPad.setImage(UIImage.init(named: "btn_play_off"), for: .normal)
                    
                } else {
                    self.playBtnOutlet.setImage(UIImage.init(named: "btn_play_off"), for: .normal)
                }
            }
            
        }
    }
    
    @IBAction func audioFilesBtn(_ sender: UIButton) {
       
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordingListViewController") as! RecordingListViewController
        
        vc.delegate = self
        vc.currentDoc = self.document
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func recordingDelete(recording: Recording, type: String?, name: String?) {
        if type == "Delete" {
            if self.audioFilesBtnOutlet.titleLabel?.text ?? "" == recording.recStr ?? "" && self .recordedData == recording.recData {
                
                self.recordedData = nil
                self.recordedUrl = nil
                self.audioPlayer = nil
                self.sliderTimer.invalidate()
                self.updateTimer.invalidate()
                
                if UIDevice.current.userInterfaceIdiom == .pad {

                    self.audioFilesBtnOutletiPad.setTitle("Audio file", for: .normal)
                    
                } else {
                   
                    self.audioFilesBtnOutlet.setTitle("Audio file", for: .normal)
                }
            }
        } else {
            
            if name == recording.recStr ?? "" && self.recordedData == recording.recData {
                if UIDevice.current.userInterfaceIdiom == .pad {

                    self.audioFilesBtnOutletiPad.setTitle(name, for: .normal)
                    
                } else {
                   
                    self.audioFilesBtnOutlet.setTitle(name, for: .normal)
                }
            }
        }
    }
    
    @IBAction func repostionViewAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.7, animations: {
            self.rePostionCamGesture(self.panGesture)
        }, completion: nil)
    }
    
    @IBAction func audioBtn(_ sender: UIButton) {
        
        self.isAudioRecorderOpen = !self.isAudioRecorderOpen
        
        if self.isAudioRecorderOpen {
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                self.ipadRecorderView.isHidden = false
                
            } else {
                
                self.recorderViewOutlet.isHidden = false
                self.recorderViewHeightConstraint.constant = 110.0
            }
            
        } else {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                self.ipadRecorderView.isHidden = true
                
            } else {
                self.recorderViewOutlet.isHidden = true
                
                self.recorderViewHeightConstraint.constant = 0.0
                
            }
        }
    }
    
    @IBAction func videoBtn(_ sender: UIButton) {
        
        self.viewAVBackground.isHidden = !self.viewAVBackground.isHidden
        
        if audioPlayer != nil {
            audioPlayer.pause()
        }
        self.isPlaying = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.playBtnOutletiPad.setImage(#imageLiteral(resourceName: "btn_play_off"), for: .normal)
            self.playBtnOutletiPad.isSelected = false
        } else {
            self.playBtnOutlet.setImage(#imageLiteral(resourceName: "btn_play_off"), for: .normal)
            self.playBtnOutlet.isSelected = false
        }
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoOptViewController") as! VideoOptViewController
//        vc.delegate = self
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                recordingCount = recordingCount + 1
                
                UserDefaults.standard.set(recordingCount, forKey: document?.docName ?? "")
                
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL {
        
        
        
        let filename = "Take \(UserDefaults.standard.value(forKey: document?.docName ?? "") ?? 1)"
    
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        self.recordedUrl = filePath

        return filePath
        
    }
    
    func randomString(length: Int) -> String {
     
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    func prepare_play(name: String) {
        guard let recordedData = self.recordedData else { return }
        
        self.updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        self.sliderTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(upSlider), userInfo: nil, repeats: true)
        
        
        do {
            
            self.audioPlayer = try AVAudioPlayer.init(data: recordedData)
            self.audioPlayer.delegate = self
            self.audioPlayer.prepareToPlay()
            
            
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.audioTrackSlideriPad.maximumValue = Float(audioPlayer.duration)
                self.audioFilesBtnOutletiPad.setTitle(name, for: .normal)
                
            } else {
                self.audioTrackSlider.maximumValue = Float(audioPlayer.duration)
                self.audioFilesBtnOutlet.setTitle(name, for: .normal)
            }
        } catch {
            print("Error")
        }
    }
    
    @objc func updateTime() {
        
        if audioPlayer != nil {
            
            let currentTime = Int(audioPlayer.currentTime)
            let seconds = currentTime % 60
            let minutes = (currentTime / 60) % 60
            let hours = (currentTime / 3600)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                currentTimeLbliPad.text = NSString(format: "%02d:%02d:%02d",hours, minutes,seconds) as String
                
            } else {
                currentTimeLbl.text = NSString(format: "%02d:%02d:%02d",hours, minutes,seconds) as String
            }
        }
    }
    
    
    
    @objc func upSlider() {
        if self.audioPlayer != nil {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                audioTrackSlideriPad.value = Float(audioPlayer.currentTime)
                
            } else {
                audioTrackSlider.value = Float(audioPlayer.currentTime)
            }
            
        }
        
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        
        if audioRecorder.isRecording  {
            
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                currentTimeLbliPad.text = totalTimeString
                
            } else {
                currentTimeLbl.text = totalTimeString
            }
            
            audioRecorder.updateMeters()
        }
    }
    
    
    func finishAudioRecording(success: Bool) {
        
        self.isReadyToRecordVoice = false
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.pauseBtnOutletiPad.setImage(UIImage(named: "btn_record_off"), for: .normal)
        } else {
            self.pauseBtnOutlet.setImage(UIImage(named: "btn_record_off"), for: .normal)
        }
        
        if success {
            
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            
        } else {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    
    @IBAction func showMeAction(_ sender: UISwitch) {
        if showMeSwitch.isOn {
            isShowMe = true
        }else{
            isShowMe = false
        }
        UserDefaults.standard.set(isShowMe, forKey: "isShowMe")
        self.featureSelected(cameraSel: isShowMe, videoRecSel: isRecordMe)
    }
    
    @IBAction func recordMeAction(_ sender: UISwitch) {
        if recordMeSwitch.isOn {
            isRecordMe = true
        }else{
            isRecordMe = false
        }
        UserDefaults.standard.set(isRecordMe, forKey: "isRecordMe")
        self.featureSelected(cameraSel: isShowMe, videoRecSel: isRecordMe)
    }
    
}


//    MARK:- DELEGATE METHODS(s)
extension PromptDocumentViewController: SetListViewControllerDelegate {
    func passDocument(document: Document) {
        self.document = document
        setCurrentDoc(document: document)
    }
}


extension PromptDocumentViewController: AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag {
            finishAudioRecording(success: false)
            
        } else {
            
            if let recordedUrl = self.recordedUrl {
                guard let data = try? Data(contentsOf: recordedUrl) else {
                    return
                }
                self.recordedData = data
                
                if let doc = self.document {
                    
                    CoreDataManager.sharedInstance.saveRecording(document: doc, recData: data, recStr: recordedUrl.lastPathComponent) { success in
                        if success {
                            self.prepare_play(name: recordedUrl.lastPathComponent)
                        }
                    }
                }
                
            } else {
               
            }
            
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        self.isPlaying = false
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.playBtnOutletiPad.setImage(UIImage.init(named: "btn_play_off"), for: .normal)
            self.pauseBtnOutletiPad.setImage(UIImage(named: "btn_record_off"), for: .normal)
        } else {
            self.playBtnOutlet.setImage(UIImage.init(named: "btn_play_off"), for: .normal)
            self.pauseBtnOutlet.setImage(UIImage(named: "btn_record_off"), for: .normal)
        }
        
    }
    
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
                     {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
}
//MARK:- VIDEO RECORDING,CAMERA AND DELEGATE METHOD(S)
extension PromptDocumentViewController : AVCaptureFileOutputRecordingDelegate {

        //  MARK: Camera Session
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
       
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            DispatchQueue.main.async {
                self.showMeThumnail()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let alertController = UIAlertController(title: "Video Recording", message: "Your recording has been saved to the photo roll. To view, go to the photos app on your device", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel) { (alertAction) in
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                let videoRecorded = self.outputURL! as URL
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            }
        }
    }
    
    @objc private func rePostionCamGesture(_ sender: UIPanGestureRecognizer){
        
        camCount += 1
            if camCount == 1{
                    sender.view!.center = CGPoint(x:100, y:self.view.frame.height - 175)

            } else if camCount == 2{
                    sender.view!.center = CGPoint(x:self.view.frame.width - 100, y:self.view.frame.height - 175)

            }else if camCount == 3{
                    sender.view!.center = CGPoint(x:self.view.frame.width - 100, y:self.topHeaderHeightConstraint.constant + 120)

            } else if camCount == 4{
                    sender.view!.center = CGPoint(x:100, y:self.topHeaderHeightConstraint.constant + 120)

                camCount = 0
            }
    }
    
    
    private func hideCamView(showCamera:Bool){
        
         if showCamera == true {
    
             showMeThumnail()
             
            } else {
                self.captureSession.stopRunning()
                self.previewLayer?.removeFromSuperlayer()
        }
    }
    
    
    func featureSelected(cameraSel: Bool?, videoRecSel: Bool?) {
        isShowMeActive = cameraSel
        isRecordMeActive = videoRecSel
        hideCamView(showCamera: isShowMeActive ?? false)
        
        
        
        isShowMeActive = UserDefaults.standard.bool(forKey: "isShowMe")
        isRecordMeActive = UserDefaults.standard.bool(forKey: "isRecordMe")
      
       
        if isShowMeActive == true {
            self.camPreview.isHidden = false
            camPreview.backgroundColor = .clear
            self.showMeThumnail()
        } else {
            self.camPreview.isHidden = true
        }
        
        if self.isShowMeActive! {
            showMeThumnail()
        }
    }
}
extension UIView {

    /**
       Rotate a view by specified degrees
       parameter angle: angle in degrees
     */

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }

}
