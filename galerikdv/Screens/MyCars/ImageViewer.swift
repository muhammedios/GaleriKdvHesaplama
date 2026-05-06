import SwiftUI
import UIKit

struct ImageViewer: View {
	let images: [UIImage]
	let startIndex: Int

	@Environment(\.dismiss) private var dismiss
	@State private var index: Int = 0

	var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()

			if images.isEmpty {
				Text("Görsel yok")
					.foregroundStyle(Color.white.opacity(0.8))
			} else {
				TabView(selection: $index) {
					ForEach(images.indices, id: \.self) { i in
						ZoomableImageView(image: images[i])
							.tag(i)
					}
				}
				.tabViewStyle(.page(indexDisplayMode: .always))
				.indexViewStyle(.page(backgroundDisplayMode: .always))
			}

			VStack {
				HStack {
					Button {
						dismiss()
					} label: {
						Image(systemName: "xmark")
							.font(.system(size: 16, weight: .bold))
							.foregroundStyle(Color.white)
							.padding(12)
							.background(Color.white.opacity(0.15))
							.clipShape(Circle())
					}
					.buttonStyle(.plain)

					Spacer()

					if !images.isEmpty {
						Text("\(index + 1)/\(images.count)")
							.font(.system(size: 14, weight: .bold))
							.foregroundStyle(Color.white.opacity(0.85))
							.padding(.horizontal, 12)
							.padding(.vertical, 8)
							.background(Color.white.opacity(0.12))
							.clipShape(Capsule())
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)

				Spacer()
			}
		}
		.onAppear {
			index = min(max(startIndex, 0), max(images.count - 1, 0))
		}
	}
}

struct ZoomableImageView: UIViewRepresentable {
	let image: UIImage

	func makeUIView(context: Context) -> UIScrollView {
		let scrollView = UIScrollView()
		scrollView.minimumZoomScale = 1
		scrollView.maximumZoomScale = 4
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.backgroundColor = .black
		scrollView.delegate = context.coordinator

		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(imageView)

		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
			imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
		])

		return scrollView
	}

	func updateUIView(_ uiView: UIScrollView, context: Context) {
		uiView.zoomScale = 1
		if let imageView = uiView.subviews.compactMap({ $0 as? UIImageView }).first {
			imageView.image = image
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	final class Coordinator: NSObject, UIScrollViewDelegate {
		func viewForZooming(in scrollView: UIScrollView) -> UIView? {
			scrollView.subviews.first
		}
	}
}

