/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

final class CollectionViewController: UICollectionViewController {
  private let cellSpacing: CGFloat = 1
  private let columns: CGFloat = 3
  private var cache: [IndexPath: UIImage] = [:]
  private var cellSize: CGFloat?
  private var urls: [URL] = []
  private lazy var queue = DispatchQueue(label: "xyz")
  
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
          let contents = try? Data(contentsOf: plist),
          let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
          let serialUrls = serial as? [String] else {
      print("Something went horribly wrong!")
      return
    }

    urls = serialUrls.compactMap { URL(string: $0) }
  }
}

// MARK: - Data source
extension CollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.urls.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "normal", for: indexPath) as! PhotoCell
  
    let cachedImage = cache[indexPath]
    cell.display(image: cachedImage)
   
    if cachedImage == nil {
     // downloadAtGlobalQueue(at: indexPath)
     // downloadByUrlSession(at: indexPath)
      downloadByWorkItem(at: indexPath)
    }
    
    return cell
  }
  
  func downloadAtGlobalQueue(at indexPath: IndexPath) {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      
      guard let data = try? Data(contentsOf: self.urls[indexPath.item]),
        let image = UIImage(data: data) else {
          return }
      
      DispatchQueue.main.async {
        let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCell
        cell?.display(image: image)
        self.cache[indexPath] = image
      }
    }
  }
  
  func downloadByWorkItem(at indexPath: IndexPath) {
    let backgroundWorkItem = DispatchWorkItem { [weak self, indexPath] in
      guard let self = self else { return }
      guard let data = try? Data(contentsOf: self.urls[indexPath.item]),
        let image = UIImage(data: data) else {
          return
      }
      self.cache[indexPath] = image
    }
    
    let updateUIWorkItem = DispatchWorkItem { [weak self, indexPath] in
      guard let self = self else { return }
      
      let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCell
      cell?.display(image: self.cache[indexPath])
    }
    
    backgroundWorkItem.notify(queue: DispatchQueue.main, execute: updateUIWorkItem)
    queue.async(execute: backgroundWorkItem)
  }
  

  func downloadByUrlSession(at indexPath: IndexPath) {
    URLSession.shared.dataTask(with: self.urls[indexPath.item]) { [weak self] (data, _, _) in
      guard let self = self else { print("oops1"); return }
      guard let data = data else { print("oops2"); return }
      guard let image = UIImage(data: data) else { print("oops3"); return }
      
      DispatchQueue.main.async {
        let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCell
        cell?.display(image: image)
        self.cache[indexPath] = image
      }
    }.resume()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if cellSize == nil {
      let layout = collectionViewLayout as! UICollectionViewFlowLayout
      let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (columns * cellSpacing - 1)
      cellSize = (view.frame.size.width - emptySpace) / columns
    }

    return CGSize(width: cellSize!, height: cellSize!)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return cellSpacing
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return cellSpacing
  }
}

