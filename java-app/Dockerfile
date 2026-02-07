FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app
COPY src /app/src

RUN javac -d /app/out /app/src/com/virtualbank/App.java \
  && jar --create --file /app/app.jar -C /app/out .

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=build /app/app.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-cp", "/app/app.jar", "com.virtualbank.App"]
