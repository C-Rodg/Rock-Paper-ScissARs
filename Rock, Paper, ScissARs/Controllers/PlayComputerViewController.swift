//
//  PlayViewController.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 7/31/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class PlayComputerViewController: UIViewController {
    
    // Shared Game Instance
    let currentGame: Game = Game.shared

    // AR View
    @IBOutlet var arView: ARSCNView!
    
    // Current Vision Request
    private lazy var visionRequest: VNCoreMLRequest = {
        do {
            // Instantiate the model
            let model = try VNCoreMLModel(for: hand_detection().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.handleClassificationComplete(for: request, error: error)
            })
            
            // Crop input to match the way ML model was trained.
            request.imageCropAndScaleOption = .centerCrop
            
            // Use CPU for Vision processing to ensure that there are adequate GPU resources for rendering.
            //request.usesCPUOnly = true
            
            return request
        } catch {
            fatalError("Failed to load model: \(error)")
        }
    }()
    
    // AR Tracking options
    let arTrackingConfiguration = ARWorldTrackingConfiguration()
    
    // The pixel buffer used to serialize Vision requests.
    private var currentBuffer: CVPixelBuffer?
    
    // Dispatch Queue for ML Object
    let dispatchQueueML = DispatchQueue(label: "com.rps.queueml")
    
    // UI Elements and Functionality
    @IBOutlet weak var exitGameButton: FloatingActionButton!
    @IBOutlet weak var manualSelectionButton: FloatingActionButton!
    @IBOutlet weak var resetGameButton: FloatingActionButton!
    @IBOutlet weak var selectPaperButton: FloatingActionButton!
    @IBOutlet weak var selectRockButton: FloatingActionButton!
    @IBOutlet weak var selectScissorsButton: FloatingActionButton!
    var manualSelectionOpen: Bool = false
    var resultsAreShowing: Bool = false
    
    // Large overlay button
    @IBOutlet weak var shootCurrentButton: OverlayActionButton!
    let paperImage: UIImage = #imageLiteral(resourceName: "paper")
    let rockImage: UIImage = #imageLiteral(resourceName: "rock")
    let scissorsImage: UIImage = #imageLiteral(resourceName: "scissor")
    let noneImage: UIImage = #imageLiteral(resourceName: "none")
    let paperInsets: UIEdgeInsets = UIEdgeInsetsMake(55, 35, 55, 75)
    let rockInsets: UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
    let scissorsInsets: UIEdgeInsets = UIEdgeInsetsMake(45, 45, 45, 45)
    let noneInsets: UIEdgeInsets = UIEdgeInsetsMake(60, 60, 60, 60)
    
    // Classification results
    private var previousResult = ""
    private var resultString = ""
    private var resultConfidence: VNConfidence = 0.0
    
    // Results Container UI
    @IBOutlet weak var scoreContainer: UIView!
    @IBOutlet weak var theirScoreContainer: ScoreTileLeft!
    @IBOutlet weak var yourScoreContainer: ScoreTileRight!
    @IBOutlet weak var resultsContainer: ResultsTile!
    @IBOutlet weak var labelSetTheirScore: UILabel!
    @IBOutlet weak var labelSetMyScore: UILabel!
    @IBOutlet weak var labelSetRecord: UILabel!
    @IBOutlet weak var labelSetResult: UILabel!
    @IBOutlet weak var labelGameOver: UILabel!
    
    // LIFECYCLE EVENT - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up delegates
        arView.delegate = self
        arView.session.delegate = self
        
        // FOR DEBUGGING ONLY - *REMOVE FOR PRODUCTION*
        //arView.showsStatistics = true
        
        // Setup UI
        hideInitialOverlays()
        setupResultsTaps()
        
        // Setup notification of app resign/becoming active
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    // LIFECYCLE EVENT - View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Start the view's session
        arView.session.run(arTrackingConfiguration)
    }
    
    // LIFECYCLE EVENT - View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        arView.session.pause()
    }
    
    // LIFECYCLE EVENT - View Entering Background
    @objc func willResignActive(_ notification: Notification) {
        arView.session.pause()
    }
    
    // LIFECYCLE EVENT - View Coming From Background
    @objc func didBecomeActive(_ notification: Notification) {
        arView.session.run(arTrackingConfiguration)
    }

    // FUNCTIONALITY - Process Vision Results
    func handleClassificationComplete(for request: VNRequest, error: Error?) {
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        
        guard let results = request.results else {
            print("No Results")
            return
        }
        
        
        // Get results of model
        let classifications = results as! [VNClassificationObservation]
        if let bestResult = classifications.first(where: { result in result.confidence > 0.8 }) {
            previousResult = resultString
            resultString = String(bestResult.identifier)
            resultConfidence = bestResult.confidence
        } else {
            // No good results
            resultString = ""
            resultConfidence = 0
        }
        
        
        
        // Display results
        DispatchQueue.main.async { [weak self] in
            self?.displayResults()
        }
    }
    
    // Handle results overlay
    private func displayResults() {
        
        // Check for manual button open
        if self.manualSelectionOpen || self.resultsAreShowing {
            self.shootCurrentButton.isHidden = true
            return
        }
        
        // Check to see if anything has changed
        if resultString == previousResult {
            return
        }
        self.shootCurrentButton.isHidden = false
        var newInsets: UIEdgeInsets = UIEdgeInsets()
        var newImage: UIImage = UIImage()
        
        // Display proper result
        if resultString == "scissors" {
            newImage = scissorsImage
            newInsets = scissorsInsets
        } else if resultString == "paper" {
            newImage = paperImage
            newInsets = paperInsets
        } else if resultString == "rock" {
            newImage = rockImage
            newInsets = rockInsets
        } else if resultString == "none" {
            newImage = noneImage
            newInsets = noneInsets
        }
        self.shootCurrentButton.imageEdgeInsets = newInsets
        self.shootCurrentButton.setImage(newImage, for: .normal)
    }
    
    // Classify current pixel buffer using Vision
    private func classifyCurrentImage() {
        // Run the image through the model with the proper orientation
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
    
        // Process the pixel buffer
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        dispatchQueueML.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.visionRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    // FUNCTIONALITY - Process image pixels
    func beginProcessImage() {
        guard let pixelBuffer: CVPixelBuffer? = (arView.session.currentFrame?.capturedImage) else {
            return
        }
        let coreImage: CIImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        // Prepare Vision request
        let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(ciImage: coreImage, options: [:])
        
        // Run Vision request
        do {
            try imageRequestHandler.perform([self.visionRequest])
        } catch {
            print(error)
        }
    }
    
    // Exit game button pressed
    @IBAction func exitGamePressed(_ sender: Any) {
        // If game is over, exit without prompt
        if !labelGameOver.isHidden && !scoreContainer.isHidden {
            self.currentGame.resetGame()
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Don't show an alert for 0-0 score
        if currentGame.myScore == 0 && currentGame.otherPlayerScore == 0 {
            self.currentGame.resetGame()
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let confirmDialog = UIAlertController(title: "Leave Game?", message: "Are you sure you want to quit this game?", preferredStyle: .alert)
        let quit = UIAlertAction(title: "Leave", style: .default, handler: { [weak self] (action) -> Void in
            self?.currentGame.resetGame()
            self?.dismiss(animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmDialog.addAction(cancel)
        confirmDialog.addAction(quit)
        
        self.present(confirmDialog, animated: true, completion: nil)
    }
    
    // Reset Game button pressed
    @IBAction func resetGamePressed(_ sender: Any) {
        if !labelGameOver.isHidden && !scoreContainer.isHidden {
            self.currentGame.resetGame()
            onResultsTapped(nil)
            return
        }
        
        // Don't show an alert for 0-0 score
        if currentGame.myScore == 0 && currentGame.otherPlayerScore == 0 {
            self.currentGame.resetGame()
            if !scoreContainer.isHidden {
                onResultsTapped(nil)
            }
            return
        }
        
        let confirmDialog = UIAlertController(title: "Reset Game?", message: "Are you sure you want reset this game?", preferredStyle: .alert)
        let reset = UIAlertAction(title: "Reset", style: .default, handler: { [weak self] (action) -> Void in
            self?.currentGame.resetGame()
            if let sc = self?.scoreContainer, sc.isHidden == false {
                self?.animateResultsOut()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmDialog.addAction(cancel)
        confirmDialog.addAction(reset)
        
        self.present(confirmDialog, animated: true, completion: nil)
    }
    
    
    // EVENT - Manual Selection toggle pressed
    @IBAction func manualSelectionTogglePressed(_ sender: Any?) {
        if !scoreContainer.isHidden {
            onResultsTapped(nil)
        }
        let toOpen = manualSelectionOpen ? false : true
        manualSelectionAnimate(toOpen: toOpen)
        manualSelectionOpen = !manualSelectionOpen
    }
    
    // EVENT - Shoot button pressed
    @IBAction func shootButtonPressed(_ sender: Any?) {
        if resultString == "none" {
            return
        }
        resultsAreShowing = true
        let computerFormation = currentGame.getComputerHandFormation()
        let result = currentGame.getResultsBetween(myPlay: self.resultString, player2: computerFormation)
        displayScoreIndicator(with: result, myHand: self.resultString, theirHand: computerFormation)
    }
    
    // Display the centered score indicator with animations
    func displayScoreIndicator(with result: String, myHand: String, theirHand: String) {
        // Record hand played
        currentGame.statsRecordFormation(with: myHand)
        
        // Update the tile strings
        labelSetTheirScore.text = theirHand.capitalized(with: NSLocale.current)
        labelSetMyScore.text = myHand.capitalized(with: NSLocale.current)
        
        // Set the results
        if result == "WIN" {
            currentGame.myScore += 1
            labelSetResult.text = "You won!"
        } else if result == "LOSS" {
            currentGame.otherPlayerScore += 1
            labelSetResult.text = "You lost..."
        } else if result == "TIE" {
            labelSetResult.text = "Tie."
        }
        
        // Determine if this the end of a round and set win/loss stats
        if currentGame.isTotalWinner(withScore: currentGame.myScore) {
            currentGame.statsSetWin()
            labelGameOver.isHidden = false
        } else if currentGame.isTotalWinner(withScore: currentGame.otherPlayerScore) {
            currentGame.statsSetLoss()
            labelGameOver.isHidden = false
        } else {
            labelGameOver.isHidden = true
        }
        
        // Set record string
        labelSetRecord.text = "\(currentGame.myScore)-\(currentGame.otherPlayerScore)"
        
        // Display the container
        animateResultsIn()
    }
    
    // EVENT - Results section tapped
    @objc func onResultsTapped(_ sender: UITapGestureRecognizer?) {
        if !labelGameOver.isHidden {
            // Game is over, reset to play again
            currentGame.resetGame()
        }
        // Move on to next round
        animateResultsOut()
    }
    
    // Add tap gesture recognizer to results view
    func setupResultsTaps() {
        let resultsTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onResultsTapped))
        resultsTapRecognizer.numberOfTapsRequired = 1
        resultsTapRecognizer.numberOfTouchesRequired = 1
        self.resultsContainer.addGestureRecognizer(resultsTapRecognizer)
    }
    
    // Handle manual selection
    func handleManualSelection(of formation: String) {
        resultsAreShowing = true
        manualSelectionTogglePressed(nil)
        let computerFormation = currentGame.getComputerHandFormation()
        let result = currentGame.getResultsBetween(myPlay: formation, player2: computerFormation)
        displayScoreIndicator(with: result, myHand: formation, theirHand: computerFormation)
    }
    
    // EVENT - manual ROCK selected
    @IBAction func manualSelectionRockPressed(_ sender: Any) {
        handleManualSelection(of: "rock")
    }
    // EVENT - manual PAPER selected
    @IBAction func manualSelectionPaperPressed(_ sender: Any) {
        handleManualSelection(of: "paper")
    }
    // EVENT - manual SCISSORS selected
    @IBAction func manualSelectionScissorsPressed(_ sender: Any) {
        handleManualSelection(of: "scissors")
    }
    
    // ANIMATION - Animate results out of the view
    func animateResultsOut() {
        theirScoreContainer.alpha = 1
        yourScoreContainer.alpha = 1
        resultsContainer.alpha = 1
        scoreContainer.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.resultsContainer.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self?.resultsContainer.alpha = 0
        })
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut, animations: { [weak self] in
            self?.yourScoreContainer.frame.origin.x -= 500
            self?.yourScoreContainer.alpha = 0
        }, completion: { [weak self] (finished: Bool) in
                if finished {
                    self?.yourScoreContainer.frame.origin.x += 500
                }
        })
        UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut, animations: { [weak self] in
            self?.theirScoreContainer.frame.origin.x += 500
            self?.theirScoreContainer.alpha = 0
            }, completion: { [weak self] (finished: Bool) in
                if finished {
                    self?.theirScoreContainer.frame.origin.x -= 500
                    self?.scoreContainer.isHidden = true
                    self?.resultsAreShowing = false
                }
        })
    }
    
    // ANIMATION - Animate the results into the view
    func animateResultsIn() {
        theirScoreContainer.alpha = 0
        theirScoreContainer.frame.origin.x -= 45
        yourScoreContainer.alpha = 0
        yourScoreContainer.frame.origin.x += 45
        scoreContainer.isHidden = false
        
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.theirScoreContainer.frame.origin.x += 45
            self?.theirScoreContainer.alpha = 1
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.yourScoreContainer.frame.origin.x -= 45
            self?.yourScoreContainer.alpha = 1
        })
        self.resultsContainer.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 0.4, delay: 0.8, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.resultsContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.resultsContainer.alpha = 1
        })
    }
    
    // ANIMATION - Show/Hide manual buttons
    func manualSelectionAnimate(toOpen: Bool) {
        let radians = toOpen ? CGFloat(0.785) : CGFloat(0)
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.manualSelectionButton.transform = CGAffineTransform(rotationAngle: radians)
        })
        
        // Animating to open
        if toOpen {
            self.selectRockButton.isHidden = false
            self.selectRockButton.frame.origin.y -= 20
            self.selectPaperButton.isHidden = false
            self.selectPaperButton.frame.origin.y -= 20
            self.selectScissorsButton.isHidden = false
            self.selectScissorsButton.frame.origin.y -= 20
            UIView.animate(withDuration: 0.20, delay: 0.14, animations: { [weak self] in
                self?.selectRockButton.alpha = 1
                self?.selectRockButton.frame.origin.y += 20
            })
            UIView.animate(withDuration: 0.20, delay: 0.24, animations: { [weak self] in
                self?.selectPaperButton.alpha = 1
                self?.selectPaperButton.frame.origin.y += 20
            })
            UIView.animate(withDuration: 0.20, delay: 0.34, animations: { [weak self] in
                self?.selectScissorsButton.alpha = 1
                self?.selectScissorsButton.frame.origin.y += 20
            })
        } else {
            // Animating to close
            UIView.animate(withDuration: 0.20, delay: 0.14, animations: { [weak self] in
                self?.selectScissorsButton.alpha = 0
                self?.selectScissorsButton.frame.origin.y -= 20
            }, completion: { [weak self] (finished: Bool) in
                if finished {
                    self?.selectScissorsButton.frame.origin.y += 20
                    self?.selectScissorsButton.isHidden = true
                }
            })
            UIView.animate(withDuration: 0.20, delay: 0.24, animations: { [weak self] in
                self?.selectPaperButton.alpha = 0
                self?.selectPaperButton.frame.origin.y -= 20
            }, completion: { [weak self] (finished: Bool) in
                if finished {
                    self?.selectPaperButton.frame.origin.y += 20
                    self?.selectPaperButton.isHidden = true
                }
            })
            UIView.animate(withDuration: 0.20, delay: 0.34, animations: { [weak self] in
                self?.selectRockButton.alpha = 0
                self?.selectRockButton.frame.origin.y -= 20
            }, completion: { [weak self ](finished: Bool) in
                if finished {
                    self?.selectRockButton.frame.origin.y += 20
                    self?.selectRockButton.isHidden = true
                }
            })
        }
    }
    
    // STYLE - Initially hide the manual buttons
    func hideInitialOverlays() {
        selectRockButton.isHidden = true
        selectRockButton.alpha = 0
        selectPaperButton.isHidden = true
        selectPaperButton.alpha = 0
        selectScissorsButton.isHidden = true
        selectScissorsButton.alpha = 0
        
        shootCurrentButton.isHidden = true
        
        scoreContainer.isHidden = true
        theirScoreContainer.alpha = 0
        yourScoreContainer.alpha = 0
        resultsContainer.alpha = 0
    }
    
    // Did receive memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Delegate Methods
extension PlayComputerViewController: ARSCNViewDelegate, ARSessionDelegate {
    // Begin classification process if buffer is available
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        classifyCurrentImage()
    }
    
}
