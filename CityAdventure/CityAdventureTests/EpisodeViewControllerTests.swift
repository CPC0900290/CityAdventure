//
//  EpisodeViewControllerTests.swift
//  CityAdventureTests
//
//  Created by Pin Chen on 2024/5/19.
//

import XCTest
import CoreLocation
@testable import CityAdventure

final class EpisodeViewControllerTests: XCTestCase {
  var viewModel: EpisodeViewModel!
  var mockDelegate: MockDelegate!
  var mockLocationManager: MockCLLocationManager!
  var mockUserDefaults: UserDefaults!
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    super.setUp()
    mockDelegate = MockDelegate()
    mockLocationManager = MockCLLocationManager()
    mockUserDefaults = UserDefaults(suiteName: #file)
    mockUserDefaults.set("EKTfK9RUZaRjSNN13PhUJPmfYJx1", forKey: "uid")
    
    viewModel = EpisodeViewModel(episode: createMockEpisode())
    viewModel.locationManager = mockLocationManager
    viewModel.delegate = mockDelegate
    viewModel.userDefault = mockUserDefaults
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    viewModel = nil
    mockDelegate = nil
    mockLocationManager = nil
    mockUserDefaults.removePersistentDomain(forName: #file)
    mockUserDefaults = nil
    super.tearDown()
  }
  
  func testFetchAnnotationsAndCoordinate() {
    viewModel.tasks = createMockTasks()
//    viewModel.fetchAnnotationsAndCoordinate()
    
    XCTAssertEqual(viewModel.taskAnnotations.count, 1)
    XCTAssertEqual(viewModel.taskCoordinates.count, 1)
    XCTAssertEqual(viewModel.taskAnnotations.first?.coordinate.latitude, 37.7749)
    XCTAssertEqual(viewModel.taskAnnotations.first?.coordinate.longitude, -122.4194)
  }
  
  func testGetDistanceToTask() {
    let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let distance = viewModel.getDistanceToTask(coordinate: coordinate)
    
    XCTAssertEqual(distance, 0, accuracy: 0.1)
  }
  
  func testConfigureTaskStatus() {
    viewModel.configureTaskStatus()
    
    let expectation = self.expectation(description: "fetchProfile")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      XCTAssertEqual(self.viewModel.taskStatus?.count, 3)
      XCTAssertTrue(self.viewModel.taskStatus?.first ?? false)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  // MARK: - Helper Methods
  func createMockEpisode() -> Episode {
    return Episode(title: "Episode Test",
                   content: "Welcome to Episode Test",
                   finishedTask: [],
                   area: "Test Place",
                   image: "test image",
                   tasks: ["{\"features\": [{\"geometry\": {\"coordinate\": [37.7749, -122.4194]}, \"properties\": {\"title\": \"Task 1\", \"locationName\": \"San Francisco\"}}]}"],
                   id: "84HPfQwsnCEjg56oMvXd")
  }
  
  func createMockTasks() -> [TaskLocations] {
    let geometry = Geometry(coordinates: nil, coordinate: [37.7749, -122.4194], type: "Point")
    let properties = Properties(
      id: "1",
      title: "Task 1",
      content: "Content for Task 1",
      locationName: "San Francisco",
      locationAddress: "123 Example St, San Francisco, CA",
      questionAnswerPair: nil,
      foodImage: nil,
      task3Question: nil
    )
    let locationPath = LocationPath(type: "Feature", properties: properties, geometry: geometry)
    let taskLocation = TaskLocations(type: "FeatureCollection", features: [locationPath])
    
    return [taskLocation]
  }
  
  class MockDelegate: EpisodeModelProtocol {
    func updatedDataModels() {
      // 模擬代理方法
    }
  }
  
  class MockCLLocationManager: CLLocationManager {
    override var location: CLLocation? {
      return CLLocation(latitude: 37.7749, longitude: -122.4194)
    }
  }
}
