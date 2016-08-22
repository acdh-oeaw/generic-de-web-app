<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0"><!-- <xsl:strip-space elements="*"/>-->
    <xsl:param name="ref"/><!--
##################################
### Seitenlayout und -struktur ###
##################################
-->
    <xsl:template match="/">
        <div class="page-header">
            <h2 align="center">
                <xsl:apply-templates select="//tei:titleStmt/tei:title"/>
            </h2>
        </div>
        <div class="regest">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <h2 align="center">Info</h2>
                    </h3>
                </div>
                <div class="panel-body">
                    <table class="table table-striped">
                        <tbody>
                            <tr>
                                <th>Titel</th>
                                <td>
                                    <xsl:apply-templates select="//tei:titleStmt/tei:title"/>
                                </td>
                            </tr>
                            <tr>
                                <th>Archivsignatur</th>
                                <td>
                                    <xsl:apply-templates select="//tei:msIdentifier"/>
                                </td>
                            </tr>
                            <tr>
                                <th>Beschreibung</th>
                                <td>
                                    <xsl:apply-templates select="//tei:msContents"/>
                                </td>
                            </tr>
                            <tr>
                                <th>Umfang</th>
                                <td>
                                    <xsl:apply-templates select="//tei:supportDesc/tei:extent"/>
                                </td>
                            </tr>
                            <tr>
                                <th>verantwortlich</th>
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
                        <xsl:element name="p">
                            <xsl:attribute name="style">
                                <xsl:text>text-align:center;</xsl:text>
                            </xsl:attribute>
                            Permalink zu dieser Seite: <br/>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('http://digital-archiv.at:8081/exist/apps/buchbesitz-collection/show/', //tei:TEI/@xml:id)"/>
                                </xsl:attribute>
                                <xsl:value-of select="concat('http://digital-archiv.at:8081/exist/apps/buchbesitz-collection/show/', //tei:TEI/@xml:id)"/>
                            </xsl:element>
                        </xsl:element>
                    </div>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">
                    <h2 align="center">
                        Transkription
                    </h2>
                </h3>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-4">
                        <h4>
                            Navigation
                        </h4>
                        <xsl:element name="ul">
                            <xsl:for-each select="//tei:body//tei:head">
                                <xsl:element name="li">
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:text>#text_</xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                        <xsl:attribute name="id">
                                            <xsl:text>nav_</xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:element>
                    </div>
                    <div class="col-md-8">
                        <h3>
                            <xsl:apply-templates select="//tei:div[@type='titelblatt']"/>
                        </h3>
                        <p>
                            <xsl:apply-templates select="//tei:div[@type='transcript']"/>
                            <xsl:apply-templates select="//tei:div[@type='text']"/>
                            <xsl:apply-templates select="//tei:body"/>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template><!--
    #####################
    ###  Formatierung ###
    #####################
--><!-- Bücher -->
    <xsl:template match="tei:bibl">
        <xsl:element name="strong">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template><!-- Seitenzahlen -->
    <xsl:template match="tei:pb">
        <xsl:element name="div">
            <xsl:attribute name="style">
                <xsl:text>text-align:right;</xsl:text>
            </xsl:attribute>
            <xsl:text>[Bl.</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>]</xsl:text>
        </xsl:element>
        <xsl:element name="hr"/>
    </xsl:template><!-- Tabellen -->
    <xsl:template match="tei:table">
        <xsl:element name="table">
            <xsl:attribute name="class">
                <xsl:text>table table-bordered table-striped table-condensed table-hover</xsl:text>
            </xsl:attribute>
            <xsl:element name="tbody">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:row">
        <xsl:element name="tr">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:cell">
        <xsl:element name="td">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template><!-- Überschriften -->
    <xsl:template match="tei:head">
        <xsl:element name="h3">
            <xsl:element name="a">
                <xsl:attribute name="id">
                    <xsl:text>text_</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:text>#nav_</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template><!--  Quotes / Zitate -->
    <xsl:template match="tei:q">
        <xsl:element name="i">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template><!-- Zeilenumbürche   -->
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template><!-- Absätze    -->
    <xsl:template match="tei:p">
        <xsl:element name="p">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template><!-- Durchstreichungen -->
    <xsl:template match="tei:del">
        <xsl:element name="strike">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>