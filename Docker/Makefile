#! make

# File: Makefile
# Last modified: ons maj 08, 2019  02:18
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
	docker exec -it AcetoScan /sbin/my_init -- bash
	#docker exec -it acetoscan:0.1 /sbin/my_init -- bash
	#docker exec -it acetoscan:0.1 /sbin/my_init -- bash -l

