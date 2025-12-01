FROM bellsoft/liberica-openjdk-alpine:17
WORKDIR /app
COPY Main.java .
RUN javac Main.java
CMD ["java", "-XX:+PreserveFramePointer", "-XX:+UnlockDiagnosticVMOptions", "-XX:+DebugNonSafepoints", "Main"]
