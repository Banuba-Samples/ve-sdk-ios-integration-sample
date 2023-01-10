import UIKit
import BanubaVideoEditorSDK
import BanubaMusicEditorSDK
import BanubaOverlayEditorSDK
import VideoEditor
import AVFoundation
import AVKit
import Photos
import BSImagePicker
import VEExportSDK

class ViewController: UIViewController {
  
  // MARK: - IBOutlet
  @IBOutlet weak var openVEButton: UIButton!
  @IBOutlet weak var openPIPButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var invalidTokenMessageLabel: UILabel!
    
  // MARK: - VideoEditorSDK
  private var videoEditorSDK: BanubaVideoEditor?
  // MARK: - life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicator.isHidden = true
  }
}

// MARK: - IBAction
extension ViewController {
  @IBAction func openVideoEditorAction(_ sender: Any) {
    initVideoEditor() { isTokenValid in
      guard isTokenValid else { return }
      let musicURL = Bundle.main.bundleURL
        .appendingPathComponent("Music/long", isDirectory: true)
        .appendingPathComponent("long_music_2.wav")
      let assset = AVURLAsset(url: musicURL)
      let musicTrackPreset = MediaTrack(
        uuid: UUID(),
        id: nil,
        url: musicURL,
        timeRange: MediaTrackTimeRange(
          startTime: .zero,
          playingTimeRange: CMTimeRange(
            start: .zero,
            duration: assset.duration
          )
        ),
        isEditable: true,
        title: "My awesome track"
      )
      
      let cameraLaunchConfig = VideoEditorLaunchConfig(
        entryPoint: .camera,
        hostController: self,
        musicTrack: nil, // Paste a music track as a track preset at the camera screen to record video with music
        animated: true
      )
      self.videoEditorSDK?.presentVideoEditor(
        withLaunchConfiguration: cameraLaunchConfig,
        completion: nil
      )
    }
    
  }
  
  @IBAction func PIPAction(_ sender: Any) {
    initVideoEditor { isTokenValid in
      guard isTokenValid else { return }
      self.openGallery()
    }
  }
}
// MARK: - initVideoEditor
extension ViewController {
  private func initVideoEditor(completion: @escaping (Bool) -> Void) {
    guard videoEditorSDK == nil else {
      videoEditorSDK?.getLicenseState(completion: completion)
      return
    }
    
    let config = createVideoEditorConfiguration()
    
    let viewControllerFactory = ViewControllerFactory()
    let musicEditorViewControllerFactory = MusicEditorViewControllerFactory()
    viewControllerFactory.musicEditorFactory = musicEditorViewControllerFactory
    viewControllerFactory.countdownTimerViewFactory = CountdownTimerViewControllerFactory()
    viewControllerFactory.exposureViewFactory = DefaultExposureViewFactory()
    
    videoEditorSDK = BanubaVideoEditor(
      token: AppDelegate.licenseToken,
      configuration: config,
      externalViewControllerFactory: viewControllerFactory
    )
    
    videoEditorSDK?.delegate = self
    
    if videoEditorSDK == nil {
      invalidTokenMessageLabel.isHidden = false
      return
    }
    videoEditorSDK?.getLicenseState(completion: { [weak self] isValid in
      if isValid {
        print("✅ License is active, all good")
      } else {
        print("❌ License is either revoked or expired")
      }
      self?.invalidTokenMessageLabel.isHidden = isValid
      completion(isValid)
    })
  }
}
// MARK: - Configuration helpers
extension ViewController {
  private func createVideoEditorConfiguration() -> VideoEditorConfig {
    var config = VideoEditorConfig()
    
    AudioBrowserConfigurator.configure()
    
    var featureConfiguration = config.featureConfiguration
    featureConfiguration.supportsTrimRecordedVideo = true
    featureConfiguration.isMuteCameraAudioEnabled = true
    config.updateFeatureConfiguration(featureConfiguration: featureConfiguration)
    
    config.isHandfreeEnabled = true
    config.gifPickerConfiguration = updateGifPickerConfiguration(config.gifPickerConfiguration)
    config.recorderConfiguration = updateRecorderConfiguration(config.recorderConfiguration)
    config.editorConfiguration = updateEditorConfiguration(config.editorConfiguration)
    config.combinedGalleryConfiguration = updateCombinedGalleryConfiguration(config.combinedGalleryConfiguration)
    config.extendedVideoCoverSelectionConfiguration = updateVideCoverSelectionConfiguration(config.extendedVideoCoverSelectionConfiguration)
    config.musicEditorConfiguration = updateMusicEditorConfigurtion(config.musicEditorConfiguration)
    config.overlayEditorConfiguration = updateOverlayEditorConfiguraiton(config.overlayEditorConfiguration)
    config.textEditorConfiguration = updateTextEditorConfiguration(config.textEditorConfiguration)
    config.trimVideoConfiguration = updateTrimVideoConfiguration(config.trimVideoConfiguration)
    config.trimVideosConfiguration = updateTrimVideosConfiguration(config.trimVideosConfiguration)
    config.filterConfiguration = updateFilterConfiguration(config.filterConfiguration)
    config.alertViewConfiguration = updateAlertViewConfiguration(config.alertViewConfiguration)
    config.fullScreenActivityConfiguration = updateFullScreenActivityConfiguration(config.fullScreenActivityConfiguration)
    config.handsfreeConfiguration = updateHandsfreeConfiguration(config.handsfreeConfiguration)
    config.aspectsConfiguration = updateAspectsConfiguration(config.aspectsConfiguration)
    
    return config
  }
  
