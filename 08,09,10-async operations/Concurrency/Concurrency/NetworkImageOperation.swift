import UIKit

typealias ImageOperationCopmpletion = ((Data?, URLResponse?, Error?) -> Void)?

class NetworkImageOperation: AsyncOperation {
  var image: UIImage?
  
  private let completion: ImageOperationCopmpletion
  private let url: URL
  private var task: URLSessionTask?
  
  init(url: URL, completion: ImageOperationCopmpletion = nil) {
    self.url = url
    self.completion = completion
    
    super.init()
  }
  
  convenience init?(urlString: String, completion: ImageOperationCopmpletion = nil) {
    guard let url = URL(string: urlString) else { return nil }

    self.init(url: url, completion: completion)
  }
  
  override func main() {
    guard !self.isCancelled else { return }
    
    task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      guard let self = self else { return }
      defer { self.state = .finished }
     
      if let completion = self.completion {
        completion(data, response, error)
        return
      }
      
      guard error == nil, let data = data else { return }
           
      self.image = UIImage(data: data)
    }
    
    task?.resume()
  }
  
  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}

extension NetworkImageOperation: ImageDataProvider { }
