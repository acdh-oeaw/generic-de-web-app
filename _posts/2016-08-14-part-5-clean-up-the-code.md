---
layout:     post
title:      # Part 5 - Clean up the code
date:       2016-08-14 11:21:29
summary:    In the fith part we will clean up our code base - a little bit
categories: digital-edition
---

# Introduction and requirements

From an application’s user’s perspective, the upcoming changes to code base are more or less invisible. But from the perspective of the people who are in charge of developing and maintaining this application, this changes will make their lives much easier - hopefully. 

In the last chapter we implemented a kind of nice function which takes an XML and transforms it with a XSLT stylesheet into a more or less good looking HTML document. The only thing the user has to do for this is clicking on a link.

But when you now try to pack your application and deploy it to another server, you will run into some severe troubles - as long as the server you try to deploy your package is not named exactly as the one you developed the application. As you can see on the following screnshot, I deployed our little application to my personal but public play and test server called [www.digital-archiv.at](http://www.digital-archiv.at) (and not localhost).

![image alt text]({{ site.baseurl }}/images/part-5/image_0.jpg)

When you try to click on one of the links, you will be redirected to localhost thanks to our hardcoded URLs. And as long as you don't have exact the same application running on your localhost, you will receive something like this:

![image alt text]({{ site.baseurl }}/images/part-5/image_1.jpg)

And even if you want to deploy your application on the same server with a new name (we will look into renaming the application in another part of the tutorial later) you will run into problems. Because now your table of content will stay completely blank since so far, the application will look for your XML documents in a collection called something like *db/***_thun-demo_***/*… and not in the collection *db/***_{name-of-your-app}_***/…* .

![image alt text]({{ site.baseurl }}/images/part-5/image_2.jpg)

# Remove hard coded links

These malfunctions are clearly related with hard coded URLs we introduced in the last chapter. So let’s remove them. A task which is thanks to the devolpers of eXist-db not too dificult to manage, because they provided us with all the necessary variables we need to replace such changeable things like the name of the server or the name of the application. 

## Table of content (app:toc)

We create the table of content with the self created function *app:toc* and so far, this function fetches the data needed to create the table of content from

`for $doc in collection("/db/apps/thun-demo/data/editions")/tei:TEI`

To remove the application’s name from this function we use the variable *$config:app-root* which, according to the inline comment to this variable/function "Determine[s] the application root collection from the current module load path." For our application this means that $config:app-root will resolve into */db/apps/thun-demo/*. Since our XML/TEI documents are stored in */db/apps/thun-demo/***_data/edition/_*** *we have to add this last part. This we achieve with the xQuery function *concat* which concatenates two or more strings. Everything put together resolves in:

```xquery
declare function app:toc($node as node(), $model as map(*)) {
    for $doc in **collection(concat($config:app-root, '/data/editions/'))//tei:TEI**
        return
        <li><a href="{concat("http://localhost:8080/exist/apps/thun-demo/pages/show.html?document=",functx:substring-after-last(document-uri(root($doc)), "/"))}">{document-uri(root($doc))}</a></li>   
};
```

This fix brings back the table of content even if we rename the application.

![image alt text]({{ site.baseurl }}/images/part-5/image_3.jpg)

Now we also want to remove the other hard coded link in this function which is the link leading to our *show.html* page:

**modules/app.xql | app:toc**

```html
<a href="{concat("**http://localhost:8080/exist/apps/thun-demo/pages/show.html**?document=",functx:substring-after-last(document-uri(root($doc)), "/"))}">{document-uri(root($doc))}</a>
```

To remove the hard coded link from above, we could basically do something similar as before. Unfortunately building the needed URL [http://localhost:8080/](http://localhost:8080/exist/apps/rita/pages/show.html)**[exis**t](http://localhost:8080/exist/apps/rita/pages/show.html)[/apps/rita/pages/show.html](http://localhost:8080/exist/apps/rita/pages/show.html)  is slightly more complicated than */db/apps/thun-demo/data/editions*. 

Without going into detail, the following (bold) line of code does the juggling and creates the appropriate link without any hard coded parts in it.

```xquery
(:~
 : creates a basic table of content derived from the documents stored in '/data/editions'
 :)
declare function app:toc($node as node(), $model as map(*)) {
    for $doc in collection(concat($config:app-root, '/data/editions/'))//tei:TEI
        return
        <li><a href="**{concat(replace(concat($config:app-root, '/pages/show.html'), '/db/', '/exist/'),'?document=',functx:substring-after-last(document-uri(root($doc)), '/'))}**">{document-uri(root($doc))}</a></li>   
};
```

To test my claim, we should browse to the table of content and follow one of the links. Although the link seems to be correct, we simply get a not very nice error message:

![image alt text]({{ site.baseurl }}/images/part-5/image_4.jpg)

BE AWARE. So far I am still working with a renamed version of our thun-demo app (which is now called rita, an abbreviation of **R**eading **I**n **T**he **A**lps). 

## app:XMLtoHTML

As the error message points out, there seems to be something wrong in the function *transfrom:transform*, a function which we are calling in our self made function *app:XMLtoHTML*. 

Inspecting this function, the problem becomes quite obvious. Look at the bold lines

**modules/app.xql | app:XMLtoHTML**

```xquery
declare function app:XMLtoHTML ($node as node(), $model as map (*), $query as xs:string?) {
let $ref := xs:string(request:get-parameter("document", ""))
let $xml := doc(concat("/db/apps/thun-demo/data/editions/",$ref))**
let $xsl := doc("/db/apps/thun-demo/resources/xslt/xmlToHtml.xsl")**
let $params := 
<parameters>
   {for $p in request:get-parameter-names()
    let $val := request:get-parameter($p,())
    where  not($p = ("document","directory","stylesheet"))
    return
       <param name="{$p}"  value="{$val}"/>
   }
</parameters>

return 
    transform:transform($xml, $xsl, $params)
};
```

The XML as well as the XSL document involved in the transformation are loaded from hard coded urls. But we can change this easily once more with the help of **$app:config**

```xquery
declare function app:XMLtoHTML ($node as node(), $model as map (*), $query as xs:string?) {
let $ref := xs:string(request:get-parameter("document", ""))
let $xml := doc(replace(concat($config:app-root,"/data/editions/",$ref), '/exist/', '/db/'))**
let $xsl := doc(concat($config:app-root, "/resources/xslt/xmlToHtml.xsl"))**
...
```

Now the creation of the table of content is showing the (right) content and sends the correct parameters to the right location of show.html which itself renders the XML/TEI document, no matter of the name of the application’s or the server’s name. 

![image alt text]({{ site.baseurl }}/images/part-5/image_5.jpg)

# Conclusion and outlook

To make our code independent from any hard coded urls we had to write several times very similar lines of code. For instance, to create the dynamic links from our table of content to the HTML representation of the chosen XML/TEI document, we had to replace ‘db’ against ‘exist’ in the first function (app:toc) only to revert this change in ‘app:XMLtoHTML’. This feels very much like useless and duplicated code. But we will keep the code as it is for the time being since all our requirements are fulfilled by the current code base and the duplicated parts of code are (still) very few. 

In the next part of this series of tutorials, we will learn how to rename our application. This is extremely useful if you plan to use the code base written so far for similar digital edition projects.

 

