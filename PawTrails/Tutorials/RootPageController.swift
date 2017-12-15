//
//  RootPageController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class RootPageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    lazy var viewControlerList: [UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "First")
        let vc2 = sb.instantiateViewController(withIdentifier: "Second")
        let vc3 = sb.instantiateViewController(withIdentifier: "Third")
        return [vc1, vc2, vc3]
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        view.backgroundColor = .white
        if let firstViewController = viewControlerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControlerList.index(of: viewController) else {return nil}
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else {return nil}
        guard viewControlerList.count > previousIndex else {return nil}
        return viewControlerList[previousIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControlerList.count
    }
  

    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewCOntroller = viewControlerList.first, let firstViewConntollerIndex = viewControlerList.index(of: firstViewCOntroller) else {
            return 0
        }
        return firstViewConntollerIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControlerList.index(of: viewController) else {return nil}
        let nextIndex = vcIndex + 1
        guard viewControlerList.count != nextIndex else {return nil}
        guard viewControlerList.count > nextIndex else {return nil}
        return viewControlerList[nextIndex]
    }


}
