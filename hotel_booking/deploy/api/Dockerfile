FROM maven:4.0.0-rc-4-eclipse-temurin-21 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Устанавливаем bash и полезные утилиты (опционально)
RUN apk add --no-cache bash

# Копируем jar файл
COPY --from=build /app/target/*.jar app.jar

# Копируем статические файлы (HTML, CSS, JS, фото)
COPY --from=build /app/src/main/resources/static /app/static

# Создаём пользователя для безопасности
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "app.jar" ]