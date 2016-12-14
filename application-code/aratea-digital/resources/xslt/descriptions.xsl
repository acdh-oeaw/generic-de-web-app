<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:template match="/">
        <div id="wrapper" class="row">
            <div class="col-xs-12 col-md-2">
                <nav class="affix" style="left:0; width:inherit;">
                    <xsl:element name="ul">
                        <xsl:for-each select="//tei:body//tei:head">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:text>#text_</xsl:text>
                                        <xsl:value-of select="parent::tei:div/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="id">
                                        <xsl:text>nav_</xsl:text>
                                        <xsl:value-of select="parent::tei:div/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="./tei:title/text()"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </nav>
            </div>
            <div class="col-xs-12 col-md-10">
                <div class="page-header">
                    <h2 align="center">
                        <xsl:apply-templates select="//tei:titleStmt/tei:title"/>
                    </h2>
                </div>
                <div class="regest">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">
                                <h2 align="center">MS-Description</h2>
                            </h3>
                        </div>
                        <div class="panel-body">
                            <table class="table table-striped">
                                <tbody>
                                    <tr>
                                        <th> Title </th>
                                        <td>
                                            <xsl:apply-templates select="//tei:fileDesc/tei:titleStmt/tei:title/text()"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Shelfmark</th>
                                        <td>
                                            <xsl:for-each select="//tei:msIdentifier/*[text()]">
                                                <xsl:element name="abbr">
                                                    <xsl:attribute name="title">
                                                        <xsl:value-of select="name(.)"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="."/>
                                                    <xsl:text> | </xsl:text>
                                                </xsl:element>
                                            </xsl:for-each>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Content</th>
                                        <td>
                                            <xsl:apply-templates select="//tei:msContents"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Extent</th>
                                        <td>
                                            <xsl:apply-templates select="//tei:supportDesc/tei:extent"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>responsible</th>
                                        <td>
                                            <xsl:apply-templates select="//tei:titleStmt/tei:respStmt"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Lizenz</th>
                                        <td>
                                            <xsl:element name="a">
                                                <xsl:attribute name="href">
                                                    <xsl:apply-templates select="//tei:licence/@target"/>
                                                </xsl:attribute>
                                                <xsl:apply-templates select="//tei:availability//tei:p[1]"/>
                                            </xsl:element>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <div class="panel-footer">
                                <p style="text-align:center;">
                                    <a id="link_to_source"/>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <h2 align="center"> Transkription </h2>
                        </h3>
                    </div>
                    <div class="panel-body">
                        <xsl:apply-templates select="//tei:body"/>
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                // creates a link to the xml version of the current docuemnt available via eXist-db's REST-API
                var params={};
                window.location.search
                .replace(/[?&amp;]+([^=&amp;;]+)=([^&amp;;]*)/gi, function(str,key,value) {
                params[key] = value;
                }
                );
                var collection;
                //alert(params['directory'])
                if (params['directory'] === "undefined"  || params['directory'] === "") {
                collection = 'editions';
                } else {
                collection = params['directory']
                }
                var path = window.location.origin+window.location.pathname;
                var replaced = path.replace("exist/apps/", "exist/rest/db/apps/");
                current_html = window.location.pathname.substring(window.location.pathname.lastIndexOf("/") + 1)
                var source_dokument = replaced.replace("pages/"+current_html, "data/"+collection+"/"+params['document']);
                // console.log(source_dokument)
                $( "#link_to_source" ).attr('href',source_dokument);
                $( "#link_to_source" ).text(source_dokument);
            </script>
        </div>
    </xsl:template><!-- crit apparatus -->
    <xsl:template match="tei:subst">
        <xsl:element name="span">
            <xsl:attribute name="class">tei-subst</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:del">
        <xsl:element name="span">
            <xsl:attribute name="class">tei-del</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:sub">
        <xsl:element name="span">
            <xsl:attribute name="class">tei-sub</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template><!-- Layout -->
    <xsl:template match="tei:pb">
        <xsl:element name="div">
            <xsl:attribute name="style">text-align:right;</xsl:attribute>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="@facs"/>
                </xsl:attribute>
                <xsl:value-of select="@n"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:div">
        <xsl:element name="div">
            <xsl:attribute name="class">body-div</xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:head">
        <xsl:element name="h2">
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:text>#nav_</xsl:text>
                    <xsl:value-of select="parent::tei:div/@xml:id"/>
                </xsl:attribute>
                <xsl:attribute name="id">
                    <xsl:text>text_</xsl:text>
                    <xsl:value-of select="parent::tei:div/@xml:id"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:p">
        <xsl:element name="p">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:choose>
            <xsl:when test="@break">
                <br class="tei-lb break-no"/>
            </xsl:when>
            <xsl:when test="@rend">
                <br class="tei-lb break-dash"/>
            </xsl:when>
            <xsl:otherwise>
                <br class="tei-lb break-default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:msItem">
        <xsl:for-each select=".">
            <p>
                <ul>
                    <xsl:for-each select="./*">
                        <li>
                            <strong>
                                <xsl:value-of select="name(.)"/>
                            </strong>: <xsl:apply-templates select="."/>
                        </li>
                    </xsl:for-each>
                </ul>
            </p>
        </xsl:for-each>
    </xsl:template><!--  Links to indices   --><!--
    #####################
    ###  entity-index-linking ###
    #####################
