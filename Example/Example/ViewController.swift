import UIKit
import BanubaVideoEditorSDK
import BanubaMusicEditorSDK
import BanubaOverlayEditorSDK
import VideoEditor
import AVFoundation
import AVKit

class ViewController: UIViewController {
  
  private var videoEditorSDK: BanubaVideoEditor?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initVideoEditor()
  }
  
  private func initVideoEditor() {
    let config = createVideoEditorConfiguration()
    
    let viewControllerFactory = ViewControllerFactory()
    let musicEditorViewControllerFactory = MusicEditorViewControllerFactory()
    viewControllerFactory.musicEditorFactory = musicEditorViewControllerFactory
    viewControllerFactory.countdownTimerViewFactory = CountdownTimerViewControllerFactory()
    viewControllerFactory.exposureViewFactory = DefaultExposureViewFactory()
    
    videoEditorSDK = BanubaVideoEditor(
      token: "Put video editor token here",
      configuration: config,
      analytics: Analytics(),
      externalViewControllerFactory: viewControllerFactory
    )
    
    videoEditorSDK?.delegate = self
  }
  
  @IBAction func openVideoEditorAction(_ sender: Any) {
    if videoEditorSDK == nil {
      initVideoEditor()
    }
    let musicURL = Bundle.main.bundleURL
      .appendingPathComponent("Music/long", isDirectory: true)
      .appendingPathComponent("long_music_2.wav")
    let assset = AVURLAsset(url: musicURL)
    let musicTrackPreset = MediaTrack(
      id: CMPersistentTrackID.random(in: 6..<CMPersistentTrackID.max),
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
    // Paste a music track as a track preset at the camera screen to record video with music
    videoEditorSDK?.presentVideoEditor(
      from: self,
      animated: true,
      musicTrack: nil,
      completion: nil
    )
  }
  
  private func createVideoEditorConfiguration() -> VideoEditorConfig {
    var config = VideoEditorConfig()
    
    AudioBrowserConfigurator.configure()
    
    var featureConfiguration = config.featureConfiguration
    featureConfiguration.supportsTrimRecordedVideo = true
    config.updateFeatureConfiguration(featureConfiguration: featureConfiguration)
    
    config.isHandfreeEnabled = true
    config.recorderConfiguration = updateRecorderConfiguration(config.recorderConfiguration)
    config.editorConfiguration = updateEditorConfiguration(config.editorConfiguration)
    config.combinedGalleryConfiguration = updateCombinedGalleryConfiguration(config.combinedGalleryConfiguration)
    config.videoCoverSelectionConfiguration = updateVideCoverSelectionConfiguration(config.videoCoverSelectionConfiguration)
    config.musicEditorConfiguration = updateMusicEditorConfigurtion(config.musicEditorConfiguration)
    config.overlayEditorConfiguration = updateOverlayEditorConfiguraiton(config.overlayEditorConfiguration)
    config.textEditorConfiguration = updateTextEditorConfiguration(config.textEditorConfiguration)
    config.speedSelectionConfiguration = updateSpeedSelectionConfiguration(config.speedSelectionConfiguration)
    config.trimGalleryVideoConfiguration = updateTrimGalleryVideoConfiguration(config.trimGalleryVideoConfiguration)
    config.multiTrimConfiguration = updateMultiTrimConfiguration(config.multiTrimConfiguration)
    config.singleTrimConfiguration = updateSingleTrimConfiguration(config.singleTrimConfiguration)
    config.filterConfiguration = updateFilterConfiguration(config.filterConfiguration)
    config.alertViewConfiguration = updateAlertViewConfiguration(config.alertViewConfiguration)
    config.fullScreenActivityConfiguration = updateFullScreenActivityConfiguration(config.fullScreenActivityConfiguration)
    config.handsfreeConfiguration = updateHandsfreeConfiguration(config.handsfreeConfiguration)
    
    return config
  }
  
  private func updateVideCoverSelectionConfiguration(_ configuration: SimpleVideoCoverSelectionConfiguration) -> SimpleVideoCoverSelectionConfiguration {
    var configuration = configuration
    
    configuration.cancelButton = TextButtonConfiguration(
      style: TextConfiguration(
        font: UIFont.boldSystemFont(ofSize: 18.0),
        color: UIColor(red: 6, green: 188, blue: 193)
      ),
      text: "Cancel"
    )
    configuration.doneButton = RoundedButtonConfiguration(
      textConfiguration: TextConfiguration(
        font: UIFont.boldSystemFont(ofSize: 18.0),
        color: UIColor(red: 6, green: 188, blue: 193)
      ),
      cornerRadius: 0.0,
      backgroundColor: .clear
    )
    configuration.sliderColor = UIColor(red: 6, green: 188, blue: 193)
    configuration.sliderMinTrackTintColor = UIColor(red: 6, green: 188, blue: 193)
    configuration.toolTipLabel = TextConfiguration(
      kern: 0.0,
      font: UIFont.systemFont(ofSize: 16.0),
      color: .white,
      alignment: .left
    )
    
    return configuration
  }
  
  private func updateSpeedSelectionConfiguration(_ configuration: SpeedSelectionConfiguration) -> SpeedSelectionConfiguration {
    var configuration = configuration
    
    configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "back_arrow"))
    configuration.speedBarConfiguration.speedItemBackgroundColor = UIColor(red: 18, green: 38, blue: 58)
    configuration.speedBarConfiguration.selectorColor = UIColor(red: 6, green: 188, blue: 193)
    configuration.speedBarConfiguration.selectorTextColor = UIColor.white
    
    return configuration
  }
  
  private func updateTrimGalleryVideoConfiguration(_ configuration: TrimGalleryVideoConfiguration) -> TrimGalleryVideoConfiguration {
    var configuration = configuration
    
    configuration.backButtonConfiguration = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "back_arrow"))
    configuration.playerControlConfiguration = PlayerControlConfiguration(
      playButtonImageName: "ic_play",
      pauseButtonImageName: "ic_trim_pause"
    )
    
    configuration.galleryVideoPartsConfiguration.addGalleryVideoPartImageName = "add_video_part"
    configuration.deleteGalleryVideoPartButtonConfiguration = ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic_delete_video_part"))
    
    configuration.nextButtonConfiguration.backgroundColor = .clear
    configuration.nextButtonConfiguration.textConfiguration.color = UIColor(red: 6, green: 188, blue: 193)
    
    configuration.editedTimeLabelConfiguration.errorColor = UIColor(red: 250, green: 62, blue: 118)
    
    return configuration
  }
  
  private func updateMultiTrimConfiguration(_ configuration: MultiTrimConfiguration) -> MultiTrimConfiguration {
    var configuration = configuration
    
    configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "back_arrow"))
    configuration.playerControlConfiguration = PlayerControlConfiguration(
      playButtonImageName: "ic_play",
      pauseButtonImageName: "ic_trim_pause"
    )
    
    configuration.trimTimeLineConfiguration.draggerImageName = "trim_left"
    configuration.trimTimeLineConfiguration.doneButtonConfiguration.style.color = UIColor(red: 6, green: 188, blue: 193)
    configuration.trimTimeLineConfiguration.trimControlsColor = UIColor(red: 250, green: 62, blue: 118)
    
    configuration.saveButton.backgroundColor = .clear
    configuration.saveButton.textConfiguration.color = UIColor(red: 6, green: 188, blue: 193)
    
    configuration.editedTimeLabelConfiguration.errorColor = UIColor(red: 250, green: 62, blue: 118)
    
    return configuration
  }
  
  private func updateSingleTrimConfiguration(_ configuration: SingleTrimConfiguration) -> SingleTrimConfiguration {
    var configuration = configuration
    
    configuration.playerControlConfiguration = PlayerControlConfiguration(
      playButtonImageName: "ic_play",
      pauseButtonImageName: "ic_trim_pause"
    )
    configuration.backButton = BackButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "back_arrow"))
    
    configuration.trimTimeLineConfiguration.draggerImageName = "trim_left"
    configuration.trimTimeLineConfiguration.trimControlsColor = UIColor(red: 250, green: 62, blue: 118)
    
    configuration.saveButton.backgroundColor = .clear
    configuration.saveButton.textConfiguration.color = UIColor(red: 6, green: 188, blue: 193)
    
    configuration.editedTimeLabelConfiguration.errorColor = UIColor(red: 250, green: 62, blue: 118)
    
    return configuration
  }
  
  private func updateFilterConfiguration(_ configuration: FilterConfiguration) -> FilterConfiguration {
    var configuration = configuration
    
    configuration.resetButton.backgroundColor = UIColor(red: 6, green: 188, blue: 193)
    configuration.resetButton.cornerRadius = 4.0
    configuration.resetButton.textConfiguration?.color = .white
    configuration.toolTipLabel.color = .white
    configuration.cursorButton = ImageButtonConfiguration(imageConfiguration: ImageConfiguration(imageName: "ic_cursor"))
  
    configuration.effectItemConfiguration.cornerRadius = 4.0
    
    return configuration
  }
  
  private func updateFullScreenActivityConfiguration(_ configuration: FullScreenActivityConfiguration) -> FullScreenActivityConfiguration {
      var configuration = configuration

      configuration.activityIndicator = SmallActivityIndicatorConfiguration(
        gradientType: .color(
          SmallActivityIndicatorConfiguration.GradientColorConfiguration(
            angle: 0.0,
            colors: [UIColor(red: 6, green: 188, blue: 193).cgColor, UIColor.white.cgColor]
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
    videoEditorSDK?.exportVideos(using: [exportConfiguration], completion: { (success, error) in
      DispatchQueue.main.async {
        // Clear video editor session data
        self.videoEditorSDK?.clearSessionData()
        if success {
          self.playVideoAtURL(videoURL)
        }
        self.videoEditorSDK = nil
      }
    })
  }
  
  private func playVideoAtURL(_ videoURL: URL) {
    let player = AVPlayer(url: videoURL)
    let playerController = AVPlayerViewController()
    playerController.player = player
    present(playerController, animated: true) {
        player.play()
    }
  }
}

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
