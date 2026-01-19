# Landscape Xray Docker 项目

这是一个基于Xray-core的Docker镜像构建项目。
集成Loyalsoldier/v2ray-rules-dat的geo文件，
集成landscape的[redirect_pkg_handler](https://github.com/ThisSeanZhang/landscape)

## Docker Hub

镜像地址: [jaycq/landscape-xray](https://hub.docker.com/r/jaycq/landscape-xray)

## GitHub

源代码: [GitHub Repository](https://github.com/WoChen5770/landscape-xray)


## 运行容器

### 基本运行
```docker compose
services:
  landscape-xray:
    image: jaycq/landscape-xray:latest
    container_name: xray
    sysctls:
      - net.ipv4.conf.lo.accept_local=1
    cap_add:
      - NET_ADMIN
      - BPF
      - PERFMON
    privileged: true 
    volumes:
      - ./logs:/var/log/xray
      - ./config:/usr/local/etc/xray
      - /app/landscape/unix_link/:/ld_unix_link/:ro
    #environment:
    #  - VLESS_LINK=vless://12345678-1234-5678-1234-567812345678@127.0.0.1:443?encryption=none&security=tls&sni=www.baidu.com#xray
```

## 注意事项

1. 确保挂载的配置目录config包含有效的Xray配置文件
2. 也可配置环境变量VLESS_LINK，用于指定vless链接
3. 以上二选一即可，若同时配置，VLESS_LINK优先级高