-->
    <xsl:template match="node()[@ref]">
        <strong style="color:green" class="linkedEntity">
            <xsl:attribute name="data-key">
                <xsl:value-of select="current()/@ref"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </strong>
    </xsl:template><!-- Incipit sectio in qua exemplaria efficiendi columnae --><!-- M. Dario Montecasparius Doctorem Petrum Andorferum S.P.D. -->
    <xsl:template match="tei:cb"/>
    <xsl:template match="tei:lb" mode="col">
        <xsl:choose>
            <xsl:when test="@break">
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> | </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p" mode="col">
        <p style="text-align:justify;">
            <xsl:apply-templates mode="col"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:*" mode="col">
        <xsl:apply-templates select="."/>
    </xsl:template>
    <xsl:template match="tei:body[not(descendant::tei:cb)]">
        <xsl:for-each select="descendant::tei:pb">
            <xsl:variable name="next" select="(following::tei:pb)[1]"/>
            <div>
                <xsl:attribute name="data-type">page-number</xsl:attribute>
                <xsl:attribute name="data-key">
                    <xsl:value-of select="current()/@n"/>
                </xsl:attribute>
                <xsl:apply-templates select="current()"/>
                <xsl:if test="(current()/following::node() intersect $next/preceding::node())[parent::tei:p[descendant::tei:pb[generate-id()=generate-id(current()) and not(following-sibling::tei:pb)]]]">
                    <p style="text-align:justify;">
                        <xsl:apply-templates select="(current()/following::node() intersect $next/preceding::node())[parent::tei:p[descendant::tei:pb[generate-id()=generate-id(current()) and not(following-sibling::tei:pb)]]]"/>
                    </p>
                </xsl:if><!-- in intersectionem sunt nodi qui et in prima et in secunda copia -->
                <xsl:apply-templates select="(current()/following::node() intersect $next/preceding::node())[self::tei:p or self::tei:head]"/><!-- vide supra; nodi qui praecedunt secundum columnae finis -->
                <p style="text-align:justify;">
                    <xsl:apply-templates select="(current()/following::node() intersect $next/preceding::node())[parent::tei:p[descendant::tei:pb[generate-id()=generate-id($next)]]]"/>
                </p>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:body[descendant::tei:cb]">
        <xsl:for-each select="descendant::tei:cb[@n = 'a']">
            <xsl:variable name="next" select="(following::tei:cb)[1]"/>
            <xsl:variable name="next2" select="(following::tei:cb)[2]"/>
            <div style="position:relative; float:left; margin-top:20px;text-align:justify;">
                <xsl:attribute name="data-type">page-number</xsl:attribute>
                <xsl:attribute name="data-key">
                    <xsl:value-of select="(preceding::tei:pb)[1]/@n"/>
                </xsl:attribute>
                <div style="width:49%; float:left"><!-- sectio continens nodi qui fratri sunt columnae finis et eam sequuntur; includitur bene praesentantur in sectionem popriam -->
                    <xsl:if test="(current()/following::node() intersect $next/preceding::node())[parent::tei:p[descendant::tei:cb[generate-id()=generate-id(current()) and not(following-sibling::tei:cb)]]]">
                        <p style="text-align:justify;">
                            <xsl:apply-templates select="(current()/following::node() intersect $next/preceding::node())[parent::tei:p[descendant::tei:cb[generate-id()=generate-id(current()) and not(following-sibling::tei:cb)]]]" mode="col"/>
                        </p>
                    </xsl:if><!-- in intersectionem sunt nodi qui et in prima et in secunda copia -->
                    <xsl:apply-templates select="(current()/following::node() intersect $next/preceding::node())[self::tei:p or self::tei:head]" mode="col"/><!-- vide supra; nodi qui praecedunt secundum columnae finis -->
                    <p style="text-align:justify;">
                        <xsl:apply-templates select="(current()/following::node() intersect $next/preceding::node())[parent::tei:p[descendant::tei:cb[generate-id()=generate-id($next)]]]" mode="col"/>
                    </p>
                </div>
                <div style="width:49%; float:left; margin-left:2%">
                    <xsl:if test="($next/following::node() intersect $next2/preceding::node())[parent::tei:p[descendant::tei:cb[generate-id()=generate-id($next) and not(following-sibling::tei:cb)]]]">
                        <p style="text-align:justify;">
                            <xsl:apply-templates select="($next/following::node() intersect $next2/preceding::node())[parent::tei:p[descendant::tei:cb[generate-id()=generate-id($next) and not(following-sibling::tei:cb)]]]" mode="col"/>
                        </p>
                    </xsl:if>
                    <xsl:apply-templates select="($next/following::node() intersect $next2/preceding::node())[self::tei:p or self::tei:head]" mode="col"/>
                    <p style="text-align:justify;">
                        <xsl:apply-templates select="($next/following::node() intersect $next2/preceding::node())[parent::tei:p[descendant::tei:cb[generate-id()=generate-id($next2)]]]" mode="col"/>
                    </p>
                </div>
                <hr style="width:100%;"/>
            </div><!-- nodi sequenti columnae finem finalem -->
            <xsl:if test="position()=last()">
                <div style="width:49%; float:left">
                    <p style="text-align:justify;">
                        <xsl:apply-templates select="current()/following::node()" mode="col"/>
                    </p>
                </div>
            </xsl:if>
        </xsl:for-each>
    </xsl:template><!-- foeliciter amen -->
</xsl:stylesheet>