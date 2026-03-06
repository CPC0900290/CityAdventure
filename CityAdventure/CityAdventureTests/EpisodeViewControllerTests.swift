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
  var mockFireStoreManager: MockFireStoreManager!

  override func setUpWithError() throws {
    super.setUp()
    mockDelegate = MockDelegate()
    mockLocationManager = MockCLLocationManager()
    mockUserDefaults = UserDefaults(suiteName: #file)
    mockUserDefaults.set("mock-user-id-for-testing", forKey: "uid")
    mockFireStoreManager = MockFireStoreManager()

    viewModel = EpisodeViewModel(episode: createMockEpisode())
    viewModel.locationManager = mockLocationManager
    viewModel.delegate = mockDelegate
    viewModel.userDefault = mockUserDefaults
    viewModel.fireStoreManager = mockFireStoreManager
  }

  override func tearDownWithError() throws {
    viewModel = nil
    mockDelegate = nil
    mockLocationManager = nil
    mockUserDefaults.removePersistentDomain(forName: #file)
    mockUserDefaults = nil
    mockFireStoreManager = nil
    super.tearDown()
  }

  func testFetchAnnotationsAndCoordinate() {
    viewModel.tasks = createMockTasks()

    XCTAssertEqual(viewModel.taskAnnotations.count, 1)
    XCTAssertEqual(viewModel.taskCoordinates.count, 1)
    XCTAssertEqual(viewModel.taskAnnotations.first?.coordinate.latitude, 37.7749)
    XCTAssertEqual(viewModel.taskAnnotations.first?.coordinate.longitude, -122.4194)
  }

  func testGetDistanceToTask() {
    if let coordinate = viewModel.taskCoordinates.first {
      let distance = viewModel.getDistanceToTask(coordinate: coordinate)
      XCTAssertEqual(distance, 0, accuracy: 0.1)
    }
  }

  func testConfigureTaskStatus() {
    let mockProfile = Profile(
      nickName: "Test User",
      titleName: "Tester",
      avatar: "",
      adventuringEpisode: [AdventuringEpisode(episodeID: "mock-episode-id-for-testing",
                                              taskStatus: [true, false, false])],
      finishedEpisodeID: [],
      userID: "mock-user-id-for-testing",
      documentID: "mock-doc-id"
    )

    viewModel.configureTaskStatus(with: mockProfile)

    XCTAssertEqual(viewModel.taskStatus?.count, 3)
    XCTAssertTrue(viewModel.taskStatus?[0] ?? false)
    XCTAssertFalse(viewModel.taskStatus?[1] ?? true)
    XCTAssertFalse(viewModel.taskStatus?[2] ?? true)
  }

  // MARK: - Helper Methods
  func createMockEpisode() -> Episode {
    return Episode(title: "Episode Test",
                   content: "Welcome to Episode Test",
                   finishedTask: [],
                   area: "Test Place",
                   image: "test image",
                   tasks: ["{\"features\": [{\"geometry\": {\"coordinate\": [37.7749, -122.4194]}, \"properties\": {\"title\": \"Task 1\", \"locationName\": \"San Francisco\"}}]}"],
                   id: "mock-episode-id-for-testing")
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

  // MARK: - Mock Classes
  class MockDelegate: EpisodeModelProtocol {
    func updatedDataModels() {}
  }

  class MockCLLocationManager: CLLocationManager {
    override var location: CLLocation? {
      return CLLocation(latitude: 37.7749, longitude: -122.4194)
    }
  }

  class MockFireStoreManager: FireStoreManaging {
    func filterDocument(collection: String,
                        field: String,
                        with: String,
                        sendSnapshot: @escaping (DocumentSnapshot) -> Void) {
      // No-op: tests that need Firebase data use configureTaskStatus(with:) directly
    }
  }
}
