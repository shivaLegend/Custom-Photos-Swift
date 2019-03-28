import UIKit
import Photos


class ViewController: UIViewController {
  //Array of PHAsset type for storing photos
  @IBOutlet weak var photosCollectionView: UICollectionView!
  var dataArrayPHAsset = [PHAsset]()
  override func viewDidLoad() {
    super.viewDidLoad()
    photosCollectionView.delegate = self
    photosCollectionView.dataSource = self
    photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    
    getImages()
    
  }
  
  func getImages() {
//    let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
//    let assets = PHAsset.fetchAssets(with: nil)
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                     ascending: false)]
    fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                         PHAssetMediaType.image.rawValue,
                                         PHAssetMediaType.video.rawValue)
//    fetchOptions.fetchLimit = 100
    
    let assets = PHAsset.fetchAssets(with: fetchOptions)
    assets.enumerateObjects({ (object, count, stop) in
      // self.cameraAssets.add(object)
      self.dataArrayPHAsset.append(object)
      
    })
    
    //In order to get latest image first, we just reverse the array
//    self.dataArrayPHAsset.reverse()
    
    // To show photos, I have taken a UICollectionView
    self.photosCollectionView.reloadData()
  }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataArrayPHAsset.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
    
    let asset = dataArrayPHAsset[indexPath.row]
    print(asset)
    let manager = PHImageManager.default()
    if cell.tag != 0 {
      manager.cancelImageRequest(PHImageRequestID(cell.tag))
    }
    cell.tag = Int(manager.requestImage(for: asset,
                                        targetSize: CGSize(width: 120.0, height: 120.0),
                                        contentMode: .aspectFill,
                                        options: nil) { (result, _) in
                                          cell.photoImageView?.image = result
    })
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = self.view.frame.width * 0.32
    let height = self.view.frame.height * 0.179910045
    return CGSize(width: width, height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 2.5
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}


