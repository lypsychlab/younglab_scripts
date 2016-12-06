# GitHub Documentation 

## About GitHub

Git is a framework that accomplishes two things:  
1. Allows you to sync directories  
2. Keeps track of what changes in your files with each sync

If you have used a command-line utility like rsync or scp, or an app like FileZilla, it's conceptually similar.
All you are doing is syncing a directory of files on your local computer with one on another computer.
GitHub's uniqueness lies in its system for tracking these syncs and the associated changes to files.

GitHub itself is three things:

1. A website (where your directory is synced to)  
	* [https://github.com](https://github.com)  
2. A command-line program called Git (that allows you to sync)  
	* download from: [https://git-scm.com/downloads](https://git-scm.com/downloads)  
3. A desktop application (basically the command-line utility, but in GUI form)  
	* download from: [https://desktop.github.com/](https://desktop.github.com/)  

## Desktop application versus command-line utility

I (Emily) generally prefer the flexibility and control of command-line programming, so the rest of this document
focuses on that. However, the desktop GUI is pretty and fairly straightforward to use. By the end of this document,
you should understand the concepts necessary to use it.

## Terminology

_repo_, or _repository_: a directory full of files, that also contains a .git subdirectory with metadata  
_remote repo_: a remote directory hosted on GitHub's servers  
_push_: to send files to another repo  
_pull_: to request files from another repo to be sent to your repo  
_add_: include a file in your set of files to be synced  
_stage for commit_: same as _add_   
_commit_: tell Git that you have made changes to a file and are ready to sync it  
_clone_: to copy an existing repo  
_branch_: a subset of your project, recording changes to files that you want to keep separate from the other parts of the project  
_merge_: merge a project branch back into the main part of the project, so that the whole project now reflects the changes made to that branch  
_master_: the name of the default or main branch created when you first make a repo  
_origin_: an alias for the URL of a remote repo that has been cloned to your computer  

## Quick how-tos:

### Setting up GitHub/Git

To make a new user account, just go to the GitHub website. You'll need a username, password, and associated email address.

Once you have done this, you can configure your local Git application to recognize your user information.
In Terminal, I'll write:  
```
git config --global user.name "[My name]"
git config --global user.email [My email address]
```

In GitHub Desktop, you can connect your GitHub account by going to GitHub Desktop > Preferences > Accounts, and signing in.

### Create a remote repo

The easiest way to do this is simply to use the GitHub website interface.
Go to your dashboard, go to the Repositories tab, and click New.

There are command-line ways of creating remote repos, but they are more advanced.
See [here](http://stackoverflow.com/questions/2423777/is-it-possible-to-create-a-remote-repo-on-github-from-the-cli-without-opening-br) if you really are interested.

### Create a repo from a local directory you already have

```git init [name of directory]```  
If this is successful, you should see a .git subdirectory in your directory.

If you are already in the directory, you can just call ```git init```.
In general, you should navigate to your repo directory when you are working on it.

### Clone a remote repo to your computer

```git clone [remote repo] [local directory]```  
Here, the name of the remote repo will be a URL, for example, https://github.com/emily-wasserman/myRepo.

If you leave out the local directory name, Git will make a new directory with the same name as the remote repo
(in this example, that would be 'myRepo').

Just like when you make a new local repo, this cloned repo should have a .git subdirectory.
This tells you that it is in fact a repo, and not just a regular directory.

### Track changes in a local repo

Let's say that I've already created a repo and added a file to it. 
Now I want to make sure Git is tracking all the changes to this file I am making in this repo. I run:  
```git add [name of file]```

Make sure you are in the repo when you run this command!

If I want Git to track ALL the files in my repo, I run: ```git add .```.

Now Git is tracking my changes, but I haven't made any commits yet.
In other words, Git knows that this file has been changed, but hasn't formally included these changes in the repo.
To commit the changes, I run:  
```git commit -m "[commit message]"```

The commit message is what people will see on GitHub when they look at all the changes you've made to your project.
It should be a concise description of what changes you are committing. For example, "Created README file".

Now Git has committed all the changes I indicated with my 'add' command.
These changes are explicitly recorded in a log associated with the project, and implicitly saved by Git.  
Essentially, all I've done is modified a file in my directory and nicely recorded the fact that I did so.
I can see all the past commits I've made, with their associated messages, by running ```git log```.

### Push to a remote repo

I've been doing some local work on my project, and I want to bring my remote repo up to date.
First, I need to figure out which URLs I can push to:  
```git remote -v```

This will list the names of all the remote repos that I can 'push' or 'fetch' (pull) data from.
It also shows their URLs, but since I know their names, I can just use the names as a stand-in.  
For most basic use cases, you'll be using the remote called 'origin'. Git creates this by default.

Now, I can push my local repo to the remote repo:
```git push [remote repo name] [branch name]```

Usually you'll be on the default master branch, pushing to origin, so this would read: ```git push origin master```.

You'll be asked to enter the username and password associated with your GitHub user account.

### Pull from a remote repo

Pulling looks just like pushing, only the direction of transfer is switched:
```git pull [remote repo name] [branch name]```

This command will grab all the files and changes from the remote repo and sync them with the branch I indicate.

As before, the typical use case is ```git pull origin master```. This brings my local master branch up-to-date with everything
in the remote repo.

### Switching branches

Usually I work on the master branch, but let's say I want to play around with some files WITHOUT altering the core of my project.

To make a new branch and switch to it, I run:  
```git checkout -b [branch name]```  
(_If my branch already exists, I can omit the -b flag._)

Now all my changes exist in this branch of the project only, and I can push/pull them specifically by indicating the branch name.

### Merging branches

I've decided that I like the changes I've made on my new branch, and I want the core of my project to reflect them. I run:  
```
git checkout master
git merge [branch name]
```

Anything I altered on my other branch is now also altered in the default master branch.
For simple projects, I'd recommend just using branches locally, then merging to master before pushing to your remote repo.
This way, every time you are pushing to remote, you know you are syncing ONLY your core project, not whatever half-finished
changes you might be working on.

### Use multiple GitHub accounts from the same computer

This is a little tricky, but useful to have on hand.

First, I'll need to generate an SSH keypair. My computer will store one half of the pair, and I'll give GitHub the other half.
That way it will be able to recognize me by matching its key to my key.
I'll do this for every new GitHub account I want to use from my computer.

In Terminal, run:  
```ssh-keygen -t rsa -C "[comment message here]" -f ~/.ssh/[name of key]```  
Typically I name my key something starting with id\_rsa, like "id\_rsa\_newKey".

I open up the .pub file I just created in ~/.ssh, id\_rsa\_newKey.pub, and copy everything in it. 
Then I go to GitHub, and log in to the user account I want to associate with this key.
Under Settings, I go to "GPG and SSH keys", and hit "New SSH key".  
I give it some title (maybe matching my comment message above), 
and paste into the Key field with everything I just copied from the .pub file.

Then I need to change permissions on my key:  
```chmod 400 ~/.ssh/[name of key]```  
And add the key to my set of SSH keys:  
```ssh-add ~/.ssh/[name of key]```

Now, I'll create and edit an SSH config file.  
```touch ~/.ssh/config```

I can open this file in any text editor. I'll add something like the following:  
Host github.com  
   Hostname github.com  
   User git  
   IdentityFile ~/.ssh/id_rsa  
Host github-[name of key]  
	HostName github.com  
	User git  
	IdentityFile ~/.ssh/[name of key]

Here, HostName, User, and IdentityFile should all be indented.

The first block just sets up my default github.com configuration, and associates it with my default SSH key.  
The second block creates a new alias for github.com, and associates it with my new key.  
Now I have two ways to communicate with GitHub's site, each associated with its own key.

To test whether this process worked, I'll first make a new remote repo, 'testRepo', on github.com, 
under the GitHub account I just associated with my new key.  
In this example, my account name is emily-wasserman, and my new key's name is newKey.
Then I will make a local repo, put a file in it, and try to sync that repo with my remote repo "testRepo".

```
mkdir ~/GitHub/testRepo
cd ~/GitHub/testRepo
git init
echo "#fake README message" >> README.md
git add README.md
git commit -m "test commit message"
git remote add origin git@github-newKey:emily-wasserman/testRepo.git
git push -u origin master
```

If this all worked, I should see a README file appear in my remote "testRepo" repo,
with the fake README message in it.
