# iOS 配置说明

## 前置步骤

1. 在 Firebase Console 创建项目
2. 添加 iOS 应用，Bundle ID 使用 `com.companion.seedling`
3. 下载 `GoogleService-Info.plist` 文件
4. 将 `GoogleService-Info.plist` 放置于此目录 (`ios/Runner/`)

## 最小配置

- iOS 12.0+ (Flutter 默认)
- 已支持 iPhone、iPad

## 权限

应用需要在 `Info.plist` 中声明权限，已包含：
- NSCameraUsageDescription (如需要拍照功能)
- NSPhotoLibraryUsageDescription (相册访问)
- NSMicrophoneUsageDescription (语音功能，可选)

通知权限在第一次运行时由系统自动请求。

## 推送证书

FCM 推送需要 APNs 证书：
1. 在 Apple Developer 创建 APNs Auth Key
2. 上传到 Firebase Console 的 iOS 应用设置中

参考：https://firebase.google.com/docs/cloud-messaging/ios/client

## 构建

```bash
flutter build ipa --release
```

或 Xcode 打开 `ios/Runner.xcworkspace` 进行 Archive 打包。

## 注意

- 必须真实设备测试推送功能（模拟器不支持 FCM）
- 国行设备可能需要额外处理