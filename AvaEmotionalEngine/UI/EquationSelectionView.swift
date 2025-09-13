import SwiftUI

struct EquationSelectionView: View {
    @ObservedObject private var metricsManager = MetricsManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(metricsManager.availableEquations, id: \.index) { equation in
                    Button(action: {
                        metricsManager.selectedEquationIndex = equation.index
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("\(equation.index). \(equation.name)")
                            Spacer()
                            if metricsManager.selectedEquationIndex == equation.index {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select KXRP Equation")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct EquationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EquationSelectionView()
    }
}
