FROM eclipse-temurin:24-jdk AS build

WORKDIR /app

COPY gradlew .
COPY gradle/ gradle/
COPY build.gradle* .
COPY settings.gradle* .

RUN ./gradlew --no-daemon dependencies

COPY . .

RUN ./gradlew bootJar -x test

FROM eclipse-temurin:24-jre-alpine

WORKDIR /app

COPY --from=build /app/build/libs/*.jar ./application.jar

# KReplica-Docs listens on 8080, KReplica-Sandbox on 8081
EXPOSE 8080
EXPOSE 8081

CMD ["java", "-jar", "application.jar"]
