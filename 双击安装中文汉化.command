#!/bin/bash
cd "$(dirname "$0")"

# 补充 macOS 常见环境路径 (兼容 Intel 与 Apple Silicon M 系列芯片及各类包管理器)
export PATH="/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 检查管理员权限，若不是 root 则自动通过 sudo 提权并保留环境变量
if [ "$EUID" -ne 0 ]; then
    echo "======================================================"
    echo " 提示：macOS 系统修改应用程序（/Applications）需要管理员权限"
    echo " 请在下方输入您的电脑开机密码（输入时密码不显示，直接回车）："
    echo "======================================================"
    exec sudo env "PATH=$PATH" "HTTP_PROXY=$HTTP_PROXY" "HTTPS_PROXY=$HTTPS_PROXY" "ALL_PROXY=$ALL_PROXY" "http_proxy=$http_proxy" "https_proxy=$https_proxy" "all_proxy=$all_proxy" "SUDO_USER=$USER" bash "$0" "$@"
fi

# 确保在提权后也具备完整的 PATH
export PATH="/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 检查 Node.js 环境
if ! command -v node &> /dev/null; then
    echo ""
    echo "======================================================"
    echo " [错误] 未检测到 Node.js 环境，无法执行汉化。"
    echo " 请前往 https://nodejs.org 下载安装 Node.js (LTS 版本) 后重试。"
    echo "======================================================"
    echo ""
    echo "按任意键退出..."
    read -n 1 -s
    exit 1
fi

# 检查是否已通过命令行传入 --brand-title
BRAND_ARG="--brand-title english"
for arg in "$@"; do
    if [[ "$arg" == --brand-title* ]]; then
        BRAND_ARG=""
        break
    fi
done

if [ -n "$BRAND_ARG" ] && [ -t 0 ]; then
    echo "====== 正在安装 macOS 版 Antigravity 中文汉化 ======"
    echo "请选择左上角品牌显示方式："
    echo "[1] 显示英文 Antigravity（推荐）"
    echo "[2] 不显示品牌名"
    echo "[3] 显示中文品牌名"
    printf "请输入 1/2/3，直接回车默认 1："
    read -r BRAND_CHOICE
    if [ "$BRAND_CHOICE" = "2" ]; then
        BRAND_ARG="--brand-title hidden"
    elif [ "$BRAND_CHOICE" = "3" ]; then
        BRAND_ARG="--brand-title translated"
    fi
fi

# 若外部未指定 --install-dir 且默认路径存在，则提供默认路径；否则交由引擎探测
INSTALL_DIR_ARG=""
HAS_CUSTOM_INSTALL_DIR=false
for arg in "$@"; do
    if [[ "$arg" == --install-dir* ]]; then
        HAS_CUSTOM_INSTALL_DIR=true
        break
    fi
done

if [ "$HAS_CUSTOM_INSTALL_DIR" = false ] && [ -d "/Applications/Antigravity.app" ]; then
    INSTALL_DIR_ARG="--install-dir /Applications/Antigravity.app"
fi

node localization_engine.js $BRAND_ARG $INSTALL_DIR_ARG "$@"

if [ $? -ne 0 ]; then
    echo ""
    echo "运行失败！请检查上方错误信息。"
    read -n 1 -s
    exit 1
fi

echo ""
echo "处理完成。窗口将在 5 秒后自动关闭（或按任意键立即关闭）..."
read -t 5 -n 1 -s || true
exit 0
