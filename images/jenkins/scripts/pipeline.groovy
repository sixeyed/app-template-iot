import hudson.plugins.git.*;

def gitHubUsername = new File("/github-username").text.trim()
def gitHubRepo = new File("/github-repo").text.trim()
def gitHubUrl = "https://github.com/${gitHubUsername}/${gitHubRepo}.git"

def scm = new GitSCM(gitHubUrl)
scm.branches = [new BranchSpec("*/master")];

def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, gitHubRepo)
job.definition = flowDefinition

parent.reload()