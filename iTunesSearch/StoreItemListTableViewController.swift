

import UIKit

class StoreItemListTableViewController: UITableViewController {
    
    var storeItemController = StoreItemController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmantedControl: UISegmentedControl!
    
    var items = [StoreItem]()
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func fetchMatchingItems() {
        
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        let mediaType = queryOptions[segmantedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            
            // set up query dictionary
            let query = [
                "term": searchTerm,
                "media": mediaType,
                "lang": "en_us",
                "limit": "10"
            ]
            
            // use the item controller to fetch items
            // if successful, use the main queue to set self.items and reload the table view
            // otherwise, print an error to the console
            Task {
                do {
                    let items = try await storeItemController.fetchItems(matching: query)
                    self.items = items
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func configure(cell: ItemCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        // set cell.name to the item's name
        cell.name = item.name
        
        // set cell.artist to the item's artist
        cell.artist = item.artist
        
        // set cell.artworkImage to nil
        cell.artworkImage = nil
        
        // initialize a network task to fetch the item's artwork keeping track of the task
        // in imageLoadTasks so they can be cancelled if the cell will not be shown after
        // the task completes.
        imageLoadTasks[indexPath] = Task {
            do {
                let image = try await storeItemController.fetchImage(from: item.artworkURL)
                cell.artworkImage = image
            } catch {
                print("Error fetching image: \(error)")
            }
            
            imageLoadTasks[indexPath] = nil
        }
        // if successful, set the cell.artworkImage using the returned image
        
        
    }
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cancel the image fetching task if we no longer need it
        imageLoadTasks[indexPath]?.cancel()
    }
}

extension StoreItemListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}
