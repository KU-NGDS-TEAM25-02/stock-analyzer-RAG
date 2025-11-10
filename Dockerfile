# 1단계: Java 17과 Gradle을 사용하여 앱을 빌드합니다 (Builder)
# (사용하시는 자바/빌드 버전에 맞춰 이미지를 변경하세요. 예: openjdk:11, gradle:jdk11)
FROM gradle:jdk17-focal AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 속도를 높이기 위해 그래들 설정 파일 먼저 복사
COPY build.gradle settings.gradle ./
# 의존성 다운로드 (소스코드가 변경되지 않으면 이 레이어를 캐시함)
RUN gradle dependencies

# 전체 소스 코드 복사
COPY src ./src

# Gradle을 사용하여 Spring Boot 실행 가능 Jar 파일 빌드
RUN gradle bootJar

# ----------------------------------------------------

# 2단계: 실제 실행을 위한 최소한의 JRE 이미지를 사용합니다 (Final Image)
# (1단계와 동일한 Java 버전의 JRE를 사용)
FROM openjdk:17-jre-slim

# 작업 디렉토리 설정
WORKDIR /app

# 1단계(builder)에서 빌드된 Jar 파일만 복사해옵니다
# Jar 파일 경로가 다를 경우 수정 필요 (예: *.jar)
COPY --from=builder /app/build/libs/*.jar app.jar

# Spring Boot의 기본 포트 8080 노출
EXPOSE 8080

# 컨테이너가 시작될 때 Jar 파일 실행
ENTRYPOINT ["java", "-jar", "app.jar"]