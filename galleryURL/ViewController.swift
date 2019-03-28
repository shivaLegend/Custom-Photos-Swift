import UIKit
import Photos
import AVKit


class ViewController: UIViewController {
  //Array of PHAsset type for storing photos
  @IBOutlet weak var photosCollectionView: UICollectionView!
  
  //TODO: -Create variables
  var dataArrayPHAsset = [PHAsset]()
  var arrayLocalString = [String]()
  
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
    
    //Get image & Video, so we have to create Descriptor
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
      self.arrayLocalString.append(object.localIdentifier)
    })
    
    //In order to get latest image first, we just reverse the array
    //    self.dataArrayPHAsset.reverse()
    
    // To show photos, I have taken a UICollectionView
    self.photosCollectionView.reloadData()
  }
}

//MARK: Collection View Datasource & Delegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataArrayPHAsset.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
    
    let asset = dataArrayPHAsset[indexPath.row]
    
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
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(arrayLocalString[indexPath.row])
    let identifier = arrayLocalString[indexPath.row]
    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
    guard let asset = assets.firstObject as? PHAsset
      else { fatalError("no asset") }
//    playVideo(asset: asset)
    takeDataImageThumbnail(asset: asset)
  }
  
  //MARK: -Take data image when click * video
  func takeDataImageThumbnail(asset: PHAsset) -> Data{
    let option = PHImageRequestOptions()
    var data = Data()
    option.isNetworkAccessAllowed = true
    let requestID = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 120.0, height: 120.0), contentMode: .aspectFill, options: nil) { (result, _) in
      data = (result?.jpegData(compressionQuality: 1.0))!
    }
    return data
  }
  
  func playVideo(asset: PHAsset) {
    
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    let requestID = PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
      guard let item = playerItem else { fatalError("can't get player item: \(info)") }
      
        // send the item to whatever you're playing AV content with, e.g.
      let myAVPlayerViewController = AVPlayerViewController()
        myAVPlayerViewController.player = AVPlayer(playerItem: item)
      self.present(myAVPlayerViewController, animated: true) {
        myAVPlayerViewController.player?.play()
      }
    }
    )
  }
}


