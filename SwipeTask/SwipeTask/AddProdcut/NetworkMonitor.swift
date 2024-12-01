import Network

// Monitor internet connectivity
class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected = false
    
    var connectionStatusChanged: ((Bool) -> Void)?
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.connectionStatusChanged?(self.isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    // Check if there's internet connection
    func isInternetAvailable() -> Bool {
        return isConnected
    }
}
