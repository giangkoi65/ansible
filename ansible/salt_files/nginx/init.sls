# ==============================================================================
# BƯỚC 1: CÀI ĐẶT PACKAGE NGINX
# ==============================================================================
install_nginx:
  pkg.installed:
    - name: nginx

# ==============================================================================
# BƯỚC 2: QUẢN LÝ CÁC FILE CẤU HÌNH (SỬ DỤNG JINJA2 CỦA SALT)
# ==============================================================================
# Cấu hình tổng của Nginx
configure_main_nginx:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/templates/nginx.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: install_nginx

# Cấu hình riêng cho Website (Virtual Host)
configure_site_nginx:
  file.managed:
    - name: /etc/nginx/sites-available/mysite.conf
    - source: salt://nginx/templates/site.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: install_nginx

# ==============================================================================
# BƯỚC 3: KÍCH HOẠT VIRTUAL HOST VÀ DỌN DẸP CONFIG CŨ
# ==============================================================================
# Tạo symlink từ sites-available sang sites-enabled
enable_site_nginx:
  file.symlink:
    - name: /etc/nginx/sites-enabled/mysite.conf
    - target: /etc/nginx/sites-available/mysite.conf
    - force: True
    - require:
      - file: configure_site_nginx

# Xóa bỏ cấu hình default của Nginx để tránh tranh chấp port 80
remove_default_site:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

# ==============================================================================
# BƯỚC 4: ĐỒNG BỘ SOURCE CODE WEBSITE (ĐỆ QUY TOÀN BỘ THƯ MỤC)
# ==============================================================================
# Vì Ansible đã ném website vào /srv/salt/website_src/ nên Salt gọi qua salt://website_src
deploy_website_source:
  file.recurse:
    - name: /var/www/my_website
    - source: salt://website_src
    - user: www-data
    - group: www-data
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - require:
      - pkg: install_nginx

# ==============================================================================
# BƯỚC 5: ĐẢM BẢO DỊCH VỤ LUÔN CHẠY VÀ TỰ RELOAD KHI CÓ THAY ĐỔI
# ==============================================================================
nginx_service_running:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - file: configure_main_nginx
      - file: configure_site_nginx
      - file: remove_default_site
      - file: deploy_website_source
