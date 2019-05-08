# README AcetoScan Docker

- Last modified: ons maj 08, 2019  03:23
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

    #docker run --rm -it acetoscan:0.1 /sbin/my_init -- acetoscan
    docker run --rm -it acetoscan:0.1 /sbin/my_init -- bash -l

    host_indata_folder=
    host_outdata_folder=
    docker run \
        --net=host \
        -v "$host_indata_folder":/AcetoScan/indata \
        -v "$host_outdata_folder":/NBIS_3080/outdata \
        -v "$host_sandbox_folder":/NBIS_3080/sandbox \
        -v "$host_refpkg_data_folder":/NBIS_3080/refpkg-data \
        -it nylander/nbis3080:1.4

