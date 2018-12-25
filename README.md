# UniTice

## 대학교 공지사항 알리미

개발중...

### 지원 (예정) 대학교

**ㄱ**

**ㄴ**

**ㄷ**

동덕여자대학교

**ㄹ**

**ㅁ**

명지대학교

**ㅂ**

**ㅅ**

서울과학기술대학교

**ㅇ**

**ㅈ**

**ㅊ**

**ㅋ**

**ㅌ**

**ㅍ**

**ㅎ**

### 제공하는 기능

- 학교별 공지 확인
- 키워드 푸시 알림

### 사용하는 라이브러리

- Kanna : 학교 공지 게시판 HTML 파싱
- Alamofire : 서버와 통신
- SwiftLint : 코딩 컨벤션 강제
- Firebase/Core : Firebase
- Firebase/Messaing : FCM
- Carte : 오픈 소스 라이센스 표시
- SnapKit : 코드에서 오토레이아웃 설정
- SkeletonView : 네트워킹 중에 컨텐츠를 로딩하고 있다는 것을 사용자에게 알리기
- DZNEmptyDataSet : 컨텐츠가 없음을 사용자에게 알리기
- XLPagerTabStrip : 상단 탭 UI 구현
- KeychainAccess : UUID 저장
- RealmSwift : 로컬 데이터베이스

### 성능 관련

#### 메모리 누수

![image](./images/1.png)

- 일단 메모리 누수는 일어나지 않는다고 봐도 괜찮을 것 같다.
- 하지만 학교 변경시 지속적으로 메모리 사용량이 증가한다. 해결해보자.

#### 에너지 임팩트

- HTML 파싱하는 부분을 `DispatchQueue.global(qos: .background).async` 안에 감싸서 앱이 멈춘 것처럼 보이는 현상은 해결하였다.
  - `.userInitiated`로는 해결하지 못했음.  Quality Of Service에 대해서 이해하고 적절하게 사용해야 할 필요가 있다.
- 네트워킹시 Overhead가 심각한데 원래 네트워킹시에는 오버헤드가 일어나는 것이 정상인 것 같다.

