# 陪伴小树苗 - 心理学数据集一键导入

Write-Host ""
Write-Host "陪伴小树苗 - 心理学数据集一键导入" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# 检查 Python
Write-Host "检查 Python 环境..." -ForegroundColor Yellow
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCmd) {
    $version = & python --version
    Write-Host "Python 已安装：$version" -ForegroundColor Green
} else {
    Write-Host "Python 未安装，请先安装 Python 3.8+" -ForegroundColor Red
    Write-Host "下载地址：https://www.python.org/downloads/"
    Write-Host ""
    Write-Host "按 Enter 退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# 检查 requests 库
Write-Host ""
Write-Host "检查 Python 依赖..." -ForegroundColor Yellow
$checkRequests = & python -c "import requests" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "requests 库已安装" -ForegroundColor Green
} else {
    Write-Host "正在安装 requests 库..." -ForegroundColor Yellow
    & python -m pip install requests
    Write-Host "requests 库安装完成" -ForegroundColor Green
}

# 创建目录
Write-Host ""
Write-Host "创建目录结构..." -ForegroundColor Yellow
$dirs = @(
    "temp",
    "assets/knowledge_base/cases/psydt_corpus",
    "assets/knowledge_base/cases/counselchat",
    "assets/knowledge_base/cases/mental_health_hotline"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  创建：$dir"
    }
}

# 运行下载脚本
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 1: 下载数据集" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

& python tools/download_datasets.py

# 运行转换脚本
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 2: 转换数据格式" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

& python tools/convert_datasets.py

# 验证结果
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "步骤 3: 验证导入结果" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$masterIndex = "assets/knowledge_base/cases/master_index.json"
if (Test-Path $masterIndex) {
    Write-Host "案例库导入成功！" -ForegroundColor Green
    Write-Host ""
    $content = Get-Content $masterIndex -Raw | ConvertFrom-Json
    Write-Host "数据集统计：" -ForegroundColor Yellow
    foreach ($source in $content.sources) {
        Write-Host "  $($source.source): $($source.total) 个案例" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "总计：$($content.totalCases) 个案例" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "未找到案例库索引文件" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "=====================================" -ForegroundColor Green
Write-Host "全部完成！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "案例库位置：" -ForegroundColor Yellow
Write-Host "  assets/knowledge_base/cases/"
Write-Host ""
Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "1. 重启 APP"
Write-Host "2. 开始对话测试"
Write-Host "3. 观察 AI 是否应用了案例库知识"
Write-Host ""
Write-Host "按 Enter 退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
