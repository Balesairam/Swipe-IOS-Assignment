import SwiftUI

struct AddProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var refreshProducts: Bool
    @StateObject private var viewModel = AddProductViewModel()
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    // Product Type Picker
                    Section(header: Text("Product Type")) {
                        Picker("Select Product Type", selection: $viewModel.selectedType) {
                            Text("Select Type").tag(String?.none)
                            ForEach(viewModel.productTypes, id: \.self) { type in
                                Text(type).tag(type as String?)
                            }
                        }
                    }

                    // Product Name
                    Section(header: Text("Product Name")) {
                        TextField("Enter Product Name", text: $viewModel.productName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }

                    // Selling Price
                    Section(header: Text("Selling Price")) {
                        TextField("Enter Selling Price", text: $viewModel.sellingPrice)
                            .keyboardType(.decimalPad)
                    }

                    // Tax Rate
                    Section(header: Text("Tax Rate")) {
                        TextField("Enter Tax Rate", text: $viewModel.taxRate)
                            .keyboardType(.decimalPad)
                    }

                    // Product Image
                    Section(header: Text("Product Image (Optional)")) {
                        if let productImage = viewModel.productImage {
                            Image(uiImage: productImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Button(action: { isImagePickerPresented = true }) {
                            Text(viewModel.productImage == nil ? "Select Image" : "Change Image")
                        }
                    }
                }

                // Progress View
                if viewModel.isSubmitting {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    ProgressView("Submitting...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("Add Product")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        viewModel.submitProduct {
                            refreshProducts = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $viewModel.productImage, isPresented: $isImagePickerPresented)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Add Product"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
