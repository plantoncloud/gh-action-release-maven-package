FROM us-central1-docker.pkg.dev/planton-shared-services-jx/afs-planton-pos-uc1-ext-docker/plantoncode/planton/pos/docker-images/build-java:java-17-planton-cli-v0.0.34
COPY entrypoint.sh /entrypoint.sh
 
ENTRYPOINT ["/entrypoint.sh"]
