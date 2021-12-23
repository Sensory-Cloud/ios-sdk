//
//  AudioStreamError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/15/21.
//

import Foundation

/// Various errors that may occur while configuring the `AudioStreamInteractor` for recording
public enum AudioStreamError: Error {
    /// Audio configuration failed
    case failedToConfigure
    /// An audio component could not be found on the device
    case failedToFindAudioComponent
    /// A microphone unit could not be found on the device
    case failedToFindMicrophoneUnit
    /// Thrown when `startRecording` is called before configuration has occurred. Configuration occurs when `RequestPermission` is called.
    case notConfigured
}
