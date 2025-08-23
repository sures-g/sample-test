# Stage 1: Build the JAR artifact
#FROM maven:3.9.6-eclipse-temurin-17 AS build
#WORKDIR /app
#COPY pom.xml .
#COPY src ./src
#RUN mvn clean install -Dmaven.test.skip=true

# Stage 2: Create the final image with JRE
#FROM eclipse-temurin:17-jre-focal
#WORKDIR /app
#COPY /app/target/sample-test-0.0.2.jar app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

# Use a slim, official OpenJDK image as the base
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file into the container
COPY target/sample-test-0.0.2.jar app.jar

# Expose the port your app will run on. Cloud Run expects 8080 by default.
EXPOSE 8080

# Define the command to run your application
CMD ["java", "-jar", "app.jar"]