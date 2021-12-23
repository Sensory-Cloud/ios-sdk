# Sensory Cloud iOS SDK

## Integration

The Sensory Cloud iOS SDK is distributed via Swift Package Manager. From Xcode 11 it is possible to [add Swift Package dependencies to Xcode projects](https://help.apple.com/xcode/mac/current/#/devb83d64851) and link targets to products of those packages; this is the easiest way to integrate Sensory Cloud with an existing `xcodeproj`.

## Code Structure

Sensory Cloud's iOS SDK allows for a fast and easy integreation into Sensory Cloud. This SDK is divided into four major sections

- Services
- Token Manager
- Interactors
- Config

This README covers the high level functions of each section.  More detailed code level documentation can be found under the `docs` folder.

### Services

Sensory Cloud uses grpc for its client server communication. All of the `Service` classes within the sdk (Ex: `AudioService`) serve as wrappers around grpc calls. 

### Token Manager

The `TokenManager` class is a helper class that provides automatic OAuth token management for Sensory Cloud. `TokenManager` takes care of requesting and refreshing OAuth tokens, storing OAuth tokens and credentials securly within Apple Keychain, and providing tokens to grpc services. While it is recommended to use `TokenManager` for OAuth token management, you can see the documentation for `Credential Provider` for information on how to provide your own token management.

### Interactors

Sensory Cloud includes two interactors, `VideoStreamInteractor` and `AudioStreamInteractor`. These are helper classes that manage getting Audio and Video data from the on device camera and microphone. Client apps are free to use their own implementation for getting audio or video data. Reguardless, client apps still need to request permission for their app to use the camera and microphone. This is done by adding purpose strings to the app's `Info.plist` file for the keys `NSCameraUsageDescription` and `NSMicrophoneUsageDescription`.

### Config

The static `Config` class provides a place for the client app to configure certain aspects of how Sensory Cloud functions. There are a few configurations that *must* be set before making any service calls. 

- `Config.SetCloudHost()` sets the cloud host that the Sensory Cloud SDK will reach out to
- `Config.TenantID` sets the tenantID of the Sensory Cloud instance to use
- `Config.DeviceID` is a unique identifier for the current device. This should not change after the device has logged into Sensory Cloud

More configurations exist under the `Config` class, but all other configurations have sutible default values and only need te be set if the default behavior is not desired.

`Config` does not save anything on device. All configurations *must* be set every time the app launches.

---

## gRPC

gRPC is "what REST should have been". gRPC is a modern open source high performance Remote Procedure Call (RPC) framework that can run in any environment. It can efficiently connect servers and clients in a more efficient and controlled manner.

[Introduction to gRPC](https://grpc.io/docs/what-is-grpc/introduction/)

---

## Maintainers

- Owner - Niles Hacking (nhacking@sensoryinc.com)
