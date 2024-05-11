#  Ulmago App Flow : 얼마고 앱 흐름
<br>

<img src="https://github.com/Dhui-Park/Ulmago/assets/67443044/610bafc9-a67d-46f0-adbb-74205fec30f9" style="width:200px"></img> | <img src="https://github.com/Dhui-Park/Ulmago/assets/67443044/5474aa08-091b-49c3-b270-c03f01c82b11" style="width:200px"></img> | <img src="https://github.com/Dhui-Park/Ulmago/assets/67443044/cd88a269-f61e-475c-a2d5-d55e67791cb3" style="width:200px"></img> | <img src="https://github.com/Dhui-Park/Ulmago/assets/67443044/4500f0b6-0268-448e-8e50-9b5f5bcd85a5" style="width:200px"></img> | <img src="https://github.com/Dhui-Park/Ulmago/assets/67443044/c7887d84-e184-4d14-b480-406c43840c51" style="width:200px"></img>
---|---|---|---|---|






</br>

## Four Flows

### 0. 스플래시 화면 흐름: SplashFlow
    [x] 스플래시 화면 : Main + SplashViewController
    
### 1. 목표 설정 흐름: GoalSettingFlow
    [x] 1-1. 목표 설정 화면: Main + ViewController
    [x] 1-2. 총 비용 설정 화면: WholeCostSettingVC
            [ ] 1-2-1. 텍스트필드 숫자 천단위 포매팅 부분 에러!
    [x] 1-2. 하루 목표 소비 금액 설정 화면: DailyExpenseSettingVC
    
### 2. 일일 가계부 흐름: DailyBudgetFlow
    [x] 2-1. 메인화면: DailyMainVC
    [x] 2-2. 목표 재설정 얼럿 화면
    [x] 2-3. 일일 가계부 화면: DailyBudgetVC
    [x] 2-4. 수정 얼럿 화면
    [x] 2-5. 삭제 얼럿 화면
    [x] 2-6. 추가 얼럿 화면
    [x] 2-7. 이전 날짜들 달력 화면: PreviousDailyBudgetVC
    [x] 2-8. 이전 일일 가계부 화면
    
### 3. 목표 달성 흐름
    [ ] 3-1. 목표 50% 달성 화면
    [ ] 3-2. 목표 100% 달성 화면


## 데이터 Data

### UserGoal - 사용자가 직접 설정한 목표들
    목표: String
    총 목표 금액: Int
    하루 소비 한도 금액: Int

### Budget - 일일 가계부 화면에서 사용자가 입력한 내역, 금액
    id: ObjectID - Primary Key
    제목: String
    소비 금액: Int
    날짜: Date
        

## 오픈소스 Open Source

> RxSwift
```
https://github.com/ReactiveX/RxSwift
```
> ALProgressView
```
https://github.com/alxrguz/ALProgressView
```
> SwiftAlertView
```
https://github.com/dinhquan/SwiftAlertView
```
> FSCalendar
```
https://github.com/WenchaoD/FSCalendar
```
> realm
```
https://github.com/realm/realm-swift
```
