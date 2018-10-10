# ROADMAP - CronKeeper

1. Command line options:

    a. init - to init a local git repo

    b. add-remote - to clone an existing repo
    
    c. commit - to commit all changes made to the git repo

    d. clean - to delete the local repo

    e. push - to push the repo to a remote repo (Github, GitLab, BitBucket)

    - push persistent - to store the login credentials for the online git repo (avoid re-entering username/password)
    - push timer [time] - how often to push to the remote repo [default = 1 day]
  
    f. edit - edit the crontab
  
    g. help - prints the help