  private func updateFilterConfiguration(_ configuration: FilterConfiguration) -> FilterConfiguration {
    var configuration = configuration
    
    configuration.resetButton.backgroundColor = UIColor(red: 6, green: 188, blue: 193, alpha: 1)
    configuration.resetButton.cornerRadius = 4.0
    configuration.resetButton.textConfiguration?.color = .white
    configuration.toolTipLabel.color = .white
    configuration.cursorButton = ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic_cursor"))
    
    configuration.effectItemConfiguration.cornerRadius = 4.0
    
    configuration.controlButtons = [
      FilterControlButtonConfig(type: .cancel, imageName: "ic_close", selectedImageName: nil),
      FilterControlButtonConfig(type: .play, imageName: "ic_editor_play", selectedImageName: "ic_pause"),
      FilterControlButtonConfig(type: .done, imageName: "ic_done", selectedImageName: nil),
    ]
    
    return configuration
  }
  
  private func updateFullScreenActivityConfiguration(_ configuration: FullScreenActivityConfiguration) -> FullScreenActivityConfiguration {
    var configuration = configuration

    configuration.activityIndicator = SmallActivityIndicatorConfiguration(
      gradientType: .color(
        SmallActivityIndicatorConfiguration.GradientColorConfiguration(
          angle: 0.0,
          colors: [UIColor(red: 6, green: 188, blue: 193, alpha: 1).cgColor, UIColor.white.cgColor]
        )
      ),
      activityLineWidth: 3.0
    )
    
    configuration.activityIndicator = SmallActivityIndicatorConfiguration(
      gradientType: .color(
        SmallActivityIndicatorConfiguration.GradientColorConfiguration(
          angle: 0.0,
          colors: [UIColor(red: 6, green: 188, blue: 193, alpha: 1).cgColor, UIColor.white.cgColor]
        )
      ),
      activityLineWidth: 3.0
    )
    return configuration
  }
}

// MARK: - Export example
extension ViewController {
  func exportVideo() {
    setupActivityIndicatorHidden(false)
    let manager = FileManager.default
    let videoURL = manager.temporaryDirectory.appendingPathComponent("tmp.mov")
    if manager.fileExists(atPath: videoURL.path) {
      try? manager.removeItem(at: videoURL)
    }
    
    let watermarkConfiguration = WatermarkConfiguration(
      watermark: ImageConfiguration(imageName: "Common.Banuba.Watermark"),
      size: CGSize(width: 204, height: 52),
      sharedOffset: 20,
      position: .rightBottom)
    
    let exportConfiguration = ExportVideoConfiguration(
      fileURL: videoURL,
      quality: .auto,
      useHEVCCodecIfPossible: true,
      watermarkConfiguration: watermarkConfiguration
    )
    
    let exportConfig = ExportConfiguration(
      videoConfigurations: [exportConfiguration],
      isCoverEnabled: true,
      gifSettings: GifSettings(duration: 0.3)
    )
    
      videoEditorSDK?.export(using: exportConfig, exportProgress: nil, completion: { success, error, exportCoverImages in
      DispatchQueue.main.async {
        // Clear video editor session data
        self.videoEditorSDK?.clearSessionData()
        if success {
          /// If you want play exported video
//          self.playVideoAtURL(videoURL)
          /// if you want share exported video
          
          if let config = self.videoEditorSDK?.currentConfiguration.sharingScreenConfiguration {
            BanubaVideoEditor.presentSharingViewController(
              from: self,
              configuration: config,
              mainVideoUrl: videoURL,
              videoUrls: [videoURL],
              previewImage: exportCoverImages?.coverImage ?? UIImage(),
              animated: true
            ) {
              self.setupActivityIndicatorHidden(true)
            }
          }
        }
        self.videoEditorSDK = nil
      }
    })
  }
  
