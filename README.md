# Orca

Orchestrate the deployment, installation, maintenance and runtimes of locally-hosted Flutter web apps.

## Why Orca?
Orca is a Flutter Web application orchestrator, but what is its purpose? Flutter Web apps can be easily developed and used across all platforms, but not all web apps need to be hosted on a server. For single-user applications, locally hosting both the application and user data is more than sufficient. However, it can be difficult for users (especially those not from a technical background) to manage applications, dependencies, and troubleshoot web apps.

Orca provides a simple interface from which the user can configure new web apps, select the dependencies it needs, and configure its access to system resources such as the file system. After that, applications can started/stopped at the click of the button, or even through some form of automation. Application logs are conveniently streamed in realtime to the Orca interface, so users always have a birds-eye view of their applications.