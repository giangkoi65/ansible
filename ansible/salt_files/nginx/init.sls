# ==============================================================================
# STATE 1: CÀI ĐẶT GÓI NGINX
# ==============================================================================
nginx_package:
  pkg.installed:
    - name: nginx

# ==============================================================================
# STATE 2: QUẢN LÝ FILE CẤU HÌNH TỔNG (NGINX.CONF) VIA JINJA2
# ==============================================================================
nginx_main_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/templates/nginx.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: nginx_package

# ==============================================================================
# STATE 3: QUẢN LÝ FILE VIRTUAL HOST MẶC ĐỊNH
# ==============================================================================
nginx_site_config:
  file.managed:
    - name: /etc/nginx/sites-available/default
    - source: salt://nginx/templates/site.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: nginx_package

# Sửa lỗi tạo symlink nếu Nginx trên hệ thống chưa tự kích hoạt sites-enabled
nginx_site_enable:
  file.symlink:
    - name: /etc/nginx/sites-enabled/default
    - target: /etc/nginx/sites-available/default
    - force: True
    - require:
      - file: nginx_site_config

# ==============================================================================
# STATE 4: ĐỒNG BỘ SOURCE CODE WEBSITE & CHỐNG DRIFT MÃ NGUỒN
# ==============================================================================
# Giải thích: Ansible đẩy code vào `/srv/salt/website_src/` trên Master.
# Salt dùng gốc 'salt://' để kéo toàn bộ cấu trúc thư mục này về Minion.
website_source_sync:
  file.recurse:
    - name: /var/www/html
    - source: salt://website_src
    - clean: True  # CHỐNG DRIFT: Tự động xóa file thừa ở Minion nếu trên Git không có
    - user: www-data
    - group: www-data
    - dir_mode: '0755'
    - file_mode: '0644'
    - require:
      - pkg: nginx_package

# ==============================================================================
# STATE 5: GIÁM SÁT VÀ KHỞI ĐỘNG DỊCH VỤ
# ==============================================================================
nginx_service_control:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: nginx_main_config
      - file: nginx_site_config
      - file: website_source_sync
