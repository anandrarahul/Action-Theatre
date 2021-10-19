//
//  VideoListNetworkService.swift
//  Action Theatre
//
//  Created by Rahul Anand on 09/10/21.
//

import Foundation

final class VideoListNetworkService {
    
    static func fetchVideoList(endpoint: URL, completion: @escaping ([VideoDetails]?, Error?) -> Void) {
        let decoder = JSONDecoder()
        URLSession.shared.dataTask(with: endpoint) { data, response, error in
            if let _ = error {
                completion(nil, VideoError.invalidResponse)
            } else {
                if let data = data {
                    let videoDetails = try? decoder.decode([VideoDetails].self, from: data)
                    completion(videoDetails, nil)
                } else {
                    completion(nil, VideoError.dataNotFound)
                }
            }
        }.resume()
        
    }
}

enum VideoError: Error {
    case unknown
    case invalidResponse
    case timeout
    case dataNotFound
}
