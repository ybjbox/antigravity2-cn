#!/bin/bash
cd "$(dirname "$0")"

# 補充 macOS 常見環境路徑 (相容 Intel 與 Apple Silicon M 系列晶片及各類套件管理器)
export PATH="/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 檢查管理員權限，若不是 root 則自動透過 sudo 提權並保留環境變數
if [ "$EUID" -ne 0 ]; then
    echo "======================================================"
    echo " 提示：macOS 系統修改應用程式（/Applications）需要管理員權限"
    echo " 請在下方輸入您的電腦開機密碼（輸入時密碼不顯示，直接 Enter）："
    echo "======================================================"
    exec sudo env "PATH=$PATH" "HTTP_PROXY=$HTTP_PROXY" "HTTPS_PROXY=$HTTPS_PROXY" "ALL_PROXY=$ALL_PROXY" "http_proxy=$http_proxy" "https_proxy=$https_proxy" "all_proxy=$all_proxy" "SUDO_USER=$USER" bash "$0" "$@"
fi

# 確保在提權後也具備完整的 PATH
export PATH="/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 檢查 Node.js 環境
if ! command -v node &> /dev/null; then
    echo ""
    echo "======================================================"
    echo " [錯誤] 未偵測到 Node.js 環境，無法執行中文化。"
    echo " 請前往 https://nodejs.org 下載安裝 Node.js (LTS 版本) 後重試。"
    echo "======================================================"
    echo ""
    echo "按任意鍵退出..."
    read -n 1 -s
    exit 1
fi

# 檢查是否已透過命令列傳入 --brand-title
BRAND_ARG="--brand-title english"
for arg in "$@"; do
    if [[ "$arg" == --brand-title* ]]; then
        BRAND_ARG=""
        break
    fi
done

if [ -n "$BRAND_ARG" ] && [ -t 0 ]; then
    echo "====== 正在安裝 macOS 版 Antigravity 繁體中文漢化 ======"
    echo "請選擇左上角品牌顯示方式："
    echo "[1] 顯示英文 Antigravity（推薦）"
    echo "[2] 不顯示品牌名稱"
    echo "[3] 顯示繁體中文品牌名"
    printf "請輸入 1/2/3，直接 Enter 預設 1："
    read -r BRAND_CHOICE
    if [ "$BRAND_CHOICE" = "2" ]; then
        BRAND_ARG="--brand-title hidden"
    elif [ "$BRAND_CHOICE" = "3" ]; then
        BRAND_ARG="--brand-title translated"
    fi
fi

# 若外部未指定 --install-dir 且預設路徑存在，則提供預設路徑；否則交由引擎探測
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

node localization_engine.js --tw $BRAND_ARG $INSTALL_DIR_ARG "$@"

if [ $? -ne 0 ]; then
    echo ""
    echo "執行失敗！請檢查上方錯誤訊息。"
    read -n 1 -s
    exit 1
fi

echo ""
echo "處理完成。視窗將在 5 秒後自動關閉（或按任意鍵立即關閉）..."
read -t 5 -n 1 -s || true
exit 0
