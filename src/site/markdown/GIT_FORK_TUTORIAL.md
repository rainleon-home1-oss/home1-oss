# oss fork开发文档

## Overview
在团队协作进行oss项目开发时，我们采用fork原工程，提交merge request的方式进行。本文档以fork工程`oss-lib`为例，来说明这种方式的具体操作流程。

## 具体步骤
 * 在gitlab中原项目点击fork，fork到自己的空间下
 * 克隆fork的项目到本地
 * 使用gitflow进行开发
 * 在feature分支上进行业务开发
 * 开发完成后，使用gitflow结束业务开发
 * 将代码push到自己的远端gitlab仓库
 * 创建远端fork项目到原项目的merge request

## fork工程同步
在fork项目后，需要我们不定期得将原项目的代码合并到fork的项目中，具体操作如下：
 * clone fork出来的项目到本地
  
  `git clone git@gitlab.internal:username/oss-lib.git`
 * 进入项目

  `cd oss-lib`
 * 添加源remote，命名为`upstream`

  `git remote add upstream git@gitlab.internal:home1-oss/oss-lib.git`
 * fetch源项目的所有分支代码

  `git fetch upstream`
 * 本地切换回初始分支`develop`

  `git checkout develop`
 * rebase 源`upstream`的`develop`分支到本项目的`develop`分支

  `git rebase upstream/develop`
通过以上步骤，就可以使得fork项目的develop分支与源项目的同一分支保持一致。

## git fork示意图
  ![intellij-maven-runner.png](images/git_fork.png)

## 关于github的PR（PULL REQUEST）

- 对于已经push的commit，无法提部分PR，PR是针对分支的，push到远端的提交，在PR的merge阶段，全部可见，可一起并入
- 对于编辑PR，在接受者端，可通过点击发起的PR，进入review阶段，可添加标注。如果需要打回，告知PR发起者，发起者可撤回PR，修改后，再次提交PR
- 压扁操作，可借助`git rebase`命令实现，具体操作参见下文。

## git 精简历史commit

> 当在fork修改历史比较多的时候，也就是说，提交了n次的commit操作，这个时候，git 的提交历史记录会很多很乱，如果直接提PR合并到owner的仓库去，也会污染原始项目的提交历史。
这时可以借助rebase来进行提交历史的合并，来改变历史，使得代码提交历史更加整洁。 我们通过`git rebase -i commit_id`来实现(对于commit_id的选择，这里注意，不包括指定的commit_id,合并范围为指定commit_id之后的提交列表)
下面我们以一个实际例子来展示如何以正确姿势使用 `git rebase -i`:

使用`git log` 查找最近4次的提交历史为：

        git log --pretty=format:"%h %s" --graph

        * 3cfe42f *  configserver nodeport指定为30000
        * c69df54 *  Jenkins ldap相关文档，项目地址替换成github项目
        * d559921 *  gitlab相关文档，项目地址替换成github项目
        * 6eae62b *  configserver + todomvc k8s配置调整
        * f281b52 add sonarqube

要将 `3cfe42f c69df54 d559921` 这三次的提交压扁合并为一次，则通过如下：

        git rebase -i 6eae62b

接下来会提示进行commit历史的操作界面

        pick d559921 *  gitlab相关文档，项目地址替换成github项目
        pick c69df54 *  Jenkins ldap相关文档，项目地址替换成github项目
        pick 3cfe42f *  configserver nodeport指定为30000

        # Rebase 6eae62b..3cfe42f onto 6eae62b (3 commands)
        #
        # Commands:
        # p, pick = use commit
        # r, reword = use commit, but edit the commit message
        # e, edit = use commit, but stop for amending
        # s, squash = use commit, but meld into previous commit
        # f, fixup = like "squash", but discard this commit's log message
        # x, exec = run command (the rest of the line) using shell
        # d, drop = remove commit
        #
        # These lines can be re-ordered; they are executed from top to bottom.
        #
        # If you remove a line here THAT COMMIT WILL BE LOST.
        #
        # However, if you remove everything, the rebase will be aborted.
        #
        # Note that empty commits are commented out

这时，可以修改为

        pick d559921 *  gitlab相关文档，项目地址替换成github项目
        squash c69df54 *  Jenkins ldap相关文档，项目地址替换成github项目
        squash 3cfe42f *  configserver nodeport指定为30000

意味着将这三次提交合并为一次，并且保留提交备注。然后输入wq退出，进入合并页面

        # This is a combination of 3 commits.
        # This is the 1st commit message:
        *  gitlab相关文档，项目地址替换成github项目
        *  Jenkins ldap相关文档，项目地址替换成github项目
        *  configserver nodeport指定为30000

修改备注，留下保留的备注，保存退出。完成合并。

注意这时的合并是提交到本地仓库的，需要向远端仓库push。如果之前的每次commit没有push到远端，则直接`git push`没有问题，如果之前的提交已经push到远端，则需要追加强制提交的参数

        git push origin develop -f

这时进入github项目提交历史页面，可以看到之前的三次提交已经合并为一个commit了，正常发起PR即可。


## NOTE
- 注意，`git push -f` 执行时，需要注意，请确保本次代码的完整性。以免导致代码丢失。


