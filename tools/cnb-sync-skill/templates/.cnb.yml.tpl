$:
  vscode:
    - docker:
        build: .ide/Dockerfile
  services:
    - vscode
    - docker

feat*:
  push:
    - stages:
        - name: sync to github
          imports: {{CNB_IMPORTS_URL}}
          image: tencentcom/git-sync
          settings:
            target_url: https://github.com/{{GITHUB_OWNER}}/${CNB_REPO_NAME}.git
            auth_type: https
            username: ${GIT_USERNAME}
            password: ${GIT_ACCESS_TOKEN}
