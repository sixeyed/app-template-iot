#!groovy

import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;

def username = new File("/run/secrets/dockerhub-username").text.trim()
def password = new File("/run/secrets/dockerhub-password").text.trim()

Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,"docker-hub", "docker-hub", username, password)
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)
