# Stage 1: Build stage
FROM ubuntu:22.04  AS Builder

# Install git, OpenJDK, and Maven
RUN apt-get update && \
    apt-get install -y git wget openjdk-17-jdk
RUN wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.6.3/apache-maven-3.6.3-bin.tar.gz && \
    tar xf apache-maven-3.6.3-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.6.3 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn


# Set the working directory inside the container
WORKDIR /var/www/html

# Clone the Git repository containing your code
RUN git clone https://github.com/spring-projects/spring-petclinic.git

WORKDIR /var/www/html/spring-petclinic

# Build the application with Maven
RUN ./mvnw package

# Stage 2: Production stage
FROM openjdk:17 AS production

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /var/www/html/spring-petclinic/target/*.jar /app/spring-petclinic.jar

# Expose the port your application will run on
EXPOSE 9001

# Define the command to run your application when the container starts
CMD ["java", "-jar","-Dspring.profiles.active=mysql", "/app/spring-petclinic.jar"]
