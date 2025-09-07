#golang을 기본 이미지로 한다 
FROM golang
#main.go 파일을 root 폴더로 복사한다
ADD main.go /root
#작업폴더를 변경한다 
WORKDIR /root
#main.go 파일을 빌드하여 /root/mainApp 실행 파일 만든다
RUN go build -o /root/mainApp /root/main.go
#mainApp을 실행한다 
CMD ["./mainApp"]

