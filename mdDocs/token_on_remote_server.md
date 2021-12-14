# API for using token from Remote Server in the AI Video Editor SDK

Banuba token can be stored on Remote Server. Follow the next steps to achieve remote token downloading

### Step 1

Create an instance of ```RemoteTokenProvider``` and pass your external token URL to ```targetURL``` property

```swift

let remoteTokenProvider = RemoteTokenProvider(
  targetURL: "url to the remote server"
)

```

### Step 2

Pass your created instance to ```VideoEditorTokenProvider```

```swift

let provider = VideoEditorTokenProvider(tokenProvider: remoteTokenProvider)

```

### Step 3

Use ```loadToken``` method of ```VideoEditorTokenProvider``` instance to load banuba_token and initialize VideoEditor SDK

```swift

provider.loadToken() { [weak self] (error, token) in
  guard let token = token else { return }
  guard let self = self else { return }
  self.videoEditorSDK = BanubaVideoEditor(
    token: token,
    configuration: self.config,
    analytics: Analytics(),
    externalViewControllerFactory: viewControllerFactory
  )
}

```

## Custom Token Provider

You can create your custom TokenProvider if you use any additional types of encryption for your token.

Here is an example of TokenProvider class to get token from ```Data```

```swift
import Foundation
import BanubaTokenStorageSDK

class RemoteTokenProvider: TokenProvidable {
  
  let targetURL: String
  
  init(
    targetURL: String
  ) {
    self.targetURL = targetURL
  }
  
  func observeToken(
    succesEvent: @escaping (String?) -> Void,
    errorEvent: @escaping (Error) -> Void
  ) {
    guard let tokenURL = URL(string: targetURL) else { return }
    URLSession.shared.dataTask(with: tokenURL) { data, urlResponse, error in
      if let data = data {
        let token = String(data: data, encoding: .utf8.self)
        DispatchQueue.main.async {
          succesEvent(token)
        }
      }
    }.resume()
  }
}

```

### Note:
For better user experience you should load the `banuba_token` at the start of your app lifecycle because  `VideoEditorTokenProvider` loads banuba_token asynchronously. **Please keep in mind that you have to handle errors when the internet is not connected and other errors.**
