#
# First Stage: Full UBI
#
FROM registry.redhat.io/ubi9/ubi AS ubi-micro-build

RUN dnf install -y unzip

# Add stuff downloaded by fetch-artifacts-pnc.yaml
ADD artifacts/keycloak-operator-*.zip /tmp/keycloak/

# Unpack the archive
RUN cd /tmp/keycloak && \
    unzip /tmp/keycloak/keycloak*.zip && \
    rm /tmp/keycloak/keycloak*.zip

# Setup the server's directory
RUN mv /tmp/keycloak/keycloak-* /opt/keycloak && \
    mkdir -p /opt/keycloak/data && \
    chmod -R g+rwX /opt/keycloak

# Bootstrap chroot with RPMs for the actual container
ADD ubi-null.sh /tmp/
RUN bash /tmp/ubi-null.sh java-21-openjdk-headless glibc-langpack-en

#
# Final Stage: UBI Micro ("Distroless")
#
FROM registry.redhat.io/ubi9/ubi-micro

LABEL \
    com.redhat.component="keycloak-rhel9-operator-container"  \
    description="Red Hat Build of Keycloak operator container image, based on the Red Hat Universal Base Image 9 Micro container image" \
    summary="Red Hat Build of Keycloak operator container image, based on the Red Hat Universal Base Image 9 Micro container image" \
    name="keycloak/rhbk-rhel9-operator" \
    version="26.0" \
    io.k8s.description="Operator for Red Hat Build of Keycloak" \
    io.k8s.display-name="Red Hat Build of Keycloak 26.0 Operator" \
    io.openshift.tags="rhbk,rhbk26,keycloak,operator" \
    maintainer="Red Hat Single Sign-On Team"

ENV LANG en_US.UTF-8

COPY --from=ubi-micro-build /tmp/null/rootfs/ /
COPY --from=ubi-micro-build --chown=1000:0 /opt/keycloak /opt/keycloak
COPY ./providers/unimed-ciam-spi.jar /opt/keycloak/providers/

RUN echo "keycloak:x:0:root" >> /etc/group && \
    echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd

USER 1000

WORKDIR /opt/keycloak

ENTRYPOINT [ "java", "-Djava.util.logging.manager=org.jboss.logmanager.LogManager", "-jar", "quarkus-run.jar" ]
