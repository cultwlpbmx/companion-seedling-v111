# 陪伴小树苗 - 24小时自我完善服务
# 使用 Windows 计划任务每6小时运行一次

# 1. 将 self_improvement_loop.py 设置为单次执行（已默认）
# 2. 创建计划任务

$taskName = "CompanionSeedling Self-Improvement"
$action = New-ScheduledTaskAction -Execute "python" -Argument "C:\Users\cultw\.openclaw\workspace\companion_seedling\tools\self_improvement_loop.py"
$trigger = New-ScheduledTaskTrigger -Daily -At 2AM -RepetitionInterval (New-TimeSpan -Hours 6) -For (New-TimeSpan -Days 1)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "陪伴小树苗每日自我学习优化"

Write-Host "✅ 已创建计划任务：$taskName"
Write-Host "⏰ 每6小时运行一次（从凌晨2点开始）"
Write-Host "📝 日志查看：C:\Users\cultw\.openclaw\workspace\companion_seedling\logs\self_improvement.log"
