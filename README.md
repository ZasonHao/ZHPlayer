# ZHPlayer 
A Video Player Which Packaged With AVPlayer

## ZHPlayer分为三部分:Manager,HandleView,DisplayView
Manager:        ZHPlayer类
<br>
HandleView:     ZHPlayerBaseHandleView类
<br>
DisplayView:    ZHplayerView类
<br><br>
### ZHPlayer类:
<br>作为整个播放器的manager，ZHPlayer处理了ZHplayerView和ZHPlayerBaseHandleView之间的逻辑、信息传递等
<br><br>
### ZHPlayerBaseHandleView类:
<br>用户对视频播放过程中的交互视图，接收命令、发出命令、处理本类的UI变化
<br><br>
### ZHplayerView类:
<br>只负责显示视频画面，接收外部命令，针对视频做出处理
<br><br>
### 三部分各司其职，层次清晰，分工明确
