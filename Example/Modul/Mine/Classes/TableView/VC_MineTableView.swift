//Created  on 2019/3/16 by  LCD:https://github.com/liucaide .

/***** 模块文档 *****
 *
 */




import UIKit
import CaamDau
import Util
//import RxSwift
//import RxCocoa


extension VC_MineTableView {
    static func show() -> VC_MineTableView {
        return VC_MineTableView.cd_storyboard( "MineStoryboard", from: "Mine") as! VC_MineTableView
    }
    static func push() {
        let vc = VC_MineTableView.show()
        CD.push(vc)
    }
}

class VC_MineTableView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabbar: CD_TopBar!
    var vm:VM_MineTableView = VM_MineTableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cd.navigationBar(hidden: true)
        self.vm.blockRequest = { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.cd
                .mjRefreshTypes(self!.vm.refreshTypes)
        }
        
        self.tableView.cd
            .estimatedAll()
            .headerMJGifWithModel({ [weak self] in
                self?.vm.requestData(true)
            }, model: self.vm.modelMj)
            .footerMJAutoWithModel({ [weak self] in
                self?.vm.requestData(false)
            })
            .mjRefreshTypes(self.vm.refreshTypes)
            .background(Config.color.bg)
        
        
        makeCounDown()
    }
    var obs:NSObjectProtocol?
    func makeCounDown(){
        /// 输出
        obs = CD.notice.addObserver(forName: Notification.Name(rawValue: "VC_MineTableView"), object: nil, queue: nil, using: { [weak self](n) in
            if let model = n.userInfo?["VC_MineTableView"] as? CD_Timer.Model {
                self?.tabbar._title = "\(model.day)天\(model.hour):\(model.minute):\(model.second)"
            }
        })
        /// 输入
        CD_Timer.make(.notification("VC_MineTableView", 172800, 1), qos: .background)
        
    }
    
    deinit {
        //如果不需要保持 可以移除
        //CD_Timer.remove("VC_MineTableView")
    }
}

extension VC_MineTableView: UITableViewDelegate,UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return vm.forms.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.forms[section].count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = vm.forms[indexPath.section][indexPath.row]
        return row.h
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = vm.forms[indexPath.section][indexPath.row]
        let cell = tableView.cd.cell(row.viewClass)!
        row.bind(cell)
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = vm.forms[indexPath.section][indexPath.row]
        row.didSelect?()
    }
}
