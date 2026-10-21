# 检查OpenSSH 的可用性
以管理员身份打开PowerShell并运行：
```bash
Get-WindowsCapability -Online | Where-Object Name -like  'OpenSSH*'
```

然后会显示：
```bash
(base) PS C:\WINDOWS\system32> Get-WindowsCapability -Online | Where-Object Name -like  'OpenSSH*'


Name  : OpenSSH.Client~~~~0.0.1.0
State : Installed

Name  : OpenSSH.Server~~~~0.0.1.0
State : NotPresent
```
表明SSH客户端可用而服务器端还需要手动安装。

根据 PowerShell (Admin) 中的要求使用以下命令。
# 安装 OpenSSH 客户端

```bash
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~ 0.0.1.0
```

# 安装 OpenSSH 服务器
```bash
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```
