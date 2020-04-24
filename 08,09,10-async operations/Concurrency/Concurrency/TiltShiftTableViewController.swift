import UIKit

class TiltShiftTableViewController: UITableViewController {
  private var urls = [URL]()
  private let operationQueue = OperationQueue()
  private var operations: [IndexPath: [Operation]] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
      let contents = try? Data(contentsOf: plist),
      let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
      let serialUrls = serial as? [String]
      else { assertionFailure("Problem with photos"); return }
    
    urls = serialUrls.compactMap(URL.init)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return urls.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! PhotoCell
    
    let networkLoadImageOperation = NetworkImageOperation(url: urls[indexPath.row])
    let tiltShiftOperation = TiltShiftOperation()
    tiltShiftOperation.addDependency(networkLoadImageOperation)
    
    tiltShiftOperation.completionBlock = {
      DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath) as? PhotoCell else { return }
        cell.isLoading = false
        cell.display(image: tiltShiftOperation.image)
      }
    }
    
    cell.isLoading = true
    cell.display(image: nil)
    
    operationQueue.addOperation(networkLoadImageOperation)
    operationQueue.addOperation(tiltShiftOperation)
    
    operations[indexPath]?.forEach { $0.cancel() }
    operations[indexPath] = [networkLoadImageOperation, tiltShiftOperation]
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    operations[indexPath]?.forEach { $0.cancel() }
  }
}
