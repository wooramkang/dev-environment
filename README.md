

docker와 makefile을 이용해 bash에 명령어를 1~3번만 입력하면 

자동으로 가상머신을 생성후 딥러닝 개발환경을 만들기 위해 작성되었습니다.

스크립트 makefile 과 dockerfile을 포함한 전반입니다.


# 해당 가상환경을 사용하기 위해 필요한 개발환경

적어도 ubuntu 또는 debian계열 리눅스 또는 해당 bash가 설치된 PC

그리고 해당 운영체제와 사용중인 GPU에 맞는 그래픽카드 드라이버지는 설치 완료된 상태

(CUDA, CUdnn 설치는 필요조건 아님 => 자동으로 적합 버전에 맞는 docker container 설정)


# 자동으로 설치되는 가상머신의 개발환경 

ubuntu 16.04

docker-ce

git

CUDA 9.0

CuDnn 7.4.2.24

OPENCV 3.4.2

python 3.5

tensorflow 1.9.0

keras 2.1.6 (2.2.4에 연산오류가 많아 안정적 버전으로 다운그레이드)

pytorch:latest (1.0.1)

pytorchvision:latest (0.2.2)

opencv 3.4.2 customed

dlib 19.15.0

pycharm-CE (pycharm을 설치하도록 유도하였으나 console로 접속하여 본인이 사용중인 IDE에서 인터프리터, 컴파일러만 가져다 사용하기를 권장)

etc(다양한 서브 패키지, 서드파티 프로그램).....


# 아래 해당 스크립트 실행 방법 및 설명

일단, bash(명령어 콘솔 입력창)를 하나 실행합니다.

- sudo make build_first_time

해당명령의경우 docker, nvidia-docker를 비롯한 도커 설치에 필요한 패키지, 환경설정 그래픽카드 설정 등을 자동으로 잡아주고 설치해줍니다. 또한 가상머신을 빌드하고 docker container를 백그라운드에 실행시킵니다. 설치간 발생가능 한 이슈에 대해 최대한 자동을 대응되도록 스트립트를 작성하였으나 문제 발생시 error 뒤에 나오는 것을 복사 후 구글에 검색하면 보통 3~5번째 글 안에서 비슷한 이슈와 그 솔루션이 나옵니다.

- sudo make build_only_image

기존에 docker와 nvidia-docker를 사용중이실경우에 한하여 해당 명령을 입력하시면 해당 프로그램들에 대한 설정, 설치 등을 생략하고 바로 docker container를 빌드하고 백드라운드에 실행시킵니다.

- sudo make build_image_again

사용중인 docker와 관련하여, dockerfile에 수정사항이 발생하였을때, container를 사용하던중에 의존성오류 및 가상머신 실행간 의존성오류 등 크리티컬한 오류가 발생하였을 경우 해당 명령을 입력하시면 기존에 실행되고있는 docker container를 kill 하고 지운후 다시 처음부터 빌드합니다. 빌드후 새로운 docker container를 백그라운드에 실행시킵니다.

- sudo make run_bash

해당 명령은 위 3개중 하나의 build과정을 성공적으로 마쳤을 경우 백그라운드에서 WAIT중인 docker container에 대한 bash를 실행시킵니다.


# 사용방법 더 자세히 

dockerfile을 열어보시면 나와있는 docker run 코드 부분을 이해하여, 직접 수정, 사용하기를 권장합니다.

<pre><code>

sudo docker run -d --runtime=nvidia -v /:/host_data/ -v /home/$(USER)/.Xauthority:/root/.Xauthority:rw --privileged -v /dev/:/dev/ --env "DISPLAY" --env QT_X11_NO_MITSHM=1 --net=host -ti --name $(IMAGE_NAME) $(IMAGE_NAME) /bin/bash

</code></pre>

- '-d' : 백그라운드에서 실행
- '-v' : volume을 마운트 시킴  -v host-dir:target-dir
- 'env' : 환경 변수 설정 bashrc에 들어가는 코드를 직접입력한다 생각하면 됨
- /bin/bash : 맨 뒤에 들어가는 명령은 해당 컨테이너에서 해당 명령을 실행시키라는 부분
- '--privileged' : 권한을 높은 권한을 주는 부분, /dev/의 장치정보를 마운트하기위해 삽입
- '$(USER)' : user id
- '$(IMAGE_NAME)' : dockerfile에 정의해 놓은 image name

docker container를 test할때는 -d를 지우고 실행하여도 무방, docker container의 속성상 실행이 종료되면 container 내부 데이터가 모두 자동으로 지워지기 때문입니다.

-v를 이용하여 host-pc의 다른 주소를 연결하여 사용할수도 있고 docker cp문을 이용하여 docker container 내부로 복사하여 사용할수도 있습니다. 다만 앞서 언급했듯이 복사와 마운트의 차이는 container가 종료되면 cp로 복사된 정보는 마운트되어있지 않은 주소에 존재하면 삭제됩니다.

추가적으로 여러 container를 사용할때 link문법이라던지 docker-swarm 등에 대한 기능을 추가적으로 업로드 예정입니다.

-v /:/host_data/에서 보이는 것 처럼 host_pc의 데이터는 /host_data/에 마운트 하여 사용가능하게 하였으나 여러명이서 개발할때는 보통 특정 구역, 폴더만을 마운트하여 사용하는 편이 더 바람직한 개발 방식입니다.

<pre><code>
sudo docker exec -ti $(IMAGE_NAME) /bin/bash
</code></pre>

dokcer container 내부의 bash console을 하나 실행합니다. 

# 가상머신 사용간 문제 발생시

<pre><code>
sudo make build_image_again
</code></pre>

또는 

<pre><code>
sudo sh erase_all_images_containers.sh && \
sudo make build_image_again
</code></pre>

erase_all_images_containers.sh는 활성화되어 있지 않은 모든 image와 containers를 지웁니다.
