# Use official Java image
FROM eclipse-temurin:17-jdk-alpine

# Add Maven & build the app
COPY . /app
WORKDIR /app
RUN CHMOD 777 ./mvnw

RUN ./mvnw package -DskipTests

# Use a smaller base image for runtime
FROM eclipse-temurin:17-jre-alpine
COPY --from=0 /app/target/sample-test-0.0.1-SNAPSHOT.jar app.jar

# Set the port (Cloud Run injects $PORT)
ENV PORT=8080
EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
