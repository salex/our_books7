<!-- prod_setup.md

our_books sites-enabled
 -->
upstream puma_our_books {
  server unix:///home/rails/apps/our_books/shared/tmp/sockets/puma.sock fail_timeout=0;

}

server {
  server_name  our_books.vfwpost8600.org;

  root /home/rails/apps/our_books/current/public;
  access_log /home/rails/apps/our_books/current/log/nginx.access.log;
  error_log /home/rails/apps/our_books/current/log/nginx.error.log info;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  try_files $uri/index.html $uri @puma_rcash;
  location @puma_rcash {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-Ssl on;
    proxy_pass http://puma_rcash;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/vfwpost8600.org-0001/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/vfwpost8600.org-0001/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}



server {

    if ($host = our_books.vfwpost8600.org) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  listen 80;
  server_name  our_books.vfwpost8600.org;
    return 404; # managed by Certbot

<!-- systemd -->

[Unit]
Description=Puma for our_books
After=network.target

[Service]
Type=simple
User=rails
WorkingDirectory=/home/rails/apps/our_books/current

ExecStart=/home/rails/.rbenv/bin/rbenv exec bundle exec puma -C /home/rails/apps/our_books/shared/puma.rb
# ExecStart=RBENV_ROOT=$HOME/.rbenv RBENV_VERSION=2.7.2 $HOME/.rbenv/bin/rbenv exec bundle exec puma -C /home/rails/apps/our_books/shared/puma.rb
# ExecReload=/bin/kill -TSTP $MAINPID
ExecReload=/bin/kill -USR1 $MAINPID
StandardOutput=append:/home/rails/apps/our_books/shared/log/puma_access.log
StandardError=append:/home/rails/apps/our_books/shared/log/puma_error.log




Restart=always
RestartSec=1

SyslogIdentifier=puma

[Install]
WantedBy=multi-user.target

