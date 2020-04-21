import UIKit

final class TiltShiftOperation: Operation {
  var outputImage: UIImage?
  
  private let inputImage: UIImage
  private static let context = CIContext()
  
  init(image: UIImage) {
      inputImage = image
      super.init()
  }
  
  override func main() {
    guard let filter = TiltShiftFilter(image: inputImage, radius: 3),
          let output = filter.outputImage,
          let cgImage = TiltShiftOperation.context.createCGImage(output, from: CGRect(origin: .zero, size: inputImage.size))
    else { return }
    
    outputImage = UIImage(cgImage: cgImage)
  }
}
