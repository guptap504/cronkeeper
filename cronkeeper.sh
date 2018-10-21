#! /bin/bash

curr_user=$(whoami)
cron_dir=$HOME/.cronkeeper

init() {
    if [-d "$cron_dir"]
    then    
        echo "Cronkeeper repo already exists"
    else
        (mkdir $cron_dir && \
        cd $cron_dir && \
        exec git init && \
        if [-e '/var/spool/cron/$curr_user']
        then
            exec git add /var/spool/cron/$curr_user && \
        fi
        echo "Repo created!")
    fi
}

commit() {
    if [-e '/var/spool/cron/$curr_user']
    then
        (cd $cron_dir && \ 
        exec git add /var/spool/cron/$curr_user && \
        exec git commit -m "Modified on $(date)")
        echo "Changes committed to local repo!"
    else
        echo "Repo doesn't exist!"
    fi
}

edit() {
    crontab -e
    if [![-d $cron_dir]]
    then
        echo "Git repo doesn't exist!\nMaking a new repo.."
        init
    fi

    commit
}

delete() {
    rm -r $cron_dir
}

push() {
    (cd $cron_dir && exec git ls-remote --exit-code &> /dev/null)
    if [$? -eq 0]
    then
        git push -u origin master
    else
        echo "No remote repo configured"
    fi
}

push-persistent() {
    (cd $cron_dir && exec git config credential.helper store)
    push
}

add-remote() {
    if [-d "$cron_dir"]
    then
        echo "Enter remote url: "
        read url
        (cd $cron_dir && exec git remote add origin $url)
    else
        echo "Local git repo not initialized!"
    fi
}



    