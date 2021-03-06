#!/bin/bash
IFS=$'\n\n'  
if [ $# -ne 1 ];then
    echo "参数错误！"
    echo "正确的格式：sh deploy_jar.sh ***.jar"
    exit
fi

chk=`awk -v var=$1 '{if($1 == var) print}' /data/scripts/baipao/config_jar.txt`
if [ "$chk" = "" ];then
    echo "包 $1 不存在！"
    exit
else
    # 从测试环境获取包
    or_dir=$(echo `awk -v var=$1 '{if($1 == var) print $3}' /data/scripts/baipao/config_jar.txt` | awk '{print $1}')
    cd $or_dir
    # 重命名旧包
#    mv $1 $1.`date +%Y%m%d.%H%M%S`
    # 将包拷贝到 188.188.1.133
#    ssh -p 2222 devuser@218.17.56.50 "sh ~/scripts/get_jar_from_uat.sh $1"
    # 获取测试环境的包
#    scp -P 2222 devuser@218.17.56.50:~/$1 .
    chmod 755 $1

    for l in $chk
    do
        host=`echo $l | awk '{print $2}'`
        or_dir=`echo $l | awk '{print $3}'`
        de_dir=`echo $l | awk '{print $4}'`
        echo "---------------------- 将包发布到 $host 上 ----------------------"
        ssh tomcat@$host "sh /data/scripts/baipao/deploy_jar_agent.sh $1 $or_dir $de_dir"
    done
fi
