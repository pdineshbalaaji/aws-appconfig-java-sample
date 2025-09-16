FROM gradle:6.9-jdk8 as build

WORKDIR /workspace/app

COPY build.gradle .
COPY settings.gradle .
COPY src src
COPY movie-service-utils movie-service-utils
RUN gradle build -x test --no-daemon
RUN mkdir -p build/dependency && (cd build/dependency; jar -xf ../libs/*.jar)

FROM gradle:6.9-jdk8
ARG DEPENDENCY=/workspace/app/build/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","com.amazonaws.samples.appconfig.movies.MoviesApplication"]