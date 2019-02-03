//
//  MessagesViewController.swift
//  Emoji MessagesExtension
//
//  Created by Aryaman Sharda on 1/7/19.
//  Copyright © 2019 Porsche Digital, Inc. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {

    @IBOutlet weak var stickerCollectionView: UICollectionView!

    var fileName = [String]()
    var stickers = [MSSticker]()

    let imageURLs = ["https://img.icons8.com/material/4ac144/256/folder.png",
                     "https://img.icons8.com/material/4ac144/256/print.png",
                     "https://img.icons8.com/material/4ac144/256/music.png"]

    override func viewDidLoad() {
        super.viewDidLoad()

        stickerCollectionView.delegate = self
        stickerCollectionView.dataSource = self

        for image in imageURLs {
            let lastPathComponent = (image as NSString).lastPathComponent
            self.fileName.append(lastPathComponent)

            self.createStickerFromRemoteImage(imageURL: image, fileName: lastPathComponent)
        }

        self.stickerCollectionView.reloadData()
    }

    func createStickerFromRemoteImage(imageURL: String, fileName: String) {

        var extensionType = "png"
        if fileName.contains("gif") {
            extensionType = "gif"
        }

        if let url = URL(string: imageURL) {
            if let data = try? Data(contentsOf: url) {
                let image = UIImage(data: data)

                if extensionType.contains("gif") {
                    var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
                    docURL = docURL?.appendingPathComponent( "\(fileName)") as NSURL?
                    do {
                        try data.write(to: docURL! as URL)

                        do {
                            let sticker = try MSSticker(contentsOfFileURL: docURL! as URL, localizedDescription: "\(fileName)")
                            stickers.append(sticker)
                        } catch {
                            print("Failed to add new sticker.")
                        }
                    } catch _ {

                    }
                } else {
                    if let fileSaveURL = saveImageToDisk(image: image!, fileName: "\(fileName)") {
                        do {
                            let sticker = try MSSticker(contentsOfFileURL: fileSaveURL, localizedDescription: "\(fileName)")
                            stickers.append(sticker)
                        } catch {
                            print("Failed to add new sticker.")
                        }
                    }
                }

            }
        }
    }

    func saveImageToDisk(image: UIImage, fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.relativePath) {
            return fileURL
        }

        if let data = image.pngData() {
            do {
                // Writes the image data to disk
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("error saving file:", error)
                return nil
            }
        }

        return nil
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class StickerCell: UICollectionViewCell {
    @IBOutlet var stickerView: MSStickerView!
}

extension MessagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
        cell.stickerView.sticker = stickers[indexPath.row]
        cell.stickerView.startAnimating()

        let stickerViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(stickerCellSelection))
        stickerViewTapGesture.name = "\(fileName[indexPath.row])"
        stickerViewTapGesture.delegate = self
        cell.stickerView.addGestureRecognizer(stickerViewTapGesture)

        return cell
    }


    @objc func stickerCellSelection(recognizer: UITapGestureRecognizer) {
        print("Selected Sticker:  \(recognizer.name!)")

        //Record the event as necessary
        // analytics.reportSelection(recognizer.name!), for example.
    }
}
