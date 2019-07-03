FROM iotkit/jenkins:2.176.1

RUN apk add --no-cache \
    curl

ENV JENKINS_HOME="/var/jenkins_home" \
    JENKINS_UC="https://updates.jenkins.io" \
    JENKINS_UC_EXPERIMENTAL="https://updates.jenkins.io/experimental" \
    JENKINS_INCREMENTALS_REPO_MIRROR="https://repo.jenkins-ci.org/incrementals" \
    COPY_REFERENCE_FILE_LOG="${JENKINS_HOME}/copy_reference_file.log" \
    JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

COPY jenkins-support /usr/local/bin/jenkins-support
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins.sh /usr/local/bin/jenkins.sh

RUN chmod +x /usr/local/bin/jenkins-support && \
    chmod +x /usr/local/bin/install-plugins.sh && \
    chmod +x /usr/local/bin/jenkins.sh && \
    /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt && \
    echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENTRYPOINT /usr/local/bin/jenkins.sh

COPY ./scripts/ /usr/share/jenkins/ref/init.groovy.d/
COPY ./secrets /run/secrets
COPY ./configs/ /