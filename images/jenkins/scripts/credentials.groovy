#!groovy

import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;

def username = new File("/run/secrets/docker-hub-username").text.trim()
def password = new File("/run/secrets/docker-hub-password").text.trim()

Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,"docker-hub", "docker-hub", username, password)
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)
