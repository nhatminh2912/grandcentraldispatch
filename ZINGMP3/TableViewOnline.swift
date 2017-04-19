//
//  TableViewOnline.swift
//  ZINGMP3
//
//  Created by Nhật Minh on 2/28/17.
//  Copyright © 2017 Nhật Minh. All rights reserved.
//

import UIKit
import MediaPlayer
let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first

class TableViewOnline: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listSongs = [Song]()
    
    var indexLink = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        getData()
        navigationController?.navigationBar.barTintColor = UIColor.clear
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        do
        {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch
        {
            
        }
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
            let audioPlay = AudioPlayer.sharedInstance
            audioPlay.pathString = self.listSongs[self.indexLink].sourceOnline
            audioPlay.titleSong = "\(self.listSongs[self.indexLink].title) Ca Si: \(self.listSongs[self.indexLink].artistName)"
            audioPlay.setupAudio()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setupObserverAudio"), object: nil)
            return .success
        })
    }
    
    @IBOutlet weak var myTableView: UITableView!
 
    func getData()
    {
        let data = NSData(contentsOf: NSURL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html") as! URL)
        let doc = TFHpple(htmlData: data as Data!)
        if let elements = doc?.search(withXPathQuery: "//h3[@class='title-item']/a") as? [TFHppleElement]
        {
            
            for element in elements
            {
                __dispatch_async(DispatchQueue.global() , {
                    let id  = self.getID(path: element.object(forKey: "href") as NSString)
                    let link = element.object(forKey: "href")!
                    let url = NSURL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    var stringData = ""
                    do
                    {
                        stringData = try String(contentsOf: url! as URL)
                    }
                    catch let error as NSError
                    {
                        print(error)
                    }
                    let json = self.convertStringToDictionay(string: stringData)
                    if json != nil
                    {
                        self.addSongToList(json: json!, link: link)
                    }
                    
                })
                
            }
        }
    }
    
    func swipe(sender: UISwipeGestureRecognizer)
    {
        __dispatch_async(DispatchQueue.main, {
            if let lyricView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lyricView") as? lyricVC
            {
                if let navigator = self.navigationController
                {
                    navigator.pushViewController(lyricView, animated: true)
                    
                }
            }
        })
    }
    
    func getID(path: NSString) -> String
    {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id
    }
    
    func convertStringToDictionay(string: String) -> [String: AnyObject]?
    {
        if let data = string.data(using: String.Encoding.utf8)
        {
            do
            {
                
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers ) as? [String: AnyObject]
                return json
            }
            catch
            {
                print("Ahaha")
            }
        }
        return nil
    }
    
    
    func addSongToList(json: [String:AnyObject], link: String)
    {
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = (json["source"] as! NSDictionary).value(forKey: "128") as! String
        let link = link
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source, link: link)
        listSongs.append(currentSong)
        __dispatch_async(DispatchQueue.main, {
            self.myTableView.reloadData()
        })
    }
    
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = listSongs[indexPath.row].title
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Download", handler: {(action, index) in
            __dispatch_async(DispatchQueue.global(), {
                self.downloadSong(index: indexPath.row)
            })
            __dispatch_async(DispatchQueue.main, {
                self.myTableView.reloadData()
            })
        })
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioPlay = AudioPlayer.sharedInstance
        print("AAAAAAAAAAAAA \(listSongs[indexPath.row].sourceOnline)")
        audioPlay.pathString = listSongs[indexPath.row].sourceOnline
        audioPlay.titleSong = "\(listSongs[indexPath.row].title) Ca Si: \(listSongs[indexPath.row].artistName)"
        audioPlay.setupAudio()
        indexLink = indexPath.row
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setupObserverAudio"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let passing = PassingLyric.sharedInstance
        let data = NSData(contentsOf: NSURL(string: "http://mp3.zing.vn\(listSongs[indexLink].link)") as! URL)
        let doc = TFHpple(htmlData: data as Data!)
        if let elements = doc?.search(withXPathQuery: "//p[@class='fn-wlyrics fn-content']") as? [TFHppleElement]
        {
            for element in elements
            {
               passing.lyric = element.content
            }
        }
        
    }
    
    func downloadSong(index: Int)
    {
        let dataSong = NSData(contentsOf: NSURL(string: listSongs[index].sourceOnline)! as URL)
        
        if let dir = kDOCUMENT_DIRECTORY_PATH
        {
        let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
        
        do
        {
            try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        writeDataToPath(data: dataSong!, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
        
        writeInfoSong(song: listSongs[index], path: pathToWriteSong)
        }
    }
    
    
    func writeInfoSong(song: Song, path: String)
    {
        let dicData = NSMutableDictionary()
        dicData.setValue(song.title, forKey: "title")
        dicData.setValue(song.artistName, forKey: "artistName")
        dicData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dicData.setValue(song.sourceOnline, forKey: "sourceOnline")
        dicData.setValue(song.link, forKey: "link")
        writeDataToPath(data: dicData, path: "\(path)/info.plist")
        
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!)
        writeDataToPath(data: dataThumbnail, path: "\(path)/thumbnail.png")
        
    }
    
    func writeDataToPath(data: NSObject, path: String)
    {
        if let dataToWrite = data as? NSData{
            dataToWrite.write(toFile: path, atomically: true)
        }
        else if let dataInfo = data as? NSDictionary
        {
            dataInfo.write(toFile: path, atomically: true)
        }
    }
    
    
    
    
    
}
