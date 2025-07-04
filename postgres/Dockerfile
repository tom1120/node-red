FROM 192.168.99.14:8101/pgvector/pgvector:0.8.0-pg17
RUN export http_proxy=http://192.168.96.18:7890 && \
    export https_proxy=http://192.168.96.18:7890
COPY ./pig_install.sh /tmp/pig_install.sh
RUN chmod +x /tmp/pig_install.sh && \
    /tmp/pig_install.sh && \
    rm -f /tmp/pig_install.sh
EXPOSE 5432
CMD [ "postgres" ]
ENTRYPOINT [ "docker-entrypoint.sh" ] 

