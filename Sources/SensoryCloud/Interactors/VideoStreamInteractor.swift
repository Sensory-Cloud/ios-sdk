//
//  VideoStreamInteractor.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import AVFoundation
import VideoToolbox
import UIKit

/// Enumeration for the camera positions on device
public enum CameraPosition {
    /// The forward facing camera
    case front
    /// The backwards facing camera
    case back
}

/// Delegate class for receiving pictures from `VideoStreamInteractor`
public protocol VideoStreamDelegate: AnyObject {
    /// This will be called after a photo has been taken with the photo jpeg data
    func didTakePhoto(_ result: Data)
    /// This will be called when an error occurs while taking a photo
    func takePhotoDidFail(_ error: Error)
}

/// Class for getting picture data from the on device camera
public class VideoStreamInteractor: NSObject {

    /// `AVCaptureSession`  being used, this may be used for showing a photo preview layer to the user
    public let session = AVCaptureSession()

    /// The desired orientation of the captured images
    public let orientation = AVCaptureVideoOrientation.portrait

    /// Delegate to receive processed photo data
    public weak var delegate: VideoStreamDelegate?

    var configured = false
    private var photoRequested = false

    override private init() {}

    /// Shared instance
    public static var shared = VideoStreamInteractor()

    /// Requests permission to use the system camera
    ///
    /// The app must contain a purpose string in the `Info.plist` file with the key `NSCameraUsageDescription` for the system to allow camera permissions
    /// This function will also configure the camera recording and thus *must* be called every time the app launches before attempting to record any video data
    /// - Parameters:
    ///   - completion: Completion block to be called after permissions have been granted/denied by the system
    ///   - Bool: A boolean indicating if camera permissions are allowed
    ///   - Error: An error if one occurred while setting up configurations for video recording
    public func requestPermission(completion: ((Bool, Error?) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] allowed in
            if allowed {
                do {
                    try self?.configure()
                    completion?(true, nil)
                } catch {
                    completion?(true, error)
                }
            } else {
                completion?(false, nil)
            }
        }
    }

    /// Starts the video recording
    ///
    /// - Throws: `VideoStreamError.notConfigured` if configuration has not occurred yet. Call `requestPermissions` to configure the `VideoStreamInteractor`
    public func startRecording() throws {
        if !configured { throw VideoStreamError.notConfigured }
        session.startRunning()
    }

    /// Stops video recording
    public func stopRecording() {
        session.stopRunning()
    }

    /// Sets the current camera to either the forward or backwards facing camera
    ///
    /// By default the forward facing camera is used
    /// This may be called while the interactor is recording without causing any errors
    /// - Parameter position: Camera position to use
    public func setCamera(to position: CameraPosition) throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        for input in session.inputs {
            session.removeInput(input)
        }

        let camera = try getCamera(for: position)
        if session.canAddInput(camera) {
            session.addInput(camera)
        } else {
            throw VideoStreamError.cameraInputError
        }
    }

    /// Requests for a photo to be taken
    ///
    /// Results are returned via the `VideoStreamDelegate`
    /// If this function is called multiple times in rapid succession, `VideoStreamDelegate` will only be called with a result once
    public func takePhoto() {

        if !session.isRunning {
            delegate?.takePhotoDidFail(VideoStreamError.notRecording)
            return
        }

        photoRequested = true
    }

    /// Configures the interactor for video recording
    ///
    /// This function should only be called once for the lifetime of the app
    private func configure() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .high

        // camera input
        let videoDeviceInput = try getCamera(for: .front)
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        } else {
            throw VideoStreamError.cameraInputError
        }

        // video Output
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        if let connection = output.connection(with: .video) {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
            connection.videoOrientation = orientation
        }
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            throw VideoStreamError.cameraOutputError
        }
        configured = true
    }

    /// Returns a camera device input for the specified position
    private func getCamera(for position: CameraPosition) throws -> AVCaptureDeviceInput {

        let avPosition: AVCaptureDevice.Position
        switch position {
        case .front:
            avPosition = .front
        case .back:
            avPosition = .back
        }

        guard let cameraInput = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: avPosition) else {
            throw VideoStreamError.cameraInputError
        }

        return try AVCaptureDeviceInput(device: cameraInput)
    }
}

extension VideoStreamInteractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Delegate function for conformance to `AVCaptureVideoDataOutputSampleBufferDelegate`
    ///
    /// This function should not be directly called by an SDK implementer
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // Make sure that the connection is using the correct orientation
        if connection.videoOrientation != orientation {
            connection.videoOrientation = orientation
        }

        if !photoRequested { return }
        photoRequested = false

        if delegate == nil { return }

        var image: CGImage?
        if let buffer = sampleBuffer.imageBuffer {
            VTCreateCGImageFromCVPixelBuffer(buffer, options: nil, imageOut: &image)
        } else {
            delegate?.takePhotoDidFail(VideoStreamError.photoExportError)
            return
        }
        guard let image = image else {
            delegate?.takePhotoDidFail(VideoStreamError.photoExportError)
            return
        }

        guard let data = imagePostProcessing(on: image) else {
            delegate?.takePhotoDidFail(VideoStreamError.photoExportError)
            return
        }

        delegate?.didTakePhoto(data)
    }

    func imagePostProcessing(on baseImage: CGImage) -> Data? {
        let width = Config.photoWidth
        let height = Config.photoHeight

        // First correct the aspect ratio of the image
        let targetAspectRatio = Double(width)/Double(height)
        var croppedOpt: CGImage?
        if targetAspectRatio < Double(baseImage.width) / Double(baseImage.height) {
            // crop width to match aspect ratio
            let delta = Double(baseImage.width) - targetAspectRatio * Double(baseImage.height)
            croppedOpt = baseImage.cropping(to: CGRect(
                x: Int(delta/2),
                y: 0,
                width: baseImage.width - Int(delta),
                height: baseImage.height
            ))
        } else {
            // crop height to match aspect ratio
            let delta = Double(baseImage.height) - (1.0/targetAspectRatio) * Double(baseImage.width)
            croppedOpt = baseImage.cropping(to: CGRect(
                x: 0,
                y: Int(delta/2),
                width: baseImage.width,
                height: baseImage.height - Int(delta)
            ))
        }

        guard let cropped = croppedOpt else {
            return nil
        }

        // Second, scale down the image to the proper size
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: cropped.bitsPerComponent,
            bytesPerRow: cropped.bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue).rawValue
        ) else {
            return nil
        }
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let resized = context.makeImage() else {
            return nil
        }

        // Third, export as a jpeg
        return UIImage(cgImage: resized).jpegData(compressionQuality: Config.jpegCompression)
    }
}
