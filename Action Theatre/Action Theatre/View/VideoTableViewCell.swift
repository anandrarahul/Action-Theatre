//
//  VideoTableViewCell.swift
//  Action Theatre
//
//  Created by Rahul Anand on 08/10/21.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var titleLbl: UILabel!
    @IBOutlet weak private var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.image = UIImage(named: "noImage")
    }
    
    func updateCell(_ thumbnail: String?, _ title: String?, _ description: String?) {
        if let thumb = thumbnail {
            let thumbnailUrl = URL(string: thumb)!
            URLSession.shared.dataTask(with: thumbnailUrl) { data, response, error in
                DispatchQueue.main.async {
                    if let _ = error {
                        self.thumbnailImageView.image = UIImage(named: "noImage")
                    } else {
                        if let imageData = data {
                            self.thumbnailImageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }.resume()
        }
        if let title = title {
            self.titleLbl.text = title
        }
        if let description = description {
            self.descriptionLbl.text = description
        }
    }

}
