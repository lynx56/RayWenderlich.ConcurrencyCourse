import UIKit

class TiltShiftTableViewController: UITableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  private let operationQueue = OperationQueue()
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! PhotoCell
        
    guard let inputImage = UIImage(named: "\(indexPath.row).png") else { cell.display(image: nil); return cell }
   
    let filterOperation = TiltShiftOperation(image: inputImage)
    
    filterOperation.completionBlock = {
      DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath) as? PhotoCell else { return }
        cell.isLoading = false
        cell.display(image: filterOperation.outputImage)
      }
    }
    
    cell.isLoading = true
    cell.display(image: nil)
   
    operationQueue.addOperation(filterOperation)
      
    return cell
  }
}
