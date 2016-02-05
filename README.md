## Run

The binhost repository is located at `/usr/gentoo-binhost` and the
distdir for the binhost at `/srv/binhost`, so you may want to mount
these in from the host or create data volume containers.

This image contains an nginx server that will listen on port `80`
and serve `/srv/binhost`.

Example command to start a container:
```sh
docker run -ti -d \
	--name=binhost \
	-p 80:80 \
	-v <host-folder>:/srv/binhost \
	-v <host-folder>:/usr/gentoo-binhost \
	mosaiksoftware/gentoo-binhost
```

Then you can `docker exec -ti binhost bash` into the container and start
building stuff. After that, you will want to push the changes in
`/usr/gentoo-binhost` to the remote repository.
