# dev-environment
auto setting machine learning develop environment of mine including docker, shell scripts etc

개발환경 ubuntu 16.04
그래픽카드 드라이버까지는 설치가 되어있다는 가정아래 작성된 자동화 makefile 과 dockerfile

# 실행 순서

1. bash를 하나 실행합니다.
2. make build_dependency를 입력합니다.
해당과정에서 자동으로 docker, nvidia-docker와 관련 하여 필요한 그래픽드라이버 설정을 자동으로 잡아줍니다.
또한 dockerfile을 자동으로 실행하여 env_baseline라는 도커 이미지를 생성합니다.
또한 같은 이름으로 백그라운드에 deploy합니다.

3. 기존에 docker 이미 사용중이고 nvidia-docker의 사용을 위한 세팅을 모두 완료한 분이시라면
make build_image를 입력합니다.
해당명령은 자동으로 dockerfile에 작성된 명령만을 추가적으로 실행하여 env_baseline이라는 도커이미지를 생성합니다.
또한 같은 이름으로 백그라운드에 deploy합니다.
(확신이 드시지 않는다면 2.를 실행하면 기존에 설치된 docker를 삭제하고 의존성에 맞는 docker를 다시 설치해줍니다.)

4. 2. 또는 3.으로 모든 과정을 마치고 나서 
make run_bash 를 입력하면 cuda, cudnn 설치등 복잡한 과정을 전부 생략하고 tensorflow , keras 등의 패키지도 자동으로 설치된 가상머신 
env_baseline이 실행됩니다. 

# 사용방법

필요할때마다 make run_bash를 입력하여 가상머신에 연결된 bash를 실행할수있습니다.
docker cp foo.txt env_baseline:/foo.txt
docker cp env_baseline:/foo.txt foo.txt
위 방법으로 간단히 가상머신과 파일을 주고받을수있습니다.


# 가상화 머신에 문제 발생시

가상머신은 완전히 독립된 환경으로 나중에 의존성오류나 사용간 문제가 발생하면
bash를 하나 실행한 후 sudo docker rmi env_baseline를 입력하고 나서
완료되면 make build_image를 입력하여 다시 이미지를 생성해주시기만 하면됩니다.


