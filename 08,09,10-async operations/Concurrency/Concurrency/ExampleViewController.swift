import UIKit

final class ExampleViewController: UIViewController {
  @IBOutlet private weak var tilted: UIImageView!
  @IBOutlet private weak var label: UILabel!
  @IBOutlet private weak var spinner: UIActivityIndicatorView!

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    defer {
      spinner.stopAnimating()
    }

    let image = UIImage(named: "dark_road_small")!

    guard let filter = TiltShiftFilter(image: image, radius:3),
      let output = filter.outputImage else {
        label.text = "Failed to generate tilt shift image"
        return
    }

    let context = CIContext()

    guard let cgImage = context.createCGImage(output, from: CGRect(origin: .zero, size: image.size)) else {
      label.text = "No image generated"
      return
    }

    tilted.image = UIImage(cgImage: cgImage)

    label.isHidden = true
  }
}
