---
layout:     post
title:      # Part 6 - Rename the app
date:       2016-08-15 11:21:29
summary:    In this sixth part of this series of tutorials we will rename, pack and (re)deploy our current digital edition’s application.
categories: digital-edition
---

# Introduction and requirements


In this sixth part of this series of tutorials we will rename, pack and (re)deploy our current digital edition’s application. If you have no intentions at all to ever create another digital editions application than the current one (which is called thun-demo), then you can go on and skip this part. If not, you will learn, which parts of which files you will have to modify to rename the package, the applications title and the visible URLs. 

This tutorial will use the code [build so far]({{ site.baseurl }}{% post_url 2016-08-14-part-5-clean-up-the-code %}) and which you can download [here]({{ site.baseurl }}/downloads/part-5/thun-demo-0.1.xar).

# expath-pkg.xml

The first file which needs some modification is called **expath-pkg.xml** which is located in the application’s root directory. For our application this file contains only the following lines:

```xml
<package xmlns="http://expath.org/ns/pkg" name="http://www.digital-archiv.at/ns/thun-demo" abbrev="thun" version="0.1" spec="1.0">
    <title>Thun Demo App</title>
    <dependency package="http://exist-db.org/apps/shared"/>
</package>
```

Thanks to the kind of self explanatory element and attribute names, figuring out which things to change is not actually rocket science. 

As far as the name attribute in the package element is concerned, the only thing we have to take care of is, that no other package deployed on our eXist-db instance uses the same URI. But to keep things consistent, I would recommend to adapt the value of the **@name** attribute. 

More important (or visible) is the **@abbrev** value which will be reflected in the package’s name. 

This is also true for the `<title>`-element. 

If you want to transform our Thun-Demo application into a digital edition dealing with sources about reading in alpine regions in the 18th/19th century and which might be called [Reading in the alps](http://digital-archiv.at:8081/exist/apps/buchbesitz-collection/index.html), then go ahead and change **expath-pkg.xml** into:

```xml
<package xmlns="http://expath.org/ns/pkg" name="http://www.digital-archiv.at/ns/rita-demo" abbrev="rita-demo" version="0.1" spec="1.0">
    <title>Reading in the Alps Demo</title>
    <dependency package="http://exist-db.org/apps/shared"/>
</package>
```

## repo.xml 

The only thing to do now, is to change **repo.xml** which is an eXist-db specific supplementation of the (standardized) expath-pkg.xml. 

```xml
<meta xmlns="http://exist-db.org/xquery/repo">
    <description>Thun-Demo</description>
    <author/>
    <website/>
    <status>alpha</status>
    <license>GNU-LGPL</license>
    <copyright>true</copyright>
    <type>application</type>
    <target>thun-demo</target>
    <prepare>pre-install.xql</prepare>
    <finish/>
    <permissions user="admin" group="dba" mode="rw-rw-r--"/>
    <deployed>2016-05-23T14:46:20.056+02:00</deployed>
</meta>
```

The important elements for renaming an applications are `<description>` and especially `<target>`. Whereas the first is used by the applications base template **templates/page.html** to prefill the templates `<meta>` element, the value of the `<target>` element sets the path to the place where the application will be stored in the databse. To quote from [Erik Siegel’s and Adam Retter’s eXist book](http://shop.oreilly.com/product/0636920026525.do), page 234: 

> The target child element tells eXist where to store the package in the database. This must be a relative path, and eXist prepends this with the root collection where the repository manager stores installed packages. This is, by default, `/db/apps`. So, a package with `<target>xyz</target>` specified in repo.xml will be stored in `/db/apps/xyz`. 

Since we took a lot of effort to remove all hard coded links from our application in the last part, the target is not absolutely crucial. But similar to the application’s namespace, it makes sense to uphold some consistency. Thats why we apply the following changes:

```xml
<meta xmlns="http://exist-db.org/xquery/repo">
    <description>Reading in the alps demo</description>
    <author/>
    <website/>
    <status>alpha</status>
    <license>GNU-LGPL</license>
    <copyright>true</copyright>
    <type>application</type>
    <target>rita</target>
    <prepare>pre-install.xql</prepare>
    <finish/>
    <permissions user="admin" group="dba" mode="rw-rw-r--"/>
    <deployed>2016-05-23T14:46:20.056+02:00</deployed>
</meta>
```

After saving our changes we can browse now to the [application's start page](http://localhost:8080/exist/apps/thun-demo/pages/index.html) and we see first traces of our work as depicted below.

![image alt text]({{ site.baseurl }}/images/part-6/image_2.jpg)

But whereas the red circles show some progress, the circles colored differently show some artifacts of the application's previous name. But those will disappear the following step.
First we can download the application by clicking on **Application/Download** button in [eXide’s navigation menu](http://localhost:8080/exist/apps/eXide/index.html) (make sure you opened any file from the application). 

# Deploy and test

And second we can install this packages and see if everything works as it should or if we still find traces of "thun-demo" in our brand new “rita-demo”. 

Looks good:

![image alt text]({{ site.baseurl }}/images/part-6/image_0.jpg)

Well not completely, since we are using still the XML/TEI documents from Thun-Demo as we can see in our table of content. 

![image alt text]({{ site.baseurl }}/images/part-6/image_1.jpg)

But this is easy to fix. Just replace the documents stored in `data/editions/` and you are done.

# Deployment Editor

If you got tired of editing raw XML documents already, which I hope you are not because there are many more things to do in the next tutorials, you can renamed/adapt/modify **expath-pkg.xml** and **repo.xml** with the help of eXide’s **Deployment Editor**. In eXides navbar click on Application/Edit Descriptors. After this sixth part of our tutorial series you should be familiar enough to now which fields map to which elements/attributes in the aforementioned documents. 

# Conclusion and outlook

Congrats! You are now in the possession of a lightweight eXist-db package containing basic functionalities of a digital editions web application. And now you are also in possession of the necessary knowledge on how to deploy, rename, pack, and (re)distribute it. So if someone is ever going to ask you, if you could build a basic digital edition web application for him, you should be capable of doing so in maximum 15 minutes (grabbing a coffee already included). 

Of course the current application is very barebone. But in the upcoming tutorials we will add more and more features to it. While doing so, we will constantly reflect our actions to make sure, that our code will stay as reusable as reasonable and possible. 

In the [next tutorial]({{ site.baseurl }}{% post_url 2016-08-16-part-7-index-based-search %}) we will tackle the topic of index or register based search functionalities.

# Disclaimer

Actually there are still traces of our thun-demo app in the code of the renamed rita-demo application (which can be downloaded as package [here]({{ site.baseurl }}/downloads/part-6/rita-demo-0.1.xar)). When you look for example into the code of `modules/app.xql` you will see that for example the **config module** is related to the namespace "http://www.digital-archiv.at/ns/**thun-demo**/config". There are basically two ways to fix this.

* We could modify the build process of the package, providing some variables and some build templates. But this is quite a lot of work and also quite error prone. 
* Alternatively we can replace the namespace by hand or even better by the use of a search & replace command. 

You can download the rita-demo package with updated namespaces [here]({{ site.baseurl }}/downloads/part-6/rita-demo-0.1_new_ns.xar)


