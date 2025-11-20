-- 创建测试表（示例）
USE app_db;  -- 对应Dockerfile中的 MYSQL_DATABASE=app_db

CREATE TABLE IF NOT EXISTS user_info (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    email VARCHAR(100) UNIQUE NOT NULL COMMENT '邮箱',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 插入测试数据
INSERT INTO user_info (username, email) VALUES 
('ubuntu_user', 'ubuntu@example.com'),
('mysql_docker', 'mysql@example.com');

-- 给普通用户授权（对应Dockerfile中的 MYSQL_USER=app_user）
GRANT SELECT, INSERT, UPDATE, DELETE ON app_db.* TO 'app_user'@'%';
FLUSH PRIVILEGES;