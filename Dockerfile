# 베이스 이미지로 Nginx Alpine 사용 (경량화)
FROM nginx:alpine

# Nginx의 기본 정적 파일 경로로 소스 파일 복사
# index.html과 이벤트 이미지를 복사합니다.
COPY index.html /usr/share/nginx/html/
COPY KakaoTalk_20260106_125546569.png /usr/share/nginx/html/

# 80번 포트 노출
EXPOSE 80

# Nginx 실행 (데몬 모드 해제)
CMD ["nginx", "-g", "daemon off;"]
