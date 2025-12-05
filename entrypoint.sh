#!/bin/bash
set -e

# 定义挂载路径
REQ_FILE="/opt/cronicle/data/requirements.txt"

# 1. 检查是否有额外的依赖需要安装 (不含 playwright)
if [ -f "$REQ_FILE" ]; then
    echo ">>>> [Init] Found requirements.txt. Installing extra dependencies..."
    # 使用清华源加速
    pip install --no-cache-dir -r "$REQ_FILE" -i https://pypi.tuna.tsinghua.edu.cn/simple
    echo ">>>> [Init] Dependencies installed."
else
    echo ">>>> [Init] No requirements.txt found, skipping pip install."
fi

# 2. Cronicle 初始化
if [ ! -f /opt/cronicle/conf/config.json ]; then
    echo ">>>> [Cronicle] Config file not found, initializing default..."
    /opt/cronicle/bin/control.sh setup
fi

# 3. 启动 Cronicle
echo ">>>> [Cronicle] Starting service..."
/opt/cronicle/bin/control.sh start

# 4. 挂起日志
tail -f /opt/cronicle/logs/cronicle.log