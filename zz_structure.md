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
│   │   │   └── FontSizeSlider.swift 
│   │   ├── MainLayout/ 
│   │   │   ├── AssistantView.swift 
│   │   │   ├── EditorView.swift 
│   │   │   └── SidebarView.swift 
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
