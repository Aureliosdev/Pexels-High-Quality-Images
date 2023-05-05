//
//  ViewController.swift
//  Pexels High-Quality images
//
//  Created by Aurelio Le Clarke on 02.05.2023.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var mainSearchBar: UISearchBar!
    
    
    @IBOutlet weak var searchHistoryCollectionView: UICollectionView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var searchPhotoResponse: SearchPhotosResponse? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
            
        }
    }
    var photos: [Photo] {
        return searchPhotoResponse?.photos ?? []
    }
    let savedSearchTextArray: String = "SavedSearchTextArrayKey"
    
    var searchTextArray: [String] = [] {
        didSet {
            searchHistoryCollectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSearchBar.delegate = self
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        imageCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl?.addTarget(self, action: #selector(search), for: .valueChanged)
        
        let flowLayout =  searchHistoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        searchHistoryCollectionView.register(UINib(nibName: "SearchTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SearchTextCollectionViewCell.identifier)
        searchHistoryCollectionView.dataSource = self
        searchHistoryCollectionView.delegate  = self
        resetSearchTextArray()
    }
  
    
    
   @objc func search() {
        self.searchPhotoResponse = nil
        guard let searchText = mainSearchBar.text else {
            print("Searchbar text is nil")
            return
        }
        guard !searchText.isEmpty else {
            print("searchbar is empty")
            return
        }
        // save  searching text
       save(searchText: searchText)
       
        let endpoint = "https://api.pexels.com/v1/search"
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "20")
        ]
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        var urlRequest: URLRequest  = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let API_KEY = "t6W6BTDFfEWRyURJ47LS8eMEYw13MfC7wOHgXkoWKaK8dthZBLad8AWa"
        urlRequest.addValue(API_KEY, forHTTPHeaderField: "Authorization")
        
       if imageCollectionView.refreshControl?.isRefreshing == false {
           imageCollectionView.refreshControl?.beginRefreshing()
       }
       
        let session: URLSession = URLSession(configuration: .default)
        
        let dataTask: URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler: searchPhotoHandler(data: response: error:))
        
        dataTask.resume()
        
    }
    func searchPhotoHandler(data: Data?, response: URLResponse?, error: Error?) {
        print("Method was called")
        DispatchQueue.main.async { [weak self] in
            if self?.imageCollectionView.refreshControl?.isRefreshing == true {
                self?.imageCollectionView.refreshControl?.endRefreshing()
            }
        }
      
        if let error = error {
            print("Error \(error.localizedDescription)")
        }else if let data = data {
            do {
               let result =  try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                self.searchPhotoResponse = result
                print("Result - \(result)")
            }catch {
                print(error)
            }
        }
    }
    func save(searchText: String) {
        var existingArray = getSaveSearchTextArray()
        existingArray.append(searchText)
        UserDefaults.standard.set(existingArray, forKey: savedSearchTextArray)
        
        resetSearchTextArray()
        
    }
    func getSaveSearchTextArray() -> [String] {
        
        let array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArray) ?? []
        
        return array
    }
    func getSortedSearchTextArray() -> [String] {
        let savedSearchTextArray: [String] = getSaveSearchTextArray()
        let reversedSavedSearchTextArray: [String] = savedSearchTextArray.reversed()
        return reversedSavedSearchTextArray
    }
    func resetSearchTextArray() {
        // Теперь вместо значения метода getSortedSearchTextArray() присваевается значение другого метода getUniqueSearchTextArray()
        self.searchTextArray = getUniqueSearchTextArray()
    }
    func getUniqueSearchTextArray() -> [String] {
        
        // Создается константа и устанавливается начальное значение, где присваевается возвращаемое значение методом getSortedSearchTextArray()
        let sortedSearchTextArray: [String] = getSortedSearchTextArray()
        
        // Создается пустая переменная для хранения уникальных текстовых запросов
        var sortedSearchTextArrayWithUniqueValues: [String] = []
        
        // Идет итерация по каждомоу элементу массива 'sortedSearchTextArray'
        sortedSearchTextArray.forEach { searchText in
            
            // Идет проверка на отсутствия элемента в массиве 'sortedSearchTextArrayWithUniqueValues'
            // Метод 'contains' возвращает TRUE если 'searchText' уже содержится в массиве 'sortedSearchTextArrayWithUniqueValues'
            if !sortedSearchTextArrayWithUniqueValues.contains(searchText) {
                sortedSearchTextArrayWithUniqueValues.append(searchText)
            }
        }
        // Возвращает массив с уникальныеми текстами
        return sortedSearchTextArrayWithUniqueValues
    }
}


extension ViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search() 
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        
        switch collectionView {
        case imageCollectionView:
            let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
            cell.setup(photo: self.photos[indexPath.item])
            return cell
        case searchHistoryCollectionView:
            let cell = searchHistoryCollectionView.dequeueReusableCell(withReuseIdentifier: SearchTextCollectionViewCell.identifier, for: indexPath) as! SearchTextCollectionViewCell
            cell.set(title: searchTextArray[indexPath.item ])
            return cell
        default:
          return UICollectionViewCell()
        }
         
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case imageCollectionView:
            return photos.count
        case searchHistoryCollectionView:
            return searchTextArray.count
        default :
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout: UICollectionViewFlowLayout? = (collectionViewLayout as? UICollectionViewFlowLayout)
    
        let horizontalSpacing:  CGFloat = (flowLayout?.minimumInteritemSpacing ?? 0) + imageCollectionView.contentInset.left + imageCollectionView.contentInset.right
        
        let width: CGFloat = (collectionView.frame.width - horizontalSpacing) / 2
        
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        
        case imageCollectionView:
            let photo = self.photos[indexPath.item]
            let url = photo.src.large2X
            
            let vc = ImageViewController(imageURL: url)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case searchHistoryCollectionView:
            // Извлекаем текст из массива 'searchTextArray' c соответсвтующим индексом
            let searchText: String = searchTextArray[indexPath.item]
            // Для свойства 'text' у 'searchBar' присваеваем ранее извлеченный текст
            mainSearchBar.text = searchText
            // Вызываем метод search(), который отправляет запрос для поиска изображений по тексту в поисковой панели
            search()
            
        default:
            ()
        }
      
    }
}
