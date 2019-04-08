# set name for envirments you want

IMAGE_NAME=base_p35_c90


run_bash:
	#GUI POSSIBLE
	sudo docker exec -ti $(IMAGE_NAME) /bin/bash

build_image_again:
	#for build
	sudo docker kill $(IMAGE_NAME) 
	sudo docker rm $(IMAGE_NAME)
	sudo docker rmi $(IMAGE_NAME)
	sudo docker build -t $(IMAGE_NAME) .
	#  					     "/home/username/..."
	sudo docker run -d --runtime=nvidia -v /:/host_data/ -v /home/$(USER)/.Xauthority:/root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

build_only_image:

	#for test
	#sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi

	#for build
	sudo docker build -t $(IMAGE_NAME) .
	sudo docker run -d --runtime=nvidia -v /:/host_data/ -v /home/$(USER)/.Xauthority:/root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

	#  					     "/home/username/..."
#	sudo docker run -d --runtime=nvidia --volume="/home/$(USER)/.Xauthority:/root/.Xauthority:rw" --#env="DISPLAY" --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

	#sudo docker run -d --runtime=nvidia -v /home/$(USER)/:/home/$(USER)/ -v /home/$(USER)/.Xauthority:/root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

#sudo docker run -d --runtime=nvidia -v /home/$(USER)/recognition_research/:/CODE/ -v /home/$(USER)/.Xauthority:/#root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name #$(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

build_first_time:
	#for build

	export TIMEZONE=UTC
	sudo cp /usr/share/zoneinfo/UTC /etc/localtime
	sudo echo "UTC" | sudo tee /etc/timezone
	sudo dpkg-reconfigure --frontend noninteractive tzdata
	#apt-get update  
	sudo add-apt-repository -y ppa:mc3man/xerus-media
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF9BDC6F03D1F02B
	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 9BDB3D89CE49EC21
	gpg --export --armor 9BDB3D89CE49EC21 | sudo apt-key add -
	sudo apt-get -f install
	sudo apt-get purge docker*
	sudo apt-get upgrade -y
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	apt-key fingerprint 0EBFCD88
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 762E3157
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
	#sudo cat /etc/apt/sources.list | grep docker
	sudo apt-get update	

	sudo apt install -y docker-ce
	#sudo groupadd docker
	#sudo usermod -aG docker $ USER
	#sudo apt-get install -y docker docker-engine docker.io
	#docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi 이 실행되지 않으므로 아래 서비스등록을 실행해야함
	sudo rm -Rf /usr/lib/systemd/system
	sudo mkdir /usr/lib/systemd/system
	sudo chown -R $(USER) /usr/lib/systemd/system
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
	#nvidia-docker가 설치되어있을 경우 아래 주석제거
	#sudo apt-get purge -y nvidia-docker
	#sudo apt-get purge -y nvidia-docker2
		

	curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
	sudo apt-key add -
	#ubuntu 16.04를 정의
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
	#curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
	#sudo tee /etc/apt/sources.list.d/nvidia-docker.list
	curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
	sudo tee /etc/apt/sources.list.d/nvidia-docker.list 
	sudo apt-get update
	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 9BDB3D89CE49EC21
	sudo apt-get update

	#sudo apt-get install -y nvidia-docker
	sudo apt-get install -y nvidia-docker2
	sudo pkill -SIGHUP dockerd
	#ls -la /dev | grep nvidia
	#cuda버전을 명시하지 않을경우 최신 버전을 실행시키므로 오류가 발생
	sudo docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
	sudo docker build -t $(IMAGE_NAME) .	
	sudo docker run -d --runtime=nvidia -v /:/host_data/ -v /home/$(USER)/.Xauthority:/root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash
	#sudo docker run -d --runtime=nvidia -v /home/$(USER)/:/home/$(USER)/ -v /home/$(USER)/.Xauthority:/root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash


#how to transfer files 
#docker cp foo.txt env_baseline:/foo.txt
#docker cp env_baseline:/foo.txt foo.txt
