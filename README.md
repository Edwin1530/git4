# Tuto installation tuyau CI/CD


Skip to content
Computer Science Class
GitHub CI

    Home
    Python Programming
    Algorithmic Thinking
    Linux
    Maths
    Data Analysis tools in Python
    Scraping
    Relational DBMS
    NoSQL DBMS
    Machine/Deep Learning
    NLP
    Audio
    Serverless
    Computer Vision
    Networking basics
    Restful API
    CI/CD
    Docker for App Deployment
    MLOps
    Web - Mobile

    CI/CD
        Introduction
        GitHub CI
        Jenkins
        Full Stack Web Pipeline

Table of contents

    What is git workflows
    Set up python application
    Create dev branch and merge code base
    Merge Pull Request
    Write your first yml workflow
    Test workflow locally with act
        Run local workflow with act
            How it's work
            Run workflows
            Managing secrets
    Deploy your workflow on github
        Trigger you workflow
    Automate the testing actions
        Adding test workflow
        Add docker build workflow
            Add Dockerfile to our python app
        Add docker push workflow
    Deployment
        Cloudron

Continus Integration/Deployment with Github

if you do not have all the git command in your head (which is normal if you are not working on github every day 😅) take a look at mini git no deep shit

For the rest of this article we will be using the following functions of github :

    add, commit and push
    create, delete branch
    merge pull request
    workflows to automate some actions
    git secrets

Let's get started by taking a look to what is github workflow:
What is git workflows

A GitHub workflow is a set of automated processes that you can set up in your GitHub repository to build, test, package, release, or deploy any code project on GitHub. The important concepts to understand are :

    Workflow Files: Workflows are defined in YAML files in the .github/workflows directory of your repository. These files specify what actions should happen when a certain event occurs in your repository.
    Events: Workflows are triggered by specific events. Common events include pushing new commits to a repository, creating a pull request, releasing a new version, or even on a scheduled basis (like running a job every night).
    Jobs: A workflow can consist of one or more jobs. Jobs are a set of steps that execute on the same runner. You can have multiple jobs run in parallel, or you can have them run sequentially, depending on your needs.
    Steps: Each job in a workflow is made up of steps. Steps can be either a shell command or an action. These steps can do things like checking out your code from the repository, running a script, installing dependencies, running tests, building your code, or deploying it.
    Actions: Actions are standalone commands that are combined into steps to create a job. GitHub provides a marketplace of pre-built actions for common tasks, or you can create your own custom actions.
    Runners: Workflows run on runners, which are specific servers with the GitHub Actions runner application installed. You can use runners hosted by GitHub, or you can host your own runners. These runners execute the jobs defined in your workflows.

In essence, leverage GitHub workflow to automate your software development processes making it easier to integrate continuous integration (CI) and continuous deployment (CD) in order to be a Master programmer 😎

    This means tasks like testing code, building binaries or docker images and deploying to production can be done automatically every time you make changes to your code, ensuring consistency and efficiency in your development process.

More information on the official documentation
Set up python application

Create a folder with this requirements.txt file inside :

pydantic
fastapi
uvicorn
python-multipart
websockets

Then create the main.py application file like this :
main.py

from fastapi import FastAPI
import json, os
from pydantic import BaseModel
from typing import List, Optional, Dict, Any

# Initialize FastAPI app
app = FastAPI()

@app.get("/")
async def test():
    return {"message": "OK"}

And that's pretty much it, we have our Python FastAPI server up and running in few lines of code 🥳

For running our app on the 8001 port (you can change this if you want) you just have to run inside you app folder this command :

uvicorn main:app --reload --port=8001

You should see the swagger generated documentation at localhost:8001/docs
Create dev branch and merge code base

In order to illustrate how branch works , lt's create a new dev branch with this command :

git checkout -b dev

Then let's write (or edit) a file, for our example let's create a start.sh bash script with only this line inside :

uvicorn main:app --reload --port=8001

It is clearly not the best optimal modification to do but it will do the trick. Then let's add, commit and push this change to our new dev branch like this :

git add *
git commit -m 'add some dev features'
git push -u origin dev

Great you now have two branches inside your project and you can switch back with the command git checkout <your-branch-name>.

Now it is the time to merge our two branches 🥳
Merge Pull Request

Then you can go on your web browser on your github repository and see the dev branch. You can see also a pull request green button, when you click on the green button you can see all the details about the pull request like below :

