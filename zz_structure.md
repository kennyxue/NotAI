# 项目结构
NotAI/
├── AIWritingAssistant/ 
│   ├── Assets.xcassets/ 
│   │   ├── AccentColor.colorset/ 
│   │   │   └── Contents.json 
│   │   ├── AppIcon.appiconset/ 
│   │   │   └── Contents.json 
│   │   └── Contents.json 
│   ├── Models/ 
│   │   ├── AIWritingAssistant.xcdatamodeld/ 
│   │   │   └── AIWritingAssistant.xcdatamodel/ 
│   │   │       └── contents 
│   │   ├── AppSettings.swift 
│   │   ├── ChatMessage.swift 
│   │   ├── Directory.swift 
│   │   └── Document.swift 
│   ├── Preview Content/ 
│   │   └── Preview Assets.xcassets/ 
│   │       └── Contents.json 
│   ├── Resources/ 
│   ├── Services/ 
│   │   ├── AIService/ 
│   │   │   └── AIService.swift 
│   │   ├── CoreData/ 
│   │   │   └── CoreDataManager.swift 
│   │   ├── DataStore/ 
│   │   │   └── DataStore.swift 
│   │   └── FileManager/ 
│   │       └── FileManager.swift 
│   ├── Utils/ 
│   │   ├── Extensions/ 
│   │   │   └── View+Extensions.swift 
│   │   └── Constants.swift 
│   ├── ViewModels/ 
│   │   ├── ChatViewModel.swift 
│   │   ├── DirectoryViewModel.swift 
│   │   └── DocumentViewModel.swift 
│   ├── Views/ 
│   │   ├── Components/ 
│   │   │   ├── DirectoryContextMenu.swift 
│   │   │   ├── DirectoryItem.swift 
│   │   │   ├── DirectorySortMenu.swift 
│   │   │   ├── TabButton.swift 
│   │   │   ├── TextFormatToolbar.swift 
│   │   │   ├── ColorPickerPanel.swift 
│   │   │   ├── FontSizeSlider.swift 
│   │   │   └── MessageBubble.swift 
│   │   ├── MainLayout/ 
│   │   │   ├── AssistantView.swift 
│   │   │   ├── EditorView.swift 
│   │   │   ├── SidebarView.swift 
│   │   │   ├── ChatView.swift 
│   │   │   ├── ComposerView.swift 
│   │   │   └── StylingView.swift 
│   │   └── Settings/ 
│   │       ├── AISettingsView.swift 
│   │       ├── GeneralSettingsView.swift 
│   │       ├── SettingsView.swift 
│   │       └── ThemeSettingsView.swift 
│   ├── AIWritingAssistant.entitlements 
│   ├── AIWritingAssistantApp.swift 
│   └── ContentView.swift 
├── AIWritingAssistant.xcodeproj/ 
│   ├── project.xcworkspace/ 
│   │   ├── xcshareddata/ 
│   │   │   └── swiftpm/ 
│   │   │       └── configuration/ 
│   │   ├── xcuserdata/ 
│   │   │   └── xueyihua.xcuserdatad/ 
│   │   │       └── UserInterfaceState.xcuserstate 
│   │   └── contents.xcworkspacedata 
│   ├── xcuserdata/ 
│   │   └── xueyihua.xcuserdatad/ 
│   │       └── xcschemes/ 
│   │           └── xcschememanagement.plist 
│   └── project.pbxproj 
├── AIWritingAssistantTests/ 
│   └── AIWritingAssistantTests.swift 
├── AIWritingAssistantUITests/ 
│   ├── AIWritingAssistantUITests.swift 
│   └── AIWritingAssistantUITestsLaunchTests.swift 
├── readme.md 
├── troubleshooting.md 
├── zz_demands.md 
├── zz_plan.md 
├── zz_structure.md 
├── .git/ 





# 架构说明

## 1. 整体架构
- 采用MVVM架构模式
- 使用SwiftUI构建用户界面
- Core Data用于本地数据持久化
- 集成OpenAI API进行AI交互

## 2. 主要模块
### 2.1 Views层
- MainLayout: 实现三栏式布局
  - ContentView: 主界面容器
  - SidebarView: 左侧目录栏
  - EditorView: 中央编辑区域
  - AssistantView: 右侧AI助手区域
- Components: 可复用的UI组件
  - TextFormatToolbar: 文本格式化工具栏
  - DirectoryItem: 目录项组件
  - TabButton: 标签按钮
  - MessageBubble: 消息气泡组件
- 响应式设计，支持窗口大小调整

### 2.2 ViewModels层
- DocumentViewModel: 处理文档相关的业务逻辑
- DirectoryViewModel: 管理目录结构和选择状态
- ChatViewModel: 处理AI对话交互
- 实现数据绑定和状态管理

### 2.3 Models层
- Document: 文档数据模型
- Directory: 目录数据模型
- ChatMessage: 聊天消息模型
- AppSettings: 应用设置模型

### 2.4 Services层
- AIService: AI服务集成
  - 支持OpenAI GPT系列模型
  - 支持Google Gemini模型
  - API请求管理
- DataStore: 数据存储服务
  - 文件读写
  - 数据序列化与反序列化
- CoreDataManager: Core Data数据管理
  - 实体映射
  - CRUD操作
  - 数据持久化

## 3. 数据流
- 单向数据流
- 事件驱动
- 状态管理清晰

## 4. 扩展性考虑
- 模块化设计
- 接口抽象
- 便于功能扩展
