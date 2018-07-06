//
//  QRScannerViewController.swift
//  the-example-app.swift
//
//  Created by JP Wright on 06.07.18.
//  Copyright © 2018 Contentful. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol QRScannerDelegate {

    func shouldOpenScannedURL(_ url: URL) -> Bool
}

// Inspired by AppCoda's example: https://github.com/appcoda/QRCodeReader
class QRScannerViewController: UIViewController, CustomNavigable {

    let captureSession: AVCaptureSession

    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var qrCodeFrameView: UIView?

    let delegate: QRScannerDelegate

    var captureMetadataOutput: AVCaptureMetadataOutput?

    init(delegate: QRScannerDelegate) {
        self.captureSession = AVCaptureSession()
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput!)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput?.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        // Start video capture.
        captureSession.startRunning()

        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.frame.size = CGSize(width: 200.0, height: 200.0)
        qrCodeFrameView?.center = view.center

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }

    // MARK: CustomNavigable

    var prefersLargeTitles: Bool {
        return false
    }

    var hasCustomToolbar: Bool {
        return false
    }

}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = .zero
            return
        }

        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, let urlString = metadataObj.stringValue else { return }
        guard let url = URL(string: urlString) else {
            // TODO: Handle failure
            return
        }
        guard delegate.shouldOpenScannedURL(url) else {
            // Red flash on view?
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            self?.captureMetadataOutput?.setMetadataObjectsDelegate(nil, queue: nil)
            self?.captureMetadataOutput = nil

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
