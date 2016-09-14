---
layout:     post
title:      # Part 11 - Start a new project
date:       2016-09-14 12:00:00
summary:    In the 11th part we are going to start a new web app based upon the code created so far
categories: digital-edition
---

# Introduction and requirements

Ok, let's say we continued working on our code base and created a beautiful and highly user friendly digital edition custom tailored towards the mark up of our XML/TEI documents. And since this web app is so wonderful, other people are now constantly knocking on our door wanting something similar. The current part of this HowTos tries to sketch one *possible* workflow.
All we need is again an eXist-db instance, and the application package we [created so far]({{ site.baseurl }}/downloads/part-10/thun-demo-0.1.xar). In case you were following the previous tutorials and you have already a running instance of our thun-demo app installed, I would kindly ask you [to rename]({{ site.baseurl }}{% post_url 2016-08-15-part-6-rename-the-app %}) this instance so you can safely install another version of thun-demo-0.1.xar. In my case I renamed it into "thun-demo-orig-0.1.xar". You can find the renamed version [here]({{ site.baseurl }}/downloads/part-11/thun-demo-orig-0.1.xar).

# Install the package

To start a fresh project, lets upload the (renamed) package via eXist-db's **Package Manager**. If everything worked you should see the according tile on the dashboard appear (maybe after you refreshed the browser). As you can see, I have now both, the 'old' and the renamed version of Thun-Demo running on my eXist-db instance.

![image alt text]({{ site.baseurl }}/images/part-11/image_0.jpg)

## Remove Thun-Traces

Since the new project most likely won't deal with any materials related to Thun, we should remove all traces of it. In the same step, we can also add an actual title, description, ... as I already described in [Part-6]({{ site.baseurl }}{% post_url 2016-08-15-part-6-rename-the-app %}). 

### application's namespace

Besides adjusting/renaming the metadata properties stored in **repo.xml** and **expath-pkg.xml** we should also search and replace for the 'old' application namespace. For this, oXygen provides a nice feature. In oXygen's data source explorer, browse to the application's root directory `db/apps/thun-demo-orig` click on it and open oXygen's context menu (right mouse click) and go to **Find/Replace in Files**. 

![image alt text]({{ site.baseurl }}/images/part-11/image_1.jpg)