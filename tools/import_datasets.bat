@echo off
echo.
echo 陪伴小树苗 - 心理学数据集导入
echo =====================================
echo.

echo 检查 Python 环境...
python --version
if errorlevel 1 (
    echo Python 未安装，请先安装 Python 3.8+
    pause
    exit /b 1
)
echo Python 环境正常
echo.

echo 安装依赖库...
python -m pip install requests -q
echo 依赖库安装完成
echo.

echo 创建目录...
if not exist "temp" mkdir temp
if not exist "assets\knowledge_base\cases\psydt_corpus" mkdir assets\knowledge_base\cases\psydt_corpus
if not exist "assets\knowledge_base\cases\counselchat" mkdir assets\knowledge_base\cases\counselchat
if not exist "assets\knowledge_base\cases\mental_health_hotline" mkdir assets\knowledge_base\cases\mental_health_hotline
echo 目录创建完成
echo.

echo =====================================
echo 步骤 1: 下载数据集
echo =====================================
echo.
python tools\download_datasets.py
echo.

echo =====================================
echo 步骤 2: 转换数据格式
echo =====================================
echo.
python tools\convert_datasets.py
echo.

echo =====================================
echo 验证导入结果
echo =====================================
echo.
if exist "assets\knowledge_base\cases\master_index.json" (
    echo 案例库导入成功！
    echo.
    echo 请查看 master_index.json 查看详细统计
) else (
    echo 未找到案例库索引文件
)
echo.

echo =====================================
echo 全部完成！
echo =====================================
echo.
echo 案例库位置：assets\knowledge_base\cases\
echo.
echo 下一步：
echo 1. 重启 APP
echo 2. 开始对话测试
echo 3. 观察 AI 是否应用了案例库知识
echo.
pause
