# 基础镜像：用官方MySQL 8.0稳定版（最小体积，兼容性最好）
FROM mysql:8.0

# 核心环境变量（必填：初始root密码；可选：自动创建数据库/用户）
ENV MYSQL_ROOT_PASSWORD=root123456  # 必须填写，root用户初始密码
ENV MYSQL_DATABASE=app_db           # 启动时自动创建的数据库（可选，删掉也能运行）
ENV MYSQL_CHARSET=utf8mb4           # 默认字符集（支持中文和emoji，无多余配置）

# 暴露MySQL默认端口（3306）
EXPOSE 3306

# 沿用官方启动命令（无需修改，保证稳定性）
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]
