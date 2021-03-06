//
//  TabViewController.swift
//  RxSwiftDemo
//
//  Created by 623971951 on 2018/3/27.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TabViewController: UIViewController {

    private var tabView: UITableView!

    /// DisposeBag：作用是 Rx 在视图控制器或者其持有者将要销毁的时候，自动释法掉绑定在它上面的资源。
    /// 它是通过类似“订阅处置机制”方式实现（类似于 NotificationCenter 的 removeObserver）。
    private let disposeBag = DisposeBag()
    
    /// 一个可观察序列对象（Observable Squence）
    private lazy var datas: Observable<[String]> = {
        let arr = Observable.just([
            "item selected",
            "model selected",
            "item deselected"
            
            ])
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "RxSwift Demo"
        self.view.backgroundColor = UIColor.white
        
        tabView = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(tabView)
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        tabView.isEditing = true
        
        // rx.items(cellIdentifier:）:这是 Rx 基于 cellForRowAt 数据源方法的一个封装。传统方式中我们还要有个 numberOfRowsInSection 方法，使用 Rx 后就不再需要了（Rx 已经帮我们完成了相关工作）
        datas.bind(to: tabView.rx.items(cellIdentifier:"cellid")) { i, v, cell in
            cell.textLabel?.text = "\(i) - \(v)"
            }.disposed(by: disposeBag)
        
        // tab 点击
        
        // 选中的索引
        tabView.rx.itemSelected.subscribe { (event) in
            print("item selected : \(event)")
            }.disposed(by: disposeBag)
        
        // rx.modelSelected： 这是 Rx 基于 UITableView 委托回调方法 didSelectRowAt 的一个封装。
        tabView.rx.modelSelected(String.self).subscribe(onNext: { event in
                print("model selected : \(event)")
            }).disposed(by: disposeBag)
        
        // 同时获取 select indexPath model
        Observable.zip(tabView.rx.itemSelected, tabView.rx.modelSelected(String.self))
            .bind { indexPath, item in
                print("observable zip item selected:\(indexPath) model selected:\(item)")
            }
            .disposed(by: disposeBag)
        
        // 取消选中 itemDeselected modelDeselected
        tabView.rx.itemDeselected.subscribe(onNext: {i in
                print("item deselected: \(i)")
            })
            .disposed(by: disposeBag)
        
        // 删除 itemDeleted modelDeleted
        tabView.rx.modelDeleted(String.self).subscribe(onNext: {event in
                print("model deleted: \(event)")
            }).disposed(by: disposeBag)
        
        // 移动 itemMoved
        tabView.rx.itemMoved.subscribe(onNext: { (from: IndexPath, to: IndexPath) in
                print("item moved from:\(from) to:\(to)")
            }).disposed(by: disposeBag)
        
        // 新增单元格 tabView.rx.itemInserted.subscribe(...)
        // 点击右侧按钮事件 tabView.rx.itemAccessoryButtonTapped.subscribe(...)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