You can also notice that github automatically detect the code conflict between your two branches.

You can also do it in command line if you fell more comfortable, follow the official documentation 🤓

    Keep in mind that in this simple case github will do the work for us but if your code is more complex it can be more challenging so it is always a good to read the code with humain eyes 🤓

Write your first yml workflow

Our goal here is to build and run the app every time new code is added to the code base or every time a pull request is trigger.

Let's start by addind this run.yml file inside your .github/workflows/run.yml at your repository root. It will just install all the necessary packages and run our python simple server, as you can see below the core benefit of the yml langage is to be easily understundable

name: FastAPI run 

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  fastapi-run:
    runs-on: ubuntu-20.04

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.7'

      - name: Install Backend Dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r ./requirements.txt

      - name: Start Backend Server
        run: uvicorn main:app --reload &

or you can use the web browser interface for creating the workflow like this :

If you are using the web browser interface you can commit it on the main branch or create a new branch for the occasion since now you know how to merge branch 😎
Test workflow locally with act

The main problem with git workflow is you can only test it on event like push, pull request ... not very handy when you try to train.

That's why act comes in, first you need to download act on their github here or follow the installation guide.

The act tool run your GitHub Actions locally! According to their github : why would you want to do this? Two reasons:

    Fast Feedback - Rather than having to commit/push every time you want to test out the changes you are making to your .github/workflows/ files (or for any changes to embedded GitHub actions), you can use act to run the actions locally.
    Local Task Runner

Run local workflow with act

Github workflows are great, it is just sad that we can just test it when you trigger event on git (push, pull request, release ect...) it's not very good for learning too. That's why act comes in by simulating the GitHub Actions environment on your local machine 😎
How it's work

At its core, act relies on Docker. Each GitHub Action you run through act is executed in a Docker container. It uses containers to mimic the environments where GitHub would normally run your workflows.

    Act starts by parsing the workflow files in your .github/workflows directory.
    For each job in your workflow, act creates a Docker container to mimic the environment specified in the workflow file and runs the steps defined in your workflow file.
    Similar to GitHub Actions, act captures outputs and artifacts generated during the workflow run.
    If your workflow includes services (like databases or caches), act can handle service containers as well by sets up networking between these containers.
    Act has a plugin system that allows the community to extend its functionality. More information on the documentation.

Run workflows

You can use the act cli in order to trigger and run certain workflow in your local environement. First list all the available workflow in your git repository (do not forget to run this commands inside your root repository)

act -l

You should see something like this (if you have only the workflow written earlier in your repository) :

Stage  Job ID       Job name     Workflow name  Workflow file  Events           
0      fastapi-run  fastapi-run  FastAPI run    run.yml        pull_request,push

Then you can run this workflow with this command :

act

or target a specific job with this command :

act -j fastapi-run

You should see after many steps a validation message like bellow :

