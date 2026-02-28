<#
.SYNOPSIS
    GitHub 自动推送工具 - 可视化界面版本
.DESCRIPTION
    一键推送代码到 GitHub，自动触发 Actions 构建 APK
.NOTES
    作者: AI Assistant
    版本: 1.0
#>

param(
    [switch]$QuickPush,
    [string]$Message = "",
    [switch]$Release,
    [string]$Version = ""
)

# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 颜色定义
$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Blue"
    Step = "Magenta"
    Menu = "White"
}

# 项目根目录
$ProjectRoot = $PSScriptRoot

# 清屏并显示标题
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor $Colors.Title
    Write-Host "          GitHub 自动推送工具 - Flutter APK 自动构建" -ForegroundColor $Colors.Title
    Write-Host "  ================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
}

# 显示项目信息
function Show-ProjectInfo {
    Write-Host "  [项目信息]" -ForegroundColor $Colors.Info
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
    
    # 项目名称
    $projectName = Split-Path $ProjectRoot -Leaf
    Write-Host "  项目名称: " -NoNewline
    Write-Host $projectName -ForegroundColor $Colors.Success
    
    # 当前分支
    $branch = git branch --show-current 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  当前分支: " -NoNewline
        Write-Host $branch -ForegroundColor $Colors.Success
    }
    
    # 远程仓库
    $remote = git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  远程仓库: " -NoNewline
        Write-Host "已配置" -ForegroundColor $Colors.Success
        $repoUrl = $remote -replace '\.git$', ''
        Write-Host "  仓库地址: " -NoNewline
        Write-Host $repoUrl -ForegroundColor DarkGray
    } else {
        Write-Host "  远程仓库: " -NoNewline
        Write-Host "未配置" -ForegroundColor $Colors.Warning
    }
    
    # 未提交更改
    $changes = git status --porcelain 2>$null
    $changeCount = ($changes | Where-Object { $_.Trim() -ne "" }).Count
    Write-Host "  未提交更改: " -NoNewline
    if ($changeCount -gt 0) {
        Write-Host "$changeCount 个文件" -ForegroundColor $Colors.Warning
    } else {
        Write-Host "无" -ForegroundColor $Colors.Success
    }
    
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# 显示主菜单
function Show-Menu {
    Write-Host "  [操作菜单]" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "  [1] 推送代码" -ForegroundColor $Colors.Menu
    Write-Host "      提交更改并推送到 GitHub，触发 Actions 构建"
    Write-Host ""
    Write-Host "  [2] 发布版本" -ForegroundColor $Colors.Menu
    Write-Host "      创建版本标签，发布正式版 APK"
    Write-Host ""
    Write-Host "  [3] 查看状态" -ForegroundColor $Colors.Menu
    Write-Host "      查看当前 Git 状态和更改文件"
    Write-Host ""
    Write-Host "  [4] 打开 Actions 页面" -ForegroundColor $Colors.Menu
    Write-Host "      在浏览器中打开 GitHub Actions 页面"
    Write-Host ""
    Write-Host "  [5] 打开 Releases 页面" -ForegroundColor $Colors.Menu
    Write-Host "      在浏览器中打开 GitHub Releases 页面"
    Write-Host ""
    Write-Host "  [Q] 退出" -ForegroundColor $Colors.Menu
    Write-Host ""
}

# 执行 Git 命令并显示结果
function Invoke-GitCommand {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Host "  -> $Description..." -NoNewline
    
    $output = & cmd /c $Command 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host " [完成]" -ForegroundColor $Colors.Success
        return @{ Success = $true; Output = $output }
    } else {
        Write-Host " [失败]" -ForegroundColor $Colors.Error
        Write-Host "     错误: $output" -ForegroundColor $Colors.Error
        return @{ Success = $false; Output = $output }
    }
}

