# syntax=docker/dockerfile:latest
FROM --platform=$BUILDPLATFORM alpine:latest AS download

LABEL maintainer="jaycq"
LABEL description="Landscape Xray with redirect_pkg_handler integration"

RUN apk add --no-cache curl unzip

WORKDIR /tmp

ARG TARGETOS
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        ARCH="64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        ARCH="arm64-v8a"; \
    else \
        ARCH="64"; \
    fi && \
    curl -L -o xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-${TARGETOS}-${ARCH}.zip" && \
    unzip xray.zip && \
    chmod +x xray

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        ARCH="x86_64-musl"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        ARCH="aarch64"; \
    else \
        ARCH="x86_64-musl"; \
    fi && \
    curl -L -o redirect_pkg_handler "https://github.com/ThisSeanZhang/landscape/releases/latest/download/redirect_pkg_handler-${ARCH}" && \
    chmod +x redirect_pkg_handler
    

RUN mkdir -p /tmp/geodat /tmp/usr/local/share/xray /tmp/usr/local/etc/xray

ADD https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat /tmp/geodat/geoip.dat
ADD https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat /tmp/geodat/geosite.dat


# 构建最终镜像
FROM alpine:latest AS final
RUN apk add --no-cache ca-certificates libelf libgcc
# 复制二进制文件
COPY --from=download --chown=0:0 /tmp/xray /usr/local/bin/xray
COPY --from=download --chown=0:0 /tmp/redirect_pkg_handler /usr/local/bin/
# 复制 Geo 数据和配置
COPY --from=download --chown=0:0 /tmp/geodat/*.dat /usr/local/share/xray/

# 时区设置
ARG TZ=Etc/UTC
ENV TZ=$TZ

# 复制配置文件和脚本
COPY --chown=0:0 script/config.json /tmp/config.json
COPY --chown=0:0 --chmod=755 redirect_pkg_handler.sh /usr/local/bin/
COPY --chown=0:0 --chmod=755 script/vless_parser.sh /usr/local/bin/

RUN ls -l /usr/local/bin/
# 设置VLESS_LINK环境变量（可选）
ENV VLESS_LINK=""

# 入口点（无需 RUN chmod！）
ENTRYPOINT ["/usr/local/bin/redirect_pkg_handler.sh"]