  /// For demonstration purpose let's play exported video
  private func playVideoAtURL(_ videoURL: URL) {
    let player = AVPlayer(url: videoURL)
    let playerController = AVPlayerViewController()
    playerController.player = player
    present(playerController, animated: true) {
      player.play()
    }
  }
}

// MARK: - BanubaVideoEditorDelegate
extension ViewController: BanubaVideoEditorDelegate {
  func videoEditorDidCancel(_ videoEditor: BanubaVideoEditor) {
    videoEditor.dismissVideoEditor(animated: true) { [weak self] in
      self?.videoEditorSDK = nil
    }
  }
  
  func videoEditorDone(_ videoEditor: BanubaVideoEditor) {
    videoEditor.dismissVideoEditor(animated: true) { [weak self] in
      self?.exportVideo()
    }
  }
}

//MARK: - PIP Helpers
extension ViewController {
  private func openGallery() {
    VideoPicker().pickVideo(
      isMultipleSelectionEnabled: false,
      from: self
    ) { assets in
      
      guard let assets = assets else {
        return
      }
      
      var resultUrls: [URL] = []
      let group = DispatchGroup()
      var exportVideoRequests = assets.count
      assets.forEach { asset in
        group.enter()
        PHImageManager.default().requestAVAsset(
          forVideo: asset,
          options: .none
        ) { (asset, _, _) in
          guard let asset = asset else { return }
          
          let groupHandler = {
            exportVideoRequests -= 1
            group.leave()
          }
          
          if let urlAsset = asset as? AVURLAsset {
            resultUrls.append(urlAsset.url)
            groupHandler()
            
          } else {
            guard let exportSession = AVAssetExportSession(
              asset: asset,
              presetName: ""
            ) else {
              return
            }
            
            let manager = FileManager.default
            let targetURL = manager.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
            
            exportSession.outputURL = targetURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronously {
              DispatchQueue.main.async {
                guard exportSession.status == .completed else {
                  groupHandler()
                  return
                }
                
                let exportedAsset = AVURLAsset(url: targetURL)
                resultUrls.append(exportedAsset.url)
                groupHandler()
              }
            }
          }
        }
      }
      
      group.notify(queue: .main) {
        guard exportVideoRequests == 0 else {
          return
        }
        
        let presentingHandler = {  [weak self] in
          guard let self = self, !resultUrls.isEmpty else { return }
          
          let pipLaunchConfig = VideoEditorLaunchConfig(
            entryPoint: .pip,
            hostController: self,
            pipVideoItem: resultUrls[.zero],
            musicTrack: nil,
            animated: true
          )
          self.videoEditorSDK?.presentVideoEditor(
            withLaunchConfiguration: pipLaunchConfig,
            completion: nil
          )
        }
        
        guard self.videoEditorSDK == nil else {
          presentingHandler()
          return
        }
        
        self.initVideoEditor() { isTokenValid in
          guard isTokenValid else { return }
          presentingHandler()
        }
      }
    }
  }
}

// MARK: - Helpers
extension ViewController {
  private func setupActivityIndicatorHidden(_ isHidden: Bool) {
    activityIndicator.isHidden = isHidden
    label.isHidden = isHidden
    openVEButton.isHidden = !isHidden
    openPIPButton.isHidden = !isHidden
    if isHidden {
      activityIndicator.stopAnimating()
    } else {
      activityIndicator.startAnimating()
    }
  }
}
