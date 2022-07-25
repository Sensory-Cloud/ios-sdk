# Sensory Cloud iOS SDK

This repository contains the source code for the Sensory Cloud iOS SDK.

## General Information

Before getting started, you must spin up a Sensory Cloud inference server or have Sensory spin one up for you. You must also have the following pieces of information:

- Your inference server URL
- Your Sensory Tenant ID (UUID)

## Integration

The Sensory Cloud iOS SDK is distributed via Swift Package Manager. From Xcode 11 it is possible to [add Swift Package dependencies to Xcode projects](https://help.apple.com/xcode/mac/current/#/devb83d64851) and link targets to products of those packages; this is the easiest way to integrate Sensory Cloud with an existing `xcodeproj`.

# Examples

## SDK Initialization

The SDK must be explicitly initialized every time the app is launched. This initialization sets up internal configurations and will also enroll the device into the Sensory Cloud server if the device has not been previously enrolled. SDK initialization is completed by calling `Initializer.initialize(...)`. There are two versions of this function. One that takes in an explicit configuration object, and one that takes in a fileURL for a config file. The following configurations are set during initialization:
 - fullyQualifiedDomainName: This is the fqdn of the Sensory Cloud server to communicate with
 - tenantID: The unique identifier (UUID) for your Sensory Cloud tenant
 - enrollmentType: The amount of security required for device enrollment. This should be one of `none`, `sharedSecret` or `jwt`. If the device has already been enrolled during a previous app session, this field is ignored
 - credential: The credential required for device enrollment, the value depends on the enrollment type:
    - `none` enrollmentType: credential should be an empty string
    - `sharedSecret` enrollmentType: credential should be the shared secret (password)
    - `jwt` enrollmentType: credential should be a hex string of the enrollment private key

    If the device has already been enrolled during a previous app session, this field is ignored
 - deviceID: A unique device identifier (UUID), if left nil the SDK will generate one
 - deviceName: The friendly name of the device, if let nil the system device name will be used (`UIDevice.current.name`)

 The iOS Sensory Cloud SDK accepts config files with the following formats: `ini`, `env`, `json`, and `plist`. Example config files for each of these formats can be found under `Tests/SensoryCloudTests/Resources/Initializer`. The below example shows how to initialize the SDK from a config file.

 ```Swift
 // Get a file URL of the config file
 guard let fileURL = Bundle.main.url(forResource: "SensoryCloudConfig", withExtension: "ini") else {
    NSLog("Failed to find config file")
    return
}

// Initialize the SDK
Initializer.initialize(configFile: fileURL) { result in
    switch result {
    case .success(let response):
        NSLog("Successful SDK initialization")
        // A response is returned if the device was newly enrolled, otherwise response will be `nil`
        if let response = response {
            NSLog("Successful device enrollment")
        } else {
            NSLog("Device was enrolled during a previous app session")
        }
    case .failure(let error):
        NSLog("An error occurred during SDK initialization")
    }
}
 ```

## The Token Manager

The `TokenManager` class manages the saving and retrieving OAuth credentials (clientID and clientSecret). This implementation uses the Apple Keychain for secure credential storage, and it is recommended to use this implementation. If a custom TokenManager is required, a custom class that conforms to the `CredentialProvider` interface should be set to `Service.credentialProvider` see the `docs` subdirectory for more information.

## Registering OAuth Credentials

OAuth credentials should be registered once per device. Registration is simple and provided as part of the SDK. The below example shows how to create an `OAuthService` and register a client for the first time.

```Swift
// setup SDK config
Config.setCloudHost(host: "inference server URL")
Config.tenantID = "Sensory Tenant ID"
Config.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

let friendlyDeviceName = "My iOS Device"

// Initialize token manager and oauth service
let tokenManager = TokenManager()
let oauthService = OAuthService()

// Generate OAuth credentials
let oauthCredentials: AccessTokenCredentials
do {
    oauthCredentials = try tokenManager.generateCredentials()
} catch {
    NSLog("Failed to generate credentials: %@", error.localizedDescription)
    return
}

// Authorization credential as configured on your instance of Sensory Cloud
let sharedSecret = "password";

let rsp = oauthService.enrollDevice(
    name: friendlyDeviceName,
    credential: sharedSecret,
    clientID: oauthCredentials.clientID,
    clientSecret: oauthCredentials.secret
)

rsp.whenSuccess { _ in
    // Successfully registered
}

rsp.whenFailure { error in
    // Handle server error
}
```

## Checking Server Health

It's important to check the health of your Sensory Inference server. You can do so via the following:

```Swift
// setup SDK config
Config.setCloudHost(host: "inference server URL")
Config.tenantID = "Sensory Tenant ID"
Config.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

// Init an health service
let healthService = HealthService()

// Get server health
let rsp = healthService.getHealth()

rsp.whenSuccess { health in
    // Process health response
}

rsp.whenFailure { error in
    // Handle server error
}
```

## Audio Methods

### Creating an Audio Service

`AudioService` provides methods to stream audio to Sensory Cloud. This service uses OAuth credentials provided by `Service.credentialProvider` (`TokenManager` by default) and pulls configuration information from the global `Config` object.

```Swift
// setup SDK config
Config.setCloudHost(host: "inference server URL")
Config.tenantID = "Sensory Tenant ID"
Config.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

// Init an audio service
AudioService audioService = AudioService()
```

### Creating an Audio Stream Interactor

`AudioStreamInteractor` is a Sensory implementation for accessing the device's microphone. This uses an instance of `AudioComponentInstance` behind the scenes. `AudioStreamInteractor` requires a purpose string in the app's `Info.plist` file for `NSMicrophoneUsageDescription`. It is important to call `AudioStreamInteractor.shared.requestPermission()` every time the app launches to ensure the interactor is setup properly

```Swift
let audioInteractor = AudioStreamInteractor.shared

audioInteractor.requestPermission { permissionAllowed, error in
  if !permissionAllowed {
    NSLog("Audio permissions denied")
  }
}
```

### Obtaining Audio Models

Certain audio models are available to your application depending on the models that are configured in your instance to Sensory Cloud. In order to determine which audio models are accessible to you, you can execute the following:

```Swift
let audioResponse = audioService.getModels()

audioResponse.whenSuccess { response in
  let models = response.models
}

audioResponse.whenFailure { error in
  // Handle server error
}
```

Audio models contain the following properties:

 - Name - the unique name tied to this model. Used when calling any other audio function.
 - IsEnrollable - indicates if the model can be enrolled into. Models that are enrollable can be used in the CreateEnrollment function.
 - ModelType - indicates the class of model and its general function.
 - FixedPhrase - for speech-based models only. Indicates if a specific phrase must be said.
 - SampleRate - indicates the audio sample rate required by this model. Generally, the number will be 16000.
 - IsLivenessSupported - indicates if this model supports liveness for enrollment and authentication. Liveness provides an added layer of security by requiring a users to speak random digits.

 ### Enrolling with Audio

In order to enroll with audio, you must first ensure you have an enrollable model enabled for your Sensory Cloud instance. This can be obtained via the `getModels` request. Enrolling with audio uses a bi-directional streaming pattern to allow immediate feedback to the user during enrollment. It is important to save the `enrollmentID` in order to perform authentication against it in the future.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Audio_CreateEnrollmentRequest,
    Sensory_Api_V1_Audio_CreateEnrollmentResponse
>?

func audioEnrollment() throws {
    // Get Basic Enrollment Info
    let modelName = "wakeword-16kHz-open_sesame.ubm"
    let userID = "72f286b8-173f-436a-8869-6f7887789ee9"
    let enrollmentDescription = "My Enrollment"
    let isLivenessEnabled = false

    // Get an audio service
    let service = AudioService()

    // Set the delegate for AudioStreamInteractor
    AudioStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.createEnrollment(
        modelName: modelName,
        userID: userID,
        description: enrollmentDescription,
        isLivenessEnabled: isLivenessEnabled
    ) { [weak self] response in
        // The response contains information about the enrollment status.
        // * audioEnergy
        // * percentComplete
        // For enrollments with liveness, there are two additional fields that are populated.
        // * modelPrompt - indicates what the user should say in order to proceed with the enrollment.
        // * sectionPercentComplete - indicates the percentage of the current ModelPrompt that has been spoken.
        // EnrollmentID will be populated once the enrollment is complete
        if response.enrollmentID != "" {
            // Enrollment is complete, close the grpc stream and stop recording
            if let openStream = self?.grpcStream {
                _ = openStream.sendEnd()
            }
            AudioStreamInteractor.shared.stopRecording()
        }
    }

    // Save the open grpc stream and start audio recording
    grpcStream = stream
    try AudioStreamInteractor.shared.startRecording()
}

// Delegate method for AudioStreamInteractor
func didProcessAudio(_ data: Data) {
    if let stream = grpcStream {
        // (Make sure you use the proper type for the grpc stream you're using)
        var request = Sensory_Api_V1_Audio_CreateEnrollmentRequest()
        request.audioContent = data
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Recording without an open grpc stream, stopping recording")
        AudioStreamInteractor.shared.stopRecording()
    }
}
```

### Authenticating with Audio

Authenticating with audio is similar to enrollment, except now you pass in an enrollmentID instead of the model name.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Audio_AuthenticateRequest,
    Sensory_Api_V1_Audio_AuthenticateResponse
>?

func audioAuthentication() throws {
    // Get Basic Enrollment Info
    let enrollmentID = "436ee716-346e-4066-8c28-7b5ef192831f"
    let isLivenessEnabled = false

    // Get an audio service
    let service = AudioService()

    // Set the delegate for AudioStreamInteractor
    AudioStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.authenticate(
        enrollment: .enrollmentID(enrollmentID),
        isLivenessEnabled: isLivenessEnabled
    ) { [weak self] response in
        // The response contains information about the authentication audio such as:
        // * audioEnergy
        // For authentications with liveness, there are two additional fields that are populated.
        // * modelPrompt - indicates what the user should say in order to proceed with the authentication.
        // * sectionPercentComplete - indicates the percentage of the current ModelPrompt that has been spoken.
        if response.success {
            // Successful authentication, close the grpc stream and stop recording
            if let openStream = self?.grpcStream {
                _ = openStream.sendEnd()
            }
            AudioStreamInteractor.shared.stopRecording()
        }
    }

    // Save the open grpc stream and start audio recording
    grpcStream = stream
    try AudioStreamInteractor.shared.startRecording()
}

// Delegate method for AudioStreamInteractor
func didProcessAudio(_ data: Data) {
    if let stream = grpcStream {
        // (Make sure you use the proper type for the grpc stream you're using)
        var request = Sensory_Api_V1_Audio_AuthenticateRequest()
        request.audioContent = data
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Recording without an open grpc stream, stopping recording")
        AudioStreamInteractor.shared.stopRecording()
    }
}
```

### Audio Events

Audio events are used to recognize specific words, phrases, or sounds.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Audio_ValidateEventRequest,
    Sensory_Api_V1_Audio_ValidateEventResponse
>?

func audioEvent() throws {
    let userID = "72f286b8-173f-436a-8869-6f7887789ee9"
    let modelName = "wakeword-16kHz-open_sesame.ubm"
    // Determines how sensitive the model should be to false accepts
    let sensitivity = Sensory_Api_V1_Audio_ThresholdSensitivity.medium

    // Get an audio service
    let service = AudioService()

    // Set the delegate for AudioStreamInteractor
    AudioStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.validateTrigger(
        modelName: modelName,
        userID: userID,
        sensitivity: sensitivity
    ) {  response in
        // the response will contain the following if the event was recognized
        // * resultId - indicating the name of the event that was recognized
        // * score - Sensory's confidence in the result
        if response.success {
            // trigger recognized!
        }
    }

    // Save the open grpc stream and start audio recording
    grpcStream = stream
    try AudioStreamInteractor.shared.startRecording()
}

// Delegate method for AudioStreamInteractor
func didProcessAudio(_ data: Data) {
    if let stream = grpcStream {
        // (Make sure you use the proper type for the grpc stream you're using)
        var request = Sensory_Api_V1_Audio_ValidateEventRequest()
        request.audioContent = data
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Recording without an open grpc stream, stopping recording")
        AudioStreamInteractor.shared.stopRecording()
    }
}

// The SDK implementer can decide when they want to close the stream
func stopAudioEvents() {
    _ = grpcStream?.sendEnd()
    AudioStreamInteractor.shared.stopRecording()
}
```

### Transcription (Sliding Window Transcript)

Transcription is used to convert audio to text.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Audio_TranscribeRequest,
    Sensory_Api_V1_Audio_TranscribeResponse
>?

func startAudioTranscription() throws {
    let userID = "72f286b8-173f-436a-8869-6f7887789ee9"
    let modelName = "wakeword-16kHz-open_sesame.ubm"

    // Get an audio service
    let service = AudioService()

    // Set the delegate for AudioStreamInteractor
    AudioStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.transcribeAudio(
        modelName: modelName,
        userID: userID
    ) {  response in
        // Response contains information about the audio such as:
        // * audioEnergy

        // Transcript contains the current running transcript of the last 7 seconds of processed audio
        // If you want a full transcript, see the below example
        let transcript = response.transcript
    }

    // Save the open grpc stream and start audio recording
    grpcStream = stream
    try AudioStreamInteractor.shared.startRecording()
}

// Delegate method for AudioStreamInteractor
func didProcessAudio(_ data: Data) {
    if let stream = grpcStream {
        // (Make sure you use the proper type for the grpc stream you're using)
        var request = Sensory_Api_V1_Audio_TranscribeRequest()
        request.audioContent = data
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Recording without an open grpc stream, stopping recording")
        AudioStreamInteractor.shared.stopRecording()
    }
}

// The SDK implementer can decide when they want to close the stream
func stopAudioTranscription() {
    _ = grpcStream?.sendEnd()
    AudioStreamInteractor.shared.stopRecording()
}
```

### Transcription (Full Transcript)

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Audio_TranscribeRequest,
    Sensory_Api_V1_Audio_TranscribeResponse
>?
let aggregator = TranscriptAggregator()

func startAudioTranscription() throws {
    let userID = "72f286b8-173f-436a-8869-6f7887789ee9"
    let modelName = "wakeword-16kHz-open_sesame.ubm"

    // Get an audio service
    let service = AudioService()

    // Set the delegate for AudioStreamInteractor
    AudioStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.transcribeAudio(
        modelName: modelName,
        userID: userID
    ) {  response in
        // Response contains information about the audio such as:
        // * audioEnergy

        // The transcript aggregator will collect all of the server responses and save a full transcript
        try? aggregator.processResponse(response.getWordList())
        transcript = aggregator.getTranscript()
    }

    // Save the open grpc stream and start audio recording
    grpcStream = stream
    try AudioStreamInteractor.shared.startRecording()
}

// Delegate method for AudioStreamInteractor
func didProcessAudio(_ data: Data) {
    if let stream = grpcStream {
        // (Make sure you use the proper type for the grpc stream you're using)
        var request = Sensory_Api_V1_Audio_TranscribeRequest()
        request.audioContent = data
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Recording without an open grpc stream, stopping recording")
        AudioStreamInteractor.shared.stopRecording()
    }
}

// The SDK implementer can decide when they want to close the stream
func stopAudioTranscription() {
    _ = grpcStream?.sendEnd()
    AudioStreamInteractor.shared.stopRecording()
}
```

## Video Methods

### Creating a Video Service

`VideoService` provides methods to stream images to Sensory Cloud. This service uses OAuth credentials provided by `Service.credentialProvider` (`TokenManager` by default) and pulls configuration information from the global `Config` object.

```Swift
// setup SDK config
Config.setCloudHost(host: "inference server URL")
Config.tenantID = "Sensory Tenant ID"
Config.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

// Init a video service
VideoService videoService = VideoService()
```

### Creating a Video Stream Interactor

`VideoStreamInteractor` is a Sensory implementation for accessing the device's microphone. This uses an instance of `AVCaptureSession` behind the scenes. The underlying `AVCaptureSession` is exposed via `VideoStreamInteractor.shared.session` which can be used to create a video preview layer to show to the user. `VideoStreamInteractor` requires a purpose string in the app's `Info.plist` file for `NSCameraUsageDescription`. It is important to call `VideoStreamInteractor.shared.requestPermission()` every time the app launches to ensure the interactor is setup properly

```Swift
let videoInteractor = VideoStreamInteractor.shared

videoInteractor.requestPermission { permissionAllowed, error in
  if !permissionAllowed {
    NSLog("Video permissions denied")
  }
}
```

### Obtaining Video Models

Certain video models are available to your application depending on the models that are configured for your instance of Sensory Cloud. In order to determine which video models are accessible to you, you can execute the following:

```Swift
let videoResponse = videoService.getModels()

videoResponse.whenSuccess { response in
  let models = response.models
}

videoResponse.whenFailure { error in
  // Handle server error
}
```

Video models contain the following properties:

 - Name - the unique name tied to this model. Used when calling any other video function.
 - IsEnrollable - indicates if the model can be enrolled into. Models that are enrollable can be used in the CreateEnrollment function.
 - ModelType - indicates the class of model and its general function.
 - FixedObject - for recognition-based models only. Indicates if this model is built to recognize a specific object.
 - IsLivenessSupported - indicates if this model supports liveness for enrollment and authentication. Liveness provides an added layer of security.

### Enrolling with Video

in order to enroll with video, you must first ensure you have an enrollable model enabled for your Sensory Cloud instance. This can be obtained via the `getModels` request. Enrolling with video uses a call and response streaming pattern to allow immediate feedback to the user during enrollment. It is important to save the enrollmentID in order to perform authentication against it in the future.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Video_CreateEnrollmentRequest,
    Sensory_Api_V1_Video_CreateEnrollmentResponse
>?

func createVideoEnrollment() throws {
    // Get basic enrollment information
    let modelName = "face_biometric_hektor";
    let userID = "72f286b8-173f-436a-8869-6f7887789ee9";
    let enrollmentDescription = "My Enrollment";
    let isLivenessEnabled = true;
    let threshold = Sensory_Api_V1_Video_RecognitionThreshold.low;
    let liveFramesRequired: Int32 = 1;

    // Get a video service
    let service = VideoService()

    // Set the delegate for VideoStreamInteractor
    VideoStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.createEnrollment(
        modelName: modelName,
        userID: userID,
        description: enrollmentDescription,
        isLivenessEnabled: isLivenessEnabled,
        livenessThreshold: threshold,
        numLiveFramesRequired: liveFramesRequired
    ) { [weak self] rsp in
        // The response contains information about the enrollment status
        // * percentComplete

        // enrollmentID will be populated once the enrollment is complete
        if rsp.enrollmentID.isEmpty {
            // If the enrollment is not complete, send the next video frame
            VideoStreamInteractor.shared.takePhoto()
        } else {
            // Enrollment is complete!

            // Close the grpc stream and stop recording
            if let openStream = self?.grpcStream {
                _ = openStream.sendEnd()
            }
            VideoStreamInteractor.shared.stopRecording()
        }
    }

    // Save the grpc stream
    self.grpcStream = stream

    // Start the video preview and request the initial image
    try VideoStreamInteractor.shared.startRecording()
    VideoStreamInteractor.shared.takePhoto()
}

// Delegate method for VideoStreamInteractor
func didTakePhoto(_ result: Data) {
    if let stream = self.grpcStream {
        // (Make sure you are using the proper type for the gprc stream you're using)
        var request = Sensory_Api_V1_Video_CreateEnrollmentRequest()
        request.imageContent = result
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Video capture is running without an open grpc stream")
        VideoStreamInteractor.shared.stopRecording()
    }
}
```

### Authenticating with Video

Authenticating with video is similar to enrollment, except now you pass in an enrollmentID instead of the model name.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Video_AuthenticateRequest,
    Sensory_Api_V1_Video_AuthenticateResponse
>?

func authenticateVideoEnrollment() throws {
    // Get basic authentication information
    let enrollmentID = "fcc8a800-252e-442c-af30-41846f248238";
    let isLivenessEnabled = true;
    let threshold = Sensory_Api_V1_Video_RecognitionThreshold.low;

    // Get a video service
    let service = VideoService()

    // Set the delegate for VideoStreamInteractor
    VideoStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.authenticate(
        enrollment: .enrollmentID(enrollmentID),
        isLivenessEnabled: isLivenessEnabled,
        livenessThreshold: threshold
    ) { [weak self] rsp in
        if rsp.success {
            // Authentication was successful!

            // Close the grpc stream and stop recording
            if let openStream = self?.grpcStream {
                _ = openStream.sendEnd()
            }
            VideoStreamInteractor.shared.stopRecording()
        } else {
            // Send the next video frame
            VideoStreamInteractor.shared.takePhoto()
        }
    }

    // Save the grpc stream
    self.grpcStream = stream

    // Start the video preview and request the initial image
    try VideoStreamInteractor.shared.startRecording()
    VideoStreamInteractor.shared.takePhoto()
}

// Delegate method for VideoStreamInteractor
func didTakePhoto(_ result: Data) {
    if let stream = self.grpcStream {
        // (Make sure you are using the proper type for the gprc stream you're using)
        var request = Sensory_Api_V1_Video_AuthenticateRequest()
        request.imageContent = result
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Video capture is running without an open grpc stream")
        VideoStreamInteractor.shared.stopRecording()
    }
}
```

### Video Liveness

Video Liveness allows one to send images to Sensory Cloud in order to determine if teh subject is a live individual rather than a spoof, such as a paper mask or picture.

```Swift
var grpcStream: BidirectionalStreamingCall<
    Sensory_Api_V1_Video_ValidateRecognitionRequest,
    Sensory_Api_V1_Video_LivenessRecognitionResponse
>?

func startValidatingLiveness() throws {
    // Get basic authentication information
    let userID = "bea536c2-45d7-47b3-94e2-4962e1bb8a2f";
    let modelName = "face_recognition_mathilde";
    let threshold = Sensory_Api_V1_Video_RecognitionThreshold.low;

    // Get a video service
    let service = VideoService()

    // Set the delegate for VideoStreamInteractor
    VideoStreamInteractor.shared.delegate = self

    // Open the grpc stream
    let stream = try service.validateLiveness(
        modelName: modelName,
        userID: userID,
        threshold: threshold
    ) { rsp in
        if rsp.isAlive {
            // The previous frame was determined to be alive
        }

        // Send the next video frame
        VideoStreamInteractor.shared.takePhoto()
    }

    // Save the grpc stream
    self.grpcStream = stream

    // Start the video preview and request the initial image
    try VideoStreamInteractor.shared.startRecording()
    VideoStreamInteractor.shared.takePhoto()
}

// Delegate method for VideoStreamInteractor
func didTakePhoto(_ result: Data) {
    if let stream = self.grpcStream {
        // (Make sure you are using the proper type for the gprc stream you're using)
        var request = Sensory_Api_V1_Video_ValidateRecognitionRequest()
        request.imageContent = result
        stream.sendMessage(request, promise: nil)
    } else {
        NSLog("Video capture is running without an open grpc stream")
        stopRecording()
    }
}

// The SDK implementer can decide when they want to close the video stream
func stopValidatingLiveness() {
    _ = grpcStream?.sendEnd()
    VideoStreamInteractor.shared.stopRecording()
}
```

## Creating a Management Service

The `ManagementService` is used to manage typical CRUD operations with Sensory Cloud, such as deleting enrollments or creating enrollment groups. For more information on the specific functions of `ManagementService`, please refer to the additional documentation in the `docs/` folder.
