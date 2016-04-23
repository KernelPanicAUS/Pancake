//
//  MainPageViewController.swift
//  Pancake
//
//  Created by Angel Vazquez on 3/15/16.
//  Copyright © 2016 Rudy Rosciglione. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        // Uses DashboardViewController as First View Controller
        let firstVC = orderedViewControllers[1]
        setViewControllers([firstVC],
            direction: .Forward,
            animated: true,
            completion: nil)
        
    }
    
    // Array containing ViewControllers for pages
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.loadViewController("AlarmTableVC"), self.loadViewController("DashboardVC"), self.loadViewController("CreateAlarmVC")]
    }()
    
    // Loads ViewControllers from Main.storyboard
    func loadViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("\(name)")
    }
    
}

//Mark: - UIPageViewControllerDataSource
extension MainPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
          return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}