# 使用官方 nginx 镜像作为基础镜像
FROM nginx:alpine

# 将当前目录下的 index.html 复制到 nginx 的默认网页目录
COPY index.html /usr/share/nginx/html/

# 暴露 80 端口
EXPOSE 80 