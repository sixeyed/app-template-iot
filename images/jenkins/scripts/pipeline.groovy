import hudson.plugins.git.*;
import hudson.triggers.SCMTrigger;
import org.jenkinsci.plugins.workflow.job.WorkflowJob;
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition;

def gitHubUsername = new File("/github-username").text.trim()
def gitHubRepo = new File("/github-repo").text.trim()
def gitHubUrl = "https://github.com/${gitHubUsername}/${gitHubRepo}.git"

def jenkins = Jenkins.instance;

def scm = new GitSCM(gitHubUrl)
scm.branches = [new BranchSpec("*/master")];
def workflowJob = new WorkflowJob(jenkins, gitHubRepo);
workflowJob.definition = new CpsScmFlowDefinition(scm, "Jenkinsfile");
def gitTrigger = new SCMTrigger("* * * * *");
workflowJob.addTrigger(gitTrigger);
workflowJob.save();

jenkins.reload()