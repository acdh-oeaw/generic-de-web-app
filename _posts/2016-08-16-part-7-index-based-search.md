---
layout:     post
title:      # Part 7 - Index based Search
date:       2016-08-16 11:21:29
summary:    In the seventh part we will attack the issue of an index based search.
categories: digital-edition
---

# Introduction and requirements

Even those humanities scholars who are usually rather skeptic about digital humanities and digital editions estimate well designed search functionalities like a fulltext search (we will address this topic in the [next tutorial]({{ site.baseurl }}{% post_url 2016-08-17-part-8-full-text-search %})) or of course an index based search. Whereas a fulltext search is something new in comparison to traditional (printed) editions an index of persons, places, terms of interest, and other things is one of the most genuine parts of a printed scholarly edition. Therefore a well planned transformation of this core asset from the printed to the digital domain will most likely help to make digital editions a sincerely respected alternative to printed ones. 
As usually you can download the [latest code base]({{ site.baseurl }}/downloads/part-6/thun-demo-0.1.xar) from the [previous tutorial]({{ site.baseurl }}{% post_url 2016-08-15-part-6-rename-the-app %})).

## Markup

Although the usage of indices in digital editions is much more comfortable than in printed editions, the creation of such an index is hard work, no matter what media we are using. 

In this tutorial the layout of an index is two folded. The first essential part is the markup in the XML/TEI files. In the documents used for our Thun-Demo words (strings) referring to places or persons have been tagged with `<placeName>` and `<personName>` elements. These elements usually contain a key attribute which value uniquely identifies the entity related with the tagged string.

### pers/placeName vs rs

