# Orca

Orchestrate the deployment, installation, maintenance and runtimes of locally-hosted Flutter web apps.

## Why Orca?
Orca is a Flutter Web application orchestrator, but what is its purpose? Flutter Web apps can be easily developed and used across all platforms, but not all web apps need to be hosted on a server. For single-user applications, locally hosting both the application and user data is more than sufficient. However, it can be difficult for users (especially those not from a technical background) to manage applications, dependencies, and troubleshoot web apps.

Orca provides a simple interface from which the user can configure new web apps, select the dependencies it needs, and configure its access to system resources such as the file system. After that, applications can started/stopped at the click of the button, or even through some form of automation. Application logs are conveniently streamed in realtime to the Orca interface, so users always have a birds-eye view of their applications.

## How Does Orca Work?

The Orca Project is made up of 3 main components:

1. Orca Core: The background process running on the client machine which orchestrates the storage, management, and communications with the UI and ServiceBridge.
2. Orca App: A simple UI for clients to configure Orca.
3. Orca ServiceBridge: SDK to allow developers to access Orca features in their apps and for 3rd party developers to allow custom services to be integrated with Orca

### The Lifecycle of An Orca App

1. Client must have Orca installed.
2. Client adds a new app via path.
> 1. Orca checks if the engine, services requirements are satisfied.
> 2. Orca registers the app in HiveDB
3. Client runs app via UI.
> 1. Orca provisions a runtime for the app
> 2. Orca places the `ORCA_APP_KEY` secret in the environment vars
4. Developer enables app to access Orca services via ServiceBridge
> 1. Call `orca.init()` to obtain `Client` instance.
> 2. Requests made by a specific runtime ID will be symmetrically encrypted
> 3. All requests are checked for authorisation before execution
> 4. Requests are executed by Orca Core
5. Client terminates app via UI.