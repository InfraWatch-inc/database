FROM mysql:latest
WORKDIR /
ENV MYSQL_ROOT_PASSWORD=urubu100
COPY ./script.sql .
EXPOSE 3306
RUN sudo mysql < script.sql