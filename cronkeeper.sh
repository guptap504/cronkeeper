#! /bin/bash

curr_user=$(whoami)
cron_dir=$HOME/.cronkeeper

init() {
    if [ -d "$cron_dir" ]
    then    
        echo "Cronkeeper repo already exists"
    else
        ( mkdir $cron_dir && \
        cd $cron_dir && \
        exec git init )
        if [ -e '/var/spool/cron/$curr_user' ]
        then
            exec git add /var/spool/cron/$curr_user 
        fi
    fi
}

commit() {
    if [ -e '/var/spool/cron/$curr_user' ] 
    then
        ( cd $cron_dir && \ 
        exec git add /var/spool/cron/$curr_user && \
        exec git commit -m "Modified on $(date)" )
        echo "Changes committed to local repo!"
    fi
}

edit() {
    crontab -e
    if [ ! -d "$cron_dir"  ]
    then
        echo "Git repo doesn't exist!\nMaking a new repo.."
        init
    fi
    commit
}

clean() {
    echo "Are you sure? (y/N): "; 
    read ans
    if [ ! -z $ans ]  
    then
        if [ $ans == "y" ] || [ $ans == "Y" ]
        then
            rm -r $cron_dir
            echo "Repo removed!"
        else
            echo "Repo not removed!"
        fi
    else    
        echo "Repo not removed!"
    fi
}

push() {
    (cd $cron_dir && exec git ls-remote --exit-code &> /dev/null)
    if [ $? -eq 0 ]
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
    if [ -d "$cron_dir" ]
    then
        echo "Enter remote url: "
        read url
        (cd $cron_dir && exec git remote add origin $url)
    else
        echo "Local git repo not initialized!"
    fi
}

push-timer() {
    sed '/usr/bin/cronkeeper/d' /var/spool/cron/$curr_user
    def_cmd="01 01 * * * /usr/bin/cronkeeper push"
    if [ -n $2 ] 
    then
        def_cmd="$2 /usr/bin/cronkeeper push"
    fi
    echo $def_cmd >> /var/spool/cron/$curr_user
}

case $1 in 
    init)
        init
        ;;
    commit)
        commit
        ;;
    edit)
        edit
        ;;
    clean)
        clean
        ;;
    push)
        push
        ;;
    push-persistent)
        push-persistent
        ;;
    push-timer)
        push-timer
        ;;
    add-remote)
        add-remote
        ;;
    *)
        echo "Incorrect usage!"
esac
    

    