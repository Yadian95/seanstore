# 基础镜像：使用官方MySQL 8.0（基于Debian，与Ubuntu二进制兼容，稳定性更强）
FROM mysql:8.0

# 维护者信息（可选）
LABEL maintainer="your-name <your-email@example.com>"
LABEL description="MySQL 8.0 镜像（适配Ubuntu系统，支持自定义配置、初始化脚本）"

# 1. 安装Ubuntu常用依赖（可选，解决部分Ubuntu环境下的兼容问题）
# 注：官方MySQL镜像已包含核心依赖，此处仅补充Ubuntu环境可能缺失的工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    vim \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*  # 清理apt缓存，减小镜像体积

# 2. 自定义MySQL配置（核心：覆盖默认配置，适配Ubuntu环境）
# 创建自定义配置目录（避免直接修改/etc/mysql/my.cnf，便于挂载）
RUN mkdir -p /etc/mysql/conf.d/custom \
    && chown -R mysql:mysql /etc/mysql/conf.d/custom \
    && chmod 755 /etc/mysql/conf.d/custom

# 复制自定义配置文件（本地需提前创建 my-custom.cnf，若无则注释此行）
# 示例配置：解决Ubuntu下字符集、连接数、日志等问题
COPY ./my-custom.cnf /etc/mysql/conf.d/custom/
RUN chown mysql:mysql /etc/mysql/conf.d/custom/my-custom.cnf && chmod 644 /etc/mysql/conf.d/custom/my-custom.cnf

# 3. 配置数据持久化目录（适配Ubuntu宿主目录权限）
# 官方默认数据目录为 /var/lib/mysql，此处明确指定并优化权限
RUN chown -R mysql:mysql /var/lib/mysql \
    && chmod 700 /var/lib/mysql  # MySQL要求数据目录权限为700（仅所有者可读写）

# 4. 初始化脚本支持（可选：容器启动时自动执行SQL脚本/Shell脚本）
# 创建初始化脚本目录（官方默认支持/docker-entrypoint-initdb.d目录）
RUN mkdir -p /docker-entrypoint-initdb.d \
    && chown -R mysql:mysql /docker-entrypoint-initdb.d \
    && chmod 755 /docker-entrypoint-initdb.d

# 复制初始化SQL脚本（本地需提前创建 init-script.sql，若无则注释此行）
# 用途：创建数据库、初始化表结构、导入测试数据等（仅首次启动执行）
COPY ./init-script.sql /docker-entrypoint-initdb.d/
RUN chown mysql:mysql /docker-entrypoint-initdb.d/init-script.sql && chmod 644 /docker-entrypoint-initdb.d/init-script.sql

# 5. 环境变量配置（核心：设置MySQL初始参数，支持运行时覆盖）
# 注：生产环境建议通过 docker run -e 或 docker-compose 传递，避免硬编码密码
ENV MYSQL_ROOT_PASSWORD=root123456  # 初始root密码（必填）
ENV MYSQL_DATABASE=app_db           # 容器启动时自动创建的数据库（可选）
ENV MYSQL_USER=app_user             # 自动创建的普通用户（可选）
ENV MYSQL_PASSWORD=app123456        # 普通用户密码（可选）
ENV MYSQL_CHARSET=utf8mb4           # 默认字符集（支持emoji）
ENV MYSQL_COLLATION=utf8mb4_unicode_ci  # 默认排序规则

# 6. 暴露MySQL默认端口（3306）
EXPOSE 3306 33060  # 33060是MySQL 8.0的X Protocol端口（可选暴露）

# 7. 启动命令（沿用官方入口脚本，保证兼容性）
# 官方entrypoint已处理初始化、权限、配置加载等逻辑，无需修改
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]