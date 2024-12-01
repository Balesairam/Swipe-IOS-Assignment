import SwiftUI
import Combine
import Network

class AddProductViewModel: ObservableObject {
    @Published var productName: String = ""
    @Published var sellingPrice: String = ""
    @Published var taxRate: String = ""
    @Published var selectedType: String? = nil
    @Published var productImage: UIImage? = nil
    @Published var isSubmitting: Bool = false
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false

    let productTypes = ["Electronics", "Clothing", "Furniture", "Books", "Other"]
    private let apiEndpoint = "https://app.getswipe.in/api/public/add"

    var isFormValid: Bool {
        guard let _ = Double(sellingPrice), let _ = Double(taxRate) else { return false }
        return !(productName.isEmpty || selectedType == nil)
    }

    func submitProduct(onSuccess: @escaping () -> Void) {
        guard let sellingPriceValue = Double(sellingPrice),
              let taxRateValue = Double(taxRate),
              let selectedType = selectedType else {
            alertMessage = "Please fill all required fields correctly."
            showAlert = true
            return
        }

        isSubmitting = true

        // Prepare the product data
        var body: [String: Any] = [
            "product_name": productName,
            "product_type": selectedType,
            "price": sellingPriceValue,
            "tax": taxRateValue
        ]

        // Add the image if available
        if let productImage = productImage,
           let imageData = productImage.jpegData(compressionQuality: 0.8) {
            body["image"] = imageData.base64EncodedString()
        }

        // Use the NetworkMonitor to check for internet connection
        let networkMonitor = NetworkMonitor()
        if networkMonitor.isInternetAvailable() {
            // There is internet, so submit the product
            uploadProductToServer(body: body, onSuccess: onSuccess)
        } else {
            // No internet, save the product locally
            let product = Product(name: productName, type: selectedType, price: sellingPriceValue, tax: taxRateValue, imageUrl: nil)
            saveProductLocally(product: product)
            alertMessage = "Product saved locally. Will upload once connected to the internet."
            showAlert = true
            isSubmitting = false
        }
    }

    // Function to upload the product to the server
    func uploadProductToServer(body: [String: Any], onSuccess: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: apiEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create body
        request.httpBody = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSubmitting = false

                if let error = error {
                    self.alertMessage = "Failed to submit: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }

                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.alertMessage = "Failed to submit product. Please try again."
                    self.showAlert = true
                    return
                }

                self.alertMessage = "Product added successfully!"
                self.showAlert = true
                onSuccess()
            }
        }.resume()
    }

    // Function to save product to UserDefaults
    func saveProductLocally(product: Product) {
        var products = loadSavedProducts()
        products.append(product)
        if let encoded = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(encoded, forKey: "savedProducts")
        }
    }

    // Function to load products from UserDefaults
    func loadSavedProducts() -> [Product] {
        guard let savedData = UserDefaults.standard.data(forKey: "savedProducts"),
              let decodedProducts = try? JSONDecoder().decode([Product].self, from: savedData) else {
            return []
        }
        return decodedProducts
    }


}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
