//
//  ScannerView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/20/24.
//

import SwiftUI
import VisionKit
import Vision

struct ScannerView: UIViewControllerRepresentable {
    var onScanComplete: (Result<[String], Error>) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onScanComplete: onScanComplete)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onScanComplete: (Result<[String], Error>) -> Void

        init(onScanComplete: @escaping (Result<[String], Error>) -> Void) {
            self.onScanComplete = onScanComplete
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
            onScanComplete(.failure(error))
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            var scannedTexts: [String] = []
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                let recognizedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
                scannedTexts.append(contentsOf: recognizedTexts)
            }
            request.recognitionLevel = .accurate

            let images = (0..<scan.pageCount).compactMap { scan.imageOfPage(at: $0).cgImage }
            let handler = VNImageRequestHandler(cgImage: images.first!, options: [:])

            do {
                try handler.perform([request])
                onScanComplete(.success(scannedTexts))
            } catch {
                onScanComplete(.failure(error))
            }
        }
    }
}
