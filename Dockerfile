# 使用官方 nginx 镜像作为基础镜像
FROM nginx:alpine

# 将当前目录下的 index.html 复制到 nginx 的默认网页目录
COPY index.html /usr/share/nginx/html/

# 复制自定义的 nginx 配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 80 端口
EXPOSE 80 