server {
	# redirect www to non-www
    server_name www.example.com;
    return 301 $scheme://example.com$request_uri;
}

server {
	server_name example.com;

	#location /static {
	#    alias /home/chengue/sites/example/static;
	#}

	#location /media {
	#    alias /home/chengue/sites/example/media;
	#}

	location / {
		proxy_set_header Host $host;
		proxy_pass http://unix:/run/gunicorn/socket;
	}
}
