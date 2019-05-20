#! make

# File: Makefile
# Last modified: mån maj 20, 2019  01:06
# Sign: JN

SHELL=/bin/bash

MYWD=$(shell pwd)

all: browse

up:
	docker run \
		--detach \
		--net=host \
		--name=AcetoScan \
		-v $(MYWD)/indata:/AcetoScan/indata \
		-v $(MYWD)/outdata:/AcetoScan/outdata \
		-it acetoscan:0.1
down:
	docker stop AcetoScan 
	docker rm -vf AcetoScan

browse: up
	docker exec -it AcetoScan /sbin/my_init -- acetoscan
	#docker exec -it AcetoScan /sbin/my_init -- bash
	#docker exec -it acetoscan:0.1 /sbin/my_init -- bash
	#docker exec -it acetoscan:0.1 /sbin/my_init -- bash -l

