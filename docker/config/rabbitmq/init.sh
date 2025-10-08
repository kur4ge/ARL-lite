#!/bin/bash
set -e

# 等待 RabbitMQ 服务启动
until rabbitmqctl status; do
    echo "Waiting for RabbitMQ to start..."
    sleep 5
done

# 检查虚拟主机是否已存在，如果不存在则创建
if ! rabbitmqctl list_vhosts | grep -q "arlv2host"; then
    echo "Creating vhost: arlv2host"
    rabbitmqctl add_vhost arlv2host
fi

# 为 root 用户设置 arlv2host 的权限
echo "Setting permissions for root on arlv2host"
rabbitmqctl set_permissions -p arlv2host root ".*" ".*" ".*"

echo "RabbitMQ initialization complete."
