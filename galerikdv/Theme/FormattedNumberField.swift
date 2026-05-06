import SwiftUI
import UIKit

struct FormattedNumberField: UIViewRepresentable {
	@Binding var text: String
	let placeholder: String
	@Binding var isFocused: Bool
	var font: UIFont = .systemFont(ofSize: 22, weight: .bold)

	func makeUIView(context: Context) -> UITextField {
		let textField = UITextField()
		textField.delegate = context.coordinator
		textField.keyboardType = .numberPad
		textField.placeholder = placeholder
		textField.font = font
		textField.textColor = UIColor(Color.appInputText)
		textField.tintColor = UIColor(Color.appGreenDark)
		textField.borderStyle = .none
		textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return textField
	}

	func updateUIView(_ uiView: UITextField, context: Context) {
		if uiView.text != text {
			uiView.text = text
		}

		if isFocused, !uiView.isFirstResponder {
			uiView.becomeFirstResponder()
		} else if !isFocused, uiView.isFirstResponder {
			uiView.resignFirstResponder()
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(text: $text, isFocused: $isFocused)
	}

	final class Coordinator: NSObject, UITextFieldDelegate {
		@Binding var text: String
		@Binding var isFocused: Bool

		init(text: Binding<String>, isFocused: Binding<Bool>) {
			_text = text
			_isFocused = isFocused
		}

		func textFieldDidBeginEditing(_ textField: UITextField) {
			isFocused = true
		}

		func textFieldDidEndEditing(_ textField: UITextField) {
			isFocused = false
		}

		func textField(
			_ textField: UITextField,
			shouldChangeCharactersIn range: NSRange,
			replacementString string: String
		) -> Bool {
			let currentText = textField.text ?? ""
			guard let stringRange = Range(range, in: currentText) else { return false }

			let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
			let formatted = CurrencyFormatter.groupedInput(updatedText)

			text = formatted
			textField.text = formatted

			let endPosition = textField.endOfDocument
			textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)

			return false
		}
	}
}

