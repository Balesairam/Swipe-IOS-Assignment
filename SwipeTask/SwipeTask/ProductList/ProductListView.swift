import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    @State var refreshProducts: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search products...", text: $viewModel.searchQuery)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Loading Indicator
                if viewModel.isLoading {
                    ProgressView("Loading Products...")
                        .padding()
                }

                // Product List
                List(viewModel.filteredProducts) { product in
                    ProductCard(product: product, toggleFavorite: {
                        viewModel.toggleFavorite(for: product)
                    })
                }
                .listStyle(PlainListStyle())

                // Navigation Link to Add Product
                NavigationLink(destination: AddProductView(refreshProducts: $refreshProducts)) {
                    Text("Add Product")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Products")
            .onAppear {
                viewModel.fetchProducts()
            }
            .onChange(of: refreshProducts) { newValue in
                if newValue {
                    viewModel.fetchProducts()
                    refreshProducts = false // Reset after refreshing
                }
            }
        }
    }
}


struct ProductCard: View {
    let product: Product
    let toggleFavorite: () -> Void

    var body: some View {
        HStack {
            if (product.imageUrl ?? "" == "") {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                AsyncImage(url: URL(string: product.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.2) // Placeholder background
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            ProgressView()
                        }
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                Text("Type: \(product.type)")
                    .font(.subheadline)
                Text("Price: $\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                Text("Tax: $\(product.tax, specifier: "%.2f")")
                    .font(.subheadline)
            }
            .padding(.leading, 8)

            Spacer()

            Button(action: toggleFavorite) {
                Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(product.isFavorite ? .red : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

