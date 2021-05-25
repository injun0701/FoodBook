//
//  IntroViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/24.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet var bannerDotCollectionView: UICollectionView!
    @IBOutlet var bannerDotCollectionViewWidth: NSLayoutConstraint!
    @IBOutlet var introCollectionView: UICollectionView!
    
    //걸음 수 배열
    var intro : [IntroModel] = []
    // 현재페이지 체크 변수 (스크롤할 때 필요)
    var nowPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walkCollectionViewData()
        walkCollectionViewSet()
        title = "FoodBook"
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    //컬랙션뷰 데이터 세팅
    func walkCollectionViewData() {
        
        intro = [
            IntroModel(title: "음식과 함께한 추억을 공유해 보세요!", content: "다른 유저들의 기록도 함께 볼 수 있어요.", img: "intro01"),
            IntroModel(title: "음식과 함께한 추억을 기록해 보세요!", content: "음식 이름, 가격, 상세한 내용까지 작성할 수 있어요.", img: "intro02"),
            IntroModel(title: "음식과 함께한 추억을 검색해보세요!", content: "제목, 내용, 유저 이름으로 검색할 수 있어요.", img: "intro03"),
            IntroModel(title: "다른 유저의 피드백을 받을 수 있어!", content: "내 게시물의 ‘좋아요’와 ‘댓글’ 알림을 확인할 수 있어요.", img: "intro04")
       ]
    }
    
    //컬랙션뷰 세팅
    func walkCollectionViewSet() {
        introCollectionView.delegate = self
        introCollectionView.dataSource = self
        introCollectionView.decelerationRate = .fast
        introCollectionView.isPagingEnabled = true
        introCollectionView.register(UINib(nibName: "IntroCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IntroCollectionViewCell")
        
        bannerDotCollectionView.delegate = self
        bannerDotCollectionView.dataSource = self
        bannerDotCollectionView.register(UINib(nibName: "BannerDotCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerDotCollectionViewCell")
        let padding = 10
        bannerDotCollectionViewWidth.constant = CGFloat(intro.count * 10 + (intro.count * padding))
        view.layoutIfNeeded()
    }
 
    //약관동의 화면으로 이동
    func toTos() {
        let sb = UIStoryboard(name: "Tos", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "TosViewController") as! TosViewController
        navigationController?.pushViewController(navi, animated: true)
    }
}

//MARK: 콜렉션뷰 구현
extension IntroViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return intro.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == introCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IntroCollectionViewCell", for: indexPath) as? IntroCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.titleLbl.text = intro[indexPath.row].title
            cell.contentLbl.text = intro[indexPath.row].content
            cell.imgView.image = UIImage(named: "\(intro[indexPath.row].img)")
            if indexPath.row == intro.count-1 {
                cell.imgViewToLeft.isHidden = false
                cell.imgViewToRigth.isHidden = true
                cell.btn.isHidden = false
                cell.btn.setTitle("시작하기", for: UIControl.State.normal)
                //btn02TapHandler 작성
                cell.btnTapHandler = {
                    //약관동의 화면으로 이동
                    self.toTos()
                }
            } else if indexPath.row == 0 {
                cell.imgViewToLeft.isHidden = true
                cell.imgViewToRigth.isHidden = false
                cell.btn.isHidden = true
            } else {
                cell.imgViewToLeft.isHidden = false
                cell.imgViewToRigth.isHidden = false
                cell.btn.isHidden = true
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerDotCollectionViewCell", for: indexPath) as? BannerDotCollectionViewCell else {
                return UICollectionViewCell()
            }
            for i in 0..<intro.count {
                if nowPage == i{
                    if indexPath.row == nowPage {
                        cell.dotView.backgroundColor = UIColor().mainColor
                    } else {
                        cell.dotView.backgroundColor = UIColor().colorEEEEEE
                    }
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == introCollectionView {
            return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
        } else {
            return CGSize(width: 10, height: 10)
        }
    }
    
    //컬렉션뷰 감속 끝났을 때 현재 페이지 체크
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        nowPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            for cell in introCollectionView.visibleCells {
                if let row = introCollectionView.indexPath(for: cell)?.item {
                    nowPage = row
                    print(nowPage)
                }
            }
            bannerDotCollectionView.reloadData()
        }
    }
}

struct IntroModel {
    var title: String
    var content: String
    var img: String
    
    
    init(title: String, content: String, img: String) {
        self.title = title
        self.content = content
        self.img = img
    }
}
