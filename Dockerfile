FROM registry.redhat.io/rhbk/keycloak-rhel9:24-12 as builder

#COPY ./keycloak.conf /opt/keycloak/conf

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true



WORKDIR /opt/keycloak

COPY ./providers/unimed-ciam-spi.jar /opt/keycloak/providers/

RUN /opt/keycloak/bin/kc.sh build

RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM registry.redhat.io/rhbk/keycloak-rhel9:24-12
COPY --from=builder /opt/keycloak/ /opt/keycloak/





ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
