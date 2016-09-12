---
layout:     post
title:      # Part 2a - Getting started (old solution)
date:       2016-08-11 11:21:29
summary:    This post contains old text, describing a (deprecated) method on how to deal with html documents stored in different locations of the application's code base.
categories: digital-edition
---

To fix this, we have to do two things. First, we have to remove the relative links in our application’s base template *templates/page.html*. Because when you open this document, you can see that the links to the start page *index.html* are described relative to our application’s root directory. 

```html
...

<a data-template="config:app-title" class="navbar-brand" href="./index.html">App Title</a>

...


<li class="dropdown" id="about">
    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Home</a>
    <ul class="dropdown-menu">
        <li>
            <a href="index.html">Home</a>
        </li>
    </ul>
</li>

...
```

Interestingly, the bootstrap css-stylesheets are found and rendered correctly (NOTE:  To be honest, the logo is rendered far too big and in the wrong place. We will deal with this later.) as is the eXist-db logo. Looking at the latter, we see that here the link is set as:

`<img src="$shared/resources/images/powered-by.svg" alt="Powered by eXist-db"/>`

Here obviously some variable **$shared** is used which resolves to the directory  `/db/apps/shared-resources/`.

Exactly this directive: »whenever you find the string **"$shared"** in a URL, replace ›$shared‹ with `/db/apps/shared-resources/`« can be found in the document named *controller.xql* which is located in our application’s root-directory. Of course, in this document this directive is written in a less prosaic but more machine readable manner (lines 32–37): 

```xquery
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
```

### $app-root-href

Let’s use a similar method for our own purposes and write our own directive. A directive which declares something like: »whenever you meet a URL containing the string ›$app-root-href‹, please redirect us to our index.html page.« To achieve this, we add this code snippet into *controller.xql*, maybe after the first *else if* statement (i.e. around line 20):

```xquery
else if (contains($exist:path,"$app-root-href")) then
    (: forward root path to index.html :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="http://localhost:8080/exist/apps/thun-demo/index.html"/>
    </dispatch>
```

Save the changes and open our main template document *templates/page.html*. In this document, we have to change the links referring to our *index.html*. Those links are found around line 22

`<a data-template="config:app-title" class="navbar-brand" href="./index.html">App Title</a>`

We change this to:

`<a data-template="config:app-title" class="navbar-brand" href="$app-root-href/index.html">App Title</a>`

and line 30

`<a href="index.html">Home</a>`

becomes:

`<a href="$app-root-href/index.html">Home</a>`

Save the changes in *templates/page.html* and then browse to our *pages.html* to check if the links are working. They should now.

### Remove hard coded links

But this solution is not perfect yet. The links will only work on your locally installed eXist-db instance because of the hard-coded link in the *controller.xql* document: 

`<redirect url="http://localhost:8080/exist/apps/thun-demo/index.html/">`.

And we don’t like hard coded links. To get rid of them, we can use the variables which were created by the **Deployment Editor** and which are already loaded by default into the *controller.xql* as you can see in the lines 3–7:

```xquery

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

```

As the names of those variables may not be totally self explanatory, I would recommend to read about their values [here](http://exist-db.org/exist/apps/doc/urlrewrite.xml), in the section »Variables«. 

As we are interested in referring to our application’s root directory, we are going to use **$exist:controller** because this points to the directory in which the document *controller.xql* is located. And this is the application’s root directory. 

So with the help of  **$exist:controller, $exist:path**, and some string manipulation, we replace the hardcoded value of the attribute ›url‹ in the ›redirect‹ element by

`<redirect url="/exist/apps/{$exist:controller}{substring-after($exist:path, "$app-root-href")}"/>`

This url still contains hard coded parts (»*/exist/apps/*«) but this part I would like to keep in my application anyway. 

After saving this change in *controller.xql*, let’s browse to [http://localhost:8080/exist/apps/thun-demo/pages/show.html](http://localhost:8080/exist/apps/thun-demo/pages/show.html) to check if the links back to *index.html* are still working. 