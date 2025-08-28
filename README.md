Here is the README documentation for the provided project files.

***

### Project Documentation: `sample-test` Application

This project contains the necessary configuration files to build, containerize, and deploy a Java Spring Boot application using Google Cloud services. The process is automated using a `cloudbuild.yaml` file, which orchestrates the entire workflow from source code to a running service on Cloud Run. 
---

### Project Structure 📁

The project consists of three main files:

* `cloudbuild.yaml`: The Google Cloud Build configuration file. This YAML file defines a series of steps to automate the build and deployment process.
* `Dockerfile`: The Docker configuration file. It specifies how to create a Docker image for the application, using a multi-stage build to keep the final image size small.
* `pom.xml`: The Maven configuration file for the Spring Boot application. It manages project dependencies, build configurations, and metadata.

---

### Application Details

The application is a Spring Boot project named `sample-test` with version `0.0.2`. It's configured to use **Java 17**. The `pom.xml` file specifies several dependencies:
* `spring-boot-starter-actuator`: Provides production-ready features like monitoring and metrics.
* `spring-boot-starter-web`: Enables the application to be a web application, providing a web server.
* `spring-boot-devtools`: Offers development-time features like automatic restarts.
* `lombok`: A library that helps reduce boilerplate code.
* `spring-boot-starter-test`: For writing and running tests.

---

### Build and Deployment Process 🚀

The entire process is automated via the `cloudbuild.yaml` file, which follows these steps:

#### **1. Docker Image Build**

The `Dockerfile` is a multi-stage build that separates the build environment from the runtime environment.

* **Stage 1: Build Artifact**: This stage uses a **Maven 3.9.6** image with **JDK 17** (`maven:3.9.6-eclipse-temurin-17`) as the base. It copies the `pom.xml` and source code (`src`) into the container. The `mvn clean install` command is then executed to compile the Java code, package it into a JAR file, and skip tests to speed up the process.
* **Stage 2: Final Image**: A much smaller **Java Runtime Environment (JRE)** image (`eclipse-temurin:17-jre-focal`) is used as the base. The compiled JAR artifact from the first stage is copied into this new image. The container's entrypoint is set to run the JAR file using the `java -jar` command.

#### **2. Cloud Build Steps**

The `cloudbuild.yaml` file automates three key steps:

1.  **Build**: The `gcr.io/cloud-builders/docker` builder is used to build the Docker image based on the `Dockerfile`. The image is tagged with the Artifact Registry path `asia-east1-docker.pkg.dev/for-tech-practice/sample-test/sampletest-image`.
2.  **Push**: The same Docker builder is used to push the newly created image to the Artifact Registry repository.
3.  **Deploy**: The `gcloud` builder (`gcr.io/google.com/cloudsdktool/cloud-sdk`) is used to deploy the image to a new **Cloud Run** service named `sample-test` in the `asia-east1` region.

#### **3. Configuration and Logging**

* **Images**: The `images` field explicitly lists the image that will be built and pushed.
* **Logs**: The build logs are configured to be stored in a specified Google Cloud Storage bucket (`gs://cloud-build-log123`) using the `logging: GCS_ONLY` option.
* **Service Account**: The build uses a dedicated service account (`for-cloud-build-deploy@for-tech-practice.iam.gserviceaccount.com`) to ensure it has the necessary permissions for all steps.