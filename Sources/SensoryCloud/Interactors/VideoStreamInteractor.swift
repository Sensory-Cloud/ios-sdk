//
//  VideoStreamInteractor.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import AVFoundation
import UIKit

public typealias PhotoResult = Result<Data, Error>

public enum VideoStreamError: Error {
    case cameraInputError
    case cameraOutputError
    case photoAlreadyRequested
    case photoExportError
    case notRecording
    case notConfigured
}

public enum CameraPosition {
    case front
    case back
}

public protocol VideoStreamDelegate: AnyObject {
    func didTakePhoto(_ result: PhotoResult)
}

public class VideoStreamInteractor: NSObject {

    public let session = AVCaptureSession()
    public weak var delegate: VideoStreamDelegate?
    var configured = false

    private var photoRequested = false

    public static var shared = VideoStreamInteractor()
    override private init() {}

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
            NSLog("Could not add the camera input")
            throw VideoStreamError.cameraInputError
        }

        // video Output
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            NSLog("Could not set the video output")
            throw VideoStreamError.cameraOutputError
        }
        configured = true
    }

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
    public func startRecording() throws {
        if !configured { throw VideoStreamError.notConfigured }
        session.startRunning()
    }

    /// Stops the video recording
    public func stopRecording() {
        session.stopRunning()
    }

    /// Sets the current camera to either the forward or backwards facing camera
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
            NSLog("Could not set the camera input")
            throw VideoStreamError.cameraInputError
        }
    }

    /// Requests for a photo to be taken
    ///
    /// Only one photo should be requested at a time, if this function is called before the callback to the previous call to `takePhoto` is called,
    /// the newer callback will be immediately called with a `PhotoAlreadyRequested` error. If there is no active video stream, the callback
    /// will be immediately called with a `NotRecording` error.
    /// - Parameter callback: Callback function that is called with the compressed jpg photo data, or the error that occurred
    public func takePhoto() {

        if !session.isRunning {
            NSLog("Cannot take a photo while not recording")
            delegate?.didTakePhoto(Result.failure(VideoStreamError.notRecording))
            return
        }

        photoRequested = true
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
            NSLog("Could not get the camera input")
            throw VideoStreamError.cameraInputError
        }

        return try AVCaptureDeviceInput(device: cameraInput)
    }
}

extension VideoStreamInteractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        if !photoRequested { return }
        photoRequested = false

        if delegate == nil { return }

        guard let image = getImage(from: sampleBuffer) else {
            NSLog("Could not get image from buffer")
            delegate?.didTakePhoto(.failure(VideoStreamError.photoExportError))
            return
        }

        guard let data = imagePostProcessing(on: image) else {
            NSLog("Could not process the collected image")
            delegate?.didTakePhoto(.failure(VideoStreamError.photoExportError))
            return
        }

        delegate?.didTakePhoto(.success(data))
    }

    func getImage(from sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            NSLog("Could not get image buffer")
            return nil
        }

        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly) }
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(imageBuffer),
            width: CVPixelBufferGetWidth(imageBuffer),
            height: CVPixelBufferGetHeight(imageBuffer),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(imageBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue).rawValue
        ) else {
            NSLog("Could not get context")
            return nil
        }

        guard let cgImage = context.makeImage() else {
            NSLog("Could not make image")
            return nil
        }

        return cgImage
    }

    func imagePostProcessing(on baseImage: CGImage) -> Data? {
        // Some of the math here may initially look a bit off.
        // For some reason, the preview image comes w/ a 90 degree rotation
        // It's easiest to un-rotate the image at the end, but it makes the widths/heights confusing

        // First correct the aspect ratio of the image
        // TODO: conig
        let targetAspectRatio = Double(720)/Double(480)
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
            NSLog("Could not get cropped image")
            return nil
        }

        // Second, scale down the image to the proper size
        // TODO: config
        guard let context = CGContext(
            data: nil,
            width: 720,
            height: 480,
            bitsPerComponent: cropped.bitsPerComponent,
            bytesPerRow: cropped.bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue).rawValue
        ) else {
            NSLog("Could not get context")
            return nil
        }
        // TODO: config
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: 720, height: 480))

        guard let resized = context.makeImage() else {
            NSLog("Cant make image")
            return nil
        }

        // Third, export as a jpeg
        let image = UIImage(cgImage: resized, scale: 0, orientation: .right)
        // TODO: config
        return image.jpegData(compressionQuality: 0.5)
    }
}
