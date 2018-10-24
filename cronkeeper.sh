#! /bin/bash

curr_user=$(whoami)
cron_dir=$HOME/.cronkeeper

check() {
    
}

init() {
    if [ -d "$cron_dir" ]
    then    
        printf "Cronkeeper repo already exists\n"
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
        exec git commit -m "Modified on $(date)" ; \
        printf "Changes committed to local repo!\n" )
    fi
}

edit() {
    crontab -e
    if [ ! -d "$cron_dir"  ]
    then
        printf "Git repo doesn't exist!\nMaking a new repo..\n"
        init
    fi
    commit
}

clean() {
    printf "Are you sure? (y/N): "; 
    read ans
    if [ ! -z $ans ]  
    then
        if [ $ans == "y" ] || [ $ans == "Y" ]
        then
            rm -rI $cron_dir
            #printf "Repo removed!\n"
        else
            printf "Repo not removed!\n"
        fi
    else    
        printf "Repo not removed!\n"
    fi
}

push() {
    (cd $cron_dir && exec git ls-remote --exit-code &> /dev/null)
    if [ $? -eq 0 ]
    then
        git push -u origin master
    else
        printf "No remote repo configured\n"
    fi
}

push-persistent() {
    (cd $cron_dir && exec git config credential.helper store)
    push
}

add-remote() {
    if [ -d "$cron_dir" ]
    then
        printf "Enter remote url: "
        read url
        (cd $cron_dir && exec git remote add origin $url)
    else
        printf "Local git repo not initialized!\n"
    fi
}

push-timer() {
    echo $curr_user
    if  grep -q cronkeeper /var/spool/cron/"$curr_user" 
    then
        sed -i '/cronkeeper/d' /var/spool/cron/$curr_user
    fi

    if [ -z "$2" ] 
    then
        printf "01 01 * * * /usr/bin/cronkeeper push\n" >> /var/spool/cron/$curr_user 
    else
        printf "$2 /usr/bin/cronkeeper push\n" >> /var/spool/cron/$curr_user
    fi 
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
        printf "Incorrect usage!\n"
esac
    

    