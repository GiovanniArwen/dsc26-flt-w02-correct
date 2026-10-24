# AI usage: dsc26-flt-w02
Understanding the purpose of the task and the architecture of the project. 
ChatGPT to understand the task requirements, implement the stock alert model and ViewModel, build the Flutter screen, and troubleshoot test failures.


## 1. Tools I used
ChatGPT to understand the task requirements, implement the stock alert model and ViewModel, build the Flutter screen, and troubleshoot test failures.

## 2. The two or three most useful prompts

<!-- Paraphrasing is fine. Say what you were trying to get. -->

1.Help implement StockAlert.fromJson, validation, copyWith, and value equality according to the task requirements.

2.Help implement AlertsViewModel with sorting, severity filters, normalized Arabic search, and acknowledgement behavior.

## 3. One thing the AI got wrong or left out, and how I found it

The initial screen implementation was still a placeholder and did not provide the required widget keys. I discovered this by running fvm flutter test, which reported missing alert and filter keys. I then implemented the screen and reran the tests successfully.

## 4. Why `visibleAlerts` lives in the view model and not in the screen

<!-- Two sentences, your own words, no AI. -->
ViewModel decides which alerts should be visible to the user. ViewModel Responsbile for searching, filtering and sorting the alerts, so the screen doesnt need to perform business logic. this makes screen very simple and easy UX to user. 