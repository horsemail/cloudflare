#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 从环境变量中获取参数
EMAIL=${EMAIL:-"horsemailma@gmail.com"}
DOMAINS="one-api.horsenma.net,newbing.horsenma.net,speedtest.horsenma.net,bing.horsenma.net,blog.horsenma.net,vp.horsenma.net,chat.horsenma.net,chatgpt.horsenma.net,freegpt.horsenma.net"
#CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY:-"6269d402124e0b2a6a4954fc40211d4af1a76"}
CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY:-"e38e7b7aba6e3fdf0045331003c046e9773ae"}

# 设置 acme.sh 的 Cloudflare API 密钥
export CF_Key="$CLOUDFLARE_API_KEY"
export CF_Email="$EMAIL"

# 安装或更新 acme.sh
if [[ ! -d /root/.acme.sh ]]; then
  apt update
  apt install certbot
  apt install python3-certbot-nginx

  curl https://get.acme.sh | sh
else
  ~/.acme.sh/acme.sh --upgrade
  ~/.acme.sh/acme.sh --register-account -m horsemailma@gmail.com
fi

if [ ! -d "/root/net" ]; then
   mkdir -p "/root/net"
fi

# 安装证书
for domain in $(echo $DOMAINS | sed 's/,/ /g'); do

    subdir=$(echo "$domain" | cut -d '.' -f 1)
    # 检查子目录是否存在，如果不存在则创建
    if [ ! -d "/root/net/$subdir" ]; then
       mkdir -p "/root/net/$subdir"
    fi
    ~/.acme.sh/acme.sh --issue --dns dns_cf -d "$domain" --force
    if [ "$subdir" = "vp" ] ; then
       ~/.acme.sh/acme.sh --install-cert -d "$domain" \
         --key-file /root/net/$domain.key \
         --fullchain-file /root/net/fullchain.cer;
    fi
    ~/.acme.sh/acme.sh --install-cert -d "$domain" \
      --key-file /root/net/$subdir/$domain.key \
      --fullchain-file /root/net/$subdir/fullchain.cer;
done

nginx -s reload

