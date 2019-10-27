# Devops pipeline with SonarQube, Jenkins, Nexus and Ansible with all components running on docker

This repo is a easy way to set up an entire devops CI/CD pipeline with nothing other than docker and an ubuntu machine.

> The setup is preconfigured to work with npm as the build and package tool. The dockerfiles and ansible playbook are attached for anyone who wants to poke around

> All the services are running on docker containers including ansible hosts

### Components used
- **Git :**  Source Code Management
- **Jenkins :**  Continuous Integration **port: 8080**
- **SonarQube :**  Static analysis **port: 9000**
- **Sonatype nexus :**  Artifactory **port: 8081**
- **Ansible cluster :**  Deployment _(1 master, 3 hosts)_
- **Docker :**  Container runtime
- **npm :**   To build the source code
- **serve :**  To serve the final application **ports: 4002, 4004, 4006** one per ansible host

> you should atleast have 20gb free disk space and 8gb of ram since sonatype nexus requires atleast 4gb spare ram
***

Our setup involves three ansible host containers, individual containers running sonarqube and nexus and another running both ansible and jenkins

## This is how you implement:

- Clone the repo, navigate to the directry, and run the setup.sh script file. Your setup is done, You are just configuring your project away from an up and running pipeline. 


``` 
    $ git clone <url>

    $ cd pipeline-on-ubuntu/

    $ ./setup.sh
```

- Your jenkins and nexus initial passwords will be fetched for you at the end of the execution of the script.

*** 
- Navigate to `localhost:9000` &rarr; login
    _User: `admin`
    Password: `admin`_

    - Under my account &rarr; generate a security token &rarr; copy to clipboard
- Navigate to `localhost:8081` &rarr; login _(User: `admin`, password will be fetched by the script)_
    - Under server administration and configuration create a a new repository with type: `raw (hosted`)


- Navigate to `localhost:8080` &rarr; login _(initial admin password will be fetched by the script)_ and setup **Jenkins**. Install additional plegins
    - Sonarqube scanner
    - Ansible
    - Gitlab, gitlab hook (Incase you are using gitlab, like we are)
    - Nexus artifact uploader

- In your `gitlab.com` account &rarr; Settings &rarr; SSH Keys &rarr; add the public key of a key pair
*** 
- Manage jenkins &rarr; Configure system &rarr; SonarQube servers
  - [x] `Enable injection of SonarQube server configuration as build environment variables`
  - Add SonarQube &rarr; 
    - Give a name
    - Server URL: `http://172.24.0.4:9000`
    - Sonarqube authentication token &rarr; Add &rarr; kind: `secret text` &rarr; copy the generated SonarQube token &rarr; andd the cred and use it &rarr; **save**

- Manage jenkins &rarr; Global tool configuration &rarr; SonarQube scanner
  - Add sonarqube scanner &rarr; Give a name &rarr; **save**
*** 
- New Item &rarr; freestyle project &rarr; **Ok**
  - Source Code Management 
    - [x] Git
    - Repository URL:  `ssh clone url`
    - Credentials &rarr; Add &rarr; kind; `SSH Username with private key` 
      - Username: `gitlab username`
      - Private key &rarr; Enter directly &rarr; Add &rarr; _private key_ of the key pair of which _public key_ is configured in gitlab
    *** 
  - Build triggers
    - [x] `Build when a change is pushed to GitLab. GitLab webhook URL:` http://localhost:8080/project/_jenkins-project-name_ &rarr; Enabled GitLab triggers
      - [x] Push Events
      - [x] Accepted Merge Request Events
      - [x] Approved Merge Requests (EE-only)
      - [x] Comments 
   
    - Navigate to `gitlab.com` &rarr; project repo &rarr; Settings &rarr; Integrations
      - URL: http://localhost:8080/project/_jenkins-project-name_ `(Gitlab wbhook URL)`
      - Trigger
        - [x] Push events
      - SSL verification
        - [ ] Enable SSL verification `(uncheck)` 
      - Add webhook &rarr; Test &rarr; Push events
       ```
       Hook executed successfully: HTTP 200 
       ```
    *** 
  - Build &rarr; Add build step
    - `Execute SonarQube Scanner &rarr; Analysis properties
        ```
        sonar.projectKey =  < Sonarqube project key >
        sonar.projectName =  < Sonarqube project name >
        sonar.projectVersion =  < Project version >
        sonar.sources =  < path to src/ dir >
        ```

    *** 
  - Build &rarr; Add build step
    - Execute shell &rarr; Command
        ```
        npm install
        npm run build
        zip -r build.zip build/
        ```
    *** 
  - Build &rarr; Add build step &rarr; Nexus artifact uploader 
    - Nexus Version: `NEXUS3`
    - Protocol: `HTTP`
    - Nexus URL: `172.24.0.12:8081`
    - Credentials: Add &rarr; kind &rarr; Username and Password &rarr; `Nexus username and password`
    - GroupId: `< nexus group id >`
    - Version: `< version of code >`
    - Repository: `< name of the repository that was created in nexus >`
    - Artifacts
      - ArtificatId: `$BUILD_ID`
      - Type: `zip`
      - Classifier: `build`
      - File: `build.zip`
 
    *** 
  - Build &rarr; Add build step &rarr; Invoke Ansible Playbook
    - PlaybookPath: `/pb1.yml`
    - Inventory &rarr; File or host list
      - File path or comma separated host list : `/inventory.txt`
- **Save**
- Jenkins project  &rarr; Build Now _(To test)_

***
In your ubuntu machine change the name of the jenkins project name in the playbook inside the ansible container

```
    $ docker container exec -it pipelineonubuntu_jekns-ans-master_1 bash
    # nano /pb1.yml

        ...
        tasks:
          - name: copy zip file
            copy:
              src: /var/jenkins_home/workspace/ <JENKINS PROJECT NAME> /build.zip
        ...
    # exit
```

***

- Go to your project directory &rarr; make a change &rarr; commit &rarr; push to git
  
**The pipeline will be triggered by default by the `gitlab webhook` &rarr; the code will undergo static analysis by sonarqube of which the result will be available in `sonarqube dashboard` &rarr; will be built by `npm` and compressed &rarr; stored in `nexus` &rarr; then deployed in the `three ansible hosts` and served at `ports 4002, 4004 and 4006 of localhost**  