[FastAPI run/fastapi-run] ⭐ Run Main Install Backend Dependencies
[FastAPI run/fastapi-run]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/workflow/2] user= workdir=
| Requirement already satisfied: pip in /opt/hostedtoolcache/Python/3.7.17/x64/lib/python3.7/site-packages (23.0.1)
| Collecting pip
|   Downloading pip-23.3.2-py3-none-any.whl.metadata (3.5 kB)
| Downloading pip-23.3.2-py3-none-any.whl (2.1 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.1/2.1 MB 2.9 MB/s eta 0:00:00
| Installing collected packages: pip
|   Attempting uninstall: pip
|     Found existing installation: pip 23.0.1
|     Uninstalling pip-23.0.1:
|       Successfully uninstalled pip-23.0.1
|...
|...
|...
|[FastAPI run/fastapi-run]   ✅  Success - Post Set up Python
|[FastAPI run/fastapi-run] Cleaning up container for job fastapi-run
|[FastAPI run/fastapi-run] 🏁  Job succeeded

Managing secrets

To run act with secrets, you can enter them interactively, supply them as environment variables or load them from a file. The following options are available for providing secrets:

    act -s MY_SECRET=somevalue - use somevalue as the value for MY_SECRET.
    act -s MY_SECRET - check for an environment variable named MY_SECRET and use it if it exists. If the environment variable is not defined, prompt the user for a value.
    act --secret-file my.secrets - load secrets values from my.secrets file. secrets file format is the same as .env format

    Do not forget to add this file into your .gitignore in order to not push it on github!

Then you can push safely your workflow to your remote repository !
Deploy your workflow on github

Now let's return on our terminal and synchronise our remote git repo (which is containing a new version of the main branch if you have merge the pull request) it is time to git pull and you should see something like this :

Updating e2d610b..8f5cb4b
Fast-forward
 .github/workflows/run.yml       |  29 +++++++++++++++++++++++++++++
 __pycache__/main.cpython-37.pyc | Bin 0 -> 718 bytes
 main.py                         |  17 +++++++++++++++++
 requirements.txt                |   6 ++++++
 start.sh                        |   1 +
 5 files changed, 53 insertions(+)
 create mode 100644 .github/workflows/run.yml
 create mode 100644 __pycache__/main.cpython-37.pyc
 create mode 100644 main.py
 create mode 100644 requirements.txt
 create mode 100644 start.sh

This output means that github have been done the synchronisartion between your code on your local computer and your code on the remote repository, which is good we have the lateast version of our code let's continue !
Trigger you workflow

As you may notice on our first workflow, it is trigger by 2 things pull request and push on the main branch which you can see with the on field on our file :

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

So let's push something, or if you are lazy just edit and modify the README.md file at the root of your repo and push the change on your main branch you should see this in the action tab of your repository :

And after few seconds the pipeline should be done and you should see this :

With all the details about the states of your pipeline (you just have to expand the items) 😎
Automate the testing actions

Now let's automate the testing actions. Each time code is push on the repo let's run our run.yml and test.yml workflows.

First in order to test our application let's refactor a little our folder according to the documentation

Here is the refactored app tree :

.
├── README.md
├── app
│   ├── __init__.py
│   ├── main.py
│   └── test_main.py
├── requirements.txt
└── start.sh

Since we have refactor our app do not forget to change the start.sh script and aading the app. prefix like this :

uvicorn app.main:app --reload --port=8001

And do the same thing for the ./github/workflows/run.yml

For the test file we will do the same thing that the documentation do :

from fastapi.testclient import TestClient
from .main import app

client = TestClient(app)

def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "OK"}

Run pytest inside your repository in order to confirm that the test is passing, you should see something like this :

=================================================================== test session starts ===================================================================
platform darwin -- Python 3.7.0, pytest-5.3.2, py-1.8.1, pluggy-0.13.1
rootdir: /Users/mac/workspace/ds_course/python-ci-cd
plugins: dash-2.8.1, anyio-3.2.0, requests-mock-1.7.0
collected 1 item                                                                                                                                          

app/test_main.py .                                                                                                                                  [100%]

==================================================================== 1 passed in 0.73s ====================================================================

It means the test has been passed well 🥳
Adding test workflow

Now our mission is to add this test into our github workflows in order to run this test for each push on the main branch. If you think about it two seconds, it is just about transform our local command line to a yml file. Take a moment and try to do it yourself then look at the solution below.

name: FastAPI test 

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  fastapi-run-test:
    runs-on: ubuntu-20.04

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.7'

      - name: Install Backend Dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r ./requirements.txt

      - name: Start Backend Server
        run: uvicorn app.main:app --reload & 

      #add some test
      - name: Test with pytest
        run: |
          pip install pytest pytest-cov
          pytest

Push this change into your repository and go to the action section of the git repo you should see this :

Add docker build workflow

Our next goal in order to build a robust continus integration pipeline is to integrate the automate docker container build task. Let's me rephrase that, we want at each push or pull request on the main branch of our repository to trigger the build of our application.

In a simple term if we know that the run and testing workflow are goods (we have seen that above) we can now build a docker image of our code. Take two minute to think about it before reading the solution below 🤓
Add Dockerfile to our python app

If we want to build some docker images let's begin to add a Dockerfile to our project. Just write this in the root of your github repository.

# Start with the FastAPI base image
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir firebase-admin pydantic
EXPOSE 8001
#COPY .env /app
# Set environment variables from .env file
ENV ENV_FILE_LOCATION=/app/.env

You can ignore the ENV instruction if you do not have set up a .env file.

name: Docker Image CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Build the Docker image
      run: docker build . --file Dockerfile --tag python-test:$(date +%s)

here :

Add docker push workflow

First you need to add your docker credentials in the secrets settings by going into settings > secrets and variables > actions > add new secret like in the picture below.

    Using secrets is essential if you want to share some private informations about your project tiers (like dockerhub or your deployment server for example) is the common practice. More informations about github secrets in the official documentation