# 推送代码
function Push-Code {
    param([string]$CommitMessage)
    
    Show-Header
    Show-ProjectInfo
    Write-Host "  [正在推送代码]" -ForegroundColor $Colors.Step
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    
    # 获取提交信息
    if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
        Write-Host "  请输入提交说明: " -NoNewline -ForegroundColor $Colors.Info
        $CommitMessage = Read-Host
        if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
            $CommitMessage = "更新应用代码"
        }
    }
    
    Write-Host ""
    
    # 步骤1: 添加更改
    Write-Host "  [步骤 1/4] 添加更改到暂存区" -ForegroundColor $Colors.Step
    $result1 = Invoke-GitCommand "git add ." "添加所有更改"
    if (-not $result1.Success) {
        Write-Host ""
        Write-Host "  操作失败，请检查 Git 状态" -ForegroundColor $Colors.Error
        Pause
        return
    }
    
    # 步骤2: 提交代码
    Write-Host ""
    Write-Host "  [步骤 2/4] 提交代码" -ForegroundColor $Colors.Step
    $result2 = Invoke-GitCommand "git commit -m `"$CommitMessage`"" "提交更改"
    # 如果没有更改，继续执行
    
    # 步骤3: 推送到 GitHub
    Write-Host ""
    Write-Host "  [步骤 3/4] 推送到 GitHub" -ForegroundColor $Colors.Step
    $branch = git branch --show-current
    $result3 = Invoke-GitCommand "git push origin $branch" "推送代码到远程仓库"
    if (-not $result3.Success) {
        Write-Host ""
        Write-Host "  推送失败，请检查网络连接和权限" -ForegroundColor $Colors.Error
        Pause
        return
    }
    
    # 步骤4: 完成
    Write-Host ""
    Write-Host "  [步骤 4/4] 触发 GitHub Actions 构建" -ForegroundColor $Colors.Step
    Write-Host "  -> GitHub Actions 已自动触发..." -ForegroundColor $Colors.Info
    Write-Host "     [完成]" -ForegroundColor $Colors.Success
    
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  推送成功!" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "  GitHub Actions 正在构建 APK，请稍后访问以下地址下载:" -ForegroundColor $Colors.Info
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        $repoUrl = $remote -replace '\.git$', ''
        Write-Host "  $repoUrl/actions" -ForegroundColor $Colors.Info
    }
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Pause
}

# 发布版本
function Publish-Release {
    param([string]$VersionTag)
    
    Show-Header
    Show-ProjectInfo
    Write-Host "  [正在发布版本]" -ForegroundColor $Colors.Step
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    
    # 获取版本号
    if ([string]::IsNullOrWhiteSpace($VersionTag)) {
        Write-Host "  请输入版本号 (例如: v1.0.0): " -NoNewline -ForegroundColor $Colors.Info
        $VersionTag = Read-Host
    }
    
    # 验证版本号格式
    if ($VersionTag -notmatch '^v?\d+\.\d+\.\d+$') {
        Write-Host "  版本号格式不正确! 请使用格式如: v1.0.0 或 1.0.0" -ForegroundColor $Colors.Error
        Pause
        return
    }
    
    # 确保版本号以 v 开头
    if (-not $VersionTag.StartsWith('v')) {
        $VersionTag = "v$VersionTag"
    }
    
    Write-Host ""
    Write-Host "  即将发布版本: $VersionTag" -ForegroundColor $Colors.Warning
    Write-Host "  这将创建一个 GitHub Release 并构建正式版 APK" -ForegroundColor $Colors.Warning
    Write-Host ""
    Write-Host "  确认发布? (Y/N): " -NoNewline -ForegroundColor $Colors.Info
    $confirm = Read-Host
    
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Host "  已取消发布" -ForegroundColor $Colors.Warning
        Pause
        return
    }
    
    Write-Host ""
    
    # 步骤1: 添加更改
    Write-Host "  [步骤 1/5] 添加更改到暂存区" -ForegroundColor $Colors.Step
    $result1 = Invoke-GitCommand "git add ." "添加所有更改"
    
    # 步骤2: 提交代码
    Write-Host ""
    Write-Host "  [步骤 2/5] 提交代码" -ForegroundColor $Colors.Step
    $commitMsg = "发布版本 $VersionTag"
    $result2 = Invoke-GitCommand "git commit -m `"$commitMsg`"" "提交更改"
    
    # 步骤3: 推送代码
    Write-Host ""
    Write-Host "  [步骤 3/5] 推送代码到 GitHub" -ForegroundColor $Colors.Step
    $branch = git branch --show-current
    $result3 = Invoke-GitCommand "git push origin $branch" "推送代码"
    if (-not $result3.Success) {
        Write-Host ""
        Write-Host "  推送失败" -ForegroundColor $Colors.Error
        Pause
        return
    }
    
    # 步骤4: 创建标签
    Write-Host ""
    Write-Host "  [步骤 4/5] 创建版本标签" -ForegroundColor $Colors.Step
    $result4 = Invoke-GitCommand "git tag $VersionTag" "创建标签 $VersionTag"
    if (-not $result4.Success) {
        Write-Host "  标签可能已存在，尝试继续..." -ForegroundColor $Colors.Warning
    }
    
    # 步骤5: 推送标签
    Write-Host ""
    Write-Host "  [步骤 5/5] 推送标签到 GitHub" -ForegroundColor $Colors.Step
    $result5 = Invoke-GitCommand "git push origin $VersionTag" "推送标签"
    if (-not $result5.Success) {
        Write-Host ""
        Write-Host "  推送标签失败" -ForegroundColor $Colors.Error
        Pause
        return
    }
    
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  版本 $VersionTag 发布成功!" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "  正式版 APK 将自动上传到 Releases 页面" -ForegroundColor $Colors.Info
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        $repoUrl = $remote -replace '\.git$', ''
        Write-Host "  $repoUrl/releases" -ForegroundColor $Colors.Info
    }
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Pause
}

