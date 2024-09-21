.PHONY: container
container:
	docker build -t wire48:latest .
	docker run -p 8080:80 --rm -it wire48:latest
