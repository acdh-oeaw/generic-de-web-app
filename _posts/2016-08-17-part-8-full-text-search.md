---
layout:     post
title:      # Part 8 - Full text search
date:       2016-08-16 11:21:29
summary:    In the eighth part we are going to build a full text search.
categories: digital-edition
---

# Introduction and requirements

In the [last part]({{ site.baseurl }}{% post_url 2016-08-16-part-7-index-based-search %}) of this series of tutorials we implemented a basic index based search functionality. The code we build so far can be downloaded [here]({{ site.baseurl }}/downloads/part-7/thun-demo-0.1.xar). In this part now, we are going to build a full text search which will allow users to 

1. search the content (the text) of all of our XML/TEI documents, 

2. inspect the results in a KWIC (**K**ey**W**ords **I**n **C**ontext) preview, 

3. and jump to the HTML representation of the documents which are matching the search query. 

Therefore we need to have to:

1. Create and configure a full text index,

2. build a new html site containing a search form and which will return the (KWIC) search results,

3. Write an xquery function which takes the search string as a parameter and returns the results.

# Create and configure a full text index

Since the nitty gritty details of creating and configuring a (full text) index are described broadly in the [eXist-db documentation](http://exist-db.org/exist/apps/doc/lucene.xml), I won't spend much time on explaining the next steps described below. Only one things should be stressed. For creating a full text index, eXist-db uses 
> Apache Lucene a high-performance, full-featured text search engine library written entirely in Java
(see [https://lucene.apache.org/core/](https://lucene.apache.org/core/)) which is currently practically the tool of choice when it comes to indexing, searching and information retrieval. 

To create and configure a full text index for our XML/TEI documents stored in **data/editions/** we have to rebuild (parts of) the structure of our application below eXist-db’s **db/system/** directory. Or, to be more precise, we have create an XML document named **collection.xconf** and store under `db/system/path/to/collection/you/would/like/to/index`. So to index all our documents stored in `db/apps/thun-demo/data/editions/` we have to create a collection.xconf document at: `/db/system/config/db/apps/thun-demo/data/editions/collection.xconf`.

Doing so in eXide looks like on the screenshot below:

![image alt text]({{ site.baseurl }}/images/part-8/image_0.jpg)

The content of this new created collection.xconf documents only contains a few lines:

**/db/system/config/db/apps/thun-demo/data/editions/collection.xconf:**

```xml
<collection xmlns="http://exist-db.org/collection-config/1.0">
    <index xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <fulltext default="none" attributes="false"/>
        <lucene>
            <text qname="tei:p"/>
        </lucene>
    </index>
</collection>
```

Important to know is, that we have now indexed the text of all TEI `<p>` elements, including the text in child nodes of `<p>`. But this is a very basic index configuration which contains no explicit rules on how to deal e.g. with tokenizing (splitting the text into small units we would like to call words) or inline elements (e.g. `<p> This is a <strong>b</trong>old capital letter</p>` which would index a ‘word’ ‘b’ and ‘old’ but not ‘bold’). Maybe we will pick this topic up in a later tutorial. 

## Trigger indexing

After we stored this document in the right place, we have to tell eXist-db to start the indexing routine. To do so, open the Collections tab from the [dashboard](http://localhost:8080/exist/apps/dashboard/index.html) browse to the collection you configured an index for (db/apps/thun-demo/data/editions/) and click on the ‘Reindex collection’ icon. Depending on the size and the amount of documents stored in this collection, this may take a while.![image alt text]({{ site.baseurl }}/images/part-8/image_1.jpg) 

To check if everything worked and eXist-db really created an index on the documents stored in **db/apps/thun-demo/data/editions/** click on the the [dashboard](http://localhost:8080/exist/apps/dashboard/index.html) on the ‘Monitoring and Profiling for eXist’ (monex) or browse to  [http://localhost:8080/exist/apps/monex/index.html](http://localhost:8080/exist/apps/monex/index.html). (It might be, that this eXist-db package is not installed by default. If so, then you have to install it via the ‘Package Manger’.) After you opened monex, click on ‘Indexes’ (or browse to[http://localhost:8080/exist/apps/monex/indexes.html](http://localhost:8080/exist/apps/monex/indexes.html)) where you should see a list of all indexed collections, where you should see an entry ‘/db/apps/thun-demo/data/editions’

![image alt text]({{ site.baseurl }}/images/part-8/image_2.jpg)

 You can now follow this link to inspect your index in detail. 

## Update the index

Once the index is configured and created, it will update automatically whenever someone changes or adds a document to the indexed collection. Only when you change something in the index configuration (`collection.xconf`) you will have to reindex the collection as described above.

## Deploy an Index

Be aware that whenever you want to deploy - and the (re)install your application as eXist-db package, your index and index configuration will be lost. Although there are solutions and methods on how to set up a new index automatically whenever you install an application like one described in the [eXist-db book](http://shop.oreilly.com/product/0636920026525.do) by Retter and Siegl (p. 235) I would opt for slightly less elaborate workflow for deploying an index. 

For a very simple solution just copy&paste the **/db/system/config/db/apps/thun-demo/data/editions/collection.xconf** document to e.g. the application’s data collection. Whenever you want to deploy your application by first packing it to a .xar package and installing it via eXist-db’s Packer Manager, the only thing you should do than is to copy&paste the collection.xconf to the applications system-path which for our example app is: 

**/db/system/config/db/apps/thun-demo/data/editions/collection.xconf.** After this, the only thing left to do is to trigger the indexing as described above. 

# Implement full text search

## ft_search.html

Now we need to provide some simple search form which will take the search string, pass it on to some xQuery script (see next section) and return the results to the users. Therefore, we create a html document **/pages/ft_search.html** and add the following lines:

```html
<div class="templates:surround?with=templates/page.html&amp;at=content">
    <div>
        <form method="get" class="form-inline" id="pageform">
            <div class="form-group">
                <div class="input-group">
                    <input type="text" class="form-control" name="searchexpr"/>
                </div>
                <button type="submit" class="btn btn-primary">Go!</button>
            </div>
        </form>
    </div>
    <hr/>
    <table>
        <thead>
            <tr>
                <th>score</th>
                <th>KWIC</th>
                <th>Link</th>
            </tr>
        </thead>
        <tbody>
            <tr data-template="app:ft_search"/>
        </tbody>
    </table>
</div>
```
Then we add a link to this page in the base tempate **/templates/pages.html:**

```html
...
<li>
    <a href="persons.html">Persons</a>
</li>
<li>
    <a href="ft_search.html">Fulltext Search</a>
</li>
...
```

But of course, when we now want to browse to this page, we will receive an error message complaining about the fact the there is no function called **app:ft_search** in **modules/app.xql**.

## app:ft_search

In **/modules/app.xql** create a new function called app:ft_search. This function has to parse the search string handed, build a full text search query and return the results to ft_search.html in a nice and KWIC way. This all can be achieved with the following few lines of code:

```
declare function app:ft_search($node as node(), $model as map (*)) {
    if (request:get-parameter("searchexpr", "") !="") then
    let $searchterm as xs:string:= request:get-parameter("searchexpr", "")
    for $hit in collection(concat($config:app-root, '/data/'))//tei:p[ft:query(.,$searchterm)]
    let $document := document-uri(root($hit))
    let $score as xs:float := ft:score($hit)
    order by $score descending
    return
    <tr>
        <td>{$score}</td>
        <td>{kwic:summarize($hit, <config width="40" link="{$document}" />)}</td>
        <td>{$document}</td>
    </tr>
 else
    <div>Nothing to search for</div>
 };
```

But trying to browse to [http://localhost:8080/exist/apps/thun-demo/pages/ft_search.html](http://localhost:8080/exist/apps/thun-demo/pages/ft_search.html) now will still result in an error message, but this time complaining about missing namespace definition. This is because we are using eXist-db’s xQuery module [kwic](http://exist-db.org/exist/apps/doc/kwic.xml) but without importing it first. To do so, we have to add the following line below the import statement for the config module: 

```
import module namespace config="http://www.digital-archiv.at/ns/thun-demo/config" at "config.xqm";

import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
```

Finally we should now be able to browse to [ft_search.html](http://localhost:8080/exist/apps/thun-demo/pages/ft_search.html) and see the following screen:

![image alt text]({{ site.baseurl }}/images/part-8/image_3.jpg)

No go ahead and search something for example: "kirche" (german for church, don’t know, why this word came to my mind).

 [http://localhost:8080/exist/apps/thun-demo/pages/ft_search.html?searchexpr=kirche](http://localhost:8080/exist/apps/thun-demo/pages/ft_search.html?searchexpr=kirche) 

![image alt text]({{ site.baseurl }}/images/part-8/image_4.jpg)

# Conclusion and outlook

As you can see, the Keyword in its context is rendered as a link. But clicking on it produces (for now) only a 404 (page not found) error. 

To fix this, we could (once more) copy and paste parts of the code used for the index based search results view. But since this would be now the third time we copy paste very similar functionalities, we should do something more advanced like writing a reusable function. But this we will engage in the [next part]({{ site.baseurl }}{% post_url 2016-08-18-part-9-code-refactoring %}). 

