FROM quay.io/keycloak/keycloak-operator:24.0.5-0
#FROM quay.io/keycloak/keycloak:24.0.5

# Copia o seu JAR customizado para a pasta de providers
#COPY ./providers/unimed-ciam-spi.jar /opt/keycloak/providers/

# (Opcional) Se quiser já construir o provider e resolver dependências
#RUN /opt/keycloak/bin/kc.sh build

# Define o comando padrão para iniciar o servidor
#ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
#CMD ["start"]
