import UIKit

final class PhotoCell: UICollectionViewCell {
  @IBOutlet private weak var imageView: UIImageView!

  func display(image: UIImage?) {
    DispatchQueue.main.async {
      self.imageView.image = image
    }
  }
}
