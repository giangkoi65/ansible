```text
ansible/                           # repo
├── .github/workflows/deploy.yml   # Định nghĩa pipeline tự động hóa của GitHub Actions
├── scripts/                       # Chứa các kịch bản lệnh bổ trợ vận hành hệ thống
├── website/                       # Chứa mã nguồn trang web cần deploy xuống Minion
│   └── index.html                 # Trang giao diện chính của website
│
└── ansible/                       # Chứa toàn bộ kịch bản và cấu hình của Ansible
    ├── ansible.cfg                # Thiết lập các thông số môi trường mặc định cho Ansible
    ├── inventory.ini              # Định nghĩa địa chỉ IP và phân vai trò Master/Minion
    ├── site.yml                   # Tệp thực thi chính (Entrypoint) để chạy Ansible Playbook
    │
    ├── roles/                     # Thư mục quản lý các cụm tính năng (Roles) độc lập
    │   └── saltstack/             # Role xử lý toàn bộ vòng đời cài đặt, cấu hình SaltStack
    │       ├── defaults/main.yml  # Định nghĩa các biến môi trường và thông số mặc định
    │       ├── handlers/main.yml  # Tự động restart dịch vụ Salt khi phát hiện thay đổi cấu hình
    │       ├── tasks/main.yml     # Logic cốt lõi: Cài đặt Salt, đồng bộ key, kích hoạt deploy
    │       └── templates/         # Chứa file cấu hình mẫu dạng Jinja2 cho các nút Salt
    │           ├── master.j2      # Mẫu cấu hình hệ thống cho các máy chủ Salt Master
    │           └── minion.j2      # Mẫu cấu hình định danh và trỏ cụm cho Salt Minion
    │
    └── salt_files/                # Nơi lưu trữ các kịch bản State cục bộ của SaltStack
        └── nginx/                 # Khối quản lý trạng thái dịch vụ web Nginx
            ├── init.sls           # Kịch bản Salt định nghĩa cài gói, sync code và quản lý dịch vụ
            └── templates/         # Chứa file cấu hình mẫu Nginx bàn giao cho Salt quản lý
                ├── nginx.conf.j2  # Bản mẫu cấu hình lõi hệ thống cho dịch vụ Nginx
                └── site.conf.j2   # Bản mẫu cấu hình Virtual Host chạy website (Port 80)
```
