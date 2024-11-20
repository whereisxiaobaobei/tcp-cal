#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 设置网络参数
echo "正在配置系统网络参数..."
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_wmem = 4096 16384 67108864
net.ipv4.tcp_rmem = 4096 87380 67108864
EOF

# 使网络参数生效
sysctl -p

# 获取网络接口名称
echo "可用的网络接口："
ip a
read -p "请输入要限速的网络接口名称（默认eth0）: " INTERFACE
INTERFACE=${INTERFACE:-eth0}

# 获取限速值
read -p "请输入限速值（Mbit）: " SPEED_LIMIT

# 清除现有TC配置
tc qdisc del dev $INTERFACE root 2>/dev/null

# 配置TC限速
echo "正在配置TC限速..."
tc qdisc add dev $INTERFACE root handle 1:0 htb default 10
tc class add dev $INTERFACE parent 1:0 classid 1:1 htb rate ${SPEED_LIMIT}mbit ceil ${SPEED_LIMIT}mbit
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip src 0.0.0.0/0 flowid 1:1
tc class add dev $INTERFACE parent 1:0 classid 1:2 htb rate ${SPEED_LIMIT}mbit ceil ${SPEED_LIMIT}mbit
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip dst 0.0.0.0/0 flowid 1:2

# 显示TC配置结果
echo "当前TC配置："
tc qdisc show dev $INTERFACE
tc class show dev $INTERFACE
tc -s filter show dev $INTERFACE

# 配置开机自启
echo "正在配置开机自启..."
cat > /etc/rc.local << EOF
#!/bin/bash
tc qdisc add dev $INTERFACE root handle 1:0 htb default 10
tc class add dev $INTERFACE parent 1:0 classid 1:1 htb rate ${SPEED_LIMIT}mbit ceil ${SPEED_LIMIT}mbit
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip src 0.0.0.0/0 flowid 1:1
tc class add dev $INTERFACE parent 1:0 classid 1:2 htb rate ${SPEED_LIMIT}mbit ceil ${SPEED_LIMIT}mbit
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip dst 0.0.0.0/0 flowid 1:2

exit 0
EOF

# 设置rc.local可执行权限
chmod +x /etc/rc.local

echo "配置完成！系统将在重启后自动应用限速设置"
echo "当前限速值为: ${SPEED_LIMIT}Mbit" 