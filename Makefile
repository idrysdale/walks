SERVER = www.idrysdale.com

.PHONY: build
build:
	bundle exec middleman build

.PHONY: install
install: build
	ssh www.iandrysdale.com "sudo /bin/mount_read_write"
	rsync -avz --delete build/ www.iandrysdale.com:/home/idrysdale/www
	ssh www.iandrysdale.com "sudo /bin/mount_read_only"
