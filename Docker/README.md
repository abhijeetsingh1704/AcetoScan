# README AcetoScan Docker

- Last modified: tis maj 07, 2019  04:57
- SIgn: JN

## Notes

Use phusion/baseimage. See <https://github.com/phusion/baseimage-docker/>

### To try out phusion/baseimage on command line:

    docker run --rm -t -i phusion/baseimage:0.11 /sbin/my_init -- bash -l

## Useful docker commands:

- List containers: `docker ps -a`
- Stop container: `docker stop <CONTAINER_ID>`
- Remove container: `docker rm <CONTAINER_ID>`
- List images: `docker images -a`
- Remove image: `docker rmi <IMAGE_ID>`
- Remove containers and images: `docker system prune -a`


## AcetoScan (with Dockerfile in the cwd)

    docker build -t "acetoscan:0.1" .
    docker history acetoscan:0.1
    docker tag acetoscan nylander/acetoscan
    docker push nylander/acetoscan:0.1


## Run AceoScan from the docker

    docker run --rm -it acetoscan:0.1 /sbin/my_init -- acetoscan
    docker run --rm -it acetoscan:0.1 /sbin/my_init -- bash -l

    docker run acetoscan:0.1 /sbin/my_init
    docker ps
    docker exec YOUR-CONTAINER-ID acetoscan
    docker exec -t -i YOUR-CONTAINER-ID bash -l


