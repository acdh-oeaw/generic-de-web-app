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

This will open a **Find/Replace in Files** form which will do exactly this what the name suggests. In case of our current project, I will search for **http://www.digital-archiv.at/ns/thun-demo/** which is the namespace of our 'old' application and replace it through **http://www.digital-archiv.at/ns/glaser/** which will be the namespace of my new application. 

![image alt text]({{ site.baseurl }}/images/part-11/image_2.jpg)

Having renamed everything, removed old data files and replaced the application's namespace, we can continue working on our new project. ([Here]())

# Version control

Either if you are developing an application or if you are e.g. working on (XML/TEI) documents it is usually a good thing save your files in some kind of version control system (e.g. GIT). This means that when you working with eXist-db you somehow need to get your data, your files, your application's code base OUT of eXist-db (or to be more precise of eXist-db's database) and on your local hard drive. eXide provides therefore a **Synchronize** function under **Application/Synchronize**. When you click on this, a new window opens where you have to fill in a **Target Directory** in which the documents of your application should be written. 

![image alt text]({{ site.baseurl }}/images/part-11/image_3.jpg)

When you try this out you will notice, that not all  documents from the root directory will be written to your hard drive. This becomes a problem if you want to build your application from your local drive because besides other files, the **build.xml** is missing. To fix this, you can crate a new document in the application's root directory and copy the following code into it. 
**sync.xql**

```xquery
xquery version "3.0";

declare namespace expath="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";

import module namespace config="http://www.digital-archiv.at/ns/glaser/config" at "modules/config.xqm";

let $target-base-default := "C:\Users\pandorfer\ownCloud\GIT\Redmine\glaser_exist\application-code"
let $app-name := doc(concat($config:app-root, "/repo.xml"))//repo:target/text()
return 

<response>{
try{
    let $source  := request:get-parameter("source",$config:app-root)
    let $target-base := request:get-parameter("target-base",$target-base-default)
    let $synced-files :=  file:sync($source, $target-base||"/"||$app-name, ()) 
    return $synced-files
    
} catch * {
    let $log := util:log("ERROR", ($err:code, $err:description) )
    return <ERROR>{($err:code, $err:description)}</ERROR>
}
}</response>
```

Adapt then the value of the variable `$target-base-default` to your needs and run **Eval** (be sure you are logged in) and ideally all files (if you run the script the first time, otherwise only modified files) will be written into the `$target-base-default` directory.
After you synced all documents to your local hard drive, you can open a comand line, browse into the directory which holds your application's code an run [ant](http://ant.apache.org/) to build your application. But be aware that you have to have ant installed for this. 

[Here]({{ site.baseurl }}/downloads/part-10/glaser-text-app-0.1.xar) is the code of the new app.