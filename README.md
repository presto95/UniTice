# UniTice

![Language](https://img.shields.io/badge/swift-4.2-orange.svg)
![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)

## 대학교 공지사항 알리미

UNDER DEVELOPMENT👩🏻‍💻👩🏻‍💻👨🏻‍💻

---

### 지원 대학교

**A**

KAIST

KC대학교

**ㄱ**

강남대학교

강원대학교

경북대학교

경상대학교

경성대학교

경희대학교

고려대학교

광운대학교

국민대학교

**ㄴ**

**ㄷ**

대진대학교

덕성여자대학교

동국대학교

동덕여자대학교

동신대학교

**ㄹ**

**ㅁ**

명지대학교

목포대학교

**ㅂ**

부경대학교

부산대학교

**ㅅ**

삼육대학교

서경대학교

서울과학기술대학교

서울교육대학교

서울대학교

서울여자대학교

성결대학교

성공회대학교

성균관대학교

성신여자대학교

세종대학교

세한대학교

숙명여자대학교

**ㅇ**

우석대학교

이화여자대학교

**ㅈ**

전남대학교

전북대학교

제주대학교

**ㅊ**

총신대학교

충남대학교

충북대학교

**ㅋ**

**ㅌ**

**ㅍ**

**ㅎ**

한국산업기술대학교

한국예술종합학교

한국외국어대학교

한성대학교

한양대학교

홍익대학교

---

### 제공하는 기능

- 학교별 공지 확인
- ~~키워드 푸시 알림~~

### 사용하는 라이브러리

- Kanna
- RealmSwift
- XLPagerTabStrip
- Firebase/Core
- Firebase/Messaing
- SnapKit
- DZNEmptyDataSet

---

### 성능 관련

#### 메모리 누수

![image](./images/1.png)

- 일단 메모리 누수는 일어나지 않는다고 봐도 괜찮을 것 같다.
- 하지만 학교 변경시 지속적으로 메모리 사용량이 증가한다. 해결해보자.

#### 에너지 임팩트

- HTML 파싱하는 부분을 `DispatchQueue.global(qos: .background).async` 안에 감싸서 앱이 멈춘 것처럼 보이는 현상은 해결하였다.
  - `.userInitiated`로는 해결하지 못했음.  Quality Of Service에 대해서 이해하고 적절하게 사용해야 할 필요가 있다.
- 네트워킹시 Overhead가 심각한데 원래 네트워킹시에는 오버헤드가 일어나는 것이 정상인 것 같다.

