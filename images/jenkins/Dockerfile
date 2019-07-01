FROM iotkit/jenkins:2.176.1

RUN apk add --no-cache \
    curl

ENV JENKINS_HOME="/var/jenkins_home" \
    JENKINS_UC="https://updates.jenkins.io" \
    JENKINS_UC_EXPERIMENTAL="https://updates.jenkins.io/experimental" \
    JENKINS_INCREMENTALS_REPO_MIRROR="https://repo.jenkins-ci.org/incrementals" \
    COPY_REFERENCE_FILE_LOG="${JENKINS_HOME}/copy_reference_file.log"

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

COPY jenkins-support /usr/local/bin/jenkins-support
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh <  /usr/share/jenkins/ref/plugins.txt
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
COPY admin.groovy /usr/share/jenkins/ref/init.groovy.d/admin.groovy

COPY jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT /usr/local/bin/jenkins.sh