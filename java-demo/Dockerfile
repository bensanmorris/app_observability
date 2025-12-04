# Use JDK so async/agent tools exist
FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY Main.java .
RUN javac Main.java

# Download Pyroscope Java agent (lightweight — no native deps)
ADD https://github.com/grafana/pyroscope-java/releases/latest/download/pyroscope.jar /app/pyroscope.jar

# Start with agent enabled for CPU profiling
CMD ["bash", "-c", "java -javaagent:/app/pyroscope.jar Main"]

