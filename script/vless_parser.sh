#!/bin/sh

parse_vless_url() {
    vless_url="$1"
    
    # 检查vless链接格式
    case "$vless_url" in
        vless://*)
            : # 格式正确
            ;;
        *)
            echo "错误: 无效的vless链接格式" >&2
            return 1
            ;;
    esac


    url_without_protocol="${vless_url#vless://}"


    case "$url_without_protocol" in
        *'#'*)
            tag_name="${url_without_protocol##*#}"
            url_without_anchor="${url_without_protocol%#*}"
            ;;
        *)
            tag_name=""
            url_without_anchor="$url_without_protocol"
            ;;
    esac


    case "$url_without_anchor" in
        *@*)
            user_info="${url_without_anchor%%@*}"
            server_info="${url_without_anchor#*@}"
            ;;
        *)
            echo "Error: Cannot parse user ID and server info" >&2
            return 1
            ;;
    esac


    case "$server_info" in
        *\?*)
            address_port="${server_info%%\?*}"
            query_string="${server_info#*\?}"
            ;;
        *)
            address_port="$server_info"
            query_string=""
            ;;
    esac


    case "$address_port" in
        *:*)
            address="${address_port%%:*}"
            port="${address_port##*:}"
            ;;
        *)
            echo "Error: Cannot parse address and port" >&2
            return 1
            ;;
    esac


    urldecode() {
        local encoded="$1"
        encoded=$(echo "$encoded" | sed 's/+/ /g')
        echo "$encoded" | sed 's/%2F/\//g; s/%2f/\//g; s/%20/ /g'
    }


    type_param="tcp"
    security_param="none"
    encryption_param="none"
    flow_param=""
    path_param="/"
    sni_param=""
    fp_param="chrome"
    pbk_param=""
    sid_param=""

    if [ -n "$query_string" ]; then
        rest="$query_string"
        while [ -n "$rest" ]; do
            case "$rest" in
                *'&'*) pair="${rest%%&*}"; rest="${rest#*&}" ;;
                *)   pair="$rest"; rest="" ;;
            esac

            case "$pair" in
                *=*)
                    key="${pair%%=*}"
                    encoded_value="${pair#*=}"
                    value="$(urldecode "$encoded_value")"
                    ;;
                *)
                    key="$pair"
                    value=""
                    ;;
            esac

            case "$key" in
                type) type_param="$value" ;;
                security) security_param="$value" ;;
                encryption) encryption_param="$value" ;;
                flow) flow_param="$value" ;;
                path) path_param="$value" ;;
                sni) sni_param="$value" ;;
                fp) fp_param="$value" ;;
                pbk) pbk_param="$value" ;;
                sid) sid_param="$value" ;;
            esac
        done
    fi


    printf '{\n'
    printf '  "tag": "proxy",\n'
    printf '  "protocol": "vless",\n'
    printf '  "settings": {\n'
    printf '    "vnext": [\n'
    printf '      {\n'
    printf '        "address": "%s",\n' "$address"
    printf '        "port": %s,\n' "$port"
    printf '        "users": [\n'
    printf '          {\n'
    printf '            "id": "%s",\n' "$user_info"

    if [ -n "$flow_param" ]; then
        printf '            "email": "t@t.tt",\n'
        printf '            "security": "auto",\n'
        printf '            "encryption": "%s",\n' "$encryption_param"
        printf '            "flow": "%s"\n' "$flow_param"
    else
        printf '            "security": "auto",\n'
        printf '            "encryption": "%s"\n' "$encryption_param"
    fi

    printf '          }\n'
    printf '        ]\n'
    printf '      }\n'
    printf '    ]\n'
    printf '  },\n'
    printf '  "streamSettings": {\n'
    printf '    "network": "%s",\n' "$type_param"
    printf '    "security": "%s",\n' "$security_param"


    if [ "$type_param" = "xhttp" ]; then
        printf '    "xhttpSettings": {\n'
        printf '      "path": "%s"\n' "$(echo "$path_param" | sed 's/"/\\"/g')"
        printf '    },\n'
    fi


    printf '    "realitySettings": {\n'
    printf '      "serverName": "%s",\n' "$sni_param"
    printf '      "fingerprint": "%s",\n' "$fp_param"
    printf '      "show": false,\n'
    printf '      "publicKey": "%s",\n' "$pbk_param"
    printf '      "shortId": "%s",\n' "$sid_param"

    if [ -n "$flow_param" ]; then
        printf '      "spiderX": "",\n'
        printf '      "mldsa65Verify": ""\n'
    else
        printf '      "spiderX": "/"\n'
    fi

    printf '    }\n'
    printf '  }'


    if [ -n "$flow_param" ]; then
        printf ',\n'
        printf '  "mux": {\n'
        printf '    "enabled": false,\n'
        printf '    "concurrency": -1\n'
        printf '  }'
    fi

    printf '\n}\n'
}

main() {
    if [ "$#" -ne 1 ]; then
        echo "格式: $0 <vless://url>" >&2
        exit 1
    fi
    parse_vless_url "$1"
}

main "$@"