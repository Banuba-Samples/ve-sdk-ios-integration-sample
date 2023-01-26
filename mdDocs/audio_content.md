# API for using client's audio content in the SDK
## Overview

The user can apply audio tracks on camera and music editor screens.

The SDK can apply an audio track to a video, trim an audio track before applying, create a new audio track as a composition of several applied audio tracks on video.

There are 2 options how to pass audio content to Video Editor:

- External Audio browser
- Banuba Audio browser

## Integration
### External Audio browser

To pass audio content to Video Editor SDK you have to implement a factory that conforms ```MusicEditorExternalViewControllerFactory``` protocol. And put it to ```musicEditorFactory``` property in [ExternalViewControllerFactory](../Example/Example/ViewController.swift#L24). Your factory should contain the following methods:

```swift
// MARK: - External Audio Browser Factory
protocol MusicEditorExternalViewControllerFactory: AnyObject {
  /// contoller which will be used for presenting otherwise makeTrackSelectionViewController will be used
  var audioBrowserController: TrackSelectionViewController? { get set }

  /// should returns controller which provides audio content for Video Editor SDK
  /// - selectedAudioItem is currently selected audio item
  func makeTrackSelectionViewController(selectedAudioItem: AudioItem?) -> TrackSelectionViewController?
  /// should returns controller which provides effects audio content for Video Editor SDK
  /// Note: MainMusicViewControllerConfig should contains editButton with type .effect
  func makeEffectSelectionViewController(selectedAudioItem: AudioItem?) -> EffectSelectionViewController?
  /// should returns view for countdown animation in record button at music editor
  func makeRecorderCountdownAnimatableView() -> MusicEditorCountdownAnimatableView?
}
```
Where ```AudioItem``` is entity contains information about selected audio item in Video Editor SDK:
```swift
// MARK: - AudioItem protocol
protocol AudioItem {
  var id: Int64 { get }
  var url: URL { get }
  var title: String? { get set }
  /// True - display track with which the video was recorded and allow users to edit it.
  /// False - track will be playing but not displayed.
  var isEditable: Bool { get set }
}
```

Your custom audio browser should conforms the following protocol:
```swift
protocol TrackSelectionViewController: UIViewController {
  var trackSelectionDelegate: TrackSelectionViewControllerDelegate? { get set }
}
```
Using ```trackSelectionDelegate``` you can notify Video Editor SDK about actions at audio browser with following methods:
```swift
// MARK: - TrackSelectionViewController
protocol TrackSelectionViewControllerDelegate: AnyObject {
  func trackSelectionViewController(
    viewController: TrackSelectionViewController,
    didSelectFile url: URL,
    isEditable: Bool,
    title: String,
    /// The id parameter should be a Int32 number from 6 to it's maximum value
    id: Int32
  )
  
  func trackSelectionViewControllerDidCancel(
    viewController: TrackSelectionViewController
  )
  
  func trackSelectionViewController(
    viewController: TrackSelectionViewController,
    didStopUsingTrackWithId trackId: Int32
  )
}
```

**NOTE: The Video Editor SDK is not responsible for providing audio content. The client has to implement an integration with an audio content provider.
The Video Editor SDK can't download music from external storage and import music tracks from Apple Music.**

If you want to pass music from Apple Music to Video Editor SDK you have to export media to temporary directory then pass music url to Video Editor SDK using ```trackSelectionDelegate```. There is example how to export music from Apple Music:
```swift
let asset = AVURLAsset(url: url)
let destination = FileManager.default
  .temporaryDirectory
  .appendingPathComponent("\(NSUUID().uuidString).caf")
let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
exportSession?.outputURL = destination
exportSession?.outputFileType = AVFileType.caf
exportSession?.exportAsynchronously() {
  if let error = exportSession?.error {
    completion(nil, error as NSError)
  } else {
    completion(destination, nil)
  }
}
```

### Banuba Audio browser

### Step 1

Add the ```BanubaAudioBrowserSDK``` dependency into your pod file containing other Video Editor SDK dependencies and setup its version:

```swift
pod 'BanubaAudioBrowserSDK', '1.26.0'

```
### Step 2

Configure mubert token to use external music provider:
```swift
let mubertPat = "Your mubert pat"
BanubaAudioBrowser.setMubertPat(mubertPat)
```

### Step 4

Your class should implement ```MusicEditorExternalViewControllerFactory``` protocol.
```swift
public protocol MusicEditorExternalViewControllerFactory: AnyObject {
  var audioBrowserController: TrackSelectionViewController? { get set }
  func makeTrackSelectionViewController(selectedAudioItem: AudioItem?) -> TrackSelectionViewController?
  func makeEffectSelectionViewController(selectedAudioItem: AudioItem?) -> EffectSelectionViewController?
  func makeRecorderCountdownAnimatableView() -> MusicEditorCountdownAnimatableView?
}
```
Here's the example of the methods implementation for using Banuba Audiobrowser:
```swift
  var audioBrowserController: TrackSelectionViewController?
  
  func makeTrackSelectionViewController(selectedAudioItem: AudioItem?) -> TrackSelectionViewController? {
    return nil
  }
  
  func makeEffectSelectionViewController(selectedAudioItem: AudioItem?) -> EffectSelectionViewController? {
    return nil
  }
  
  func makeRecorderCountdownAnimatableView() -> MusicEditorCountdownAnimatableView? {
    return nil
  }
```
See an example in sample [here](../Example/Example/Helpers/MusicEditorViewControllerFactory.swift#L14).

### Step 5

The class in which you have implemented the ``` MusicEditorExternalViewControllerFactory ``` protocol must be passed to ```musicEditorFactory```.

See an example [here](../Example/Example/ViewController.swift#L30).

### Step 6

Banuba Audiobrowser can be configured to work with online music providers, local audio files or with all sources. To control this behaviour customize ```musicSource``` property:
```swift

AudioBrowserConfig.shared.musicSource = .mubert

// Available options
@objc public enum AudioBrowserMusicSource: Int, CaseIterable {
  /// enables only Mubert music in AudioBrowser
  case mubert = 1
  /// disables Mubert music. Only local music with my files will be available
  case localStorageWithMyFiles = 2
  /// all sources are enabled
  case allSources = 3
}
```
