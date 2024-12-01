import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Bind search query to update filtered products
        $searchQuery
            .sink { [weak self] query in
                self?.filterProducts(by: query)
            }
            .store(in: &cancellables)

        fetchProducts()
    }

    func fetchProducts() {
        isLoading = true
        guard let url = URL(string: "https://app.getswipe.in/api/public/get") else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching products: \(error)")
                }
            }, receiveValue: { [weak self] products in
                let uniqueProducts = Array(Set(products.map { $0 }))
                self?.products = uniqueProducts
                self?.filteredProducts = uniqueProducts
            })
            .store(in: &cancellables)
    }

    func toggleFavorite(for product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isFavorite.toggle()
            sortProducts()
        }
    }

    private func filterProducts(by query: String) {
        if query.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
    }

    private func sortProducts() {
        products.sort { $0.isFavorite && !$1.isFavorite }
        filteredProducts = products
    }
}

