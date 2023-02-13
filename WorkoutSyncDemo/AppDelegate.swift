//
//  AppDelegate.swift
//  WorkoutSyncDemo
//
//  Created by Kuba Suder on 13/02/2023.
//

import Cocoa
import HealthKit


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Sorry, HealthKit is not available")
            return
        }

        let dataTypes: Set<HKObjectType> = [HKObjectType.workoutType()]
        let healthStore = HKHealthStore()

        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { success, error in
            if success {
                print("HealthKit authorized")

                let query = HKSampleQuery(
                    sampleType: .workoutType(),
                    predicate: nil,
                    limit: 0,
                    sortDescriptors: [NSSortDescriptor(
                        key: HKSampleSortIdentifierEndDate,
                        ascending: false
                    )]
                ) { query, samples, error in
                    if let samples = samples as? [HKWorkout] {
                        print("Got \(samples.count) workouts:")

                        for workout in samples.prefix(upTo: 25) {
                            let type: String
                            switch workout.workoutActivityType {
                            case .running:
                                type = "running 🏃🏻‍♂️"
                            case .walking:
                                type = "walking 🚶🏻‍♂️"
                            case .hiking:
                                type = "hiking 🏔"
                            case .cycling:
                                type = "cycling 🚴🏻‍♂️"
                            default:
                                type = "other (\(workout.workoutActivityType.rawValue))"
                            }

                            let formatter = DateComponentsFormatter()
                            formatter.allowedUnits = [.hour, .minute]
                            formatter.unitsStyle = .abbreviated

                            print("At \(workout.startDate): \(type), time = \(formatter.string(from: workout.duration)!), distance = \(workout.totalDistance!)")
                        }
                    } else {
                        print("Error loading workouts: \(error?.localizedDescription ?? "")")
                    }
                }

                healthStore.execute(query)
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
            }
        }
    }

}

