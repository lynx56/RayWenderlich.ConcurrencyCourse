import UIKit

final class TiltShiftOperation: Operation {
  var outputImage: UIImage?
  
  private var inputImage: UIImage?
  private static let context = CIContext()
  
  convenience init(image: UIImage) {
    self.init()
    inputImage = image
  }
  
  override func main() {
    guard !isCancelled else { return }
    
    guard let inputImage = inputImage ?? dependencies.compactMap({ ($0 as? ImageDataProvider)?.image }).last else { return }
    
    guard let filter = TiltShiftFilter(image: inputImage, radius: 3),
          let output = filter.outputImage,
          let cgImage = TiltShiftOperation.context.createCGImage(output, from: CGRect(origin: .zero, size: inputImage.size))
    else { return }
    
    outputImage = UIImage(cgImage: cgImage)
  }
}

extension TiltShiftOperation: ImageDataProvider {
  var image: UIImage? { return outputImage }
}
