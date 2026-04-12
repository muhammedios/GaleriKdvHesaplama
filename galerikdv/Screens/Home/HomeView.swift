import SwiftUI
import UIKit

struct HomeView: View {
    @Environment(\.openURL) private var openURL

    @StateObject private var viewModel = HomeViewModel()
    @State private var focusedField: Field?
    @State private var isInfoMenuVisible = false
    @State private var showInputWarning = false

    private let privacyURL = URL(string: "https://muhammedylmz.com/hesaplama/gizlilik")
    private let termsURL = URL(string: "https://muhammedylmz.com/hesaplama/kosullar")

    private enum Field {
        case buyPrice
        case sellPrice
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appScreen, Color.appSurfaceLow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
                .onTapGesture {
                    isInfoMenuVisible = false
                    dismissKeyboard()
                }

            RadialGradient(
                colors: [Color.appAmbientMint.opacity(0.22), .clear],
                center: .top,
                startRadius: 40,
                endRadius: 340
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    modeGrid
                    formCard
                    resultCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded {
                    guard focusedField != nil else { return }
                    isInfoMenuVisible = false
                    dismissKeyboard()
                }
            )

            if isInfoMenuVisible {
                infoAlertOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(20)
            }
        }
        .animation(.spring(response: 0.30, dampingFraction: 0.82), value: isInfoMenuVisible)
        .alert("Uyarı", isPresented: $showInputWarning) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Şahıstan Alış için alış ve satış alanlarının ikisi de dolu olmalı.")
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Galeri KDV Hesaplama")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.appTitle)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                    isInfoMenuVisible.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 32, height: 32)

                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appInfo)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Bilgi")
        }
    }

    private var infoAlertOverlay: some View {
        ZStack {
            Button {
                isInfoMenuVisible = false
            } label: {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
            }
            .buttonStyle(.plain)

            VStack(spacing: 12) {
                Text("Bilgi")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTitle)

                Button {
                    isInfoMenuVisible = false
                    if let privacyURL {
                        openURL(privacyURL)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Gizlilik")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.appTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.appSurfaceLowest)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    isInfoMenuVisible = false
                    if let termsURL {
                        openURL(termsURL)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Koşullar")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.appTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.appSurfaceLowest)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

            }
            .padding(16)
            .frame(width: 286)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.16), radius: 18, y: 8)
            .onTapGesture {
                // Prevent taps inside alert card from falling through to the backdrop.
            }
        }
    }

    private var modeGrid: some View {
        VStack(spacing: 14) {
            GeometryReader { proxy in
                let cardWidth = (proxy.size.width - 12) / 2

                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        modeSelectionButton(.ihaledenAlis)
                        modeSelectionButton(.galeridenAlis)
                    }

                    HStack {
                        Spacer(minLength: 0)
                        modeSelectionButton(.sahistanAlis)
                            .frame(width: cardWidth)
                        Spacer(minLength: 0)
                    }
                }
            }
            .frame(height: 186)

            if viewModel.selectedMode != .sahistanAlis {
                if viewModel.selectedMode == .galeridenAlis {
                    HStack(spacing: 12) {
                        vatButton(rate: 1)
                        vatButton(rate: 20)
                        specialMatrahButton
                    }
                } else {
                    HStack(spacing: 12) {
                        vatButton(rate: 1)
                        vatButton(rate: 20)
                    }
                }
            }
        }
    }

    private func modeSelectionButton(_ mode: CalculatorMode) -> some View {
        let isSelected = mode == viewModel.selectedMode

        return Button {
            viewModel.selectedMode = mode
            if mode == .sahistanAlis {
                viewModel.selectedVatRate = 20
                viewModel.isSpecialMatrahSelected = false
            } else if mode != .galeridenAlis {
                viewModel.isSpecialMatrahSelected = false
            }
        } label: {
            VStack(spacing: 5) {
                Text(mode.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? Color.white : Color.appTitle)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(mode.subtitle)
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(0.8)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.70) : Color.appMuted.opacity(0.55))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 88)
            .background(isSelected ? Color.appGreen : Color.appSurfaceLowest)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: isSelected ? Color.appGreen.opacity(0.20) : Color.appGreenDark.opacity(0.06), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func vatButton(rate: Int) -> some View {
        let isSelected = !viewModel.isSpecialMatrahSelected && viewModel.selectedVatRate == rate
        let isLocked = viewModel.selectedMode == .sahistanAlis

        return Button {
            guard !isLocked else { return }
            viewModel.selectedVatRate = rate
            viewModel.isSpecialMatrahSelected = false
        } label: {
            Text("%\(rate)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(isSelected && !isLocked ? Color.white : Color.appTitle)
                .frame(maxWidth: .infinity, minHeight: 68)
                .background(isSelected && !isLocked ? Color.appGreen : Color.appSurfaceLowest)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected || isLocked ? Color.clear : Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: isSelected && !isLocked ? Color.appGreen.opacity(0.20) : Color.appGreenDark.opacity(0.06), radius: 10, y: 5)
                .opacity(isLocked ? 0.55 : 1)
        }
        .disabled(isLocked)
        .buttonStyle(.plain)
    }

    private var specialMatrahButton: some View {
        let isSelected = viewModel.isSpecialMatrahSelected

        return Button {
            viewModel.isSpecialMatrahSelected = true
        } label: {
            Text("KDV siz")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(isSelected ? Color.white : Color.appTitle)
                .frame(maxWidth: .infinity, minHeight: 68)
                .background(isSelected ? Color.appGreen : Color.appSurfaceLowest)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.appOutlineVariant.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: isSelected ? Color.appGreen.opacity(0.20) : Color.appGreenDark.opacity(0.06), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            if shouldShowBuyPriceInput {
                inputSection(
                    title: "ALIŞ FİYATI",
                    text: Binding(
                        get: { viewModel.buyPrice },
                        set: { viewModel.updateBuyPrice($0) }
                    ),
                    field: .buyPrice
                )
                .transition(.opacity)
            }
            inputSection(
                title: "SATIŞ FİYATI",
                text: Binding(
                    get: { viewModel.sellPrice },
                    set: { viewModel.updateSellPrice($0) }
                ),
                field: .sellPrice
            )

            HStack(spacing: 12) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("Sıfırla")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Color.appTitle)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Button {
                    if viewModel.selectedMode == .sahistanAlis, !bothInputsFilled {
                        showInputWarning = true
                    } else {
                        viewModel.calculate()
                    }
                } label: {
                    Text("Hesapla")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.appGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.appGreen.opacity(0.22), radius: 14, y: 8)
                }
            }
            .padding(.top, 8)
        }
        .padding(22)
        .background(Color.appSurfaceLowest.opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(Color.appOutlineVariant.opacity(0.42), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.appGreenDark.opacity(0.11), radius: 20, y: 9)
        .animation(.easeInOut(duration: 0.2), value: shouldShowBuyPriceInput)
    }

    private var shouldShowBuyPriceInput: Bool {
        viewModel.selectedMode != .ihaledenAlis && viewModel.selectedMode != .galeridenAlis
    }

    private var bothInputsFilled: Bool {
        !viewModel.buyPrice.filter(\.isNumber).isEmpty && !viewModel.sellPrice.filter(\.isNumber).isEmpty
    }

    private var resultCard: some View {
        VStack(spacing: 20) {
            Text("HESAPLANAN DEĞER")
                .font(.system(size: 14, weight: .heavy))
                .tracking(3)
                .foregroundStyle(Color.appResultLabel)

            Text(CurrencyFormatter.format(viewModel.outputValue))
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(Color.appGreenDark)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 22)
        .background(Color.appSurfaceLowest)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.appGreenDark.opacity(0.08), radius: 24, y: 14)
    }

    private func inputSection(title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.appMuted)

            HStack(spacing: 12) {
                Text("₺")
                    .font(.system(size: 21, weight: .heavy))
                    .foregroundStyle(Color.appMuted)

                FormattedNumberField(
                    text: text,
                    placeholder: "0",
                    isFocused: Binding(
                        get: { focusedField == field },
                        set: { isFocused in
                            focusedField = isFocused ? field : nil
                        }
                    )
                )
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .background(Color.appSurfaceLowest)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appGreen.opacity(0.58), lineWidth: 2.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = field
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

private struct FormattedNumberField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .numberPad
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 22, weight: .bold)
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
