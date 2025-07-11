//
//  SearchCoordinator.swift
//  ApoStoreClone
//
//  Created by ksmartech on 2023/09/19.
//

import UIKit

class SearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ListSearchViewController()
        vc.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 4
        )
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.container
        
        // 서비스 주입
        let recentSearchService = container.resolve(RecentSearchService.self)!
        let appSearchService = container.resolve(AppSearchServiceProtocol.self)!
        
        // Clean Swift VIP 사이클 설정
        let interactor = ListSearchInteractor(recentSearchService: recentSearchService, appSearchService: appSearchService)
        let presenter = ListSearchPresenter()
        let router = ListSearchRouter()
        
        vc.interactor = interactor
        vc.router = router
        interactor.presenter = presenter
        presenter.viewController = vc
        router.viewController = vc
        router.dataStore = interactor
        
        navigationController.pushViewController(vc, animated: true)
    }


    
//    func start() {
//        let vc = SearchViewController()
//        vc.tabBarItem = UITabBarItem(
//            title: "검색",
//            image: UIImage(systemName: "magnifyingglass"),
//            tag: 4
//        )
//        vc.coordinator = self
//        vc.reactor = SearchReactor(
//            recentService: RecentSearchServiceImp(repository: UserDefaultService()),
//            appService: AppSearchServiceImp(network: NetworkImp())
//        )
//        navigationController.pushViewController(vc, animated: true)
//    }
    
    // 앱 상세 화면으로 이동 - Clean Swift에서 사용
//    func showAppDetail(with appData: ListSearch.AppSearchResultDTO) {
//        // 임시로 상세 화면 이동을 비활성화합니다.
//        // 나중에 AppDetailViewController 구현 후 다시 활성화할 예정
//        print("Selected app: \(appData.trackName) (ID: \(appData.trackId))")
//        // let appDetailViewController = AppDetailViewController()
//        // appDetailViewController.configure(with: appData)
//        // navigationController.pushViewController(appDetailViewController, animated: true)
//    }
//    
//    // 기존 ReactorKit 버전에서 사용하던 메서드 - 호환성을 위해 유지
//    func didSelected(with data: ListSearch.AppSearchResultDTO) {
//        showAppDetail(with: data)
//    }
}