The usage of `<placeName>` and `<personName>` (or just `<name>` as in a project about [letters from/to Mozart](http://letters.mozartways.com/index.php?lang=deu&letter=43&bd=241&xmlview=on) to tag a **reference string** is actually not the best option. Take the following sentence for example: 

```xml
<div>...Daß auf den Antrag der Synode von <date>1848</date> der <persName key="maximilian-II-von-bayern">König von Baiern</persName> <hi rend="ul">die Trennung des Consistorialbezirks ...</div>
```

Here the string "König von Baiern" (King of Bavaria) is tagged with `<personName>` which is slightly odd, because strictly spoken, “King of Bavaria” is not a person’s name. But of course it references a real person who the editors were able to identify as some “maximilian-II-von-bayern” as the `@key` value indicates. The semantically more appropriate solution would have been to tag “König von Baiern” with the element `<rs>` which: 
> contains a general purpose name or referring string. ([http://www.tei-c.org/release/doc/tei-p5-doc/de/html/ref-rs.html](http://www.tei-c.org/release/doc/tei-p5-doc/de/html/ref-rs.html))
The rs-element usually uses a type attribute to make explicit what kind of entity it refers to. So for our example we could would tag:

```html
<div>Daß auf den Antrag der Synode von <date>1848</date> der <rs type="person" ref="#maximilian-II-von-bayern">König von Baiern</rs><hi rend="ul">die Trennung des Consistorialbezirks...</div>
```

But why did we change the `@key` into `@ref`? And why do we need now the "#" before the actual value? Since this is not a tutorial about TEI, here the cheap answer: Because the TEI demands these things. Anyhow, it is important to know that you are completely free to name the values of `@ref` or `@key` as you like as long as you follow the general standards for valid XML (xml:id) attributes. But ideally you are following some naming conventions and use some meaningful strings like “#maximilian-II-von-bayern” and maybe not some anonymous identifiers like “xyz124431ads”. 

## Indices

The second cornerstone of our index based search are **index documents** containing further information about the entities identified and tagged in the edited texts. The link between the XML/TEI documents - the actual digital edition - and the index documents is established by the `@key` or preferably the `@ref` value.

Ideally the further information in the index documents is stored in valid XML/TEI documents as well. Such a documents provides all necessary information about the index (eg. its creator, the documents it is related with, used naming conventions) in the TEI header and the actual content in the tei:body element. The index for persons used in the Thun-Project looks like this: 

```html
<?xml version="1.0" encoding="UTF-8"?>
<body>
    <div type="index_persons">
        <listPerson>
            <person xml:id="KEY">
                <persName>
                    <surname>NACHNAME</surname>
                    <forename>VORNAME</forename>
                </persName>
                <note>
                    <p>LEBENSDATEN</p>
                    <p>LEBEN</p>
                    <p>URL-To-GND</p>
                    <p>ZUSÄTZE</p>
                </note>
            </person>
            <person xml:id="maximilian-II-von-bayern">
                <persName>
                    <surname>Maximilian II. Joseph</surname>
                    <forename>k_A</forename>
                </persName>
                <note>
                    <p>München 1811–1864 München</p>
                    <p>ab 1848 König von Bayern</p>
                    <p>http://d-nb.info/gnd/118579347</p>
                    <p>k_A</p>
                </note>
            </person>
        </listPerson>
    </div>
</body>
```

Unfortunately there are more than one ways to encode the same or similar information. The following snippet provides a semantically enhanced example of how an index of person could look like. 

```html
<person xml:id="pe295" n="Person 295">
    <persName>
        <surname>Beroaldo senior</surname>
        <forename>Filippo</forename>
    </persName>
    <occupation>Italian humanist and poet</occupation>
    <birth>
        <date>1472</date>
    </birth>
    <death>
        <date>1518</date>
    </death>
    <bibl type="printed">Gilmore, M. "Beroaldo, Filippo, senior", Dizionario biografico degli italiani 9 (1967), pp. 382‒384.</bibl>
    <bibl type="weblink">
        <ptr target="https://de.wikipedia.org/wiki/Filippo_Beroaldo_der_%C3%84ltere"/>
    </bibl>
</person>
``` 

So if you have to decided on how to structure your index documents I very much recommend to look into other people’s projects and see how they did it. Of course it is also usually a good idea to be as explicit as possible which means, using semantically meaningful TEI markup wherever possible. 

# Show all persons

## Indices collection

Getting back to our concrete Thun-Demo application, we now have to think about a place or collection where to store the index documents in the database. Since the index files are closely related to the XML/TEI documents of the edited texts, it makes sense to keep them close to each other. Therefore let’s create in `/data` a new collection called `/data/indices/` and here we store our person index, which will name **listperson.xml.** You can download such a document [here](({{ site.baseurl }}/downloads/part-7/listperson.xml)

![image alt text]({{ site.baseurl }}/images/part-7/image_0.jpg)

## HTML and xQuery

The next step should be already familiar to you. First we need an HTML file (`/pages/persons.html`) which calls our base template `/templates/pages.html` and an xQuery function (**app:listPers**) which transformed the data stored in listperson.xml in HTML code we can embed into **persons.html**. 

**/pages/persons.html**

```html
<div class="templates:surround?with=templates/page.html&amp;at=content">
    <h1>Persons</h1>
    <div data-template="app:listPers"/>
</div>
```

And in **/modules/app.xql** we have to declare the aforementioned function **app:listPers** which is very similar to **app:toc**. 

```xquery
declare function app:listPers($node as node(), $model as map(*)) {
    for $person in doc(concat($config:app-root, '/data/indices/listperson.xml'))//tei:listPerson/tei:person
        return
        <li>{$person/tei:persName}</li>
};
```

What is left to do now, is to add a link to **/pages/persons.html** into the applications navbar.

```html
<div class="navbar-collapse collapse" id="navbar-collapse-1">
    <ul class="nav navbar-nav">
        <li class="dropdown" id="about">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">Home</a>
            <ul class="dropdown-menu">
                <li>
                    <a href="index.html">Home</a>
                </li>
                <li>
                    <a href="toc.html">Table of Content</a>
                </li>
                <li>
                    <a href="persons.html">Persons</a>
                </li>
            </ul>
        </li>
    </ul>
</div>
```

Now we can browse to the person’s index of our digital edition.

![image alt text]({{ site.baseurl }}/images/part-7/image_1.jpg)

# Link index with documents

Of course our index is just a list of all person names mentioned in the listperson.xml. And since there is no connection between this list of persons and our XML/TEI documents from which this list is actually derived, it is a rather useless list. So let’s change this.

We want to implement the following procedure. A user should be enabled to click on any name on this list to get some see a list of all documents in which this person was mentioned (i.e. tagged). Therefore we need a function which takes as a parameter the the xml:id of the person of interest to query all documents for matches. And we need some html page which will receive the xml:id, passes it to this function and then lists all potential hits. We will start with the latter.

## hits.html

Create a new html document called **/pages/hits.html** which contains the following few lines of code:

```html
<div class="templates:surround?with=templates/page.html&amp;at=content">
    <h1>Hits</h1>
    <div data-template="app:listPers_hits"/>
</div>
```

Now we could start writing the **app:listPers_hits** function. But before we do this, we should rework the **app:listPers** function because we have to provide links from **persons.html** to **hits.html** which submits the xml:id as a URL parameter. This can be achieved like this:

**/modules/app app:listPers**

```
declare function app:listPers($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $person in doc(concat($config:app-root, '/data/indices/listperson.xml'))//tei:listPerson/tei:person
        return
        <li><a href="{concat($hitHtml,data($person/@xml:id))}">{$person/tei:persName}</a></li>
};
```

Now the names listed in persons.html are nice links:

![image alt text]({{ site.baseurl }}/images/part-7/image_2.jpg)

But since we did not yet create a function called **app:listPers_hits** yet, we will receive the following error message when we try to follow one of those links. But the important thing is, that the we landed on the right page (hits.html) and that the value of the xml:id of the person’s name we clicked on shows up as in the ‘searchkey’ URL parameter. 

![image alt text]({{ site.baseurl }}/images/part-7/image_3.jpg)

## app:listPers_hits

The next thing to do is to write the missing function.

**/modules/app.xql**

```
declare function app:listPers_hits($node as node(), $model as map(*), $searchkey as xs:string?, $path as xs:string?)
{
    for $hit in collection(concat($config:app-root, '/data/editions/'))//tei:TEI[.//tei:persName[@key=$searchkey]]
    let $doc := document-uri(root($hit))
    return
    <li>{$doc}</li>
 };
```

Let's try again, browse to [http://localhost:8080/exist/apps/thun-demo/pages/persons.html](http://localhost:8080/exist/apps/thun-demo/pages/persons.html) and click on e.g. *Thun-Hohenstein Leo (Leopold)*. Now we will be presented with a list of all documents in which a person was tagged an identified as *thun-hohenstein-leo*.

 As mentioned in the beginning of this document, strings referring to persons, places or other things you find important enough to tag them, should actually be tagged with `<rs>`. To make our little **app:listPers_hits** agnostic to the chosen markup, we can add another constraint on the "for" expression
**modules/app.xql**:

```
declare function app:listPers_hits($node as node(), $model as map(*), $searchkey as xs:string?, $path as xs:string?)
{
    for $hit in collection(concat($config:app-root, '/data/editions/'))//tei:TEI[.//tei:persName[@key=$searchkey] | .//tei:rs[@ref=concat("#",$searchkey)]] 
    let $doc := document-uri(root($hit))
    return
    <li>{$doc}</li>
 };
```

The `|` stands here for “or” which means that this functions returns now all documents containing one or more `<persName>` as well as `<rs>` elements. 

The last thing to do now is to provide links to the HTML representations of the XML/TEI files listed in **hits.html**. Since this is basically the same procedure as we already implemented in **app:toc**, we can copy paste most parts of the needed code from there to **app:listPers_hits**.
**/modules/app.xql:**

```
declare function app:listPers_hits($node as node(), $model as map(*), $searchkey as xs:string?, $path as xs:string?)
{
    for $hit in collection(concat($config:app-root, '/data/editions/'))//tei:TEI[.//tei:persName[@key=$searchkey] |.//tei:rs[@ref=concat("#",$searchkey)]] 
    let $doc := document-uri(root($hit))
    return

    <li><a href="{concat('show.html','?document=',functx:substring-after-last($doc, '/'))}">{$doc}</a></li>   
 };
```

No we have perfectly working links:

![image alt text]({{ site.baseurl }}/images/part-7/image_5.jpg)

But be aware that using the same or very similar lines of code in several different places is a good indicator for bad code and usually an excellent starting point for refactoring the code. We will take care about this in one of the following tutorials.

# Conclusion and outlook

In this part of the tutorial we added an index of persons to our digital editions app which allows users to quickly identify and view all documents in the edition where the persons of their interests have been mentioned. For other indices (likes places or terms or bibliographic references) we can more or less re use the same logic and functionalities, either by copy and pasting most parts of the code or by improving the already existing functionality. We will come back to this question in one of the following tutorials. 

But in the [next one]({{ site.baseurl }}{% post_url 2016-08-17-part-8-full-text-search %}), we will create a nice full text search which will allow searching all documents of our digital edition at once.

