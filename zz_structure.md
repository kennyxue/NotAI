# 项目结构


├── troubleshooting.md 
├── AIWritingAssistant/ 
│   ├── ViewModels/ 
│   │   ├── ChatViewModel.swift 
│   │   ├── DocumentViewModel.swift 
│   │   └── DirectoryViewModel.swift 
│   ├── Resources/ 
│   ├── Assets.xcassets/ 
│   │   ├── AppIcon.appiconset/ 
│   │   │   └── Contents.json 
│   │   ├── AccentColor.colorset/ 
│   │   │   └── Contents.json 
│   │   └── Contents.json 
│   ├── Utils/ 
│   │   ├── Constants.swift 
│   │   └── Extensions/
│   │       └── View+Extensions.swift
│   ├── Models/ 
│   │   ├── ChatMessage.swift 
│   │   ├── Directory.swift 
│   │   ├── Document.swift 
│   │   ├── AppSettings.swift
│   │   └── AIWritingAssistant.xcdatamodeld/
│   │       └── AIWritingAssistant.xcdatamodel/
│   │           └── contents
│   ├── Preview Content/ 
│   │   └── Preview Assets.xcassets/ 
│   │       └── Contents.json 
│   ├── AIWritingAssistant.entitlements 
│   ├── Views/ 
│   │   ├── Components/ 
│   │   │   ├── TabButton.swift 
│   │   │   ├── DirectoryItem.swift 
│   │   │   ├── DirectoryContextMenu.swift 
│   │   │   └── DirectorySortMenu.swift 
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── ThemeSettingsView.swift
│   │   │   ├── AISettingsView.swift
│   │   │   └── GeneralSettingsView.swift
│   │   └── MainLayout/ 
│   │       ├── SidebarView.swift 
│   │       ├── EditorView.swift 
│   │       └── AssistantView.swift 
│   ├── ContentView.swift 
│   ├── AIWritingAssistantApp.swift 
│   └── Services/ 
│       ├── DataStore/ 
│       │   └── DataStore.swift 
│       ├── CoreData/
│       │   └── CoreDataManager.swift
│       ├── AIService/ 
│       │   └── AIService.swift 
│       └── FileManager/ 
│           └── FileManager.swift 
├── zz_plan.md 
├── zz_structure.md 
├── AIWritingAssistantUITests/ 
│   ├── AIWritingAssistantUITestsLaunchTests.swift 
│   └── AIWritingAssistantUITests.swift 
├── readme.md 
├── AIWritingAssistant.xcodeproj/ 
│   ├── project.pbxproj 
│   ├── xcuserdata/ 
│   │   └── xueyihua.xcuserdatad/ 
│   │       └── xcschemes/ 
│   │           └── xcschememanagement.plist 
│   └── project.xcworkspace/ 
│       ├── contents.xcworkspacedata 
│       ├── xcuserdata/ 
│       │   └── xueyihua.xcuserdatad/ 
│       │       └── UserInterfaceState.xcuserstate 
│       └── xcshareddata/ 
│           └── swiftpm/ 
│               └── configuration/ 
├── zz_demands.md 
├── AIWritingAssistantTests/ 
│   └── AIWritingAssistantTests.swift 
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
- Components: 可复用的UI组件
- 响应式设计，支持窗口大小调整

### 2.2 ViewModels层
- 处理业务逻辑
- 状态管理
- 数据转换和处理

### 2.3 Models层
- 核心数据模型
- 数据结构定义
- 业务实体对象

### 2.4 Services层
- 文件操作服务
- AI服务集成
- 数据持久化服务

## 3. 数据流
- 单向数据流
- 事件驱动
- 状态管理清晰

## 4. 扩展性考虑
- 模块化设计
- 接口抽象
- 便于功能扩展
