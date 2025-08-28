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





### ------------------------------------------------------------------------------------------------ ###
### GCP setup steps for this project###

Based on the `cloudbuild.yaml` file and the general requirements for a Cloud Build and Cloud Run project, here are the necessary Google Cloud Platform (GCP) setup steps.

### 1. Enable Required APIs
You must enable the APIs for the services used in the workflow. From the `cloudbuild.yaml` file, the project utilizes Cloud Build, Artifact Registry, and Cloud Run.
You can enable these APIs using the `gcloud` command line tool or through the GCP Console:

* **Cloud Build API**: `gcloud services enable cloudbuild.googleapis.com`
* **Artifact Registry API**: `gcloud services enable artifactregistry.googleapis.com`
* **Cloud Run API**: `gcloud services enable run.googleapis.com`

---

### 2. Set Up Artifact Registry
The project uses Artifact Registry to store the Docker image. The `cloudbuild.yaml` specifies an Artifact Registry repository in the `asia-east1` region. You will need to create this repository.

* Create a Docker repository in the `asia-east1` region with the name `sample-test`:
    `gcloud artifacts repositories create sample-test --repository-format=docker --location=asia-east1`

---

### 3. Configure IAM Permissions
The `cloudbuild.yaml` file specifies a custom service account for the build process: `for-cloud-build-deploy@for-tech-practice.iam.gserviceaccount.com`. This service account needs specific IAM roles to successfully perform the build and deployment.

* **Create the service account**: If this service account does not already exist, create it:
    `gcloud iam service-accounts create for-cloud-build-deploy --project=for-tech-practice`

* **Grant IAM roles**: Grant the necessary roles to the service account. These roles are essential for the service account to build, push, and deploy the application.
    * **Artifact Registry Writer**: This role is required for pushing the Docker image to the Artifact Registry repository.
        `gcloud artifacts repositories add-iam-policy-binding sample-test --location=asia-east1 --member="serviceAccount:for-cloud-build-deploy@for-tech-practice.iam.gserviceaccount.com" --role="roles/artifactregistry.writer"`
    * **Cloud Run Admin**: This role is needed to deploy and manage the Cloud Run service.
        `gcloud projects add-iam-policy-binding for-tech-practice --member="serviceAccount:for-cloud-build-deploy@for-tech-practice.iam.gserviceaccount.com" --role="roles/run.admin"`
    * **Cloud Storage Object Admin**: The `cloudbuild.yaml` file specifies a log bucket (`gs://cloud-build-log123`). The service account needs permission to write logs to this bucket.
        `gcloud storage buckets add-iam-policy-binding gs://cloud-build-log123 --member="serviceAccount:for-cloud-build-deploy@for-tech-practice.iam.gserviceaccount.com" --role="roles/storage.objectAdmin"`


### GCP CloudBuild trigger steps for this project###

To set up a Cloud Build trigger for this project, you will need to connect a source code repository and configure the trigger to automatically start a build whenever a new change is pushed. This automates the process of building and deploying your application based on the `cloudbuild.yaml` file.

Here are the steps to set up a Cloud Build trigger, assuming your code is in a supported repository like GitHub, Bitbucket, or Cloud Source Repositories. 

### 1. Connect Your Repository
First, you need to connect your source code repository to Google Cloud Build.

* In the Google Cloud Console, navigate to **Cloud Build > Triggers**.
* Click **"Connect repository"**.
* Select your source provider (e.g., GitHub, Bitbucket, or Cloud Source Repositories) and follow the prompts to authorize Google Cloud.
* Choose the repository that contains your project files (`cloudbuild.yaml`, `Dockerfile`, `pom.xml`).

---

### 2. Create the Trigger
After connecting your repository, create the build trigger.

* Go back to the **Triggers** page and click **"Create trigger"**.
* Give your trigger a descriptive name, such as `java-app-ci-cd`.
* Under **"Event"**, choose the type of event that will start the build. For continuous deployment, you would typically select **"Push to a branch"**.
* Under **"Source"**, select the repository you just connected and the specific branch you want to monitor (e.g., `main` or `master`).
* In the **"Configuration"** section, choose the build configuration type. Select **"Cloud Build configuration file (yaml or json)"**.
* Specify the location of your build file. Since it's in the project's root directory, the default path `cloudbuild.yaml` should be correct.

---

### 3. Save the Trigger
Finally, save your configuration to activate the trigger.

* Click **"Create"**.

Once the trigger is created, any new push to the specified branch of your repository will automatically initiate a Cloud Build that follows the steps in your `cloudbuild.yaml` file—building the Docker image, pushing it to Artifact Registry, and deploying it to Cloud Run.