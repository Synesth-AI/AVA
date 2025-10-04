import SwiftUI

// Separate view for each equation row to simplify the main view
private struct EquationRowView: View {
    let equation: KXRPEquation
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(equation.index). \(equation.name)")
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .foregroundColor(.primary)
    }
}

struct EquationSelectionView: View {
    @ObservedObject private var metricsManager = MetricsManager.shared
    @Environment(\.presentationMode) private var presentationMode

    private func makeEquationRow(_ equation: KXRPEquation) -> some View {
        EquationRowView(
            equation: equation,
            isSelected: metricsManager.selectedEquationIndex == equation.id,
            action: {
                metricsManager.selectedEquationIndex = equation.id
                presentationMode.wrappedValue.dismiss()
            }
        )
    }

    private var doneButton: some View {
        Button("Done") {
            presentationMode.wrappedValue.dismiss()
        }
    }

    var body: some View {
        NavigationView {
            List(metricsManager.availableEquations) { equation in
                makeEquationRow(equation)
            }
            .navigationTitle("Select KXRP Equation")
        }
    }
}

struct EquationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EquationSelectionView()
    }
}
