import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Health Data Types
    private var hrvType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    }
    
    private var heartRateType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .heartRate)
    }
    
    private var restingHeartRateType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)
    }
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.ava.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        // Define the types we want to read from HealthKit
        var typesToRead: Set<HKObjectType> = []
        
        if let hrvType = hrvType { typesToRead.insert(hrvType) }
        if let heartRateType = heartRateType { typesToRead.insert(heartRateType) }
        if let restingHeartRateType = restingHeartRateType { typesToRead.insert(restingHeartRateType) }
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - Data Queries
    func getHRVData(startDate: Date, endDate: Date = Date(), completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        guard let hrvType = hrvType else {
            completion(nil, NSError(domain: "com.ava.healthkit", code: 3, userInfo: [NSLocalizedDescriptionKey: "HRV data type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (_, samples, error) in
            DispatchQueue.main.async {
                if let samples = samples as? [HKQuantitySample] {
                    completion(samples, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Check Authorization Status
    func checkAuthorizationStatus(completion: @escaping (HKAuthorizationStatus) -> Void) {
        guard let hrvType = hrvType else {
            completion(.notDetermined)
            return
        }
        
        let status = healthStore.authorizationStatus(for: hrvType)
        completion(status)
    }
    
    // MARK: - Background Delivery
    func enableBackgroundDelivery() {
        guard let hrvType = hrvType else { return }
        
        healthStore.enableBackgroundDelivery(
            for: hrvType,
            frequency: .hourly
        ) { success, error in
            if let error = error {
                print("Error enabling background delivery: \(error.localizedDescription)")
            }
        }
    }
}
