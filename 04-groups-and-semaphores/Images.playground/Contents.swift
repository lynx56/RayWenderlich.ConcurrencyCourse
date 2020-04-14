//
// Dowloading images using DispatchGroup
//
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//Main
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

let base = "https://wolverine.raywenderlich.com/books/con/image-from-rawpixel-id-"
let ids = [ 466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052 ]

var images: [UIImage] = []

for id in ids {
    guard let url = URL(string: "\(base)\(id)-jpeg.jpg") else { continue }
    group.enter()
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
        defer { group.leave() }
        guard let data = data, let image = UIImage(data: data) else { return }
        
        images.append(image)
    }
    
    task.resume()
}
//group.notify(queue: queue) or group.wait for collect results

//Additional: display results
let view = UIView(frame: .init(origin: .zero, size: .init(width: 300, height: 500)))
view.backgroundColor = .white
PlaygroundPage.current.liveView = view
group.notify(queue: queue) {
    DispatchQueue.main.async {
        let imageView = UIImageView()
        imageView.frame = view.bounds.applying(.init(scaleX: 0.8, y: 0.8))
        imageView.center = view.center
        imageView.clipsToBounds = true
        imageView.animationImages = images
        imageView.layer.cornerRadius = 20
        imageView.animationDuration = 10
        imageView.startAnimating()
        view.addSubview(imageView)
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 10, execute: {
            imageView.stopAnimating()
            PlaygroundPage.current.finishExecution()
        })
    }
}
