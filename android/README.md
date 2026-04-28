# Android 配置说明

## 前置步骤

1. 在 Firebase Console 创建项目
2. 添加 Android 应用，包名使用 `com.companion.seedling`
3. 下载 `google-services.json` 文件
4. 将 `google-services.json` 放置到此目录 (`android/app/`)

## 最小配置

- `minSdkVersion`: 21 (已在 pubspec.yaml 隐含要求)
- 已支持 Android 5.0+

## 权限

应用需要的权限已在 `AndroidManifest.xml` 中配置：

- INTERNET (网络)
- POST_NOTIFICATIONS (Android 13+ 通知)
- WAKE_LOCK (保持设备唤醒，用于提醒)

## 构建

```bash
flutter build apk --release
```

或生成 app bundle：
```bash
flutter build appbundle --release
```

## 签名

发布版本需要配置签名。参考 Flutter 官方文档：
https://docs.flutter.dev/deployment/android

## 注意

- FCM 推送需要 Google Play 服务支持
- 在中国大陆地区可能需适配国内推送服务（如华为、小米推送）