Then we can edit our new action workflow, let's name it push-docker.yml it will simply login into your dockerhub account, build and push our image on it.

name: Publish Docker image

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  push_to_registry:
    name: Push Docker image to Docker Hub
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/arm/v7
          push: true
          tags: bdallard/python-ci:latest

Then we can see our pipeline of 4 workflows :

    Run our server
    Test our server
    Build docker image of our server
    Publish the docker image on our private dockerhub repository

You should see green flags ✅ like this in your repository :

Great work, you now have set up and entier CI github pipeline 🥳
Deployment

Deployment refers to the process of putting your application or code into a production environment where it can be used by end-users. This means moving the code from a development or staging environment (where you test and finalize your application) to a production environment : where the application is actually used.

    Every deployment it's specific to a certain environement and needs to be specify into the workflow file, define the steps for deployment. This is pretty much the same steps : - Checking out your code. - Building your application (if necessary for node, java and 🧙🏼‍♂️). - Running tests to ensure code reliability. - Actually deploying the code to your custom server.

jobs:
  deploy-my-custom-app:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build and Tests 🤓
      run: |
        # Add commands to build and test your app
    - name: Deploy to my custom server 🥳
      run: |
        # Add commands to deploy your app on your custom server
        # This might involve SSHing into your server, copying files...
        # Or you can do it with docker like a 🥷🏼

Then as you may know it is a good practice to configure your secrets for your deployment process like server IP, passwords or API keys, you can store these as encrypted secrets in your GitHub repository settings and reference these secrets in your workflow file like we did before.

    Monitor Your Deployment 🤓
    - Check the progress and outcome of your deployment in the Actions tab of your GitHub repository. If there are issues, the logs provided there can help you troubleshoot.

Cloudron

In this example let's try to deploy our app through Cloudron with docker like a 🥷🏼

    Do not forget to read the cloudron documentation before digging into the code below 🤓

First RTFM and add a CloudronManifest.json file in your repo like in the example :

{
  "id": "com.example.test",
  "title": "Example FastAPI Application",
  "author": "Benjamin",
  "description": "This is an example python app",
  "tagline": "A great coding adventure",
  "version": "0.0.1",
  "healthCheckPath": "/",
  "httpPort": 8001,
  "addons": {
    "localstorage": {},
    "ldap": {},
    "proxyAuth": {}
  },
  "manifestVersion": 2,
  "website": "https://www.example.com",
  "contactEmail": "support@clourdon.io",
  "icon": "file://icon.png",
  "tags": [ "test", "collaboration" ],
  "mediaLinks": [ "https://images.rapgenius.com/fd0175ef780e2feefb30055be9f2e022.520x343x1.jpg" ]
}

    If you notice we added some addons : "addons": { "localstorage": {}, "ldap": {}, "proxyAuth": {} } In order to leverage the SSO auth of cloudron 😎

Then build your image and push it into your private dockerhub repository, store it as secret into your github secrets then write the cloudron-deploy.yml file here :

name: CloudRon Auto Deployment

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Environment Setup
        uses: actions/setup-node@v2-beta
        with:
          node-version: '18'
      - name: Deploy setup
        run: npm install -g cloudron
      - name: Update App
        run: |
          update="cloudron update --no-wait \
            --server ${{ secrets.CLOUDRON_SERVER }} \
            --token ${{ secrets.CLOUDRON_TOKEN }} \
            --app ${{ secrets.CLOUDRON_APP }} \
            --image ${{ secrets.DOCKER_IMAGE }}"
          # Retry up to 5 times (with linear backoff)
          NEXT_WAIT_TIME=0
          until [ $NEXT_WAIT_TIME -eq 5 ] || $update; do
              sleep $(( NEXT_WAIT_TIME++ ))
          done
          [ $NEXT_WAIT_TIME -lt 5 ]

You should see in your logs :

 => Waiting for app to be updated 
 => Queued 
 => Creating container 
 => Wait for health check ......

App is updated.

That's it for our cloudron deployment, be proud you

The specifics of your deployment process will depend on the technology you're using for your server, where you're deploying it (like a cloud provider or your own server), and the needs of your application.
Was this page helpful?
Previous
Introduction
Next
Jenkins
Copyright © 2019 - 2024 Dallard Tech
