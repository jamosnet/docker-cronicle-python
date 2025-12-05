#!/bin/bash
set -e

# === 1. 动态安装 Python 依赖 ===
REQ_FILE="/opt/cronicle/data/requirements.txt"
if [ -f "$REQ_FILE" ]; then
    echo ">>>> [Init] Found requirements.txt. Installing extra dependencies..."
    pip install --no-cache-dir -r "$REQ_FILE" -i https://pypi.tuna.tsinghua.edu.cn/simple
    echo ">>>> [Init] Dependencies installed."
else
    echo ">>>> [Init] No requirements.txt found, skipping pip install."
fi

# === 2. 优化后的 Setup 逻辑 ===
# 如果 config.json 不存在，或者 data 目录是空的（没有 .setup_completed 标记），则运行 setup
DATA_MARKER="/opt/cronicle/data/.setup_completed"
CONFIG_FILE="/opt/cronicle/conf/config.json"

if [ ! -f "$CONFIG_FILE" ] || [ ! -f "$DATA_MARKER" ]; then
    echo ">>>> [Init] Configuration or Data missing. Running Cronicle Setup..."
    
    # 运行 setup
    /opt/cronicle/bin/control.sh setup
    
    # 标记 setup 已完成
    touch "$DATA_MARKER"
    echo ">>>> [Init] Setup completed."
else
    echo ">>>> [Init] Setup marker found. Skipping setup."
fi

# === 3. 启动 Cronicle ===
echo ">>>> [Cronicle] Starting service..."
/opt/cronicle/bin/control.sh start

# === 4. 智能追踪日志 (核心修复) ===
LOG_DIR="/opt/cronicle/logs"

echo ">>>> [Cronicle] Waiting for log file to appear in $LOG_DIR..."

# 循环等待，直到 logs 目录下出现任何 .log 文件
# ls -1qA 只是为了检查目录下是否有文件
while [ -z "$(ls -A $LOG_DIR/*.log 2>/dev/null)" ]; do
    sleep 1
done

# 自动找到最新的那个 log 文件 (无论是 Cronicle.log 还是 cronicle.log)
LOG_FILE=$(ls -t $LOG_DIR/*.log | head -1)

echo ">>>> [Cronicle] Log file found: $LOG_FILE"
echo ">>>> [Cronicle] Tailing logs..."

# 追踪这个文件
tail -f "$LOG_FILE"
