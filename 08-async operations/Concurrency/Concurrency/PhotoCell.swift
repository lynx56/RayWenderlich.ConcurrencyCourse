import UIKit

final class PhotoCell: UITableViewCell {
  @IBOutlet private weak var theImageView: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoading: Bool {
        get { return activityIndicator.isAnimating }
        set { newValue == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating() }
    }
    
    func display(image: UIImage?) {
    theImageView.image = image
  }
}

