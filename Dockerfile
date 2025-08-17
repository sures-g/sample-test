      #DOCKER FILE
# Use a base image with Java 17 and Maven 3.6.0
FROM maven:3.8.3-openjdk-17 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml and source code to the container
COPY pom.xml .
COPY src ./src

# Build the application with Maven
RUN mvn clean install -DskipTests

# Use a lightweight Java 17 image for running the application
FROM openjdk:17

# Set the working directory in the container
WORKDIR /app

# Copy the built JAR file from the build stage to the runtime image
COPY --from=build /app/target/sample-test .

# Set the entry point for the container
ENTRYPOINT ["java", "-jar", "sample-test"]
