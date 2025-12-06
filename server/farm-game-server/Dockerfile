# Stage 1: Build the JAR using Maven
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy Maven configuration first for caching
COPY pom.xml .
COPY src ./src

# Build the JAR
RUN mvn clean package -DskipTests

# Stage 2: Run the Spring Boot app
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Set default environment variables (can be overridden in docker-compose)
ENV SPRING_PROFILES_ACTIVE=default

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]