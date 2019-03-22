# set name for envirments you want

IMAGE_NAME=env_baseline

run_bash:
	#GUI POSSIBLE
	#sudo docker run -d --runtime=nvidia --volume="/home/rd/.Xauthority:/root/.Xauthority:rw" --env="DISPLAY" --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash
	sudo docker exec -ti env_baseline /bin/bash

build_image:

	#for test
	#sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi

	sudo docker build -t $(IMAGE_NAME) .		
	#  					 "/home/username/..."
	sudo docker run -d --runtime=nvidia --volume="/home/rd/.Xauthority:/root/.Xauthority:rw" --env="DISPLAY" --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

build_dependency:

	mkdir /usr/lib/systemd/system
	echo "[Unit]\n\
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
	
	curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
	curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
	sudo tee /etc/apt/sources.list.d/nvidia-docker.list

	sudo apt-get update
	
	sudo apt-get remove docker docker-engine docker.io

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"

	sudo apt-get update
	sudo apt install docker-ce

	sudo apt-get remove docker docker-engine docker.io

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"

	sudo apt-get update
	sudo apt install docker-ce

	sudo apt-get install -y nvidia-docker2
	sudo pkill -SIGHUP dockerd
	ls -la /dev | grep nvidia

	#docker build -t $(IMAGE_NAME)
	sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
	sudo docker build -t $IMAGE_NAME .	
	#  					     "/home/username/...
	#sudo docker run -d --runtime=nvidia --volume="/home/rd/.Xauthority:/root/.Xauthority:rw" --env="DISPLAY" --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash


#how to transfer files 
#docker cp foo.txt env_baseline:/foo.txt
#docker cp env_baseline:/foo.txt foo.txt
