#!groovy

import jenkins.install.*;
import jenkins.model.*
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.*
import hudson.util.*;

def instance = Jenkins.getInstance()

def username = new File("/run/secrets/jenkins-username").text.trim()
def password = new File("/run/secrets/jenkins-password").text.trim()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)