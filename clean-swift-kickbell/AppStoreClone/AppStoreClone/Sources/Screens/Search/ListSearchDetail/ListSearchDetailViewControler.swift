//
//  ListSearchDetailViewControler.swift
//  AppStoreClone
//
//  Created by jc.kim on 9/20/23.
//

import UIKit

protocol ListSearchDetailDisplayLogic: AnyObject {
    func displayAppDetail(viewModel: ListSearchDetail.ShowAppDetail.ViewModel)
}

class ListSearchDetailViewControler: UIViewController, ListSearchDetailDisplayLogic {
    //MARK: - Properties
    
    var interactor: ListSearchDetailBusinessLogic?
    var router: (NSObjectProtocol & ListSearchDetailRoutingLogic & ListSearchDetailDataPassing)?
    
    // DataStore
    private var appData: ListSearch.AppSearchResultDTO!
    
    //MARK: - LifeCycles
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupVIPCycle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupVIPCycle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // 데이터 로드 요청
        let request = ListSearchDetail.ShowAppDetail.Request()
        interactor?.showAppDetail(request: request)
    }
    
    
    //MARK: - Views
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()
    
    private let releaseNoteView = ShowMoreView()
    
    private let appIconDetailView = AppIconDetailView()
    
    private let appInfoDetailView = AppInfoDetailView()
    
    // MARK: - Setup
    
    private func setupVIPCycle() {
        let viewController = self
        let interactor = ListSearchDetailInteractor()
        let presenter = ListSearchDetailPresenter()
        let router = ListSearchDetailRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        
        // 라우터의 dataStore에 데이터 설정
        if let appData = router.dataStore?.searchResults {
            interactor.searchResults = appData
        }
    }
    
    // MARK: - Display Logic
    
    func displayAppDetail(viewModel: ListSearchDetail.ShowAppDetail.ViewModel) {
        // 앱 상세 데이터로 UI 업데이트
        
        let info: ListSearch.AppSearchResultDTO = viewModel.appData
        
        let appIconContainerInfo = AppIconDetailView.Info(
            artworkUrl512: info.artworkUrl512,
            sellerName: info.sellerName,
            trackName: info.trackName
        )
        appIconDetailView.info = appIconContainerInfo
        
        
        let appInfoContainerInfo = AppInfoDetailView.Info(
            userRatingCount: info.userRatingCount,
            averageUserRating: info.averageUserRating,
            contentAdvisoryRating: info.contentAdvisoryRating,
            trackContentRating: info.trackContentRating,
            genres: info.genres,
            artistName: info.artistName,
            languageCodesISO2A: info.languageCodesISO2A
        )
        appInfoDetailView.info = appInfoContainerInfo
        
        let newFeatureContainerInfo = NewFeatureView.Info(
            version: info.version,
            currentVersionReleaseDate: info.currentVersionReleaseDate
        )
        newFeatureView.info = newFeatureContainerInfo
        newFeatureView.versionHistoryButton.accessibilityLabel = "\(info.trackName)의 버전 기록"

        releaseNoteView.text = info.releaseNotes
        releaseNoteView.showMoreButton.accessibilityLabel = "\(info.trackName)의 새로운 기능 더보기"
        
        let screenshotsPreviewInfo = ScreenshotsPreviewView.Info(
            images: info.screenshotImages,
            imageSize: CGSize(width: 250, height: 500),
            type: .iphone
        )
        screenshotsPreviewView.configure(with: screenshotsPreviewInfo)
        
        descriptionView.text = info.description
        descriptionView.showMoreButton.accessibilityLabel = "\(info.trackName)의 앱 설명 더보기"

        let subtitleInfo = SubtitleView.Info(title: info.artistName, subtitle: "개발자")
        subtitleView.info = subtitleInfo
    }
    
    private let screenshotsPreviewView = ScreenshotsPreviewView()
    
    private let newFeatureView = NewFeatureView()
    
    private let descriptionView = ShowMoreView()
    
    private let subtitleView = SubtitleView()
}


//MARK: - Methods


extension ListSearchDetailViewControler {
    private func createView<T: UIView>(
        _ viewType: T.Type,
        initializer: (() -> T)? = nil) -> T {
            if let initializer = initializer {
                return initializer()
            } else {
                return T.init()
            }
        }
}


//MARK: - Setups

extension ListSearchDetailViewControler {
    private func setup() {
        setupUI()
        setupViews()
        setupConstraints()
        setupDelegates()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupViews() {
        stackView.addArrangedSubviews([
            appIconDetailView,
            ViewFactory.create(SeparatorView.self, direction: .horizontal),
            appInfoDetailView,
            ViewFactory.create(SeparatorView.self, direction: .horizontal),
            newFeatureView,
            releaseNoteView,
            ViewFactory.create(SeparatorView.self, direction: .horizontal),
            screenshotsPreviewView,
            ViewFactory.create(SeparatorView.self, direction: .horizontal),
            descriptionView,
            SpacerView(),
            subtitleView,
        ])
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -44),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupDelegates() {
    }
}


