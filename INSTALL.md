# 安装说明

## 安装

在 `D:\work\OhMyPm` 执行：

```powershell
powershell -File .\installers\install.ps1
```

## 项目启用

在目标项目根目录执行：

```powershell
powershell -File D:\work\OhMyPm\scripts\control\init-project.ps1
```

启用后项目内会有：

- `.ohmypm/status.json`
- `.ohmypm/memory.md`
- `output/prd`
- `output/prototype`
- `output/review`

## 使用

- 默认自然语言触发
- 必要时可强制执行 `ompgo.ps1`
