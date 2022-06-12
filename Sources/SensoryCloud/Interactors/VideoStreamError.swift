//
//  VideoStreamError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/15/21.
//

import Foundation

/// Various errors that may occur while configuring `VideoStreamInteractor` for recording
public enum VideoStreamError: Error {
    /// An error occurred while configuring the camera
    case cameraInputError
    /// An error occurred while setting the camera output
    case cameraOutputError
    /// An error occurred while exporting a photo that has been taken
    case photoExportError
    /// Thrown when a photo is requested, but the interactor is not currently recording
    case notRecording
    /// Thrown when `startRecording`is called before configuration has occurred. Configuration occurs when `RequestPermission` is called.
    case notConfigured
}
