#!/bin/bash

# 定义重试次数
retry_times=100
# 定义重试间隔时间（单位：秒）
sleep_time=5
# 循环执行命令，直到成功或者超过重试次数为止
for ((i=1; i<=$retry_times; i++)) 
do
    # 执行命令，并获取返回值保存到变量中 
    result=$(make push)
    # 判断命令是否执行成功 
    if [ $? -eq 0 ]; then 
        # 成功退出循环 
        break
    else
        # 失败 sleep 5 秒后再次尝试 
        echo "Command failed, retrying after ${sleep_time}s..." 
        sleep $sleep_time
    fi
done