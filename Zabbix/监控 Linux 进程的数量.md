创建监控项

![image-20191216102055042](C:/Users/haiqi/Desktop/devops-note/Zabbix/assets/image-20191216102055042.png)

关于proc.num[<name>,<user>,<state>,<cmdline>]

>**name** - 进程名称 (默认是 *all processes*) 
>
>**user** - 用户名 (默认是 *all users*) 
>
>**state** - 可选的值: *all* (default), *run*, *sleep*, *zomb* 
>
>**cmdline** - 按命令行过滤（它是一个正则表达式）
>
>示例:
>⇒ proc.num[,mysql] → 在mysql用户下运行的进程数
>⇒ proc.num[apache2,www-data] → 在www-data用户下运行的apache2进程数
>⇒ proc.num[,oracle,sleep,oracleZABBIX] → 在oracleZABBIX命令行下的oracle用户运行的睡眠状态进程数。
>
>参考 说明 关于选择进程 name 和 cmdline 参数(适用于Linux).
>
>在Windows上，只支持name和user参数。

