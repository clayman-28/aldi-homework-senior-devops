# Goal 1

## Python app:

- Used Flask as web framework, it can host the required endpoints.
- Created the endpoints what were in the requirements.
- Created config key-value store

* For transparency: I used claude sonnet to guide me through to declare the endpoints, since I am more strong in operational tasks and automation scripts, not building apps from sratch.

## Dockerfile:

- Created a multistage dockerfile to minimize container image size.
- Added environment variables for the app to do not write to cache, since in a container it does not matter, every restart will make it dissappear. Removed buffer to make it easier to integrate it with for example grafana alloy and featch every log line immidietly.

## Helm(chart):

- Cought some typos and missconfigurations:
    - the ingress was wrong, it was pointing to a service which does not exist
    - the service selector was pointing to a wrong app name
    - containerport wasn't gunicorn compliant, it was pointing to 5000 and the app is on 8080
    - the template had hardcoded values, which was declared in the values, it would never been templated
- Improvements:
    - added health and statup probes, for orchestration it is mandatory to let kubernetes know if the app is healthy and/or needs attention
    - added resource limits, it's the best practice to figure out if something is wrong with the app and consuming more more than it's allowed to. also it can prevent additional costs and make the node resource starve.

- I made a validation with the templates using helm cli and kubeform:
'''bash
     helm template myapp . | kubeconform -strict -summary                                                                                                                                                                                             2s
Summary: 3 resources found parsing stdin - Valid: 3, Invalid: 0, Errors: 0, Skipped: 0
'''

 ## Terraform:

- There were syntax errors in main tf, missing values and hardcoded variables. (I used terraform fmt for validation)
- Helm chart path was wrong
- Pinned to providers to a required version, so the exact provider versions will work in the future. Updates won't brake future runs.

- Improvements:
    - Added output values, so the vars will be availble in state file and will be readable afterwards
    - Added descriptions for variables for readability for other colleagues
    - Added default values
    - Added validation for environments, so there will be no typos and unallowed environment deployments

## Pipeline:

- Wrote the test_app.py and added to appm since without it the app validation can not run.
- Added necessary env vars for authentication to resources
- Added 4 stages according to best practice and my current workflow:
    - lint jobs for validating every component
    - run tests
    - build/push the image (used kaniko, because it can run without root privileges and docker socket mount, which is a security vulnurability)
    - terraform apply with multienv option for deployment

* For transparency: I created the logic and the required steps and security improvements, but i used claude sonnet to write the app test and helped me to implement GitLab CI syntax, since I am using Jenkins for CI for a long time. I will learn it's syntax if that's the default CI tool at the company.

