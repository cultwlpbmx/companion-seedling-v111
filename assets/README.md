# 资源文件夹说明

此文件夹包含应用所需的静态资源。

## images/
放置应用内使用的图片（JPG/PNG格式）

请添加以下资源：
- logo.png (应用 Logo)
- onboarding_1.jpg, onboarding_2.jpg, ... (引导页图片)
- empty_state_*.png (空状态插画)
- illustrations/

当前为空目录，运行前需填充。

## icons/
放置 SVG 或 PNG 图标，分为：
- tabbar/ (底部导航图标)
- actions/ (动作图标)
- categories/ (分类图标)

当前为空目录，运行前需填充。

## animations/
放置 Lottie JSON 动画文件，如：
- seedling_grow.json (树苗生长动画)
- celebrate.json (庆祝动画)
- loading.json (加载动画)

当前为空目录，运行前需填充。

## fonts/
自定义字体文件，已配置 Noto Sans SC（需自行下载字体文件放入）

当前为空目录，运行前需添加字体文件或注释掉 pubspec.yaml 中的 fonts 配置。

## knowledge_base/
存放理论和案例的 JSON 文件，已提供默认内容：
- theories.json - 理论知识
- cases.json - 实践案例

可根据需要扩展。