Goal 1 (python app):

- Used Flask as web framework, it can host the required endpoints.
- Created the endpoints what were in the requirements.
- Created config key-value store

* For transparency: I used claude sonnet to guide me through to declare the endpoints, since I am more strong in operational tasks and automation scripts, not building apps from sratch.

Goal 2 (dockerfile):

- Created a multistage dockerfile to minimize container image size.
- Added environment variables for the app to do not write to cache, since in a container it does not matter, every restart will make it dissappear. Removed buffer to make it easier to integrate it with for example grafana alloy and featch every log line immidietly.

Goal 3 (helm(chart)):

- Cought some typos and missconfigurations:
    - the ingress was wrong, it was pointing to a service which does not exist
    - the service selector was pointing to a wrong app name
    - containerport wasn't gunicorn compliant, it was pointing to 5000 and the app is on 8080
    - the template had hardcoded values, which was declared in the values, it would never been templated
- Improvements:
    - added health and statup probes, for orchestration it is mandatory to let kubernetes know if the app is healthy and needs attention
    - added resource limits, it's the best practice to figure out if something is wrong with the app and consuming more more than it's allowed to. also it can prevent additional costs and make the node resource starve.

- I made a validation with the templates using helm cli and kubeform:
'''bash
     helm template myapp . | kubeconform -strict -summary                                                                                                                                                                                             2s
Summary: 3 resources found parsing stdin - Valid: 3, Invalid: 0, Errors: 0, Skipped: 0
'''

