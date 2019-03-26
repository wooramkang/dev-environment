# set name for envirments you want

IMAGE_NAME=env_base

run_bash:
	#GUI POSSIBLE
	sudo docker exec -ti $(IMAGE_NAME) /bin/bash

build_only_image:

	#for test
	#sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
	#for build

	sudo docker build -t $(IMAGE_NAME) .
	#  					     "/home/username/..."
	sudo docker run -d --runtime=nvidia --volume="/home/rd/.Xauthority:/root/.Xauthority:rw" --env="DISPLAY" --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

build_first_time:
	#for build
	#mkdir /usr/lib/systemd/system
	
	sudo apt-get remove docker docker-engine docker.io
	sudo apt-get purge docker*

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"

	sudo apt-get update	
	sudo apt install docker-ce
	sudo apt-get install docker docker-engine docker.io

	sudo echo "[Unit]\n\
	Description=NVIDIA Persistence Daemon\n\
	Wants=syslog.target\n\
	\n\
	[Service]\n\
	Type=forking\n\
	PIDFile=/var/run/nvidia-persistenced/nvidia-persistenced.pid\n\
	Restart=always\n\
	ExecStart=/usr/bin/nvidia-persistenced --verbose\n\
	ExecStopPost=/bin/rm -rf /var/run/nvidia-persistenced\n\
	\n\
	[Install]\n\
	WantedBy=multi-user.target" > /usr/lib/systemd/system/nvidia-persistenced.service 

	sudo systemctl enable nvidia-persistenced
	
	docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
	sudo apt-get purge -y nvidia-docker
	
	curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
	sudo apt-key add -
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
	curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
	sudo tee /etc/apt/sources.list.d/nvidia-docker.list
	sudo apt-get update
	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 9BDB3D89CE49EC21
	sudo apt-get update

	sudo apt-get install -y nvidia-docker
	sudo apt-get install -y nvidia-docker2
	sudo pkill -SIGHUP dockerd
	#ls -la /dev | grep nvidia

	sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
	sudo docker build -t $(IMAGE_NAM)E .	
	#  					     "/home/username/...
	sudo docker run -d --runtime=nvidia --volume="/home/rd/.Xauthority:/root/.Xauthority:rw" --env="DISPLAY" --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash


#how to transfer files 
#docker cp foo.txt env_baseline:/foo.txt
#docker cp env_baseline:/foo.txt foo.txt
