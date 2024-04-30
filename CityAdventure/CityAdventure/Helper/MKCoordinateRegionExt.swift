//
//  MKCoordinateRegionExt.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/29.
//

import Foundation
import MapKit
extension MKCoordinateRegion {
  init(coordinates: [CLLocationCoordinate2D]) {
    let minLat = coordinates.min(by: { $0.latitude < $1.latitude })?.latitude ?? 0
    let maxLat = coordinates.max(by: { $0.latitude < $1.latitude })?.latitude ?? 0
    let minLon = coordinates.min(by: { $0.longitude < $1.longitude })?.longitude ?? 0
    let maxLon = coordinates.max(by: { $0.longitude < $1.longitude })?.longitude ?? 0
    
    // 計算中心點
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
    
    // 計算跨度，並確保有一個最小的跨度值
    let minSpan = 0.01 // 最小跨度值，避免跨度太小
    let latitudeDelta = max((maxLat - minLat) * 1.1, minSpan)
    let longitudeDelta = max((maxLon - minLon) * 1.1, minSpan)
    let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    self.init(center: center, span: span)
  }
}
