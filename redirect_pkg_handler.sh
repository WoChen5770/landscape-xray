#!/bin/sh

if [ -n "${VLESS_LINK}" ]; then
    echo "检测到VLESS_LINK变量，正在解析VLESS链接..."
    node_config=$(/usr/local/bin/vless_parser.sh "${VLESS_LINK}")
    if [ $? -ne 0 ]; then
        echo "错误: VLESS链接解析失败"
        exit 1
    fi
    echo "解析到的VLESS节点配置: ${node_config}"
    awk -v repl="$node_config" 'BEGIN { target = "{{node_config}}" } { gsub(target, repl); print }' /tmp/config.json > /tmp/config.tmp
    mv /tmp/config.tmp /usr/local/etc/xray/config.json
    echo "VLESS配置已替换到 /usr/local/etc/xray/config.json"
fi

  ip rule add fwmark 0x1/0x1 lookup 100
  ip route add local default dev lo table 100

  /usr/local/bin/redirect_pkg_handler &
  /usr/local/bin/xray run -c /usr/local/etc/xray/config.json &

  wait