# 查看状态
function Show-Status {
    Show-Header
    Write-Host "  [Git 状态]" -ForegroundColor $Colors.Info
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    
    # 显示详细状态
    git status
    
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Pause
}

# 打开 Actions 页面
function Open-ActionsPage {
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        $repoUrl = $remote -replace '\.git$', ''
        $actionsUrl = "$repoUrl/actions"
        Write-Host "  正在打开: $actionsUrl" -ForegroundColor $Colors.Info
        Start-Process $actionsUrl
    } else {
        Write-Host "  未配置远程仓库" -ForegroundColor $Colors.Error
    }
    Start-Sleep -Seconds 1
}

# 打开 Releases 页面
function Open-ReleasesPage {
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        $repoUrl = $remote -replace '\.git$', ''
        $releasesUrl = "$repoUrl/releases"
        Write-Host "  正在打开: $releasesUrl" -ForegroundColor $Colors.Info
        Start-Process $releasesUrl
    } else {
        Write-Host "  未配置远程仓库" -ForegroundColor $Colors.Error
    }
    Start-Sleep -Seconds 1
}

# 主循环
function Main {
    # 快速推送模式
    if ($QuickPush -and $Message) {
        Push-Code -CommitMessage $Message
        return
    }
    
    # 快速发布模式
    if ($Release -and $Version) {
        Publish-Release -VersionTag $Version
        return
    }
    
    # 交互模式
    while ($true) {
        Show-Header
        Show-ProjectInfo
        Show-Menu
        
        Write-Host "  请选择操作: " -NoNewline -ForegroundColor $Colors.Info
        $choice = Read-Host
        
        switch ($choice.ToUpper()) {
            '1' { Push-Code }
            '2' { Publish-Release }
            '3' { Show-Status }
            '4' { Open-ActionsPage }
            '5' { Open-ReleasesPage }
            'Q' { 
                Show-Header
                Write-Host "  感谢使用!" -ForegroundColor $Colors.Success
                Write-Host ""
                exit 
            }
            default { 
                Write-Host "  无效选择，请重试" -ForegroundColor $Colors.Error
                Start-Sleep -Seconds 1
            }
        }
    }
}

# 启动主程序
Main
